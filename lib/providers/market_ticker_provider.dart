import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_binance/data/entities/ticker_entity.dart';
import 'package:app_binance/data/mappers/ticker_mapper.dart';
import 'package:app_binance/data/models/ticker_model.dart';
import 'package:app_binance/services/binance_api_service.dart';
import 'package:app_binance/services/binance_websocket_service.dart';

class MarketTickerProvider with ChangeNotifier {
  final BinanceWebSocketService _webSocketService;
  final Map<String, TickerEntity> _tickers = {};
  StreamSubscription<Map<String, dynamic>>? _subscription;

  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  MarketTickerProvider(this._webSocketService) {
    _init();
  }

  List<TickerEntity> get tickers => List.unmodifiable(_tickers.values);

  BinanceWebSocketService get webSocketService => _webSocketService;

  Future<void> _init() async {
    await _loadInitialData();
    _subscribeToStream();
    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> reloadData() async {
    _isInitialLoading = true;
    notifyListeners();

    await _loadInitialData();
    _subscribeToStream();

    _isInitialLoading = false;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    try {
      final symbols = ['BTCUSDT', 'ETHUSDT'];

      final responses = await Future.wait(
        symbols.map(BinanceApiService.fetchTicker24h),
      );

      for (final model in responses.whereType<TickerModel>()) {
        if (model.symbol.isNotEmpty) {
          final entity = model.toEntity();
          _tickers[entity.symbol.toUpperCase()] = entity;
          debugPrint('✅ REST inicial cargado: ${entity.symbol}');
          debugPrint(
            '✅ REST inicial cargado2: ${{'symbol': model.symbol, 'lastPrice': model.lastPrice, 'priceChange': model.priceChange, 'priceChangePercent': model.priceChangePercent, 'volume': model.volume, 'quoteVolume': model.quoteVolume}}',
          );
        } else {
          debugPrint(
            '❌ Ignorado modelo con símbolo vacío: ${model.toString()}',
          );
        }
      }

      // Reintento
      for (final symbol in symbols) {
        if (!_tickers.containsKey(symbol.toUpperCase())) {
          final retry = await BinanceApiService.fetchTicker24h(symbol);
          if (retry != null && retry.symbol.isNotEmpty) {
            _tickers[symbol.toUpperCase()] = retry.toEntity();
            debugPrint('🔁 Reintento exitoso: $symbol');
          }
        }
      }

      notifyListeners(); // <- 🔥 Esto es clave para que la UI actualice
    } catch (e) {
      debugPrint('❌ Error al cargar datos REST iniciales: $e');
    }
  }

  void _subscribeToStream() {
    _subscription?.cancel();
    _subscription = _webSocketService.stream.listen(_handleData);
  }

  void _handleData(Map<String, dynamic> json) {
    if (json['s'] != null && json.containsKey('c')) {
      final model = TickerModel.fromJson(json);

      if (model.symbol.isEmpty) {
        debugPrint('❌ TickerModel recibido con símbolo vacío en stream');
        return;
      }

      final entity = model.toEntity();
      final symbolKey = entity.symbol.toUpperCase();
      final previous = _tickers[symbolKey];

      if (previous != null) {
        final updated = previous.copyWith(
          lastPrice: entity.lastPrice,
          priceChange: entity.priceChange,
          priceChangePercent: entity.priceChangePercent,
          volume: entity.volume,
          quoteVolume: entity.quoteVolume,
        );

        if (!_entitiesEqual(previous, updated)) {
          _tickers[symbolKey] = updated;
          notifyListeners();
          debugPrint('🔄 Actualizado ticker: $symbolKey');
        }
      } else {
        _tickers[symbolKey] = TickerEntity(
          symbol: entity.symbol,
          lastPrice: entity.lastPrice,
          openPrice: entity.openPrice,
          priceChange: entity.priceChange,
          priceChangePercent: entity.priceChangePercent,
          highPrice: 0,
          lowPrice: 0,
          volume: 0,
          quoteVolume: 0,
        );
        notifyListeners();
        debugPrint('➕ Añadido nuevo ticker desde stream: $symbolKey');
      }
    }
  }

  bool _entitiesEqual(TickerEntity a, TickerEntity b) {
    return a.lastPrice == b.lastPrice &&
        a.priceChange == b.priceChange &&
        a.priceChangePercent == b.priceChangePercent &&
        a.volume == b.volume &&
        a.quoteVolume == b.quoteVolume;
  }

  void resubscribe() {
    _subscribeToStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

TickerEntity fallbackTickerEntity(String symbol) {
  return TickerEntity(
    symbol: symbol,
    lastPrice: 0,
    openPrice: 0,
    priceChange: 0,
    priceChangePercent: 0,
    highPrice: 0,
    lowPrice: 0,
    volume: 0,
    quoteVolume: 0,
  );
}

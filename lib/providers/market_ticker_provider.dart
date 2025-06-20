import 'package:flutter/material.dart';
import '../services/binance_websocket_service.dart';

class MarketTickerProvider with ChangeNotifier {
  late final BinanceWebSocketService _service;
  final Map<String, Map<String, dynamic>> _tickers = {};
  late final List<String> _symbols;
  late final Stream<Map<String, dynamic>> _stream;

  MarketTickerProvider() : _symbols = ['btcusdt', 'ethusdt'] {
    _init();
  }

  /// Inicializa el servicio y escucha el stream
  void _init() {
    final streams = _symbols.map((s) => '$s@ticker').toList();
    _service = BinanceWebSocketService(streams);
    _stream = _service.stream;

    _stream.listen((data) {
      final symbol = (data['s'] as String).toLowerCase();
      _tickers[symbol] = data;
      notifyListeners();
    }, onError: (e) => debugPrint('Stream error: $e'));
  }

  /// Retorna los datos de un par como BTCUSDT o ETHUSDT
  Map<String, dynamic>? getTicker(String pair) => _tickers[pair.toLowerCase()];

  /// Última data cacheada por símbolo
  Map<String, Map<String, dynamic>> get allTickers => _tickers;

  /// Estado actual de la conexión WebSocket
  ValueNotifier<bool> get isConnected => _service.connectionStatus;

  /// Permite agregar un nuevo par de trading dinámicamente (bonus feature)
  void addPair(String pair) {
    final lower = pair.toLowerCase();
    if (!_symbols.contains(lower)) {
      _symbols.add(lower);
      _service.subscribeToStreams(['$lower@ticker']);
    }
  }

  /// Permite quitar un par y dejar de escucharlo
  void removePair(String pair) {
    final lower = pair.toLowerCase();
    _symbols.remove(lower);
    _tickers.remove(lower);
    _service.unsubscribeFromStreams(['$lower@ticker']);
    notifyListeners();
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }
}

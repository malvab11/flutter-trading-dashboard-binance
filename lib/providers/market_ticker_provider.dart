import 'package:app_binance/data/entities/ticker_entity.dart';
import 'package:app_binance/data/mappers/ticker_mapper.dart';
import 'package:app_binance/data/models/ticker_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/binance_websocket_service.dart';

class MarketTickerProvider with ChangeNotifier {
  final BinanceWebSocketService _webSocketService;

  final Map<String, TickerEntity> _tickers = {};

  MarketTickerProvider(this._webSocketService) {
    _webSocketService.stream.listen(_handleData);
  }

  List<TickerEntity> get tickers => _tickers.values.toList();

  void _handleData(Map<String, dynamic> json) {
    if (json['s'] != null && json.containsKey('c')) {
      final model = TickerModel.fromJson(json);
      final entity = model.toEntity();
      _tickers[entity.symbol] = entity;
      notifyListeners();
    }
  }
}

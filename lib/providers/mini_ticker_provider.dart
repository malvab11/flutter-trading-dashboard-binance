import 'package:app_binance/data/entities/mini_ticker_entity.dart';
import 'package:app_binance/data/mappers/mini_ticker_model.dart';
import 'package:app_binance/data/models/mini_ticker_model.dart';
import 'package:flutter/foundation.dart';
import '../services/binance_websocket_service.dart';

class MiniTickerProvider with ChangeNotifier {
  final BinanceWebSocketService _webSocketService;

  final Map<String, MiniTickerEntity> _miniTickers = {};

  MiniTickerProvider(this._webSocketService) {
    _webSocketService.stream.listen(_handleData);
  }

  List<MiniTickerEntity> get miniTickers => _miniTickers.values.toList();

  void _handleData(Map<String, dynamic> json) {
    if (json['s'] != null && json.containsKey('c')) {
      final model = MiniTickerModel.fromJson(json);
      final entity = model.toEntity();
      _miniTickers[entity.symbol] = entity;
      notifyListeners();
    }
  }
}

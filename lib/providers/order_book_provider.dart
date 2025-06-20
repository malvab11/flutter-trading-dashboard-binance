import 'package:app_binance/data/entities/order_book_entity.dart';
import 'package:app_binance/data/mappers/order_mapper.dart';
import 'package:app_binance/data/models/order_book_model.dart';
import 'package:flutter/foundation.dart';
import '../services/binance_websocket_service.dart';

class OrderBookProvider with ChangeNotifier {
  final BinanceWebSocketService _webSocketService;

  final Map<String, OrderBookEntity> _orderBooks = {};

  OrderBookProvider(this._webSocketService) {
    _webSocketService.stream.listen(_handleData);
  }

  OrderBookEntity? getOrderBook(String symbol) => _orderBooks[symbol];

  void _handleData(Map<String, dynamic> json) {
    if (json['bids'] != null && json['asks'] != null && json['s'] != null) {
      final model = OrderBookModel.fromJson(json);
      final entity = model.toEntity();
      _orderBooks[entity.symbol] = entity;
      notifyListeners();
    }
  }
}

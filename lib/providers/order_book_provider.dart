import 'package:app_binance/data/entities/order_book_entity.dart';
import 'package:app_binance/data/mappers/order_mapper.dart';
import 'package:app_binance/data/models/order_book_model.dart';
import 'package:app_binance/services/binance_websocket_service.dart';
import 'package:flutter/foundation.dart';

class OrderBookProvider extends ChangeNotifier {
  final BinanceWebSocketService _webSocketService;

  String _currentSymbol = 'BTCUSDT';
  final Map<String, OrderBookEntity> _orderBooks = {};

  OrderBookProvider(this._webSocketService) {
    _webSocketService.stream.listen(_handleData);
    _subscribeToCurrentSymbol();
  }

  String get currentSymbol => _currentSymbol;

  OrderBookEntity? get currentOrderBook {
    final book = _orderBooks[_currentSymbol];
    debugPrint(
      '📥 ViewModel: currentOrderBook ($_currentSymbol): ${book == null ? '❌ NULO' : '✅ OK'}',
    );
    return book;
  }

  void setSymbol(String newSymbol) {
    newSymbol = newSymbol.toUpperCase();
    if (_currentSymbol == newSymbol) return;

    debugPrint('🔄 Cambiando símbolo de $_currentSymbol a $newSymbol');

    // UNSUBSCRIBE anterior
    _webSocketService.unsubscribeFromStreams([
      '${_currentSymbol.toLowerCase()}@depth',
    ]);
    debugPrint(
      '📤 Enviando UNSUBSCRIBE: ${_currentSymbol.toLowerCase()}@depth',
    );

    _currentSymbol = newSymbol;

    // SUBSCRIBE nuevo
    _webSocketService.subscribeToStreams([
      '${_currentSymbol.toLowerCase()}@depth',
    ]);
    debugPrint('📨 Enviando SUBSCRIBE: ${_currentSymbol.toLowerCase()}@depth');

    notifyListeners();
  }

  void _handleData(Map<String, dynamic> data) {
    try {
      final model = OrderBookModel.fromJson(data);
      final incomingEntity = model.toEntity();
      final symbolKey = incomingEntity.symbol.toUpperCase();

      final previous = _orderBooks[symbolKey];

      // 🔄 Merge inteligente: respeta las cantidades != 0 y elimina los 0
      final combinedBids = _mergeOrders(
        previous?.bids ?? [],
        incomingEntity.bids,
      );
      final combinedAsks = _mergeOrders(
        previous?.asks ?? [],
        incomingEntity.asks,
      );

      final updatedEntity = OrderBookEntity(
        symbol: symbolKey,
        bids: combinedBids,
        asks: combinedAsks,
      );

      _orderBooks[symbolKey] = updatedEntity;
      debugPrint('📡 OrderBookProvider almacenó datos de $symbolKey');

      if (symbolKey == _currentSymbol) {
        notifyListeners();
      }
    } catch (e, s) {
      debugPrint('❌ Error adaptando OrderBook: $e\n$s');
    }
  }

  /// Mergea listas de órdenes, reemplazando las que llegan y eliminando las que tienen qty = 0
  List<Order> _mergeOrders(List<Order> oldList, List<Order> newList) {
    final Map<double, Order> map = {
      for (final order in oldList) order.price: order,
    };

    for (final newOrder in newList) {
      if (newOrder.quantity == 0) {
        map.remove(newOrder.price);
      } else {
        map[newOrder.price] = newOrder;
      }
    }

    return map.values.toList();
  }

  void _subscribeToCurrentSymbol() {
    final stream = '${_currentSymbol.toLowerCase()}@depth';
    _webSocketService.subscribeToStreams([stream]);
    debugPrint('📡 Subscrito inicialmente a $stream');
  }

  @override
  void dispose() {
    _webSocketService.unsubscribeFromStreams([
      '${_currentSymbol.toLowerCase()}@depth',
    ]);
    super.dispose();
  }
}

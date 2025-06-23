import 'package:flutter/material.dart';
import 'package:app_binance/data/entities/order_book_entity.dart';
import 'package:app_binance/providers/order_book_provider.dart';

class OrderBookViewModel with ChangeNotifier {
  final OrderBookProvider _orderBookProvider;
  String _selectedSymbol = 'BTCUSDT';

  OrderBookViewModel(this._orderBookProvider) {
    _orderBookProvider.addListener(_onDataUpdate);
    debugPrint('✅ ViewModel creado con símbolo inicial: $_selectedSymbol');
    _orderBookProvider.setSymbol(_selectedSymbol);
  }

  void _onDataUpdate() {
    final orderBook = _orderBookProvider.currentOrderBook;
    debugPrint(
      '📥 ViewModel: currentOrderBook ($_selectedSymbol): ${orderBook == null ? "❌ NULO" : "✅ OK"}',
    );
    notifyListeners(); // Notificamos siempre para permitir visual updates acumulativos
  }

  String get selectedSymbol => _selectedSymbol;

  set selectedSymbol(String symbol) {
    final upper = symbol.toUpperCase();
    if (_selectedSymbol != upper) {
      debugPrint('🔄 Cambiando símbolo de $_selectedSymbol a $upper');
      _selectedSymbol = upper;
      _orderBookProvider.setSymbol(upper);
      // No notificamos manualmente aquí; el provider lo hará al recibir datos
    }
  }

  OrderBookEntity? get currentOrderBook => _orderBookProvider.currentOrderBook;

  List<Order> get sortedBids {
    final book = currentOrderBook;
    if (book == null) return [];
    final bids = List<Order>.from(book.bids);
    bids.removeWhere((e) => e.quantity == 0); // Seguridad adicional
    bids.sort((a, b) => b.price.compareTo(a.price));
    return bids;
  }

  List<Order> get sortedAsks {
    final book = currentOrderBook;
    if (book == null) return [];
    final asks = List<Order>.from(book.asks);
    asks.removeWhere((e) => e.quantity == 0); // Seguridad adicional
    asks.sort((a, b) => a.price.compareTo(b.price));
    return asks;
  }

  double get spread {
    final bid = sortedBids.isNotEmpty ? sortedBids.first.price : null;
    final ask = sortedAsks.isNotEmpty ? sortedAsks.first.price : null;
    if (bid == null || ask == null) return 0.0;
    return ask - bid;
  }

  @override
  void dispose() {
    _orderBookProvider.removeListener(_onDataUpdate);
    super.dispose();
  }
}

class OrderBookEntity {
  final String symbol;
  final List<Order> bids;
  final List<Order> asks;

  const OrderBookEntity({
    required this.symbol,
    required this.bids,
    required this.asks,
  });

  OrderBookEntity copyWith({List<Order>? bids, List<Order>? asks}) {
    return OrderBookEntity(
      symbol: symbol,
      bids: bids ?? this.bids,
      asks: asks ?? this.asks,
    );
  }

  OrderBookEntity merge(OrderBookEntity incoming) {
    return OrderBookEntity(
      symbol: symbol,
      bids: _mergeOrders(bids, incoming.bids, descending: true),
      asks: _mergeOrders(asks, incoming.asks, descending: false),
    );
  }

  List<Order> _mergeOrders(
    List<Order> current,
    List<Order> updates, {
    required bool descending,
  }) {
    final Map<double, double> merged = {
      for (var order in current) order.price: order.quantity,
    };

    for (var order in updates) {
      if (order.quantity == 0) {
        merged.remove(order.price);
      } else {
        merged[order.price] = order.quantity;
      }
    }

    return merged.entries
        .map((e) => Order(price: e.key, quantity: e.value))
        .toList()
      ..sort(
        (a, b) =>
            descending
                ? b.price.compareTo(a.price)
                : a.price.compareTo(b.price),
      );
  }
}

class Order {
  final double price;
  final double quantity;

  const Order({required this.price, required this.quantity});
}

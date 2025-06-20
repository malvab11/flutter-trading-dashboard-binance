class OrderBookEntity {
  final String symbol;
  final List<Order> bids;
  final List<Order> asks;

  const OrderBookEntity({
    required this.symbol,
    required this.bids,
    required this.asks,
  });
}

class Order {
  final double price;
  final double quantity;

  const Order({required this.price, required this.quantity});
}

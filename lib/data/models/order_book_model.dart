class OrderBookModel {
  final String symbol;
  final List<List<String>> bids; // Esto es : [price, quantity]
  final List<List<String>> asks;

  OrderBookModel({
    required this.symbol,
    required this.bids,
    required this.asks,
  });

  factory OrderBookModel.fromJson(Map<String, dynamic> json) {
    return OrderBookModel(
      symbol: json['s'] ?? '',
      bids: List<List<String>>.from(
        json['bids']?.map((e) => List<String>.from(e)) ?? [],
      ),
      asks: List<List<String>>.from(
        json['asks']?.map((e) => List<String>.from(e)) ?? [],
      ),
    );
  }
}

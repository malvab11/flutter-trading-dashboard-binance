class TickerModel {
  final String symbol; // s
  final String lastPrice; // c
  final String priceChange; // p
  final String priceChangePercent; // P
  final String highPrice; // h
  final String lowPrice; // l
  final String volume; // v
  final String quoteVolume; // q

  TickerModel({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  factory TickerModel.fromJson(Map<String, dynamic> json) {
    return TickerModel(
      symbol: json['s'] ?? '',
      lastPrice: json['c'] ?? '0',
      priceChange: json['p'] ?? '0',
      priceChangePercent: json['P'] ?? '0',
      highPrice: json['h'] ?? '0',
      lowPrice: json['l'] ?? '0',
      volume: json['v'] ?? '0',
      quoteVolume: json['q'] ?? '0',
    );
  }
}

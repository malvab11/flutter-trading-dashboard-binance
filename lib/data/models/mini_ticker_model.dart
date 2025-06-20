class MiniTickerModel {
  final String symbol; // s
  final String closePrice; // c

  MiniTickerModel({required this.symbol, required this.closePrice});

  factory MiniTickerModel.fromJson(Map<String, dynamic> json) {
    return MiniTickerModel(
      symbol: json['s'] ?? '',
      closePrice: json['c'] ?? '0',
    );
  }
}

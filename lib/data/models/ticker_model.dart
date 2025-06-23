import 'package:flutter/material.dart';

class TickerModel {
  final String symbol;
  final double lastPrice;
  final double openPrice;
  final double priceChange;
  final double priceChangePercent;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final double quoteVolume;

  TickerModel({
    required this.symbol,
    required this.lastPrice,
    required this.openPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
  });

  factory TickerModel.fromJson(Map<String, dynamic> json) {
    final rawSymbol = (json['symbol'] ?? json['s'] ?? '').toString();

    if (rawSymbol.isEmpty) {
      debugPrint('⚠️ TickerModel con símbolo vacío: $json');
    }

    return TickerModel(
      symbol: rawSymbol,
      lastPrice: _parseDouble(json['c']),
      openPrice: _parseDouble(json['o']),
      priceChange: _parseDouble(json['p']),
      priceChangePercent: _parseDouble(json['P']),
      highPrice: _parseDouble(json['h']),
      lowPrice: _parseDouble(json['l']),
      volume: _parseDouble(json['v']),
      quoteVolume: _parseDouble(json['q']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'lastPrice': lastPrice,
    'openPrice': openPrice,
    'priceChange': priceChange,
    'priceChangePercent': priceChangePercent,
    'highPrice': highPrice,
    'lowPrice': lowPrice,
    'volume': volume,
    'quoteVolume': quoteVolume,
  };

  @override
  String toString() => toJson().toString();
}

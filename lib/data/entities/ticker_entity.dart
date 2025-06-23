import 'package:equatable/equatable.dart';

class TickerEntity extends Equatable {
  final String symbol;
  final double lastPrice;
  final double priceChange;
  final double priceChangePercent;
  final double highPrice;
  final double lowPrice;
  final double openPrice;
  final double volume;
  final double quoteVolume;

  const TickerEntity({
    required this.symbol,
    required this.lastPrice,
    required this.priceChange,
    required this.priceChangePercent,
    required this.highPrice,
    required this.lowPrice,
    required this.openPrice,
    required this.volume,
    required this.quoteVolume,
  });

  /// Indica si el precio ha subido (verde) o bajado (rojo)
  bool get isUp => priceChange >= 0;

  /// Clona la entidad con campos opcionales actualizados
  TickerEntity copyWith({
    double? lastPrice,
    double? priceChange,
    double? priceChangePercent,
    double? highPrice,
    double? lowPrice,
    double? openPrice,
    double? volume,
    double? quoteVolume,
  }) {
    return TickerEntity(
      symbol: symbol,
      lastPrice: lastPrice ?? this.lastPrice,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
      highPrice: highPrice ?? this.highPrice,
      lowPrice: lowPrice ?? this.lowPrice,
      openPrice: openPrice ?? this.openPrice,
      volume: volume ?? this.volume,
      quoteVolume: quoteVolume ?? this.quoteVolume,
    );
  }

  @override
  List<Object?> get props => [
    symbol,
    lastPrice,
    priceChange,
    priceChangePercent,
    highPrice,
    lowPrice,
    openPrice,
    volume,
    quoteVolume,
  ];
}

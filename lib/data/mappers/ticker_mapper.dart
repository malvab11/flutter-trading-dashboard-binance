import '../models/ticker_model.dart';
import '../entities/ticker_entity.dart';

extension TickerMapper on TickerModel {
  TickerEntity toEntity() {
    return TickerEntity(
      symbol: symbol,
      lastPrice: double.tryParse(lastPrice) ?? 0,
      priceChange: double.tryParse(priceChange) ?? 0,
      priceChangePercent: double.tryParse(priceChangePercent) ?? 0,
      highPrice: double.tryParse(highPrice) ?? 0,
      lowPrice: double.tryParse(lowPrice) ?? 0,
      volume: double.tryParse(volume) ?? 0,
      quoteVolume: double.tryParse(quoteVolume) ?? 0,
    );
  }
}

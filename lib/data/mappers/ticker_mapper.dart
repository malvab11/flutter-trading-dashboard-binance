import 'package:app_binance/data/entities/ticker_entity.dart';
import 'package:app_binance/data/models/ticker_model.dart';

extension TickerModelMapper on TickerModel {
  TickerEntity toEntity() {
    return TickerEntity(
      symbol: symbol.toUpperCase(),
      lastPrice: lastPrice,
      openPrice: openPrice,
      priceChange: priceChange,
      priceChangePercent: priceChangePercent,
      highPrice: highPrice,
      lowPrice: lowPrice,
      volume: volume,
      quoteVolume: quoteVolume,
    );
  }
}

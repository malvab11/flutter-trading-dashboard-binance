import '../models/mini_ticker_model.dart';
import '../entities/mini_ticker_entity.dart';

extension MiniTickerMapper on MiniTickerModel {
  MiniTickerEntity toEntity() {
    return MiniTickerEntity(
      symbol: symbol,
      closePrice: double.tryParse(closePrice) ?? 0,
    );
  }
}

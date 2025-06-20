import '../models/order_book_model.dart';
import '../entities/order_book_entity.dart';

extension OrderBookMapper on OrderBookModel {
  OrderBookEntity toEntity() {
    return OrderBookEntity(
      symbol: symbol,
      bids:
          bids.map((e) {
            return Order(
              price: double.tryParse(e[0]) ?? 0,
              quantity: double.tryParse(e[1]) ?? 0,
            );
          }).toList(),
      asks:
          asks.map((e) {
            return Order(
              price: double.tryParse(e[0]) ?? 0,
              quantity: double.tryParse(e[1]) ?? 0,
            );
          }).toList(),
    );
  }
}

import '../models/order_book_model.dart';
import '../entities/order_book_entity.dart';

extension OrderBookMapper on OrderBookModel {
  OrderBookEntity toEntity() {
    return OrderBookEntity(
      symbol: symbol.toUpperCase(),
      bids:
          bids
              .map(
                (e) => Order(
                  price: double.tryParse(e[0]) ?? 0,
                  quantity: double.tryParse(e[1]) ?? 0,
                ),
              )
              .where((order) => order.quantity > 0)
              .toList(),
      asks:
          asks
              .map(
                (e) => Order(
                  price: double.tryParse(e[0]) ?? 0,
                  quantity: double.tryParse(e[1]) ?? 0,
                ),
              )
              .where((order) => order.quantity > 0)
              .toList(),
    );
  }
}

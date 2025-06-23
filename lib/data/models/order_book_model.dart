import 'package:flutter/material.dart';

class OrderBookModel {
  final String symbol;
  final List<List<String>> bids;
  final List<List<String>> asks;

  OrderBookModel({
    required this.symbol,
    required this.bids,
    required this.asks,
  });

  factory OrderBookModel.fromJson(Map<String, dynamic> json) {
    final rawSymbol = (json['symbol'] ?? json['s'] ?? '').toString();

    List<List<String>> parseList(dynamic rawList) {
      if (rawList is List) {
        return rawList.map<List<String>>((e) {
          if (e is List) {
            return e.map((v) => v.toString()).toList();
          } else {
            debugPrint('⚠️ Elemento inesperado en lista: $e');
            return [];
          }
        }).toList();
      }
      return [];
    }

    return OrderBookModel(
      symbol: rawSymbol,
      bids: parseList(json['bids'] ?? json['b']),
      asks: parseList(json['asks'] ?? json['a']),
    );
  }
}

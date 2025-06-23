import 'dart:convert';
import 'package:app_binance/data/models/ticker_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BinanceApiService {
  static const _baseUrl = 'https://api.binance.com';

  static Future<TickerModel?> fetchTicker24h(String symbol) async {
    final url = Uri.parse('$_baseUrl/api/v3/ticker/24hr?symbol=$symbol');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('code')) {
          debugPrint('⚠️ Binance API error [symbol: $symbol]: ${data['msg']}');
          return null;
        }
        debugPrint('✅ Binance API OK [symbol: $symbol]');
        return TickerModel.fromJson(data);
      } else {
        debugPrint('❌ HTTP error ${response.statusCode} for $symbol');
      }
    } catch (e) {
      debugPrint('❌ Excepción al obtener $symbol: $e');
    }
    return null;
  }

  static Future<List<TickerModel>> fetchInitialTickers(
    List<String> symbols,
  ) async {
    final futures = symbols.map(fetchTicker24h).toList();
    final results = await Future.wait(futures);
    return results.whereType<TickerModel>().toList();
  }
}

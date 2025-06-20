import 'package:flutter/material.dart';
import '../services/binance_websocket_service.dart';

class OrderBookProvider with ChangeNotifier {
  final String pair;
  late final BinanceWebSocketService _service;
  List<List<String>> _asks = [];
  List<List<String>> _bids = [];
  double _spread = 0.0;

  OrderBookProvider(this.pair) {
    _service = BinanceWebSocketService(['$pair@depth20@100ms']);
    _listenToStream();
  }

  List<List<String>> get asks => _asks;
  List<List<String>> get bids => _bids;

  /// Spread entre mejor ask y mejor bid
  double get spread => _spread;

  /// Estado actual de la conexión WebSocket
  ValueNotifier<bool> get isConnected => _service.connectionStatus;

  void _listenToStream() {
    _service.stream.listen(
      (data) {
        try {
          if (data['asks'] != null && data['bids'] != null) {
            _asks = List<List<String>>.from(
              data['asks'].map((e) => List<String>.from(e)),
            );
            _bids = List<List<String>>.from(
              data['bids'].map((e) => List<String>.from(e)),
            );

            _calculateSpread();
            notifyListeners();
          }
        } catch (e) {
          debugPrint('Error parsing order book: $e');
        }
      },
      onError: (e) {
        debugPrint('OrderBook stream error: $e');
      },
    );
  }

  void _calculateSpread() {
    if (_asks.isNotEmpty && _bids.isNotEmpty) {
      final bestAsk = double.tryParse(_asks.first[0]) ?? 0.0;
      final bestBid = double.tryParse(_bids.first[0]) ?? 0.0;
      _spread = (bestAsk - bestBid).abs();
    }
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }
}

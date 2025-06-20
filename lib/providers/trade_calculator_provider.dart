import 'package:flutter/material.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';

class TradeCalculatorProvider with ChangeNotifier {
  final MarketTickerProvider _marketProvider;

  TradeCalculatorProvider(this._marketProvider);

  String _pair = 'btcusdt';
  String _action = 'buy'; // 'buy' o 'sell'
  double _amount = 0.0;
  final double _feeRate = 0.001;

  String? _errorMessage;

  // Validaciones personalizadas (opcional)
  final double _minAmount = 1;
  final double _maxAmount = 100000;

  void setAmount(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      _errorMessage = 'Monto inválido';
    } else if (parsed < _minAmount) {
      _errorMessage = 'El monto mínimo es $_minAmount';
    } else if (parsed > _maxAmount) {
      _errorMessage = 'El monto máximo es $_maxAmount';
    } else {
      _amount = parsed;
      _errorMessage = null;
    }
    notifyListeners();
  }

  void setAction(String action) {
    if (action == 'buy' || action == 'sell') {
      _action = action;
      notifyListeners();
    }
  }

  void setPair(String pair) {
    _pair = pair.toLowerCase();
    notifyListeners();
  }

  String get action => _action;
  String get pair => _pair;
  double get amount => _amount;
  double get fee => _amount * _feeRate;

  String? get error => _errorMessage;

  bool get isValid => _errorMessage == null && _amount > 0;

  double get result {
    final price = currentPrice;
    if (price == 0 || !isValid) return 0;

    final netAmount = _amount - fee;
    return _action == 'buy'
        ? netAmount /
            price // cuánto compro con USDT
        : netAmount * price; // cuánto obtengo en USDT
  }

  double get currentPrice {
    final ticker = _marketProvider.getTicker(_pair);
    return double.tryParse(ticker?['c'] ?? '') ?? 0;
  }

  String get formattedResult {
    final res = result;
    return res == 0 ? '0.00' : res.toStringAsFixed(6);
  }

  String get formattedFee {
    return fee == 0 ? '0.00' : fee.toStringAsFixed(2);
  }

  double get percentChange {
    final ticker = _marketProvider.getTicker(_pair);
    return double.tryParse(ticker?['P'] ?? '') ?? 0;
  }

  String get priceChangeDirection =>
      percentChange >= 0 ? 'up' : 'down'; // Para flecha o color
}

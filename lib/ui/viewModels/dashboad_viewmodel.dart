import 'package:app_binance/data/entities/ticker_entity.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardViewModel with ChangeNotifier {
  MarketTickerProvider? _marketProvider;
  MarketTickerProvider get marketProvider => _marketProvider!;

  DashboardViewModel(this._marketProvider) {
    _marketProvider?.addListener(_onMarketProviderChange);
  }

  void updateMarketProvider(MarketTickerProvider newProvider) {
    if (_marketProvider != newProvider) {
      _marketProvider?.removeListener(_onMarketProviderChange);
      _marketProvider = newProvider;
      _marketProvider?.addListener(_onMarketProviderChange);
      notifyListeners(); // opcional, si quieres forzar refresh inmediato
    }
  }

  void _onMarketProviderChange() {
    notifyListeners(); // 🔥 Esto refresca la UI automáticamente
  }

  List<TickerEntity> get tickers => marketProvider.tickers;

  bool get isLoading => marketProvider.isInitialLoading;

  Color getPriceColor(TickerEntity entity) {
    if (entity.priceChange > 0) return Colors.green;
    if (entity.priceChange < 0) return Colors.red;
    return Colors.grey;
  }

  IconData getPriceIcon(TickerEntity entity) {
    if (entity.priceChange > 0) return Icons.arrow_upward;
    if (entity.priceChange < 0) return Icons.arrow_downward;
    return Icons.trending_flat;
  }

  String formatPrice(double price, {String symbol = '\$'}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    ).format(price);
  }

  String formatPercent(double percent) {
    return "${percent.toStringAsFixed(2)}%";
  }

  TickerEntity? findTicker(String symbol) {
    try {
      return marketProvider.tickers.firstWhere(
        (t) => t.symbol.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _marketProvider?.removeListener(_onMarketProviderChange);
    super.dispose();
  }
}

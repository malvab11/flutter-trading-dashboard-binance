import 'package:app_binance/providers/mini_ticker_provider.dart';
import 'package:app_binance/providers/order_book_provider.dart';
import 'package:app_binance/services/binance_websocket_service.dart';
import 'package:app_binance/ui/screens/dashboard_screen.dart';
import 'package:app_binance/ui/viewModels/dashboad_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';
import 'package:app_binance/ui/themes/app_theme.dart';

void main() {
  final webSocketService = BinanceWebSocketService([
    'btcusdt@ticker',
    'ethusdt@ticker',
    'btcusdt@depth',
    'ethusdt@depth',
    'btcusdt@miniTicker',
    'ethusdt@miniTicker',
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MarketTickerProvider(webSocketService),
        ),
        ChangeNotifierProxyProvider<MarketTickerProvider, DashboardViewModel>(
          create:
              (context) =>
                  DashboardViewModel(context.read<MarketTickerProvider>()),
          update: (context, marketProvider, viewModel) {
            viewModel!.updateMarketProvider(marketProvider);
            return viewModel;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => MiniTickerProvider(webSocketService),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderBookProvider(webSocketService),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Binance Trading Dashboard',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}

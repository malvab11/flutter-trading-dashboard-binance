import 'package:app_binance/ui/screens/order_book_screen.dart';
import 'package:app_binance/ui/viewModels/order_book_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_binance/services/binance_websocket_service.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';
import 'package:app_binance/providers/mini_ticker_provider.dart';
import 'package:app_binance/providers/order_book_provider.dart';

import 'package:app_binance/ui/viewModels/dashboad_viewmodel.dart';

import 'package:app_binance/ui/screens/dashboard_screen.dart';
import 'package:app_binance/ui/themes/app_theme.dart';

void main() {
  final webSocketService = BinanceWebSocketService([
    'btcusdt@ticker',
    'ethusdt@ticker',
  ]);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: webSocketService),
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
        ChangeNotifierProxyProvider<OrderBookProvider, OrderBookViewModel>(
          create:
              (context) =>
                  OrderBookViewModel(context.read<OrderBookProvider>()),
          update:
              (context, orderBookProvider, viewModel) =>
                  viewModel!..selectedSymbol = viewModel.selectedSymbol,
        ),
      ],
      child: const MyApp(),
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
      routes: {
        '/dashboard': (_) => const DashboardScreen(),
        '/orderbook': (_) => const OrderBookScreen(), // si ya la tienes
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';
import 'package:app_binance/ui/screens/splash_screen.dart';
import 'package:app_binance/ui/themes/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MarketTickerProvider(),
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
      home: const SplashScreen(),
    );
  }
}

import 'package:app_binance/ui/screens/detail_view_screen.dart';
import 'package:app_binance/ui/screens/order_book_screen.dart';
import 'package:app_binance/ui/screens/trade_calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MarketTickerProvider>();
    final btc = provider.getTicker('btcusdt');
    final eth = provider.getTicker('ethusdt');

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1D23),
        centerTitle: true,
        title: const Text(
          'Trading Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildTickerCard('BTC/USDT', btc)),
                const SizedBox(width: 12),
                Expanded(child: _buildTickerCard('ETH/USDT', eth)),
              ],
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.book,
                  label: 'Order Book',
                  color: Colors.indigoAccent,
                  destination: const OrderBookScreen(),
                ),
                _buildNavButton(
                  context,
                  icon: Icons.calculate,
                  label: 'Calculator',
                  color: Colors.teal,
                  destination: const TradeCalculatorScreen(),
                ),
                _buildNavButton(
                  context,
                  icon: Icons.pie_chart,
                  label: 'Detail View',
                  color: Colors.deepPurple,
                  destination: const DetailViewScreen(symbol: "btcusdt"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTickerCard(String title, Map<String, dynamic>? data) {
    final price = double.tryParse(data?['c'] ?? '') ?? 0;
    final change = double.tryParse(data?['P'] ?? '') ?? 0;
    final color = change >= 0 ? Colors.greenAccent : Colors.redAccent;
    final arrow = change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontFamily: 'RobotoMono',
                ),
              ),
              const SizedBox(width: 8),
              Icon(arrow, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${change.toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Widget destination,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_book_provider.dart';

class OrderBookScreen extends StatelessWidget {
  const OrderBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OrderBookProvider('btcusdt'),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text('Order Book - BTC/USDT'),
          backgroundColor: const Color(0xFF1E1E1E),
          centerTitle: true,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: _OrderBookBody(),
        ),
      ),
    );
  }
}

class _OrderBookBody extends StatelessWidget {
  const _OrderBookBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderBookProvider>();
    final asks = provider.asks;
    final bids = provider.bids;

    double spread = 0;
    if (asks.isNotEmpty && bids.isNotEmpty) {
      final askPrice = double.tryParse(asks.first[0]) ?? 0;
      final bidPrice = double.tryParse(bids.first[0]) ?? 0;
      spread = askPrice - bidPrice;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle('SELL ORDERS (ASKS)', Colors.redAccent),
        const SizedBox(height: 8),
        _buildList(asks, Colors.redAccent),

        const SizedBox(height: 24),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Spread: \$${spread.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionTitle('BUY ORDERS (BIDS)', Colors.greenAccent),
        const SizedBox(height: 8),
        _buildList(bids, Colors.greenAccent),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildList(List<List<String>> entries, Color color) {
    return Column(
      children: entries.take(5).map((e) => _buildOrderRow(e, color)).toList(),
    );
  }

  Widget _buildOrderRow(List<String> data, Color color) {
    final price = double.tryParse(data[0]) ?? 0;
    final qty = double.tryParse(data[1]) ?? 0;
    final total = price * qty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
          Text(
            '${qty.toStringAsFixed(4)}',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

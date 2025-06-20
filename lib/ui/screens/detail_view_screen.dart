import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';

class DetailViewScreen extends StatelessWidget {
  final String symbol; // ej: 'btcusdt'

  const DetailViewScreen({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MarketTickerProvider>().getTicker(symbol);

    if (data == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final double price = double.tryParse(data['c'] ?? '') ?? 0;
    final double open = double.tryParse(data['o'] ?? '') ?? 0;
    final double high = double.tryParse(data['h'] ?? '') ?? 0;
    final double low = double.tryParse(data['l'] ?? '') ?? 0;
    final double close = double.tryParse(data['c'] ?? '') ?? 0;
    final double changePercent = double.tryParse(data['P'] ?? '') ?? 0;

    final Color changeColor =
        changePercent >= 0 ? Colors.greenAccent : Colors.redAccent;
    final IconData arrow =
        changePercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${symbol.toUpperCase()} Detail'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Precio actual
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(arrow, color: changeColor),
                    const SizedBox(width: 6),
                    Text(
                      '\$${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: changeColor,
                        fontFamily: 'RobotoMono',
                      ),
                    ),
                  ],
                ),
                Text(
                  '${changePercent.toStringAsFixed(2)}%',
                  style: TextStyle(fontSize: 18, color: changeColor),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Estadísticas: Open, High, Low, Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Open', open),
                _buildStat('High', high),
                _buildStat('Low', low),
                _buildStat('Close', close),
              ],
            ),
            const SizedBox(height: 32),

            const Text(
              'Precio (últimos 30s)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Gráfico simulado
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateMockData(price),
                      isCurved: true,
                      color: changeColor,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'RobotoMono',
          ),
        ),
      ],
    );
  }

  List<FlSpot> _generateMockData(double basePrice) {
    // ⚠️ Simula variaciones aleatorias para el gráfico (reemplazar luego con datos reales)
    return List.generate(
      30,
      (i) => FlSpot(i.toDouble(), basePrice + (i % 5 - 2).toDouble() * 2),
    );
  }
}

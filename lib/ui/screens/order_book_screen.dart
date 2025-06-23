import 'package:app_binance/ui/viewModels/order_book_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_binance/data/entities/order_book_entity.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class OrderBookScreen extends StatelessWidget {
  const OrderBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          return Consumer<OrderBookViewModel>(
            builder: (context, viewModel, child) {
              final bids = viewModel.sortedBids;
              final asks = viewModel.sortedAsks;
              final spread = viewModel.spread;
              final symbol = viewModel.selectedSymbol;

              return Scaffold(
                appBar: AppBar(
                  title: Text('Order Book - $symbol'),
                  actions: [
                    DropdownButton<String>(
                      value: symbol,
                      items: const [
                        DropdownMenuItem(
                          value: 'BTCUSDT',
                          child: Text('BTC/USDT'),
                        ),
                        DropdownMenuItem(
                          value: 'ETHUSDT',
                          child: Text('ETH/USDT'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          viewModel.selectedSymbol = value;
                        }
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'ASKS',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: OrderChart(orders: asks, color: Colors.red),
                      ),
                    ),
                    const _TableHeader(),
                    Expanded(
                      child: _OrderListWidget(orders: asks, color: Colors.red),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_vert, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            'Spread: ${spread.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'BIDS',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 140,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: OrderChart(orders: bids, color: Colors.green),
                      ),
                    ),
                    const _TableHeader(),
                    Expanded(
                      child: _OrderListWidget(
                        orders: bids,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '#',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Price',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Qty',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Total',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderListWidget extends StatelessWidget {
  final List<Order> orders;
  final Color color;

  const _OrderListWidget({required this.orders, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final total = order.price * order.quantity;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.03)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${index + 1}.',
                style: const TextStyle(color: Colors.white54),
              ),
              Text(
                order.price.toStringAsFixed(2),
                style: TextStyle(color: color),
              ),
              Text(
                order.quantity.toStringAsFixed(4),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                total.toStringAsFixed(2),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrderChart extends StatelessWidget {
  final List<Order> orders;
  final Color color;

  const OrderChart({required this.orders, required this.color});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    double cumulative = 0;

    for (var order in orders.take(50)) {
      cumulative += order.quantity;
      spots.add(FlSpot(order.price, cumulative));
    }

    final minX = spots.map((e) => e.x).reduce(min);
    final maxX = spots.map((e) => e.x).reduce(max);
    final minY = 0.0;
    final maxY = spots.map((e) => e.y).reduce(max);

    final xRange = maxX - minX;
    final yRange = maxY - minY;

    double getInterval(double range) {
      if (range > 100000) return 10000;
      if (range > 10000) return 1000;
      if (range > 1000) return 100;
      if (range > 100) return 10;
      return 1;
    }

    final xInterval = getInterval(xRange);
    final yInterval = getInterval(yRange);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: false),
            color: color,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), color.withOpacity(0.05)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: yInterval,
              getTitlesWidget:
                  (value, meta) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: xInterval,
              getTitlesWidget:
                  (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ),
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems:
                (touchedSpots) =>
                    touchedSpots.map((spot) {
                      return LineTooltipItem(
                        'Price: ${spot.x.toStringAsFixed(1)}\nQty: ${spot.y.toStringAsFixed(1)}',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    }).toList(),
          ),
        ),
      ),
    );
  }
}

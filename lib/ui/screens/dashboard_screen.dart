import 'package:app_binance/data/entities/ticker_entity.dart';
import 'package:app_binance/ui/viewModels/dashboad_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final symbols = ['BTCUSDT', 'ETHUSDT'];

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final tickers =
        viewModel.isLoading
            ? []
            : symbols
                .map((s) => viewModel.findTicker(s))
                .whereType<TickerEntity>()
                .toList();

    final isLoading = viewModel.isLoading || tickers.length < symbols.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Dashboard'),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable:
                viewModel.marketProvider.webSocketService.connectionStatus,
            builder:
                (_, connected, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    connected ? Icons.wifi : Icons.wifi_off,
                    color: connected ? Colors.green : Colors.red,
                  ),
                ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            isLoading
                ? _buildLoadingSkeleton()
                : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tickers.length,
                    itemBuilder: (_, i) {
                      final e = tickers[i];
                      final hasData = _hasValidData(e);

                      return Card(
                        key: ValueKey('${e.symbol}_${e.lastPrice}_${e.volume}'),
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          title: Text(
                            e.symbol,
                            style: _monoBoldStyle(
                              color: Colors.amber,
                              size: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              hasData
                                  ? _AnimatedPrice(
                                    price: e.lastPrice,
                                    color: viewModel.getPriceColor(e),
                                  )
                                  : const Text(
                                    'Precio: --',
                                    style: TextStyle(
                                      fontFamily: 'RobotoMono',
                                      color: Colors.white70,
                                    ),
                                  ),
                              Text(
                                'Vol: ${hasData ? NumberFormat.compact().format(e.volume) : '--'}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          trailing:
                              hasData
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        viewModel.getPriceIcon(e),
                                        color: viewModel.getPriceColor(e),
                                        size: 20,
                                      ),
                                      Text(
                                        viewModel.formatPercent(
                                          e.priceChangePercent,
                                        ),
                                        style: TextStyle(
                                          color: viewModel.getPriceColor(e),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                  : null,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/detail',
                                arguments: e.symbol,
                              ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/orderbook'),
                icon: const Icon(Icons.list),
                label: const Text('Order Book'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/calculator'),
                icon: const Icon(Icons.calculate),
                label: const Text('Calculadora'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasValidData(TickerEntity entity) => entity.lastPrice > 0;

  TextStyle _monoBoldStyle({Color color = Colors.white, double size = 14}) {
    return TextStyle(
      fontFamily: 'RobotoMono',
      fontWeight: FontWeight.bold,
      fontSize: size,
      color: color,
    );
  }

  Future<void> _handleRefresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final marketProvider = context.read<DashboardViewModel>().marketProvider;

    await marketProvider.reloadData();

    messenger.showSnackBar(
      const SnackBar(
        content: Text('🔄 Datos actualizados correctamente.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) {
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[600]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: 100, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 6),
                  Container(height: 14, width: 150, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedPrice extends StatelessWidget {
  final double price;
  final Color color;

  const _AnimatedPrice({required this.price, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: Text(
        'Precio: \$${price.toStringAsFixed(2)}',
        key: ValueKey(price),
        style: TextStyle(
          fontFamily: 'RobotoMono',
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_binance/providers/market_ticker_provider.dart';
import 'package:app_binance/providers/trade_calculator_provider.dart';

class TradeCalculatorScreen extends StatelessWidget {
  const TradeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final marketProvider = Provider.of<MarketTickerProvider>(
      context,
      listen: false,
    );

    return ChangeNotifierProvider(
      create: (_) => TradeCalculatorProvider(marketProvider),
      child: const _CalculatorScaffold(),
    );
  }
}

class _CalculatorScaffold extends StatelessWidget {
  const _CalculatorScaffold();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TradeCalculatorProvider>();
    final direction = provider.priceChangeDirection;
    final percentChange = provider.percentChange.toStringAsFixed(2);
    final priceColor =
        direction == 'up' ? Colors.greenAccent : Colors.redAccent;
    final arrowIcon =
        direction == 'up' ? Icons.arrow_upward : Icons.arrow_downward;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trade Calculator'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de par de trading
            DropdownButton<String>(
              dropdownColor: Colors.grey[900],
              value: provider.pair,
              items: const [
                DropdownMenuItem(value: 'btcusdt', child: Text('BTC/USDT')),
                DropdownMenuItem(value: 'ethusdt', child: Text('ETH/USDT')),
              ],
              onChanged: (value) {
                if (value != null) provider.setPair(value);
              },
              style: const TextStyle(color: Colors.white),
              iconEnabledColor: Colors.white,
            ),
            const SizedBox(height: 12),

            // Precio actual con animación visual
            Row(
              children: [
                Icon(arrowIcon, color: priceColor),
                const SizedBox(width: 8),
                Text(
                  '\$${provider.currentPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: priceColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMono',
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '(${percentChange}%)',
                  style: TextStyle(color: priceColor, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Acción: Comprar o Vender
            Row(
              children: [
                const Text("Acción:", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  dropdownColor: Colors.grey[900],
                  value: provider.action,
                  items: const [
                    DropdownMenuItem(value: 'buy', child: Text('Comprar')),
                    DropdownMenuItem(value: 'sell', child: Text('Vender')),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setAction(value);
                  },
                  style: const TextStyle(color: Colors.white),
                  iconEnabledColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo para ingresar el monto
            TextField(
              decoration: InputDecoration(
                labelText: 'Cantidad en USDT',
                labelStyle: const TextStyle(color: Colors.white70),
                errorText: provider.error,
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMono',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: provider.setAmount,
            ),
            const SizedBox(height: 24),

            // Resultado
            Text(
              'Resultado: ${provider.formattedResult} ${provider.action == 'buy' ? provider.pair.split('usdt').first.toUpperCase() : 'USDT'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'RobotoMono',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fee (0.1%): ${provider.formattedFee} USDT',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontFamily: 'RobotoMono',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

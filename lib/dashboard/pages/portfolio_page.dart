import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signal_engine/provider/equity_curve_provider.dart';
import '../provider/trade_history_provider.dart';
import '../widgets/equity_curve_widget.dart';
import '../widgets/trade_widget.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(tradeHistoryProvider);
    final equityCurve = ref.watch(equityCurveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Portfolio & PnL"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref.read(tradeHistoryProvider.notifier).clearTrades();
              ref.invalidate(equityCurveProvider);
            },
          )
        ],
      ),
      body: Column(
        children: [
          const AddTradeWidget(), // Manual trade input
          const SizedBox(height: 16),
          Expanded(
            flex: 2,
            child: Card(
              color: Colors.blueAccent,
              margin: const EdgeInsets.all(16),
              child: EquityCurveWidget(
                  equityCurve: equityCurve), // Draw equity curve
            ),
          ),
          Expanded(
            flex: 3,
            child: trades.isEmpty
                ? const Center(child: Text("No trades yet"))
                : ListView.builder(
                    itemCount: trades.length,
                    itemBuilder: (context, index) {
                      final t = trades[index];
                      return ListTile(
                        leading: Icon(
                          t.isWin ? Icons.arrow_upward : Icons.arrow_downward,
                          color: t.isWin ? Colors.green : Colors.red,
                        ),
                        title:
                            Text("${t.type} @ ${t.entry.toStringAsFixed(2)}"),
                        subtitle: Text(
                            "SL: ${t.stopLoss.toStringAsFixed(2)} | TP: ${t.takeProfit.toStringAsFixed(2)} | PnL: ${t.pnl.toStringAsFixed(2)}"),
                        trailing: Text(
                          t.isWin ? "WIN" : "LOSS",
                          style: TextStyle(
                              color: t.isWin ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

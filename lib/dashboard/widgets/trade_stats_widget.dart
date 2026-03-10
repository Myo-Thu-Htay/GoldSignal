import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/controller_provider.dart';
import '../provider/trade_history_provider.dart';
import '../service/trade_calculator.dart';

class TradeStatsWidget extends ConsumerWidget {
  const TradeStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trades = ref.watch(tradeHistoryProvider);
    final controller = ref.watch(controllerProvider);
    final wins = trades.where((t) => t.isWin).length;
    final winRate =
        trades.isEmpty ? 0 : (wins / trades.length * 100).toStringAsFixed(1);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Trading Stats",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text("Total PnL"),
                      ValueListenableBuilder(
                          valueListenable: controller.livePrice,
                          builder: (context, value, child) {
                            final totalPnL =
                                TradeCalculator.totalPnL(trades, value);
                            return Text(
                              "\$${totalPnL.toStringAsFixed(2)}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    totalPnL >= 0 ? Colors.green : Colors.red,
                              ),
                            );
                          })
                    ],
                  ),
                  Column(
                    children: [
                      Text("Win Rate"),
                      Text(
                        "$winRate %",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text("Trades"),
                      Text(
                        "${trades.length}",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

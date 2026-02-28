import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signal_engine/model/timeframe.dart';
import '../../signal_engine/provider/market_provider.dart';
import '../../signal_engine/provider/signal_provider.dart';
import '../../signal_engine/services/sr_service.dart';
import '../../signal_engine/services/trend_service.dart';
import '../widgets/trend_widget.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTF = ref.watch(selectedTimeframeProvider);
    final candlesAsync = ref.watch(binanceCandlesProvider);
    final signalAsync = ref.watch(signalProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            // 1️⃣ Timeframe Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 150),
                DropdownButton<Timeframe>(
                  value: selectedTF,
                  items: Timeframe.values.map((tf) {
                    return DropdownMenuItem(
                      value: tf,
                      child: Text(tf.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    ref.read(selectedTimeframeProvider.notifier).state = value!;
                    // Trigger signal refresh
                    ref.invalidate(binanceCandlesProvider);
                    ref.invalidate(signalProvider);
                  },
                ),
                const SizedBox(width: 50),
                // Manual Refresh Button
                ElevatedButton(
                    onPressed: () {
                      ref.invalidate(binanceCandlesProvider);
                      ref.invalidate(signalProvider);
                    },
                    child: const Text("Refresh"))
              ],
            ),

            // 2️⃣ Manual Account Balance Input
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Row(
            //     children: [
            //       const Text("Balance: "),
            //       SizedBox(
            //         width: 100,
            //         child: TextFormField(
            //           initialValue: account.balance.toStringAsFixed(0),
            //           keyboardType: TextInputType.number,
            //           onFieldSubmitted: (val) {
            //             final balance = double.tryParse(val);
            //             if (balance != null) {
            //               ref
            //                   .read(accountProvider.notifier)
            //                   .update(balance, account.riskPercent);
            //             }
            //           },
            //         ),
            //       ),
            //       const SizedBox(width: 20),
            //       const Text("Risk %: "),
            //       SizedBox(
            //         width: 80,
            //         child: TextFormField(
            //           initialValue: account.riskPercent.toString(),
            //           keyboardType: TextInputType.number,
            //           onFieldSubmitted: (val) {
            //             final risk = double.tryParse(val);
            //             if (risk != null) {
            //               ref
            //                   .read(accountProvider.notifier)
            //                   .update(account.balance, risk);
            //             }
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // 3️⃣ Candles & Signal Display
            Expanded(
              child: candlesAsync.when(
                data: (candles) {
                  // Detect Support/Resistance
                  final srService = SupportResistanceService();
                  final levels = srService.detectLevels(candles);
                  // Detect Trend
                  final trendService = TrendService();
                  final trendValues = trendService.calculateTrend(candles);

                  return Column(
                    children: [
                      SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Container(
                              decoration: BoxDecoration(
                                  color: trendService.isUptrend(candles)
                                      ? Colors.green[100]
                                      : trendService.isDowntrend(candles)
                                          ? Colors.red[100]
                                          : Colors.grey[200],
                                  border: Border.all(color: Colors.grey)),
                              child: TrendWidget(trend: trendValues))),
                      // Trend Display
                      Text(
                        trendService.detectTrend(candles),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Support/Resistance Display
                      Text(
                        "Resistance: ${levels[1].toStringAsFixed(2)}, Support: ${levels[0].toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      const SizedBox(height: 8),

                      // Signal Card
                      Expanded(
                        child: signalAsync.when(
                          data: (signal) {
                            if (signal == null) {
                              return const Card(
                                color: Colors.grey,
                                margin: EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    'No Signal, Trend is Unclear',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              );
                            }
                            return SizedBox(
                              width: double.infinity,
                              height: 100,
                              child: Card(
                                color: signal.isBuy ? Colors.green : Colors.red,
                                margin: const EdgeInsets.all(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        signal.isBuy ? 'BUY' : 'SELL',
                                        style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                          "Entry: ${signal.entry.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      Text(
                                          "Stop Loss: ${signal.stopLoss.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      Text(
                                          "Take Profit: ${signal.takeProfit.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      Text(
                                          "Lot Size: ${signal.lotSize.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      Text(
                                          "RR: ${signal.riskReward.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Text('Error: $e'),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error loading candles: $e'),
              ),
            ),

            //4️⃣ Refresh Button
            // FloatingActionButton(
            //   onPressed: () {
            //     ref.invalidate(binanceCandlesProvider);
            //     ref.invalidate(signalProvider);
            //   },
            //   child: const Icon(Icons.refresh),
            // ),
          ],
        ),
      ),
    );
  }

  /// Simple EMA trend detection
}

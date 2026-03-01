import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/signal_engine/services/signal_service.dart';
import '../../signal_engine/model/timeframe.dart';
import '../../signal_engine/provider/market_provider.dart';
import '../../signal_engine/provider/signal_provider.dart';
import '../../signal_engine/services/sr_service.dart';
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
                    ref.invalidate(binanceCandlesProvider);
                    ref.invalidate(signalProvider);
                  },
                ),
                const SizedBox(width: 50),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(binanceCandlesProvider);
                    ref.invalidate(signalProvider);
                  },
                  child: const Text("Refresh"),
                )
              ],
            ),

            // 2️⃣ Candles & Signal Display
            Expanded(
              child: candlesAsync.when(
                data: (candles) {
                  final srService = SupportResistanceService();
                  final levels = candles.isNotEmpty
                      ? srService.detectLevels(candles)
                      : [0.0, 0.0];

                  final signalService = SignalService();

                  // Trend display
                  String trendText = candles.isNotEmpty
                      ? signalService.detectTrend(candles)
                      : 'No Trend';
                  // ignore: unused_local_variable
                  List<double> trendValues = candles.isNotEmpty
                      ? signalService.calculateTrend(candles)
                      : [];

                  // RSI
                  double rsiValue = candles.isNotEmpty
                      ? signalService.calculateRSI(candles)
                      : 50.0;
                  final signal = signalAsync.asData?.value;
                  return Column(
                    children: [
                      // Trend Chart
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            color: candles.isNotEmpty
                                ? signalService.isBullish(candles)
                                    ? Colors.green[100]
                                    : signalService.isBearish(candles)
                                        ? Colors.red[100]
                                        : Colors.grey[200]
                                : Colors.grey[200],
                            border: Border.all(color: Colors.grey),
                          ),
                          child: TrendWidget(
                            trend: candles,
                            supportLevel: levels[0],
                            resistanceLevel: levels[1],
                            isBuySignal: signal?.isBuy ?? false,
                            isHoldSignal: signal?.isHold ?? false,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Trend Text
                      Text(
                        trendText,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),

                      // RSI Display
                      Text(
                        'RSI: ${rsiValue.toStringAsFixed(2)}',
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
                            // ✅ Treat "Hold" as no signal
                            //final hasSignal = signal != null && signal.isHold != true;

                            if (signal.isHold) {
                              return const Card(
                                color: Colors.grey,
                                margin: EdgeInsets.all(16),
                                child: Center(
                                  child: Text(
                                    'No Signal, Trend is Sideways',
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
                                          "RR: 1:${signal.riskReward.toStringAsFixed(0)}",
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
          ],
        ),
      ),
    );
  }
}

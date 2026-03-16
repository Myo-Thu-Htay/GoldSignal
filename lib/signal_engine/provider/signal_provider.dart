import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/signal_engine.dart';
import 'market_provider.dart';
import '../model/trade_signal.dart';
import '../../dashboard/provider/account_provider.dart';

final signalEngineProvider = Provider((ref) => SignalEngine());
final signalProvider = StreamProvider<TradeSignal>((ref) async* {
  final repo = ref.watch(marketRepositoryProvider);
  final account = ref.watch(accountProvider);
  final engine = ref.watch(signalEngineProvider);
  DateTime? lastCandleTime;
  // Listen to the stream of signals from the engine
  while (ref.mounted) {
    try {
      final candles = await repo.getBinanceCandles();
      final latestCandle = candles.m5.last;
      final latestTime = latestCandle.time;
      if (lastCandleTime == null || latestTime.isAfter(lastCandleTime)) {
        lastCandleTime = latestTime;
        final signal = await engine.evaluate(
            candles, account.balance, account.riskPercent);
        yield signal;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in signal provider: $e');
      }
    }
    await Future.delayed(const Duration(seconds: 20)); // Poll every 20 seconds
  }
});

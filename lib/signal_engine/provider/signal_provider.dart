import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/signal_engine.dart';
import 'market_provider.dart';
import '../model/trade_signal.dart';
import 'account_provider.dart';

final signalEngineProvider = Provider((ref) => SignalEngine());
final signalProvider = FutureProvider<TradeSignal?>((ref) async {
  final binanceCandles = await ref.watch(binanceCandlesProvider.future);
  final account = ref.watch(accountProvider);
  final engine = ref.read(signalEngineProvider);
  return engine.evaluate(binanceCandles, account.balance, account.riskPercent);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/signal_engine/api/binance_api_service.dart';
import '../api/forex_api_service.dart';
import '../model/candle.dart';
import '../model/timeframe.dart';
import '../api/market_repository_impl.dart';

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  return MarketRepositoryImpl(
      apiService: ForexApiService(), binanceApiService: BinanceApiService());
});

final selectedTimeframeProvider = StateProvider<Timeframe>((ref) {
  return Timeframe.h1; // Default timeframe
});

final binanceCandlesProvider = FutureProvider<List<Candle>>((ref) async {
  final repository = ref.read(marketRepositoryProvider);
  final tf = ref.read(selectedTimeframeProvider);
  return await repository.getCandles(tf,useBinance: true);
});

final finageCandlesProvider = FutureProvider<List<Candle>>((ref) async {
  final repository = ref.read(marketRepositoryProvider);
  final tf = ref.watch(selectedTimeframeProvider);
  return await repository.getCandles(tf,useBinance: false);
});

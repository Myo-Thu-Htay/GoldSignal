import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/api/binance_api_service.dart';
import '../../core/api/market_repository_impl.dart';
import '../model/candle.dart';
import '../model/multi_timeframe_model.dart';
import '../model/timeframe.dart';

final binanceApiProvider = Provider((ref) {
  return BinanceApiService();
});

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final apiService = ref.watch(binanceApiProvider);
  return MarketRepositoryImpl(binanceApiService: apiService);
});
final selectedTimeframeProvider = StateProvider<Timeframe>((ref) =>Timeframe.h1 // Default timeframe
);

final binanceCandlesProvider = FutureProvider<List<Candle>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  final tf = ref.watch(selectedTimeframeProvider);
  return await repository.getCandles(tf);
});
final getBinanceCandles = FutureProvider<MultiTimeFrameModel>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return await repository.getBinanceCandles();
});


import 'package:gold_signal/core/api/binance_api_service.dart';
import 'package:gold_signal/signal_engine/model/multi_timeframe_model.dart';
import '../../signal_engine/model/candle.dart';
import '../../signal_engine/model/timeframe.dart';
import '../constants/timeframe.dart';

abstract class MarketRepository {
  Future<List<Candle>> getCandles(Timeframe tf);
  Future<MultiTimeFrameModel> getBinanceCandles();
}

class MarketRepositoryImpl implements MarketRepository {
  final BinanceApiService binanceApiService;

  MarketRepositoryImpl({required this.binanceApiService});

  @override
  Future<List<Candle>> getCandles(Timeframe tf) async {
    final interval = mapTimeFrameToBinance(tf);
    return await binanceApiService.getCandles(interval);
  }

  MultiTimeFrameModel? cache;
  DateTime? lastFetch;
  @override
  Future<MultiTimeFrameModel> getBinanceCandles() async {
    // Simple in-memory caching to avoid hitting API too frequently
    if (cache != null &&
        lastFetch != null &&
        DateTime.now().difference(lastFetch!) < Duration(seconds: 30)) {
      return cache!;
    }
    final results = await Future.wait([
      binanceApiService.getCandles('4h'),
      binanceApiService.getCandles('1h'),
      binanceApiService.getCandles('15m'),
      binanceApiService.getCandles('5m')
    ]);
    cache = MultiTimeFrameModel(
        h4: results[0], h1: results[1], m15: results[2], m5: results[3]);
    lastFetch = DateTime.now();
    return MultiTimeFrameModel(
        h4: results[0], h1: results[1], m15: results[2], m5: results[3]);
  }

  
}

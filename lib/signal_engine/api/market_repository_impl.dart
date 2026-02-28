import 'package:gold_signal/signal_engine/api/binance_api_service.dart';

import '../model/candle.dart';
import '../model/timeframe.dart';
import 'forex_api_service.dart';

abstract class MarketRepository {
  Future<List<Candle>> getCandles(Timeframe tf, {bool useBinance = true});
}

class MarketRepositoryImpl implements MarketRepository {
  final ForexApiService apiService;
  final BinanceApiService binanceApiService;

  MarketRepositoryImpl(
      {required this.apiService, required this.binanceApiService});

  @override
  Future<List<Candle>> getCandles(Timeframe tf,
      {bool useBinance = true}) async {
    if (useBinance) {
      final interval = mapTimeFrameToBinance(tf);
      return await binanceApiService.getCandles(interval);
    } else {
      return await apiService.fetchCandles(tf);
    }
  }

  String mapTimeFrameToBinance(Timeframe tf) {
    switch (tf) {
      case Timeframe.m1:
        return '1m';
      case Timeframe.m5:
        return '5m';
      case Timeframe.m15:
        return '15m';
      case Timeframe.m30:
        return '30m';
      case Timeframe.h1:
        return '1h';
      case Timeframe.h4:
        return '4h';
      case Timeframe.d1:
        return '1d';
      default:
        return '1h';
    }
  }
}

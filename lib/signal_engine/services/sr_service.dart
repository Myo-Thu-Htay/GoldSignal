import '../model/candle.dart';

class SupportResistanceService {
  /// Returns approximate support/resistance levels from last N candles
  List<double> detectLevels(List<Candle> candles, {int lookback = 50}) {
    if (candles.length < lookback) return [];

    final recent = candles.sublist(candles.length - lookback);
    final highs = recent.map((c) => c.high).toList();
    final lows = recent.map((c) => c.low).toList();

    final resistance = highs.reduce((a, b) => a > b ? a : b);
    final support = lows.reduce((a, b) => a < b ? a : b);

    return [support, resistance];
  }
}
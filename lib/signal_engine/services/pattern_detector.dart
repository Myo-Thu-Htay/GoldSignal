import '../model/candle.dart';

class PatternDetector {
  double detectBullishEngulfing(List<Candle> candles) {
    if (candles.length < 2) return 0.0;
    final prev = candles[candles.length - 2];
    final current = candles.last;
    if (prev.close < prev.open && // Previous is bearish
        current.close > current.open && // Current is bullish
        current.open < prev.close && // Current opens below previous close
        current.close > prev.open) {
      // Current closes above previous open
      return 0.8; // Strong bullish signal
    }
    return 0.0; // No pattern detected
  }

  double detectBearishEngulfing(List<Candle> candles) {
    if (candles.length < 2) return 0.0;
    final prev = candles[candles.length - 2];
    final current = candles.last;

    if (prev.close > prev.open &&
        current.close < current.open &&
        current.open > prev.close &&
        current.close < prev.open) {
      return 0.8;
    }
    return 0.0;
  }

  double detectSideWays(List<Candle> candles) {
    if (candles.isEmpty) return 0.0;
    final high = candles.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final low = candles.map((e) => e.high).reduce((a, b) => a < b ? a : b);
    final range = high - low;
    if (range < (candles.last.close * 0.002)) {
      return 0.5;
    }
    return 0.0;
  }
}

import '../model/candle.dart';

class TrendService {
  double calculateTrendStrength(List<Candle> candles) {
    if (candles.isEmpty) return 0.0;
    final first = candles.first;
    final last = candles.last;
    final priceChange = last.close - first.open;
    final trendStrength = (priceChange / first.open) * 100;
    return trendStrength.clamp(-100, 100);
  }

  bool isStrongUptrend(List<Candle> candles) {
    return calculateTrendStrength(candles) > 2; // Arbitrary threshold
  }

  bool isStrongDowntrend(List<Candle> candles) {
    return calculateTrendStrength(candles) < -2; // Arbitrary threshold
  }

  bool isSideways(List<Candle> candles) {
    final strength = calculateTrendStrength(candles);
    return strength > -5 && strength < 5; // Arbitrary range for sideways
  }

  bool isTrendReversal(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend < -5) ||
        (prevTrend < -5 && currentTrend > 5);
  }

  bool isTrendContinuation(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend > 5) ||
        (prevTrend < -5 && currentTrend < -5);
  }

  bool isTrendWeakening(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend > 0 && currentTrend < prevTrend) ||
        (prevTrend < -5 && currentTrend < 0 && currentTrend > prevTrend);
  }

  bool isTrendStrengthening(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend > prevTrend) ||
        (prevTrend < -5 && currentTrend < prevTrend);
  }

  bool isTrendExhaustion(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend < prevTrend && currentTrend > 0) ||
        (prevTrend < -5 && currentTrend > prevTrend && currentTrend < 0);
  }

  bool isTrendAcceleration(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && currentTrend > prevTrend * 1.5) ||
        (prevTrend < -5 && currentTrend < prevTrend * 1.5);
  }

  bool isUptrendWithPullback(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return prevTrend > 5 && currentTrend < prevTrend && currentTrend > 0;
  }

  bool isDowntrendWithPullback(List<Candle> candles) {
    if (candles.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return prevTrend < -5 && currentTrend > prevTrend && currentTrend < 0;
  }

  bool isTrendReversalWithConfirmation(List<Candle> candles) {
    if (candles.length < 4) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 2));
    final reversalTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    return (prevTrend > 5 && reversalTrend < -5 && currentTrend < -5) ||
        (prevTrend < -5 && reversalTrend > 5 && currentTrend > 5);
  }

  bool isTrendContinuationWithVolume(
      List<Candle> candles, List<double> volumes) {
    if (candles.length < 3 || volumes.length < 3) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    final prevVolume = volumes[volumes.length - 2];
    final currentVolume = volumes.last;
    return (prevTrend > 5 && currentTrend > 5 && currentVolume > prevVolume) ||
        (prevTrend < -5 && currentTrend < -5 && currentVolume > prevVolume);
  }

  bool isTrendReversalWithVolume(List<Candle> candles, List<double> volumes) {
    if (candles.length < 4 || volumes.length < 4) return false;
    final prevTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 2));
    final reversalTrend =
        calculateTrendStrength(candles.sublist(0, candles.length - 1));
    final currentTrend = calculateTrendStrength(candles);
    final prevVolume = volumes[volumes.length - 2];
    final currentVolume = volumes.last;
    return (prevTrend > 5 &&
            reversalTrend < -5 &&
            currentTrend < -5 &&
            currentVolume > prevVolume) ||
        (prevTrend < -5 &&
            reversalTrend > 5 &&
            currentTrend > 5 &&
            currentVolume > prevVolume);
  }

  bool isUptrend(List<Candle> candles) {
    if (candles.length < 50) return false;
    double multiplier = 2 / (50 + 1);
    double ema50 = candles.first.close;
    for (int i = 1; i < candles.length; i++) {
      ema50 = (candles[i].close - ema50) * multiplier + ema50;
    }
    return candles.last.close > ema50;
  }

  bool isDowntrend(List<Candle> candles) {
    if (candles.length < 50) return false;
    double multiplier = 2 / (50 + 1);
    double ema50 = candles.first.close;
    for (int i = 1; i < candles.length; i++) {
      ema50 = (candles[i].close - ema50) * multiplier + ema50;
    }
    return candles.last.close < ema50;
  }
}

// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:gold_signal/signal_engine/model/multi_timeframe_model.dart';

import '../model/candle.dart';

class SignalService {
  bool isBullish(List<Candle> candles) {
    if (candles.length < 50) return false;
    double ema50 = calculatEMA50(candles);
    return candles.last.close > ema50;
  }

  bool isBearish(List<Candle> candles) {
    if (candles.length < 50) return false;
    double ema50 = calculatEMA50(candles);
    return candles.last.close < ema50;
  }

  String detectTrend(List<Candle> candles) {
    bool bull = isBullish(candles);
    bool bear = isBearish(candles);
    if (!bull && !bear) {
      return 'Side Way';
    } else if (bear) {
      return 'Down Trend';
    }
    return 'Up Trend';
  }

  double calculateTrendStrength(List<Candle> candles) {
    if (candles.isEmpty) return 0.0;
    final first = candles.first;
    final last = candles.last;
    final priceChange = last.close - first.open;
    final trendStrength = (priceChange / first.open) * 100;
    return trendStrength.clamp(-100, 100);
  }

  List<double> calculateTrend(List<Candle> candles) {
    final List<double> strengths = [];
    for (int i = 1; i < candles.length; i++) {
      final sublist = candles.sublist(0, i + 1);
      strengths.add(calculateTrendStrength(sublist));
    }
    return strengths;
  }

  double calculateConfidence(MultiTimeFrameModel multiTf) {
    int score = 0;
    if (isBullish(multiTf.h1)) {
      score += 2;
    } else if (isBearish(multiTf.h1)) score -= 2;
    if (isBullish(multiTf.m15))
      score += 1;
    else if (isBearish(multiTf.m15)) score -= 1;
    if (isBullish(multiTf.m5))
      score += 1;
    else if (isBearish(multiTf.m5)) score -= 1;

    return (score + 4) / 8; // Normalize to 0-1
  }

  double calculateSMA(List<Candle> candles, int period) {
    if (candles.length < period) return 0.0;
    double sum = 0.0;
    for (int i = candles.length - period; i < candles.length; i++) {
      sum += candles[i].close;
    }
    return sum / period;
  }

  double calculateEMA(List<Candle> candles, int period) {
    if (candles.length < period) return 0.0;
    double k = 2 / (period + 1);
    //Step 1 : first EMA = SMA
    double ema = calculateSMA(candles.sublist(0, period), period);
    //Step 2 : Continue EMA
    for (int i = period; i < candles.length; i++) {
      ema = (candles[i].close * k) + (ema * (1 - k));
    }
    return ema;
  }

  double calculatEMA50(List<Candle> candles) {
    return calculateEMA(candles, 50);
  }

  bool isPullBackToEMA50(List<Candle> candles) {
    if (candles.length < 51) return false;
    const k = 2 / (50 + 1);
    // Calculate full EMA50 series
    List<double> ema50Series = [];
    double ema = calculateSMA(candles.sublist(0, 50), 50);
    ema50Series.add(ema);
    for (int i = 50; i < candles.length; i++) {
      ema = (candles[i].close * k) + (ema * (1 - k));
      ema50Series.add(ema);
    }
    int lastIndex = ema50Series.length - 1;
    double prevClose = candles[lastIndex + 49].close;
    double lastClose = candles[lastIndex + 50].close;
    double prevEma = ema50Series[lastIndex - 1];
    double lastEma = ema50Series[lastIndex];

    return (prevClose > prevEma && lastClose < lastEma) ||
        (prevClose < prevEma && lastClose > lastEma);
  }

  bool bullishBreak(List<Candle> m5) {
    if (m5.length < 2) return false;
    final lastCandle = m5.last;
    final prevCandle = m5[m5.length - 2];
    return lastCandle.close > prevCandle.high &&
        lastCandle.close > prevCandle.close;
  }

  double calculateRSI(List<Candle> candles, {int period = 14}) {
    if (candles.length < 15) {
      return 50.0;
    }
    double gain = 0.0;
    double loss = 0.0;
    // Initial average gain/loss
    for (int i = 1; i < period; i++) {
      double change = candles[i].close - candles[i - 1].close;
      if (change > 0) {
        gain += change;
      } else {
        loss += change.abs();
      }
    }
    double avgGain = gain / period;
    double avgLoss = loss / period;
    // Continue smoothing (Wilder's smoothing)
    for (int i = period + 1; i < candles.length; i++) {
      double change = candles[i].close - candles[i - 1].close;
      double currentGain = change > 0 ? change : 0;
      double currentLoss = change < 0 ? change.abs() : 0;
      avgGain = ((avgGain * (period - 1)) + currentGain) / period;
      avgLoss = ((avgLoss * (period - 1)) + currentLoss) / period;
    }
    if (avgLoss == 0) return 100.0;
    double rs = avgGain / avgLoss;
    double rsi = 100 - (100 / (1 + rs));
    return rsi;
  }

  // RSI confirmation
  bool rsiBullish(List<Candle> candles) {
    double rsi = calculateRSI(candles);
    return rsi > 50 && rsi < 70;
  }

  bool rsiBearish(List<Candle> candles) {
    double rsi = calculateRSI(candles);
    return rsi < 50 && rsi > 30;
  }

  String generateSignal(MultiTimeFrameModel multiTf) {
    if(multiTf.h1.length < 50 || multiTf.m15.length < 50 || multiTf.m5.length < 50) return 'Hold';
   bool h1Bull = isBullish(multiTf.h1);
    bool h1Bear = isBearish(multiTf.h1);
    bool pullBack = false;
    try {
      pullBack = isPullBackToEMA50(multiTf.m15);
    } catch (e) {
      pullBack = false;
    }
    bool breakM5 = false;
    try {
      breakM5 = bullishBreak(multiTf.m5);
    } catch (e) {
      breakM5 = false;
    }
    bool rsiBull = rsiBullish(multiTf.m15);
    bool rsiBear = rsiBearish(multiTf.m15);
    if (h1Bull && pullBack && breakM5 && rsiBull) {
      return 'Strong Buy';
    } else if (h1Bear && pullBack && breakM5 && rsiBear) {
      return 'Strong Sell';
    } else if (h1Bull && rsiBull) {
      return 'Buy';
    } else if (h1Bear && rsiBear) {
      return 'Sell';
    } else {
      return 'Hold';
    }
  }
}

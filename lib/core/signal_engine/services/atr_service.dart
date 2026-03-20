import '../model/candle.dart';

class AtrService {
  double calculateATR(List<Candle> candles, int period) {
    if (candles.length < period + 1) return 0.0;
    double atr = 0.0;
    for (int i = candles.length - period; i < candles.length; i++) {
      final current = candles[i];
      final previous = candles[i - 1];
      final highLow = current.high - current.low;
      final highClose = (current.high - previous.close).abs();
      final lowClose = (current.low - previous.close).abs();
      final trueRange =
          [highLow, highClose, lowClose].reduce((a, b) => a > b ? a : b);
      atr += trueRange;
    }
    return atr / period;
  }

  
}

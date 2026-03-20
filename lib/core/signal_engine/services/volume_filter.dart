import '../model/candle.dart';

class VolumeFilter {
  bool confirm(List<Candle> candles) {
    final validVolume =
        candles.map((e) => e.volume).where((c) => c > 0).toList();
    if (validVolume.isEmpty) return true;
    final lastVolume = validVolume.last;
    final avgVolume = validVolume.reduce((a, b) => a + b) / validVolume.length;
    return lastVolume > avgVolume * 1.2; // Arbitrary threshold for high
  }

  bool confirmBullish(List<Candle> candles) {
    final last = candles.last;
    if (last.close <= last.open) return false;
    return confirm(candles);
  }

  bool confirmBearish(List<Candle> candles) {
    final last = candles.last;
    if (last.close >= last.open) return false;
    return confirm(candles);
  }
}

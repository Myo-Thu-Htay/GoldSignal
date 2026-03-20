class TradeLevels {
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double rr;

  TradeLevels({
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.rr,
  });
}

class TpSlService {
  static TradeLevels? calculateLevels({
    required double currentPrice,
    required bool isBuy,
    required double atr,
    double minRR = 2.0,
  }) {
    double buffer =
        atr * 0.2; // Buffer to avoid placing SL/TP too close to current price
    if (isBuy) {
      final entry =
          currentPrice + buffer; // Entry at the upper boundary of the zone
      final sl =
          entry - buffer; // Subtracting a small buffer to the support level
      final tp = entry +
          buffer; // Subtracting a small buffer from the resistance level
      final risk = (entry - sl).abs();
      final reward = (tp - entry).abs();

      if (risk == 0) return null;

      final rr = reward / risk;

      if (rr < minRR) return null;

      return TradeLevels(
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        rr: rr,
      );
    } else {
      final entry =
          currentPrice - buffer; // Entry at the lower boundary of the zone
      final sl =
          entry + buffer; // Adding a small buffer to the resistance level
      final tp = entry - buffer; // Adding a small buffer to the support level

      final risk = (sl - entry).abs();
      final reward = (entry - tp).abs();

      if (risk == 0) return null;
      final rr = reward / risk;
      if (rr < minRR) return null;

      return TradeLevels(
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        rr: rr,
      );
    }
  }
}

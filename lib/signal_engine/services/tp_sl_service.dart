import '../model/srzone_model.dart';

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
    required List<SrServiceZone> zones,
    required double atr,
    double minRR = 2.0,
  }) {
    if (zones.isEmpty) return null;
    double buffer =
        atr * 0.2; // Buffer to avoid placing SL/TP too close to current price
    final supports =
        zones.where((z) => z.isSupport && z.price < currentPrice).toList();
    //print('Supports: ${supports.map((s) => s.price).toList()}');
    final resistances =
        zones.where((z) => !z.isSupport && z.price > currentPrice).toList();
    //print('Resistances: ${resistances.map((r) => r.price).toList()}');

    if (isBuy) {
      if (supports.isEmpty || resistances.isEmpty) return null;

      final nearestSupport = supports.reduce((a, b) =>
          (currentPrice - a.price).abs() < (currentPrice - b.price).abs()
              ? a
              : b);

      final nearestResistance = resistances.reduce((a, b) =>
          (currentPrice - a.price).abs() < (currentPrice - b.price).abs()
              ? a
              : b);
      // print(
      //     'Buy Nearest Support: ${nearestSupport.price}, Nearest Resistance: ${nearestResistance.price}');
      final entry = currentPrice;
      final sl = nearestSupport.price -
          buffer; // Subtracting a small buffer to the support level
      final tp = nearestResistance.price -
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
      if (supports.isEmpty || resistances.isEmpty) return null;

      final nearestResistance = resistances.reduce((a, b) =>
          (currentPrice - a.price).abs() < (currentPrice - b.price).abs()
              ? a
              : b);

      final nearestSupport = supports.reduce((a, b) =>
          (currentPrice - a.price).abs() < (currentPrice - b.price).abs()
              ? a
              : b);
      // print(
      //     'Sell Nearest Resistance: ${nearestResistance.price}, Nearest Support: ${nearestSupport.price}');
      final entry = currentPrice;
      final sl = nearestResistance.price +
          buffer; // Adding a small buffer to the resistance level
      final tp = nearestSupport.price +
          buffer; // Adding a small buffer to the support level

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

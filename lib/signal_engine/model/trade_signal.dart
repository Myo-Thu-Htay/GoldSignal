class TradeSignal {
  final bool isBuy;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double lotSize;
  final int confidence;

  TradeSignal({
    required this.isBuy,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.lotSize,
    required this.confidence,
  });

  double get riskReward {
    double risk = 0.0;
    double reward = 0.0;
    if (isBuy) {
      risk = (entry - stopLoss).abs();
      reward = (takeProfit - entry).abs();
    } else {
      risk = (stopLoss - entry).abs();
      reward = (entry - takeProfit).abs();
    }
    return reward / (risk == 0 ? 1 : risk);
  }
}

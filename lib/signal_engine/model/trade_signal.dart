class TradeSignal {
  final bool isBuy;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double lotSize;
  final double confidence;

  TradeSignal({
    required this.isBuy,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.lotSize,
    required this.confidence,
  });

  double get riskReward {
    final risk = (isBuy ? entry - stopLoss : stopLoss - entry).abs();
    final reward = (isBuy ? takeProfit - entry : entry - takeProfit).abs();
    return reward / risk;
  }
}

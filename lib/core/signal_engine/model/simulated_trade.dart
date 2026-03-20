class SimulatedTrade {
  final bool isBuy;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double lotSize;
  final double pnl;
  final bool isWin;
  final DateTime timestamp;
  final String type;

  SimulatedTrade({
    required this.isBuy,
    required this.entry,
    required this.stopLoss,
    required this.takeProfit,
    required this.lotSize,
    required this.pnl,
    required this.isWin,
    required this.timestamp,
    required this.type,
  });
}
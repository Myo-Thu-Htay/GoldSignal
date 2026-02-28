class Trade {
  final bool isBuy;
  final double entry;
  final double stopLoss;
  final double takeProfit;
  final double lotSize;
  final bool isWin;
  final double pnl;
  final DateTime timestamp;
  final String type; // "BUY" or "SELL"

  Trade(
      {required this.isBuy,
      required this.entry,
      required this.stopLoss,
      required this.takeProfit,
      required this.lotSize,
      required this.isWin,
      required this.pnl,
      required this.timestamp,
      required this.type});

 Map<String, dynamic> toJson() {
    return {
      'isBuy': isBuy,
      'entry': entry,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'lotSize': lotSize,
      'isWin': isWin,
      'pnl': pnl,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      isBuy: json['isBuy'],
      entry: json['entry'],
      stopLoss: json['stopLoss'],
      takeProfit: json['takeProfit'],
      lotSize: json['lotSize'],
      isWin: json['isWin'],
      pnl: json['pnl'],
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
    );
  }
}

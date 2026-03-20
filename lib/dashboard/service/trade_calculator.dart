import 'package:gold_signal/core/signal_engine/model/candle.dart';

import '../models/trade_model.dart';

class TradeCalculator {
  ///Determine exit price based on result or candle movement
  static double calculateExit({
    required bool isBuy,
    required double entry,
    required double sl,
    required double tp,
    required String result,
    required List<Candle> candles,
    double? manualExit,
  }) {
    if (candles.isEmpty) return entry; // No candles, return entry price as exit
    final last = candles.last;

    //Manual results
    if (result == "TP") return tp;
    if (result == "SL") return sl;
    if (result == "Manual" && manualExit != null) return manualExit;

    //Automatic results based on candle movement
    if (isBuy) {
      if (last.low <= sl) return sl; // Stop Loss hit
      if (last.high >= tp) return tp; // Take Profit hit
      return last.close; // Trade still open, return last close price
    } else {
      if (last.high >= sl) return sl; // Stop Loss hit
      if (last.low <= tp) return tp; // Take Profit hit
      return last.close; // Trade still open, return last close price
    }
  }

  ///Calculate profit or loss percentage
  static double calculatePnL(
      {required bool isBuy,
      required double entry,
      required double exit,
      required double lot}) {
    if (entry == 0) return 0; // Avoid division by zero
    if (isBuy) {
      return (exit - entry) * lot * 100; // Profit for Buy
    } else {
      return (entry - exit) * lot * 100; // Profit for Sell
    }
  }

  ///calculate Total PnL for multiple trades
  static double totalPnL(List<Trade> trades, double livePrice) {
    double total = 0;
    for (Trade trade in trades) {
      double exitPrice;
      if (trade.isOpen) {
        exitPrice = livePrice;
      }else {
        exitPrice = trade.exitPrice!; 
      }
      double pnl;
      if (trade.isBuy){
        pnl = (exitPrice - trade.entry) * trade.lotSize * 100;
      }else {
        pnl = (trade.entry - exitPrice) * trade.lotSize * 100;
      }
      total += pnl;
    }
    return total;
  }

  ///Calculate Risk-Reward Ratio
  static double riskReward(
      {required double entry, required double sl, required double tp}) {
    final risk = (entry - sl).abs();
    final reward = (tp - entry).abs();
    if (risk == 0) return 0; // Avoid division by zero
    return reward / risk; // Risk-Reward Ratio
  }
}

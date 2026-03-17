import 'package:gold_signal/signal_engine/model/trade_signal.dart';

class SignalValidator {
  static const int expiryMinutes = 60; // Example expiry time for signals
  static TradeSignal validateSignal(TradeSignal signal, double currentPrice) {
    
    double maxMove = (signal.takeProfit - signal.entry).abs() * 0.5; // 50% of expected move
    // Check if signal is already expired
    if (signal.status != SignalStatus.active) {
      return signal; // No change if not active
    }
    //Missed Entry Validation
    if (signal.isBuy && currentPrice > signal.entry + maxMove) {
      return signal.copyWith(status: SignalStatus.invalid); // Missed buy entry
    } 
    if (!signal.isBuy && currentPrice < signal.entry - maxMove) { 
      return signal.copyWith(status: SignalStatus.invalid); // Missed sell entry
    }
     if (DateTime.now().difference(signal.generatedAt).inMinutes >
          expiryMinutes) {
        signal = signal.copyWith(status: SignalStatus.expired);
      } // Expiry Validation
    // Buy Signal Validation
    if (signal.isBuy) {
      if (currentPrice >= signal.takeProfit) {
        signal = signal.copyWith(status: SignalStatus.tpHit);
      } 
      if (currentPrice <= signal.stopLoss) {
        signal = signal.copyWith(status: SignalStatus.slHit);
      }
    } else {
      // Sell Signal Validation
      if (currentPrice <= signal.takeProfit) {
        signal = signal.copyWith(status: SignalStatus.tpHit);
      } 
      if (currentPrice >= signal.stopLoss) {
        signal = signal.copyWith(status: SignalStatus.slHit);
      } 
     }
    return signal;
  }
}
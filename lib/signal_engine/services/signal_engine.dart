import 'package:shared_preferences/shared_preferences.dart';

import '../../dashboard/service/notification_service.dart';
import '../model/multi_timeframe_model.dart';
import 'signal_service.dart';
import 'sr_service.dart';
import 'tp_sl_service.dart';
//import 'volume_filter.dart';
import '../model/trade_signal.dart';
import 'risk_service.dart';

class SignalEngine {
  final RiskService _riskService = RiskService();
  final SrService srService = SrService();
  final SignalService _signalService = SignalService();

  static const int emaPeriod = 50;

  Future<TradeSignal> evaluate(MultiTimeFrameModel candles,
      double accountBalance, double riskPercent) async {
    final confidence = _signalService.calculateConfidence(candles);
    final signal = _signalService.generateSignal(candles, confidence);
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    // === BUY Condition ===
    if (signal == 'Strong Buy') {
      final zones = SrService.calculateZones(
        candles.h1,
        lookback: 300,
        zoneTolerance: 0.5,
        minTouches: 2,
      );
      // print(
      //     'Buy Calculated SR Zones: ${zones.map((z) => z.price.toStringAsFixed(2)).toList()}');
      final trade = TpSlService.calculateLevels(
        currentPrice: candles.m5.last.close,
        isBuy: true, // Assuming a buy signal for demonstration
        zones: zones,
        minRR: 2.0,
      );
      //print('Buy Calculated Trade Levels: ${trade ?? "None"}');
      if (trade == null) {
        return holdSignal(confidence); // No valid trade levels, hold signal
      }
      final lot = _riskService.calculateLotSize(
          balance: accountBalance,
          entry: trade.entry,
          riskPercent: riskPercent,
          stopLoss: trade.stopLoss);

      final entry = trade.entry;
      final sl = trade.stopLoss;
      final tp = trade.takeProfit;
      if (notificationsEnabled) {
        NotificationService.showNotification(
          title: 'New Trade Signal',
          body:
              'Buy Signal: Entry: ${entry.toStringAsFixed(2)}, SL: ${sl.toStringAsFixed(2)}, TP: ${tp.toStringAsFixed(2)}, Lot Size: ${lot.toStringAsFixed(2)}, Confidence: ${((confidence / 20) * 100).toStringAsFixed(1)}%',
        );
      }

      return TradeSignal(
        isBuy: true,
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: lot,
        confidence: confidence,
      );
    }
    if (signal == 'Buy') {
      double entry = candles.m5.last.close;
      double sl = entry - 20; // Example SL for a regular buy signal
      double tp = entry + 40; // Example TP for a regular buy signal
      double lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: entry,
        riskPercent: riskPercent,
        stopLoss: sl,
      );
      if (notificationsEnabled) {
        NotificationService.showNotification(
          title: 'New Trade Signal',
          body:
              'Buy Signal: Entry: ${entry.toStringAsFixed(2)}, SL: ${sl.toStringAsFixed(2)}, TP: ${tp.toStringAsFixed(2)}, Lot Size: ${lot.toStringAsFixed(2)}, Confidence: ${((confidence / 20) * 100).toStringAsFixed(1)}%',
        );
      }
      return TradeSignal(
        isBuy: true,
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: lot,
        confidence: confidence,
      );
    }
    // === SELL Condition ===
    if (signal == 'Strong Sell') {
      final zones = SrService.calculateZones(
        candles.h1,
        lookback: 300,
        zoneTolerance: 0.5,
        minTouches: 2,
      );
      // print(
      //     'Sell Calculated SR Zones: ${zones.map((z) => z.price.toStringAsFixed(2)).toList()}');
      final trade = TpSlService.calculateLevels(
        currentPrice: candles.m5.last.close,
        isBuy: false, // Assuming a sell signal for demonstration
        zones: zones,
        minRR: 2.0,
      );
      //print('Sell Calculated Trade Levels: ${trade ?? "None"}');
      if (trade == null) {
        return holdSignal(confidence); // No valid trade levels, hold signal
      }
      final entry = trade.entry;
      final tp = trade.takeProfit;
      final sl = trade.stopLoss;
      final lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: trade.entry,
        riskPercent: riskPercent,
        stopLoss: trade.stopLoss,
      );
      if (notificationsEnabled) {
        NotificationService.showNotification(
            title: 'New Trade Signal',
            body:
                'Sell Signal: Entry: ${entry.toStringAsFixed(2)}, SL: ${sl.toStringAsFixed(2)}, TP: ${tp.toStringAsFixed(2)}, Lot Size: ${lot.toStringAsFixed(2)}, Confidence: ${((confidence / 20) * 100).toStringAsFixed(1)}%');
      }

      return TradeSignal(
        isBuy: false,
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: lot,
        confidence: confidence,
      );
    }
    if (signal == 'Sell') {
      double entry = candles.m5.last.close;
      double sl = entry + 20; // Example SL for a regular sell signal
      double tp = entry - 40; // Example TP for a regular sell signal
      double lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: entry,
        riskPercent: riskPercent,
        stopLoss: sl,
      );
      if (notificationsEnabled) {
        NotificationService.showNotification(
            title: 'New Trade Signal',
            body:
                'Sell Signal: Entry: ${entry.toStringAsFixed(2)}, SL: ${sl.toStringAsFixed(2)}, TP: ${tp.toStringAsFixed(2)}, Lot Size: ${lot.toStringAsFixed(2)}, Confidence: ${((confidence / 20) * 100).toStringAsFixed(1)}%');
      }
      return TradeSignal(
        isBuy: false,
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: lot,
        confidence: confidence,
      );
    }

    return holdSignal(confidence);
  }

  // Helper holdSignal function
  TradeSignal holdSignal(int confidence) {
    return TradeSignal(
        isBuy: false,
        entry: 0.0,
        stopLoss: 0.0,
        takeProfit: 0.0,
        lotSize: 0.0,
        confidence: confidence);
  }
}

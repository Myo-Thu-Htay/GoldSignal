import 'package:flutter/foundation.dart';
import 'package:gold_signal/signal_engine/model/entry_zone_model.dart';
import 'package:gold_signal/signal_engine/services/entryservice.dart';
import '../../core/constants/trading_constants.dart';
import '../model/multi_timeframe_model.dart';
import 'atr_service.dart';
import 'signal_service.dart';
import 'sr_service.dart';
import 'tp_sl_service.dart';
import '../model/trade_signal.dart';
import 'risk_service.dart';

class SignalEngine {
  final RiskService _riskService = RiskService();
  final SrService srService = SrService();
  final SignalService _signalService = SignalService();
  final AtrService _atrService = AtrService();
  static const int emaPeriod = 50;

  Future<TradeSignal> evaluate(MultiTimeFrameModel candles,
      double accountBalance, double riskPercent) async {
    int confidence = _signalService.calculateConfidence(candles);
    final signal = _signalService.generateSignal(candles, confidence);

    final h4 = candles.h4;
    final h1 = candles.h1;
    final m15 = candles.m15;
    final m5 = candles.m5;
    final currPrice = m5.last.close;
    final atr = _atrService.calculateATR(h1, TradingConstants.atrPeriod);
    final ema50 = _signalService.calculateEMA(m15, emaPeriod);
    final zones = SrService.calculateZones(h4);
    final emaZone = Entryservice.emaZone(ema50);
    final srZone =
        SrService.getNearestZone(currPrice, zones, signal.contains('Buy'));
    final entryZone = Entryservice.mergeZones(srZone, emaZone);
    final trade = TpSlService.calculateLevels(
      currentPrice: currPrice,
      isBuy: signal.contains('Buy'),
      minRR: 2.0,
      atr: atr,
    );
    if (trade == null) {
      // If we can't calculate valid trade levels, return a hold signal
      if (kDebugMode) {
        print('Could not calculate valid trade levels, returning HOLD signal.');
      }
      return holdSignal(entryZone, confidence);
    }
    final lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: trade.entry,
        riskPercent: riskPercent,
        stopLoss: trade.stopLoss);
    final entry = signal.contains('Buy')
        ? currPrice < trade.entry
            ? currPrice
            : currPrice > trade.entry
                ? currPrice
                : trade.entry
        : signal.contains('Sell')
            ? currPrice > trade.entry
                ? currPrice
                : currPrice < trade.entry
                    ? currPrice
                    : trade.entry
            : trade.entry;
    final sl = trade.stopLoss;
    final tp = trade.takeProfit;
    // if (signal == 'HOLD') {
    //   return holdSignal(entryZone, confidence);
    // }
    return TradeSignal(
      isBuy: signal.contains('Buy'),
      entryZone: entryZone,
      entry: entry,
      stopLoss: sl,
      takeProfit: tp,
      lotSize: lot,
      rr: trade.rr,
      confidence: confidence,
      status: SignalStatus.pending,
      generatedAt: DateTime.now(),
    );
  }

  // Helper holdSignal function
  TradeSignal holdSignal(EntryZone entryZone, int confidence) {
    return TradeSignal(
      isBuy: false,
      entryZone: entryZone,
      entry: 0.0,
      stopLoss: 0.0,
      takeProfit: 0.0,
      lotSize: 0.0,
      rr: 0.0,
      confidence: confidence,
      status: SignalStatus.expired,
      generatedAt: DateTime.now(),
    );
  }
}

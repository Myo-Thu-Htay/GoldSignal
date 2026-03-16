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
    final confidence = _signalService.calculateConfidence(candles);
    final signal = _signalService.generateSignal(candles, confidence);
    final atr =
        _atrService.calculateATR(candles.h1, TradingConstants.atrPeriod);

    if (signal == 'HOLD') {
      return holdSignal(confidence);
    }

    final zones = SrService.calculateZones(
      candles.h4,
    );
    final trade = TpSlService.calculateLevels(
      currentPrice: candles.m15.last.close,
      isBuy: signal.contains('Buy'), // Assuming a buy signal for demonstration
      zones: zones,
      minRR: 2.0,
      atr: atr,
    );
    if (trade == null) {
      // print(
      //     'No valid trade levels found, holding signal with confidence: $confidence');
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
    return TradeSignal(
      isBuy: signal.contains('Buy'),
      entry: entry,
      stopLoss: sl,
      takeProfit: tp,
      lotSize: lot,
      confidence: confidence,
    );
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

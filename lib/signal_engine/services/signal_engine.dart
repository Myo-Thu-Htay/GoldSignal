import '../model/multi_timeframe_model.dart';
import 'atr_service.dart';
import 'pattern_detector.dart';
import 'signal_service.dart';
import 'sr_service.dart';
import 'volume_filter.dart';
import '../model/trade_signal.dart';
import 'risk_service.dart';

class SignalEngine {
  final AtrService _atrService = AtrService();
  final PatternDetector _patternDetector = PatternDetector();
  final VolumeFilter _volumeFilter = VolumeFilter();
  final RiskService _riskService = RiskService();
  final SupportResistanceService srService = SupportResistanceService();
  final SignalService _signalService = SignalService();
  static const int emaPeriod = 50;

  TradeSignal evaluate(
      MultiTimeFrameModel candles, double accountBalance, double riskPercent) {
    if (candles.h1.length < emaPeriod ||
        candles.m15.length < emaPeriod ||
        candles.m5.length < emaPeriod) {
      throw Exception('Not enough candles for analysis');
    }

    // ===Trend analysis===
    final signal = _signalService.generateSignal(candles);
    final isUp = _signalService.isBullish(candles.h1);
    final isDown = _signalService.isBearish(candles.h1);
    final confidence = _signalService.calculateConfidence(candles);

    if (!isUp && !isDown) {
      return holdSignal(confidence); // Low confidence hold
    }

    // ===Pattern detection===
    final bullishPattern =
        _patternDetector.detectBullishEngulfing(candles.m15) > 0;
    final bearishPattern =
        _patternDetector.detectBearishEngulfing(candles.m15) > 0;

    // ===Volume filter===
    final volumeConfirm = _volumeFilter.confirm(candles.m15);

    // === ATR Filter ===
    final atr = _atrService.calculateATR(candles.m15, 14);
    if (atr < 0) {
      return holdSignal(confidence); // Higher volatility, be cautious
    }
    // Avoid low volatility
    if (atr < 1.0) return holdSignal(confidence);

    // === BUY Condition ===
    if ((isUp && bullishPattern && volumeConfirm) &&
        (signal == 'Strong Buy' || signal == 'Buy')) {
      final levels = srService.detectLevels(candles.m15);
      final support = levels[0];
      final resistance = levels[1];
      final currentPrice = candles.m5.last.close;
      // Avoid buying directly into resistance
      if ((resistance - currentPrice) < atr * 1.2) {
        return holdSignal(confidence);
      }
      // prefer entry near support (pullback)
      if ((currentPrice - support) > atr * 1.5) {
        return holdSignal(confidence);
      }
      final entry = currentPrice;
      final sl = support - atr * 0.5; // SL below support
      final tp = resistance - 3; // TP below resistance for avoid pullback
      final lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: entry,
        riskPercent: riskPercent,
        stopLoss: sl,
      );
      return TradeSignal(
        isBuy: true,
        isHold: false,
        entry: entry,
        stopLoss: sl,
        takeProfit: tp,
        lotSize: lot,
        confidence: confidence,
      );
    }

    // === SELL Condition ===
    if ((isDown && bearishPattern && volumeConfirm) &&
        (signal == 'Strong Sell' || signal == 'Sell')) {
      final levels = srService.detectLevels(candles.m15);
      final support = levels[0];
      final resistance = levels[1];
      final currentPrice = candles.m5.last.close;
      // Avoid Selling ditectly into support
      if ((currentPrice - support) < atr * 1.2) {
        return holdSignal(0.45);
      }
      // prefer entry near resistance (pullback)
      if ((resistance - currentPrice) > atr * 1.5) {
        return holdSignal(0.5);
      }
      final entry = currentPrice;
      final tp = support + 3;
      final sl = resistance + atr * 0.5;
      final lot = _riskService.calculateLotSize(
        balance: accountBalance,
        entry: entry,
        riskPercent: riskPercent,
        stopLoss: sl,
      );
      return TradeSignal(
        isBuy: false,
        isHold: false,
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
  TradeSignal holdSignal(double confidence) {
    return TradeSignal(
        isBuy: false,
        isHold: true,
        entry: 0.0,
        stopLoss: 0.0,
        takeProfit: 0.0,
        lotSize: 0.0,
        confidence: confidence);
  }
}

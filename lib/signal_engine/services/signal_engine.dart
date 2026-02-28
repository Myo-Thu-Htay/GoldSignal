import '../model/candle.dart';
import 'atr_service.dart';
import 'pattern_detector.dart';
import 'sr_service.dart';
import 'trend_service.dart';
import 'volume_filter.dart';
import '../model/trade_signal.dart';
import 'risk_service.dart';

class SignalEngine {
  final TrendService _trendService = TrendService();
  final AtrService _atrService = AtrService();
  final PatternDetector _patternDetector = PatternDetector();
  final VolumeFilter _volumeFilter = VolumeFilter();
  final RiskService _riskService = RiskService();

  TradeSignal evaluate(
      List<Candle> candles, double accountBalance, double riskPercent) {
    if (candles.length < 50) {
      throw Exception('Not enough candles for analysis');
    }

    // Pattern detection
    final bullishScore = _patternDetector.detectBullishEngulfing(candles);
    final bearishScore = _patternDetector.detectBearishEngulfing(candles);
    final patternScore = bullishScore - bearishScore;

    // Trend detection
    final isUp = _trendService.isUptrend(candles);
    final isDown = _trendService.isDowntrend(candles);
    final trendScore = isUp
        ? 1
        : isDown
            ? -1
            : 0;

    // Volume confirmation
    final volumeConfirmed = _volumeFilter.confirm(candles);

    // Final confidence: 0–1
    final confidence = ((patternScore / 100).clamp(0.0, 1.0) * 0.6 +
            (volumeConfirmed ? 0.3 : 0.0) +
            (trendScore != 0 ? 0.1 : 0.0))
        .clamp(0.0, 1.0);
    // Resistance/Support detection
    final srService = SupportResistanceService();
    final levels = srService.detectLevels(candles);
    final entry =
        candles.last.close; // Use resistance as entry for buy, support for sell
    final atr = _atrService.calculateATR(candles, 14);
    final sl = isUp ? entry - atr * 1.5 : entry + atr * 1.5;
    final tp = isUp ? entry + atr * 1.5 : entry - atr * 1.5;

    // Lot size
    final lot = _riskService.calculateLotSize(
      balance: accountBalance,
      entry: entry,
      riskPercent: riskPercent,
      stopLoss: sl,
    );

    // Decide buy/sell based on trend
    final isBuy = isUp ||
        (trendScore == 0 && bullishScore > bearishScore) ||
        entry - levels[0] < levels[1] - entry;

    return TradeSignal(
      isBuy: isBuy,
      entry: entry,
      stopLoss: sl,
      takeProfit: tp,
      lotSize: lot,
      confidence: confidence,
    );
  }

  // Helper trend functions
  bool isUptrend(List<Candle> candles) => _trendService.isUptrend(candles);
  bool isDowntrend(List<Candle> candles) => _trendService.isDowntrend(candles);
  bool isSideways(List<Candle> candles) =>
      !isUptrend(candles) && !isDowntrend(candles);
}

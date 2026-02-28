class TradingConstants {
  static const String finageApiUrl =
      'https://api.finage.co.uk/agg/forex/XAUUSD/1/day/2025-01-01/2026-02-23?apikey=';
  static const String binanceApi = 'https://fapi.binance.com/fapi/v1/klines';
  static const String symbol = 'XAUUSD'; // Gold symbol for the API
  static const String binanceSymbol = 'XAUUSDT'; // Gold symbol for Binance API
  static const double pipValue = 1.0; // Example pip value for gold
  static const double defaultRiskPercentage =
      1.0; // Default risk percentage per trade
  static const double pipSize = 0.01; // XAUUSD pip size
  static const double defaultStopLossPips = 50.0; // Default stop loss in pips
  static const double defaultTakeProfitPips = 100.0; // Default take profit
  static const double slMultiplier =
      1.5; // Multiplier for calculating stop loss based on ATR
  static const double tpMultiplier =
      1.5; // Multiplier for calculating take profit
  static const int minCandles =
      100; // Minimum number of candles required for analysis
  static const int atrPeriod = 14; // Period for ATR calculation
  static const int maxOpenTrades = 5; // Maximum number of open trades
  static const int tradingHoursStart = 0; // Start of trading hours (0 = 00:00)
  static const int tradingHoursEnd = 24; // End of trading hours (24 = 24:00)
  static const double minimumAccountBalance =
      100.0; // Minimum account balance to start trading
  static const double lotSize = 0.01; // Default lot size for trading
  static const double leverage = 100.0; // Default leverage
  static const double slippageTolerance = 0.5; // Maximum slippage in pips
  static const double commissionPerLot = 7.0; // Commission per lot traded
  static const double swapLong = -0.5; // Swap for long positions
  static const double swapShort = -0.5; // Swap for short positions
  static const double marginRequirement = 1.0; // Margin requirement percentage
  static const double riskRewardRatio = 2.0; // Default risk-reward ratio
  static const int maxConsecutiveLosses =
      3; // Maximum consecutive losses before stopping trading
  static const int maxConsecutiveWins =
      5; // Maximum consecutive wins before taking a
  static const double maxDrawdownPercentage =
      20.0; // Maximum drawdown percentage before stopping trading
  static const double profitTargetPercentage =
      10.0; // Profit target percentage to stop trading
  static const double trailingStopPips = 20.0; // Trailing stop in pips
  static const double breakEvenPips =
      10.0; // Pips to move stop loss to break even
  static const double partialClosePercentage =
      50.0; // Percentage of position to close at take profit
  static const double partialClosePips =
      50.0; // Pips to close part of the position
  static const double martingaleMultiplier =
      2.0; // Multiplier for martingale strategy
  static const double antiMartingaleMultiplier =
      0.5; // Multiplier for anti-martingale strategy
  static const double maxLotSize =
      100.0; // Maximum lot size to prevent overexposure
  static const double minLotSize = 0.01; // Minimum lot size to ensure
  static const double lotSizeStep =
      0.01; // Lot size step for incremental adjustments
  static const double maxRiskPerTrade =
      5.0; // Maximum risk percentage per trade
  static const double minRiskPerTrade =
      0.1; // Minimum risk percentage per trade
  static const double riskStep =
      0.1; // Risk percentage step for incremental adjustments
  static const double maxStopLossPips = 200.0; // Maximum stop loss in pips
  static const double minStopLossPips = 10.0; // Minimum stop loss in pips
  static const double stopLossStepPips =
      10.0; // Stop loss step in pips for incremental adjustments
  static const double maxTakeProfitPips = 400.0; // Maximum take profit in pips
  static const double minTakeProfitPips = 20.0; // Minimum take profit in pips
  static const double takeProfitStepPips =
      20.0; // Take profit step in pips for incremental adjustments
  static const double maxSlippagePips = 5.0; // Maximum slippage in pips
  static const double minSlippagePips = 0.0; // Minimum slippage in pips
  static const double slippageStepPips =
      0.5; // Slippage step in pips for incremental adjustments
  static const double maxLeverage =
      500.0; // Maximum leverage allowed by the broker
  static const double minLeverage =
      1.0; // Minimum leverage allowed by the broker
  static const double leverageStep =
      1.0; // Leverage step for incremental adjustments
  static const double maxMarginRequirement =
      100.0; // Maximum margin requirement percentage
  static const double minMarginRequirement =
      0.1; // Minimum margin requirement percentage
  static const double marginRequirementStep =
      0.1; // Margin requirement step for incremental adjustments
  static const double maxRiskRewardRatio = 10.0; // Maximum risk-reward ratio
  static const double minRiskRewardRatio = 0.1; // Minimum risk-reward ratio
  static const double riskRewardRatioStep =
      0.1; // Risk-reward ratio step for incremental adjustments
  static const double maxDrawdownPercentageForMartingale =
      50.0; // Maximum drawdown percentage before stopping martingale strategy
  static const double maxConsecutiveLossesForMartingale =
      5; // Maximum consecutive losses before stopping martingale strategy
  static const double maxConsecutiveWinsForAntiMartingale =
      5; // Maximum consecutive wins before stopping anti-martingale strategy
  static const double maxDrawdownPercentageForAntiMartingale =
      50.0; // Maximum drawdown percentage before stopping anti-martingale strategy
  static const double profitTargetPercentageForAntiMartingale =
      20.0; // Profit target percentage to stop anti-martingale strategy
  static const double trailingStopStepPips =
      5.0; // Trailing stop step in pips for incremental adjustments
  static const double breakEvenStepPips =
      5.0; // Break even step in pips for incremental adjustments
  static const double partialCloseStepPercentage =
      10.0; // Partial close step percentage for incremental adjustments
  static const double partialCloseStepPips =
      10.0; // Partial close step in pips for incremental adjustments
  static const double maxLotSizeForMartingale =
      10.0; // Maximum lot size for martingale strategy to prevent overexposure
  static const double maxLotSizeForAntiMartingale =
      10.0; // Maximum  lot size for anti-martingale strategy to prevent overexposure
  static const double minLotSizeForMartingale =
      0.01; // Minimum lot size for martingale strategy to ensure proper risk management
  static const double minLotSizeForAntiMartingale =
      0.01; // Minimum lot size for anti-martingale strategy to ensure proper risk management
  static const double lotSizeStepForMartingale =
      0.01; // Lot size step for martingale strategy for incremental adjustments
  static const double lotSizeStepForAntiMartingale =
      0.01; // Lot size step for anti-martingale strategy for incremental adjustments
  static const double maxRiskPerTradeForMartingale =
      5.0; // Maximum  risk percentage per trade for martingale strategy
  static const double maxRiskPerTradeForAntiMartingale =
      5.0; // Maximum risk percentage per trade for anti-martingale strategy
  static const double minRiskPerTradeForMartingale =
      0.1; // Minimum risk percentage per trade for martingale strategy
  static const double minRiskPerTradeForAntiMartingale =
      0.1; // Minimum risk percentage per trade for anti-martingale strategy
  static const double riskStepForMartingale =
      0.1; // Risk percentage step  for martingale strategy for incremental adjustments
  static const double riskStepForAntiMartingale =
      0.1; // Risk percentage step for anti-martingale strategy for incremental adjustments
  static const double maxStopLossPipsForMartingale =
      200.0; // Maximum stop loss in pips for martingale strategy
  static const double maxStopLossPipsForAntiMartingale =
      200.0; // Maximum stop loss in pips for anti-martingale strategy
  static const double minStopLossPipsForMartingale =
      10.0; // Minimum stop loss in pips for martingale strategy
  static const double minStopLossPipsForAntiMartingale =
      10.0; // Minimum stop loss in pips for anti-martingale strategy
  static const double stopLossStepPipsForMartingale =
      10.0; //  Stop loss step in pips for martingale strategy for incremental adjustments
  static const double stopLossStepPipsForAntiMartingale =
      10.0; // Stop loss step in pips for anti-martingale strategy for incremental adjustments
  static const double maxTakeProfitPipsForMartingale =
      400.0; // Maximum take profit in pips for martingale strategy
  static const double maxTakeProfitPipsForAntiMartingale =
      400.0; // Maximum take profit in pips for anti-martingale strategy
  static const double minTakeProfitPipsForMartingale =
      20.0; // Minimum take profit in pips for martingale strategy
  static const double minTakeProfitPipsForAntiMartingale =
      20.0; // Minimum take profit in pips for anti-martingale strategy
  static const double takeProfitStepPipsForMartingale =
      20.0; // Take profit step in pips for martingale strategy for incremental adjustments
  static const double takeProfitStepPipsForAntiMartingale =
      20.0; // Take profit step in pips for anti-martingale strategy for incremental adjustments
  static const double maxSlippagePipsForMartingale =
      5.0; // Maximum slippage in pips for martingale strategy
  static const double maxSlippagePipsForAntiMartingale =
      5.0; // Maximum slippage in pips for anti-martingale strategy
  static const double minSlippagePipsForMartingale =
      0.0; //  Minimum slippage in pips for martingale strategy
  static const double minSlippagePipsForAntiMartingale =
      0.0; // Minimum slippage in pips for anti-martingale strategy
  static const double slippageStepPipsForMartingale =
      0.5; // Slippage step in pips for martingale strategy for incremental adjustments
  static const double slippageStepPipsForAntiMartingale =
      0.5; // Slippage step in pips for anti-martingale strategy for incremental adjustments
  static const double maxLeverageForMartingale =
      500.0; // Maximum leverage for martingale strategy
}

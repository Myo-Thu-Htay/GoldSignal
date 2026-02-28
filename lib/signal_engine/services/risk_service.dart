class RiskService {
  double contractSize = 100.0; // 1 standard lot = 100 oz for gold
  double calculateLotSize({
    required double balance,
    required double riskPercent,
    required double entry,
    required double stopLoss,
  }) {
    final safeRisk = riskPercent.clamp(0.1, 3.0);
    final riskAmount = balance * (safeRisk / 100);
    final stopDistance = (entry - stopLoss).abs(); // 1 standard lot = 100 oz

    final lotSize =
        riskAmount / (stopDistance * contractSize); // 1 standard lot = 100 oz

    return lotSize.clamp(0.01, 100.0); //make sure to broker compatible
  }
}

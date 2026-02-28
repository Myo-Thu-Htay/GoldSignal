import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  static const _balanceKey = "account_balance";
  static const _riskKey = "risk_percent";

  Future<void> saveBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_balanceKey, balance);
  }

  Future<void> saveRisk(double risk) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_riskKey, risk);
  }

  Future<double> loadBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_balanceKey) ?? 10000;
  }

  Future<double> loadRisk() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_riskKey) ?? 1.0;
  }
}
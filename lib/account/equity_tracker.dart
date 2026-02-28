import 'package:shared_preferences/shared_preferences.dart';

class EquityTracker {
  final List<double> equityHistory = [];
  
  void addEquity(double value) async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    equityHistory.add(value);
    prefs.setStringList('equity_history', equityHistory.map((e) => e.toString()).toList());
  }

  double get maxEquity =>
      equityHistory.isEmpty ? 0 : equityHistory.reduce((a, b) => a > b ? a : b);

  double get currentEquity =>
      equityHistory.isEmpty ? 0 : equityHistory.last;

  double get drawdown {
    if (equityHistory.isEmpty) return 0;
    final peak = maxEquity;
    final current = currentEquity;
    return ((peak - current) / peak) * 100;
  }
}
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gold_signal/account/trade.dart';
import 'package:shared_preferences/shared_preferences.dart';

final tradeHistoryProvider =
    StateNotifierProvider<TradeHistoryNotifier, List<Trade>>(
        (ref) => TradeHistoryNotifier());

class TradeHistoryNotifier extends StateNotifier<List<Trade>> {
  TradeHistoryNotifier() : super([])
  {
    _loadTrades();
  }

  Future<void> _loadTrades() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tradeStrings = prefs.getStringList('trade_history') ?? [];
    state = tradeStrings.map((t) => Trade.fromJson(jsonDecode(t))).toList();
  }

  Future<void> addTrade(Trade trade) async {
    state = [...state, trade];
    await _saveTrades();
  }

  Future<void> _saveTrades() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tradeStrings = state.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('trade_history', tradeStrings);
  }

  Future<void> clearTrades() async {
    state = [];
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('trade_history');
  }

  Future<void> addManualTrade({
    required bool isBuy,
    required double entry,
    required double sl,
    required double tp,
    required double lot,
    required DateTime timestamp,
  }) async{
    final pnl = (isBuy ? (tp - entry) : (entry - tp)) * lot; // pipValue can be included
    final isWin = (isBuy && tp > entry) || (!isBuy && tp < entry);
    final trade = Trade(
      isBuy: isBuy,
      entry: entry,
      stopLoss: sl,
      takeProfit: tp,
      lotSize: lot,
      pnl: pnl,
      isWin: isWin,
      timestamp: timestamp,
      type: isBuy ? "BUY" : "SELL",
    );
    state = [...state, trade];
    await _saveTrades();
  }
}
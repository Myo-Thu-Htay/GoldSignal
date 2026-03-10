import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/dashboard/provider/controller_provider.dart';
import 'package:gold_signal/dashboard/service/trade_calculator.dart';
import '../../../signal_engine/model/candle.dart';
import '../../../signal_engine/provider/equity_curve_provider.dart';
import '../../../signal_engine/provider/market_provider.dart';
import '../provider/trade_history_provider.dart';
import '../widgets/timepicker_widget.dart';
import 'trade_history_screen.dart';

class AddTrade extends ConsumerStatefulWidget {
  const AddTrade({super.key});

  @override
  ConsumerState<AddTrade> createState() => _AddTradeState();
}

class _AddTradeState extends ConsumerState<AddTrade> {
  bool isBuy = true;
  DateTime entryTime = DateTime.now().toUtc();
  DateTime exitTime = DateTime.now().toUtc();
  final entryController = TextEditingController();
  final slController = TextEditingController();
  final tpController = TextEditingController();
  final lotController = TextEditingController();
  final exitPrice = TextEditingController();
  String result = "TP";

  final pnlPreview = ValueNotifier(0.0);
  void calculatePreview(List<Candle> candles) async {
    final entry = double.tryParse(entryController.text);
    final sl = double.tryParse(slController.text);
    final tp = double.tryParse(tpController.text);
    final lot = double.tryParse(lotController.text);
    final exitManual = double.tryParse(exitPrice.text);
    if (candles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Candle data not available for preview")),
      );
      return;
    }

    if (entry == null || sl == null || tp == null || lot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please enter a valid Value for ${entry == null ? "Entry Price" : sl == null ? "Stop Loss" : tp == null ? "Take Profit" : "Lot Size"}")),
      );
      return;
    }

    final exit = TradeCalculator.calculateExit(
      isBuy: isBuy,
      entry: entry,
      sl: sl,
      tp: tp,
      candles: candles,
      result: result,
      manualExit: exitManual,
    );

    final pnl = TradeCalculator.calculatePnL(
        isBuy: isBuy, entry: entry, exit: exit, lot: lot);

    pnlPreview.value = pnl;
  }

  Future<void> pickTime(bool isEntry) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isEntry ? entryTime : exitTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null) return;

    final Duration? time = await showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => TimePickerWidget(
            initialTime: TimeOfDay.now(),
            onTimeChanged: (t) => Navigator.pop(context, t)));

    if (time == null) return;

    final finalDate = DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.inHours,
      time.inMinutes % 60,
      time.inSeconds % 60,
    );

    setState(() {
      if (isEntry) {
        entryTime = finalDate;
      } else {
        exitTime = finalDate;
      }
    });
  }

  void addTrade(bool isOpen) async {
    final entry = double.tryParse(entryController.text);
    final sl = double.tryParse(slController.text);
    final tp = double.tryParse(tpController.text);
    final lot = double.tryParse(lotController.text);
    final exitManual = double.tryParse(exitPrice.text);

    if (entry == null || sl == null || tp == null || lot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "Please enter a valid Value for ${entry == null ? "Entry Price" : sl == null ? "Stop Loss" : tp == null ? "Take Profit" : "Lot Size"}")),
      );
      return;
    }
    List<Candle> candles = ref.watch(binanceCandlesProvider).value ?? [];
    double exit = TradeCalculator.calculateExit(
      isBuy: isBuy,
      entry: entry,
      sl: sl,
      tp: tp,
      candles: candles,
      result: result,
      manualExit: exitManual,
    );

    ref.watch(tradeHistoryProvider.notifier).addManualTrade(
          isBuy: isBuy,
          entry: entry,
          exit: exit,
          sl: sl,
          tp: tp,
          lot: lot,
          entryTime: entryTime,
          exitTime: exitTime,
          isOpen: isOpen,
        );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Trade Added")),
    );
  }

  @override
  void dispose() {
    entryController.dispose();
    slController.dispose();
    tpController.dispose();
    lotController.dispose();
    exitPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(controllerProvider);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text("Trade History"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(tradeHistoryProvider.notifier).clearTrades();
                ref.invalidate(equityCurveProvider);
              },
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                child: ValueListenableBuilder(
                    valueListenable: controller.candles,
                    builder: (context, candle, child) {
                      return ExpansionTile(
                        title: const Text("Add Manual Trade"),
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 10),
                              const Text("Type: "),
                              const SizedBox(width: 10),
                              DropdownButton<bool>(
                                value: isBuy,
                                items: const [
                                  DropdownMenuItem(
                                      value: true, child: Text("BUY")),
                                  DropdownMenuItem(
                                      value: false, child: Text("SELL")),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    isBuy = v!;
                                  });
                                },
                              ),
                              const SizedBox(width: 60),
                              Row(
                                children: [
                                  const Text("Result: "),
                                  const SizedBox(width: 10),
                                  DropdownButton<String>(
                                    value: result,
                                    items: const [
                                      DropdownMenuItem(
                                          value: "TP", child: Text("TP Hit")),
                                      DropdownMenuItem(
                                          value: "SL", child: Text("SL Hit")),
                                      DropdownMenuItem(
                                          value: "Manual",
                                          child: Text("Manual Close")),
                                      DropdownMenuItem(
                                          value: "Open",
                                          child: Text("Open Position")),
                                    ],
                                    onChanged: (v) {
                                      setState(() {
                                        result = v!;
                                      });
                                      calculatePreview(candle);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter entry price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            controller: entryController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Entry Price"),
                            onChanged: (_) => calculatePreview(candle),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter stop loss';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            controller: slController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Stop Loss"),
                            onChanged: (_) => calculatePreview(candle),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter take profit';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            controller: tpController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Take Profit"),
                            onChanged: (_) => calculatePreview(candle),
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Lot Size';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            controller: lotController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: "Lot Size"),
                            onChanged: (_) => calculatePreview(candle),
                          ),
                          result == "Manual"
                              ? TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter exit price';
                                    }
                                    if (double.tryParse(value) == null) {
                                      return 'Please enter a valid number';
                                    }
                                    return null;
                                  },
                                  controller: exitPrice,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      labelText: "Exit Price"),
                                  onChanged: (_) => calculatePreview(candle),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => pickTime(true),
                            child: Text(
                              "Entry Time: ${entryTime.toString().substring(0, 16)}",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          result != "Open"
                              ? TextButton(
                                  onPressed: () => pickTime(false),
                                  child: Text(
                                    "Exit Time: ${exitTime.toString().substring(0, 16)}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              : const SizedBox(),
                          const SizedBox(height: 10),
                          ValueListenableBuilder(
                              valueListenable: pnlPreview,
                              builder: (context, value, child) {
                                return Text(
                                  "PnL Preview: \$${value.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: pnlPreview.value >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                );
                              }),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size.fromHeight(40),
                            ),
                            onPressed: () {
                              result == "Open"
                                  ? addTrade(true)
                                  : addTrade(false);
                              entryController.clear();
                              slController.clear();
                              exitPrice.clear();
                              tpController.clear();
                              lotController.clear();
                            },
                            child: const Text("Save Trade"),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    }),
              ),
              TradeHistoryScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

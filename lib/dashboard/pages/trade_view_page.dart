import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trade_model.dart';
import '../provider/controller_provider.dart';
import '../provider/trade_history_provider.dart';
import '../widgets/timepicker_widget.dart';

class ViewTradePage extends ConsumerStatefulWidget {
  final Trade trade;

  const ViewTradePage({super.key, required this.trade});

  @override
  ConsumerState<ViewTradePage> createState() => _ViewTradePageState();
}

class _ViewTradePageState extends ConsumerState<ViewTradePage> {
  bool isBuy = true;
  DateTime entryTime = DateTime.now().toUtc();
  DateTime exitTime = DateTime.now().toUtc();
  final slController = TextEditingController();
  final tpController = TextEditingController();
  final exitPrice = TextEditingController();
  String result = "TP";
  final pnlPreview = ValueNotifier(0.0);
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

  void editTrade(bool isOpen, bool isBuy, double currPrice) {
    final sl = double.tryParse(slController.text) ?? 0.0;
    final tp = double.tryParse(tpController.text) ?? 0.0;
    final exitManual = double.tryParse(exitPrice.text) ?? 0.0;
    final exitTime = DateTime.now().toUtc();
    final updatedTrade = widget.trade.copyWith(
      stopLoss: sl,
      takeProfit: tp,
      exitPrice: widget.trade.isOpen ? currPrice : exitManual,
      exitTime: result != "Open" ? exitTime : null,
      isOpen: result == "Open" ? true : false,
      isWin: result == "TP",
    );

    ref.read(tradeHistoryProvider.notifier).updateTrade(updatedTrade);
  }

  @override
  void dispose() {
    slController.dispose();
    tpController.dispose();
    exitPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(controllerProvider);    
    double entry = widget.trade.entry;
    double sl = double.tryParse(slController.text) ?? 0.0;
    double tp = double.tryParse(tpController.text) ?? 0.0;
    double lot = widget.trade.lotSize;
    double exitManual = double.tryParse(exitPrice.text) ?? 0.0;
    final pnl = ValueNotifier(0.0);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Trade History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ref
                  .read(tradeHistoryProvider.notifier)
                  .deleteTradeByTime(widget.trade.entryTime);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                    color: widget.trade.isWin
                        ? Colors.green
                        : widget.trade.isOpen
                            ? Colors.blue
                            : Colors.red,
                    width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("XAUUSD "),
                      const SizedBox(width: 10),
                      Text(widget.trade.type),
                      const SizedBox(width: 10),
                      Text("Lot: ${widget.trade.lotSize}"),
                      const SizedBox(width: 20),
                      Text(
                        widget.trade.isOpen
                            ? "Open"
                            : widget.trade.isWin
                                ? "Win"
                                : "Loss",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.trade.isOpen
                                ? Colors.blue
                                : widget.trade.isWin
                                    ? Colors.green
                                    : Colors.red),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("\$${widget.trade.entry.toStringAsFixed(2)}"),
                      const SizedBox(width: 10),
                      Text("==>"),
                      const SizedBox(width: 10),
                      ValueListenableBuilder(
                          valueListenable: controller.candles,
                          builder: (context, value, child) {
                            return Text(
                                "\$${widget.trade.isOpen ? value.last.close.toStringAsFixed(2) : widget.trade.isWin ? widget.trade.takeProfit.toStringAsFixed(2) : (!widget.trade.isWin && widget.trade.exitPrice != null) ? widget.trade.exitPrice!.toStringAsFixed(2) : widget.trade.stopLoss.toStringAsFixed(2)}");
                          }),
                      const SizedBox(width: 30),
                      ValueListenableBuilder(
                          valueListenable: controller.livePrice,
                          builder: (context, value, child) {
                            pnl.value = controller.calculatePreview(
                              controller.candles.value,
                              widget.trade.isBuy,
                              widget.trade.entry,
                              widget.trade.stopLoss,
                              widget.trade.takeProfit,
                              widget.trade.lotSize,
                              value,
                              widget.trade.isOpen
                                  ? "Open"
                                  : widget.trade.isWin
                                      ? "TP"
                                      : "SL",
                            );
                            return Text(
                              '\$${pnl.value.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: pnl.value >= 0
                                      ? Colors.green
                                      : Colors.red),
                            );
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("SL: "),
                      const SizedBox(width: 10),
                      Text(widget.trade.stopLoss.toStringAsFixed(2)),
                      const SizedBox(width: 20),
                      Text("TP: "),
                      const SizedBox(width: 10),
                      Text(widget.trade.takeProfit.toStringAsFixed(2)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Entry Time: "),
                      const SizedBox(width: 10),
                      Text(widget.trade.entryTime.toString()),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Exit Time: "),
                      const SizedBox(width: 10),
                      Text(widget.trade.exitTime.toString()),
                    ],
                  ),
                ],
              ),
            ),
            (widget.trade.isOpen)
                ? ExpansionTile(
                    title: const Text("Edit Trade"),
                    children: [
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
                        decoration: InputDecoration(
                          labelText: "Stop Loss",
                        ),
                        onChanged: (_) =>
                            controller.calculatePreview(controller.candles.value,
                                            isBuy, entry,sl, tp, lot, exitManual, result),
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
                        decoration: InputDecoration(
                          labelText: "Take Profit",
                        ),
                        onChanged: (_) =>
                            controller.calculatePreview(controller.candles.value,
                                            isBuy, entry,sl, tp, lot, exitManual, result),
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
                              onChanged: (_) =>
                                  controller.calculatePreview(controller.candles.value,
                                            isBuy, entry,sl, tp, lot, exitManual, result),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
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
                          editTrade(
                              true, isBuy, controller.candles.value.last.close);
                          slController.clear();
                          tpController.clear();
                          exitPrice.clear();
                        },
                        child: const Text("Save Trade"),
                      ),
                      const SizedBox(height: 10),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}

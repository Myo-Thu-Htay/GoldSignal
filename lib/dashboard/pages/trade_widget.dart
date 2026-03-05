// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/trade_history_provider.dart';

class AddTradeWidget extends ConsumerStatefulWidget {
  const AddTradeWidget({super.key});

  @override
  ConsumerState<AddTradeWidget> createState() => _AddTradeWidgetState();
}

class _AddTradeWidgetState extends ConsumerState<AddTradeWidget> {
  bool isBuy = true;
  final entryController = TextEditingController();
  final slController = TextEditingController();
  final tpController = TextEditingController();
  final lotController = TextEditingController();
  DateTime? selectedDate;
  DateTime? entryDate;
  DateTime? exitDate;

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate(BuildContext context,) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked == null) return;
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now().toUtc()),
      );

      if (time == null) return;
      setState(() {
        selectedDate = DateTime(
            picked.year, picked.month, picked.day, time.hour, time.minute);
      });
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Trade'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            //title: const Text("Add Manual Trade"),
            children: [
              Row(
                children: [
                  const Text("Type: "),
                  SizedBox(
                    width: 10,
                  ),
                  DropdownButton<bool>(
                    value: isBuy,
                    items: const [
                      DropdownMenuItem(value: true, child: Text("BUY")),
                      DropdownMenuItem(value: false, child: Text("SELL")),
                    ],
                    onChanged: (val) => setState(() => isBuy = val!),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                    onPressed: () => selectDate(context),
                    child: Text(
                      selectedDate == null
                          ? "Select Date & Time"
                          : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour}:${selectedDate!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ),
              TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: entryController,
                  decoration: const InputDecoration(labelText: "Entry")),
              TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: slController,
                  decoration: const InputDecoration(labelText: "Stop Loss")),
              TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: tpController,
                  decoration: const InputDecoration(labelText: "Take Profit")),
              TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: lotController,
                  decoration: const InputDecoration(labelText: "Lot Size")),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  final entry = double.tryParse(entryController.text);
                  final sl = double.tryParse(slController.text);
                  final tp = double.tryParse(tpController.text);
                  final lot = double.tryParse(lotController.text);
                  if (entry != null &&
                      sl != null &&
                      tp != null &&
                      lot != null) {
                    ref.read(tradeHistoryProvider.notifier).addManualTrade(
                          isBuy: isBuy,
                          entry: entry,
                          sl: sl,
                          tp: tp,
                          lot: lot,
                          timestamp: selectedDate ?? DateTime.now(),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Manual trade added!")),
                    );
                    entryController.clear();
                    slController.clear();
                    tpController.clear();
                    lotController.clear();
                    setState(() => selectedDate = null);
                  }
                },
                child: const Text("Add Trade"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

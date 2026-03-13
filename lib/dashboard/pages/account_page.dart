import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_strings.dart';
import '../provider/account_provider.dart';
import '../provider/controller_provider.dart';
import '../provider/setting_provider.dart';
import '../provider/trade_history_provider.dart';
import '../service/trade_calculator.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _balanceController = TextEditingController();
  final _riskController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Load saved values
    final account = ref.read(accountProvider);
    _balanceController.text = account.balance.toStringAsFixed(2);
    _riskController.text = account.riskPercent.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final settingAsync = ref.watch(settingsProvider);
    double balance = ref.watch(accountProvider).balance;
    double risk = ref.watch(accountProvider).riskPercent;
    final controller = ref.watch(controllerProvider);
    final trades = ref.watch(tradeHistoryProvider);

    return settingAsync.when(
      data: (settings) {
        return Scaffold(
          appBar: AppBar(
              title: Text(AppStrings.text('account', settings.languageCode))),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${AppStrings.text('balance', settings.languageCode)}:",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "\$${balance.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Equity: ",
                                style: TextStyle(fontSize: 16),
                              ),
                              ValueListenableBuilder(
                                  valueListenable: controller.livePrice,
                                  builder: (context, value, child) {
                                    double totalPnL =
                                        TradeCalculator.totalPnL(trades, value);
                                    double equity = controller
                                        .calculateAccBalance(balance, totalPnL);
                                    return Text(
                                      "\$${equity.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: totalPnL >= 0
                                              ? Colors.green
                                              : Colors.red),
                                    );
                                  }),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Risk: ",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "${risk.toStringAsFixed(2)}%",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ExpansionTile(
                  title: const Text("Edit Account"),
                  children: [
                    TextField(
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText:
                              "${AppStrings.text('account', settings.languageCode)} ${AppStrings.text('balance', settings.languageCode)} (\$)"),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _riskController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: "Risk % per trade"),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        balance =
                            double.tryParse(_balanceController.text) ?? 10000;
                        risk = double.tryParse(_riskController.text) ?? 1;
                        ref
                            .read(accountProvider.notifier)
                            .update(balance, risk);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Settings saved!")),
                        );
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(child: Text("Error loading settings: $error")),
      ),
    );
  }
}

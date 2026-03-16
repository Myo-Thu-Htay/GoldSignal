import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:gold_signal/core/api/binance_api_service.dart';
import 'package:gold_signal/core/api/market_repository_impl.dart';
import 'package:gold_signal/signal_engine/model/trade_signal.dart';
import 'package:gold_signal/signal_engine/services/signal_engine.dart';
import 'package:gold_signal/signal_engine/services/signal_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: 'gold_signal_channel',
      initialNotificationTitle: 'Gold Signal Service',
      initialNotificationContent: 'Analyzing market data in the background',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );
  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final prefs = await SharedPreferences.getInstance();
  double accountBalance = prefs.getDouble('account_balance') ?? 10000;
  final riskPercent = prefs.getDouble('account_risk') ?? 1;
  final engine = SignalEngine();
  final api = BinanceApiService();
  final repo = MarketRepositoryImpl(binanceApiService: api);

  Timer.periodic(const Duration(seconds: 20), (timer) async {
    // if (service is AndroidServiceInstance) {
    //   if (await service.isForegroundService()) {
    //     service.setForegroundNotificationInfo(
    //       title: 'Gold Signal',
    //       content: 'Analyzing market data...',
    //     );
    //   }
    // }
    final candles = await repo.getBinanceCandles();
    final signal = await engine.evaluate(candles, accountBalance, riskPercent);
    final validSignal =
        SignalValidator.validateSignal(signal, candles.m5.last.close);
    if (validSignal.status != SignalStatus.active) {
      // Handle non-active signal (e.g., log, notify user, etc.)
      await prefs.remove(
          'latest_signal'); // Clear stored signal if it's no longer active
      if (kDebugMode) {
        print('Signal status: ${validSignal.status}');
      }
    } else {
      service.invoke('update_signal', {
        'signal': validSignal.toJson(),
      });
    }
    // Store or update the signal in local storage
    if (validSignal.status == SignalStatus.active) {
      await prefs.setString('latest_signal', jsonEncode(validSignal.toJson()));
    } else {
      await prefs.remove('latest_signal'); // Remove expired/invalid signal
    }
  });
}

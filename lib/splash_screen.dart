import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/core/routing/app_router.dart';
import 'package:gold_signal/dashboard/provider/market_stream_provider.dart';
import 'signal_engine/provider/market_provider.dart';
import 'signal_engine/provider/signal_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();

    // Simulate some initialization work (e.g., fetching initial data, etc.)
    ref.read(selectedTimeframeProvider);
    ref.read(binanceCandlesProvider);
    ref.read(getBinanceCandles);
    ref.read(signalProvider);
    ref.read(marketStreamProvider);

    // Ensure the splash screen is shown for at least 2 seconds
    final elapsedTime = DateTime.now().difference(startTime);
    final minSplash = const Duration(seconds: 10);
    if (elapsedTime < minSplash) {
      await Future.delayed(minSplash - elapsedTime);
    }
    if (!mounted) return;
    Future.microtask(() => AppRouter.delegate.navigateTo(AppRouter.dashboard));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Image(
                  image: AssetImage('assets/goldSplashLogo.png'), height: 300, width: 300),
              SizedBox(height: 20),
              Text('Initializing...'),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

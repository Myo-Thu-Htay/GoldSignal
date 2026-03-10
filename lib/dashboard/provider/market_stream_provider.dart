import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../signal_engine/provider/market_provider.dart';
import '../service/candle_stream_service.dart';
import 'controller_provider.dart';

final marketStreamProvider = Provider<void>((ref) {
  final controller = ref.read(controllerProvider);
  final socketService = CandleStreamService();
  final tf = ref.read(selectedTimeframeProvider);
  socketService.start(tf);
  socketService.stream.listen((candle) {
    controller.addCandle(candle);
    controller.updatePrice(candle.close);
  });
});

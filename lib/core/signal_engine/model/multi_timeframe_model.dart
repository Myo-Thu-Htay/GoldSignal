import 'candle.dart';

class MultiTimeFrameModel {
  final List<Candle> h1;
  final List<Candle> m15;
  final List<Candle> m5;
  final List<Candle> h4;

  MultiTimeFrameModel({
    required this.h1,
    required this.m15,
    required this.m5,
    required this.h4
  });
}
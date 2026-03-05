import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gold_signal/signal_engine/api/binance_futures_socket.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../signal_engine/model/candle.dart';
import '../../signal_engine/services/signal_service.dart';

class TrendWidget extends StatefulWidget {
  final List<Candle> trend;
  final bool? isBuySignal;
  final bool? isHoldSignal;

  const TrendWidget(
      {super.key, required this.trend, this.isBuySignal, this.isHoldSignal});

  @override
  State<TrendWidget> createState() => _TrendWidgetState();
}

class _TrendWidgetState extends State<TrendWidget> {
  late BinanceFuturesSocketService _socketService;
  late List<Candle> _candles;
  late List<Candle> sortedTrend;
  late Candle? lastCandle;
  late double lastClose;
  final signalService = SignalService();
  late double volume;
  late List<Candle> ma10;
  late double rsiValue;
  ChartSeriesController? _seriesController;

  @override
  void initState() {
    super.initState();
    _candles = widget.trend;
    _socketService = BinanceFuturesSocketService();
    _socketService.connect(
      symbol: 'xauusdt',
      interval: '1m',
      onUpdate: _startAutoUpdate,
    );
  }

  Timer? timer;
  void _startAutoUpdate(Candle candle) {
    timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      onCandleUpdate(candle);
    });
  }

  void onCandleUpdate(Candle candle) {
    final list = [..._candles];
    if (list.isNotEmpty && list.last.time == candle.time) {
      // Show only the last 300 candles for better performance

      list[list.length - 1] = candle;
      if (list.length > 200) {
        list.removeAt(0);
        list[list.length - 1] = candle; // Update last candle
        _seriesController?.updateDataSource(
          updatedDataIndexes: [list.length - 1],
          removedDataIndexes: [0],
        );
      }
    }
    _candles = list;
  }

  @override
  void dispose() {
    _socketService.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        sortedTrend = widget.trend.length > 300
            ? widget.trend.sublist(widget.trend.length - 300)
            : widget.trend;
        lastCandle = sortedTrend.isNotEmpty ? sortedTrend.last : null;
        lastClose = lastCandle?.close ?? 0.0;
        volume = lastCandle?.volume ?? 0.0;
        ma10 = signalService.calculateMA(sortedTrend, 10);
        rsiValue = sortedTrend.isNotEmpty
            ? signalService.calculateRSI(sortedTrend)
            : 50.0;

        return Column(
          children: [
            Expanded(
              flex: 3,
              child: SfCartesianChart(
                annotations: [
                  CartesianChartAnnotation(
                    region: AnnotationRegion.chart,
                    widget: Text(
                      '                    ---\$${lastClose.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: lastCandle!.close >= lastCandle!.open
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    coordinateUnit: CoordinateUnit.point,
                    x: lastCandle!.time,
                    y: lastCandle!.close,
                  )
                ],
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.minutes,
                  dateFormat: DateFormat('dd/MM/yyyy HH:mm'),
                  majorGridLines: MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.simpleCurrency(decimalDigits: 2),
                  opposedPosition: true,
                  majorGridLines: MajorGridLines(width: 0.5),
                  plotBands: [
                    PlotBand(
                      isVisible: true,
                      start: lastClose,
                      end: lastClose,
                      borderWidth: 1,
                      dashArray: [6, 4],
                    ),
                    PlotBand(
                      isVisible: true,
                      start: lastClose + 0.5,
                      end: lastClose + 0.5,
                      borderWidth: 1,
                      dashArray: [6, 4],
                    ),
                  ],
                ),
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  zoomMode: ZoomMode.xy,
                ),
                series: <CartesianSeries<Candle, DateTime>>[
                  CandleSeries<Candle, DateTime>(
                    initialSelectedDataIndexes: [sortedTrend.length - 100],
                    onRendererCreated: (controller) {
                      _seriesController = controller;
                    },
                    animationDuration: 0,
                    dataSource: sortedTrend,
                    enableSolidCandles: true,
                    enableTooltip: true,
                    xValueMapper: (value, index) => value.time,
                    lowValueMapper: (value, index) => value.low,
                    highValueMapper: (value, index) => value.high,
                    openValueMapper: (value, index) => value.open,
                    closeValueMapper: (value, index) => value.close,
                    //width: 0.5,
                    showIndicationForSameValues: true,
                    spacing: 1,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'RSI: ${rsiValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'MA(10): ${ma10.last.close.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Vol: ${volume.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

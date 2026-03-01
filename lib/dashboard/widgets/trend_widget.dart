import 'package:flutter/material.dart';
import 'package:gold_signal/signal_engine/api/binance_futures_socket.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../signal_engine/model/candle.dart';

class TrendWidget extends StatefulWidget {
  final List<Candle> trend;
  final double supportLevel;
  final double resistanceLevel;
  final bool? isBuySignal;
  final bool? isHoldSignal;

  const TrendWidget(
      {super.key,
      required this.trend,
      required this.supportLevel,
      required this.resistanceLevel,
      this.isBuySignal,
      this.isHoldSignal});

  @override
  State<TrendWidget> createState() => _TrendWidgetState();
}

class _TrendWidgetState extends State<TrendWidget> {
  late BinanceFuturesSocketService _socketService;
  late List<Candle> _candles;

  @override
  void initState() {
    super.initState();
    _candles = widget.trend;
    _socketService = BinanceFuturesSocketService();
    _socketService.connect(
      symbol: 'xauusdt',
      interval: '1m',
      onUpdate: onCandleUpdate,
    );
  }

  void onCandleUpdate(Candle candle, bool isClosed) {
      if (isClosed) {
        setState(() {
         if (_candles.isNotEmpty && _candles.last.time == candle.time) {
            _candles[_candles.length - 1] = candle; // Update last candle
          } else {
            _candles.add(candle); // Add new candle
          }
          if (_candles.length > 200) {
            _candles.removeAt(0); // Keep only the latest 200 candles
          }
        });
      }
    if (isClosed) {
      setState(() {
        _candles.add(candle);
        if (_candles.length > 200) {
          _candles.removeAt(0); // Keep only the latest 200 candles
        }
      });
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Candle> sortedTrend = widget.trend.length > 200
        ? widget.trend.sublist(widget.trend.length - 200)
        : widget.trend; // Show only the last 50 candles for better performance
    final lastCandle = sortedTrend.isNotEmpty ? sortedTrend.last : null;
    final lastClose = lastCandle?.close ?? 0.0;
    return Padding(
      padding: const EdgeInsets.all(1),
      child: SizedBox(
        height: 300,
        child: SfCartesianChart(
          
          annotations: [
            widget.isHoldSignal == true
                ? CartesianChartAnnotation(
                    widget: Text(''),
                    coordinateUnit: CoordinateUnit.point,
                    x: lastCandle?.time,
                    y: lastCandle?.close,
                  )
                : CartesianChartAnnotation(
                    widget: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isBuySignal! ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.isBuySignal! ? 'Buy Signal' : 'Sell Signal',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    coordinateUnit: CoordinateUnit.point,
                    x: lastCandle?.time,
                    y: lastCandle?.close,
                  ),
            CartesianChartAnnotation(
              widget: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  lastClose.toStringAsFixed(2),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              coordinateUnit: CoordinateUnit.point,
              x: lastCandle?.time,
              y: lastCandle?.close,
              horizontalAlignment: ChartAlignment.far,
              verticalAlignment: ChartAlignment.near,
            )
          ],
          primaryXAxis: DateTimeAxis(
            intervalType: DateTimeIntervalType.hours,
            dateFormat: DateFormat('dd/MM/yyyy HH:mm'),
            majorGridLines: MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            // plotBands: [
            //   PlotBand(
            //     isVisible: false,
            //     start: sortedTrend.first.time,
            //     end: sortedTrend.last.time,
            //     borderColor: Colors.green,
            //     borderWidth: 2,
            //     //text: 'Support',
            //     //textStyle: TextStyle(color: Colors.green, fontSize: 12),
            //     dashArray: [5, 5],
            //   ),
            //   PlotBand(
            //     isVisible: false,
            //     start: sortedTrend.first.time,
            //     end: sortedTrend.last.time,
            //     borderColor: Colors.red,
            //     borderWidth: 2,
            //     //text: 'Resistance',
            //     //textStyle: TextStyle(color: Colors.red, fontSize: 12),
            //     dashArray: [5, 5],
            //   ),
            // ],
          ),
          primaryYAxis: NumericAxis(
            plotBands: [
              PlotBand(
                isVisible: true,
                start: lastClose,
                end: lastClose,
                //borderColor: Colors.green,
                borderWidth: 2,
                // text: 'Price',
                // textStyle: TextStyle(color: Colors.green, fontSize: 12),
                dashArray: [5, 5],
              ),
              PlotBand(
                isVisible: true,
                start: widget.supportLevel,
                end: widget.supportLevel,
                borderColor: Colors.green,
                borderWidth: 2,
                text: 'Support',
                textStyle: TextStyle(color: Colors.green, fontSize: 12),
                dashArray: [5, 5],
              ),
              PlotBand(
                isVisible: true,
                start: widget.resistanceLevel,
                end: widget.resistanceLevel,
                borderColor: Colors.red,
                borderWidth: 2,
                text: 'Resistance',
                textStyle: TextStyle(color: Colors.red, fontSize: 12),
                dashArray: [5, 5],
              ),
            ],
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePinching: true,
            enablePanning: true,
            zoomMode: ZoomMode.x,
          ),
          series: <CandleSeries<Candle, DateTime>>[
            CandleSeries<Candle, DateTime>(
              dataSource: sortedTrend,
              enableSolidCandles: true,
              enableTooltip: true,
              xValueMapper: (value, index) => value.time,
              lowValueMapper: (value, index) => value.low,
              highValueMapper: (value, index) => value.high,
              openValueMapper: (value, index) => value.open,
              closeValueMapper: (value, index) => value.close,
              width: 0.5,
              trendlines: [
                Trendline(
                  type: TrendlineType.linear,
                  color: Colors.blueAccent,
                  width: 2,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

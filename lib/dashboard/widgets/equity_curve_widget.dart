import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EquityCurveWidget extends ConsumerStatefulWidget {
  final List<double> equityCurve;

  const EquityCurveWidget({
    super.key,
    required this.equityCurve,
  });

  @override
  ConsumerState<EquityCurveWidget> createState() => _EquityCurveWidgetState();
}

class _EquityCurveWidgetState extends ConsumerState<EquityCurveWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.equityCurve.isEmpty) {
      return const Center(
        child: Text("No trades yet"),
      );
    }
    List<double> visibleEquity = widget.equityCurve.length > 20
        ? widget.equityCurve.sublist(widget.equityCurve.length - 20)
        : widget.equityCurve;
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Md(),
        intervalType: DateTimeIntervalType.minutes,
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
      ),
      series: <CartesianSeries>[
        ColumnSeries<EquityData, DateTime>(
          dataSource: equityData(visibleEquity),
          xValueMapper: (data, index) => data.time,
          yValueMapper: (data, index) => data.equity,
          pointColorMapper: (data, index) => data.color,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelAlignment: ChartDataLabelAlignment.top),
          dataLabelMapper: (data, index) =>
              "\$${data.equity.toStringAsFixed(0)}",
          width: 0.2,
          spacing: 0.1,
        )
      ],
    );
  }
}

class EquityData {
  final DateTime time;
  final double equity;
  final Color color;

  EquityData(this.time, this.equity, this.color);
}

List<EquityData> equityData(List<double> equityCurve) {
  List<EquityData> data = [];
  for (int i = 0; i < equityCurve.length; i++) {
    Color color;
    if (i == 0) {
      color = Colors.blue;
    } else {
      color = equityCurve[i] < equityCurve[i - 1] ? Colors.red : Colors.green;
    }
    data.add(EquityData(
      DateTime.now().toLocal().add(Duration(minutes: i)),
      equityCurve[i],
      color,
    ));
  }
  return data;
}

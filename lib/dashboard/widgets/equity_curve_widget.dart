import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../provider/equity_chart_provider.dart';

class EquityCurveWidget extends ConsumerWidget {
  const EquityCurveWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equityCurve = ref.watch(equityChartProvider);
    if (equityCurve.isEmpty) {
      return const Center(
        child: Text("No trades yet"),
      );
    }
    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Md(),
        intervalType: DateTimeIntervalType.days,
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        numberFormat: NumberFormat.simpleCurrency(decimalDigits: 0),
      ),
      series: <CartesianSeries>[
        ColumnSeries<EquityData, DateTime>(
          dataSource: equityCurve,
          xValueMapper: (data, index) => data.time,
          yValueMapper: (data, index) => data.equity,
          pointColorMapper: (data, index) => data.color,
          dataLabelSettings: const DataLabelSettings(
              isVisible: true, labelAlignment: ChartDataLabelAlignment.top),
          dataLabelMapper: (data, index) =>
              "\$${data.equity.toStringAsFixed(2)}",
          width: 0.2,
          spacing: 0.1,
        )
      ],
    );
  }
}

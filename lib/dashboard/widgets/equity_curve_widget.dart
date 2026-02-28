import 'package:flutter/material.dart';

class EquityCurveWidget extends StatelessWidget {
  final List<double> equityCurve;

  const EquityCurveWidget({
    super.key,
    required this.equityCurve,
  });

  @override
  Widget build(BuildContext context) {
    if (equityCurve.isEmpty) {
      return const Center(
        child: Text("No trades yet"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _EquityPainter(equityCurve),
        child: Container(),
      ),
    );
  }
}

class _EquityPainter extends CustomPainter {
  final List<double> equity;

  _EquityPainter(this.equity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final minEquity = equity.reduce((a, b) => a < b ? a : b);
    final maxEquity = equity.reduce((a, b) => a > b ? a : b);
    final range = (maxEquity - minEquity) == 0
        ? 1
        : (maxEquity - minEquity);

    final path = Path();

    for (int i = 0; i < equity.length; i++) {
      final x = i / (equity.length - 1) * size.width;
      final y = size.height -
          ((equity[i] - minEquity) / range * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
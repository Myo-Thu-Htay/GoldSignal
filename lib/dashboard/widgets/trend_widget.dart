import 'package:flutter/material.dart';

class TrendWidget extends StatelessWidget {
  final List<double> trend;

  const TrendWidget({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: _TrendPainter(trend),
        child: Container(),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> trend;

  _TrendPainter(this.trend);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final minEquity = trend.reduce((a, b) => a < b ? a : b);
    final maxEquity = trend.reduce((a, b) => a > b ? a : b);
    final range = (maxEquity - minEquity) == 0 ? 1 : (maxEquity - minEquity);

    final path = Path();

    for (int i = 0; i < trend.length; i++) {
      final x = i / (trend.length - 1) * size.width;
      final y = size.height - ((trend[i] - minEquity) / range * size.height);

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

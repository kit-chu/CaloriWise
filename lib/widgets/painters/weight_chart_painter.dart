import 'package:flutter/material.dart';

class WeightChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> weightData;

  WeightChartPainter(this.weightData);

  @override
  void paint(Canvas canvas, Size size) {
    if (weightData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Find min and max weight for scaling
    double minWeight = weightData.map((e) => e['weight'] as double).reduce((a, b) => a < b ? a : b);
    double maxWeight = weightData.map((e) => e['weight'] as double).reduce((a, b) => a > b ? a : b);

    // Add some padding to the range
    double range = maxWeight - minWeight;
    minWeight -= range * 0.1;
    maxWeight += range * 0.1;

    if (range == 0) {
      minWeight -= 1;
      maxWeight += 1;
    }

    // Draw the weight trend line
    final path = Path();
    for (int i = 0; i < weightData.length; i++) {
      final x = size.width * i / (weightData.length - 1);
      final weight = weightData[i]['weight'] as double;
      final y = size.height - (size.height * (weight - minWeight) / (maxWeight - minWeight));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw data points
      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      // Draw weight value
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${weight.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 20));
    }

    canvas.drawPath(path, paint);

    // Draw gradient fill under the line
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.withOpacity(0.3),
          Colors.blue.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

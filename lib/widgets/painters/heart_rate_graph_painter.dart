import 'package:flutter/material.dart';

class HeartRateGraphPainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final double maxY = 85; // Maximum heart rate
  final double minY = 65; // Minimum heart rate
  final int horizontalLines = 4; // จำนวนเส้นแนวนอน
  final int verticalLines = 6; // จำนวนเส้นแนวตั้ง

  HeartRateGraphPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    _drawGrid(canvas, size);

    // Draw the graph
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final linePath = Path();

    final double xStep = size.width / (points.length - 1);
    final double yRange = maxY - minY;

    // Start from the bottom-left
    path.moveTo(0, size.height);
    linePath.moveTo(0, size.height - (points[0] - minY) / yRange * size.height);

    // Create smooth curve through points
    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * xStep;
      final x2 = (i + 1) * xStep;
      final y1 = size.height - (points[i] - minY) / yRange * size.height;
      final y2 = size.height - (points[i + 1] - minY) / yRange * size.height;

      final cx1 = x1 + xStep / 3;
      final cx2 = x2 - xStep / 3;

      linePath.cubicTo(cx1, y1, cx2, y2, x2, y2);
      path.cubicTo(cx1, y1, cx2, y2, x2, y2);
    }

    // Complete the path for filling
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(linePath, linePaint);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Draw horizontal lines and BPM values
    final horizontalSpacing = size.height / horizontalLines;
    final bpmSpacing = (maxY - minY) / horizontalLines;

    for (int i = 0; i <= horizontalLines; i++) {
      final y = i * horizontalSpacing;
      final bpmValue = maxY - (i * bpmSpacing);

      // Draw line
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw BPM text
      textPaint.text = TextSpan(
        text: bpmValue.round().toString(),
        style: TextStyle(
          color: Colors.grey.withOpacity(0.6),
          fontSize: 10,
        ),
      );
      textPaint.layout();
      textPaint.paint(canvas, Offset(-textPaint.width - 4, y - textPaint.height / 2));
    }

    // Draw vertical lines and time values
    final verticalSpacing = size.width / verticalLines;
    for (int i = 0; i <= verticalLines; i++) {
      final x = i * verticalSpacing;

      // Draw line
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );

      // Draw time text (in seconds)
      if (i < verticalLines) { // ไม่แสดงเวลาที่จุดสุดท้าย
        textPaint.text = TextSpan(
          text: '${i * 5}s',
          style: TextStyle(
            color: Colors.grey.withOpacity(0.6),
            fontSize: 10,
          ),
        );
        textPaint.layout();
        textPaint.paint(
          canvas,
          Offset(x, size.height + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

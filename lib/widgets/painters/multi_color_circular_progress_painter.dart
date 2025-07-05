import 'dart:math';
import 'package:flutter/material.dart';

class MultiColorCircularProgressPainter extends CustomPainter {
  final List<Color> colors;
  final double strokeWidth;
  final double percent;

  MultiColorCircularProgressPainter({
    required this.colors,
    required this.strokeWidth,
    required this.percent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final double radius = (size.width - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: Offset(center, center), radius: radius);

    // Background circle
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.grey.withOpacity(0.2);
    canvas.drawCircle(Offset(center, center), radius, paint);

    // Progress arcs for each macro
    if (percent > 0) {
      final double startAngle = -1.5708; // Start from top (-90 degrees in radians)
      final double totalAngle = percent * 2 * pi; // Total arc length in radians
      final double segmentAngle = totalAngle / colors.length; // Split into equal segments

      // Draw segments for each macro
      for (int i = 0; i < colors.length; i++) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors[i]
          ..strokeCap = StrokeCap.round;

        final double segmentStart = startAngle + (i * segmentAngle);

        // For smooth connection between segments, we overlap them slightly
        final double overlap = 0.02;
        final double drawAngle = i < colors.length - 1
            ? segmentAngle + overlap
            : segmentAngle;

        canvas.drawArc(
          rect,
          segmentStart,
          drawAngle,
          false,
          paint,
        );
      }

      // Draw round cap at the end if not complete
      if (percent < 1.0) {
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..color = colors.last
          ..strokeCap = StrokeCap.round;

        final double endAngle = startAngle + totalAngle;
        canvas.drawArc(
          rect,
          endAngle - 0.01,
          0.02,
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

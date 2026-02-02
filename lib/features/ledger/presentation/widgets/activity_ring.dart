import 'package:flutter/material.dart';
import 'dart:math' as math;

class ActivityRing extends StatelessWidget {
  final double investedProgress;
  final double spentProgress;
  final Widget child;
  final double size;
  final double strokeWidth;

  const ActivityRing({
    super.key,
    required this.investedProgress,
    required this.spentProgress,
    required this.child,
    this.size = 40,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ActivityRingPainter(
              investedProgress: investedProgress,
              spentProgress: spentProgress,
              strokeWidth: strokeWidth,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _ActivityRingPainter extends CustomPainter {
  final double investedProgress;
  final double spentProgress;
  final double strokeWidth;

  _ActivityRingPainter({
    required this.investedProgress,
    required this.spentProgress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Draw background circle (inactive)
    final bgPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // 2. Draw Invested Progress (Black)
    if (investedProgress > 0) {
      final investedPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * investedProgress,
        false,
        investedPaint,
      );
    }

    // 3. Draw Spent Progress (Grey)
    // Starts where Invested ends
    if (spentProgress > 0) {
      final spentPaint = Paint()
        ..color = Colors.grey[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -math.pi / 2 + (2 * math.pi * investedProgress),
        2 * math.pi * spentProgress,
        false,
        spentPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityRingPainter oldDelegate) {
    return oldDelegate.investedProgress != investedProgress ||
        oldDelegate.spentProgress != spentProgress;
  }
}

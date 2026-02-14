import 'dart:math';
import 'package:flutter/material.dart';

class BatikPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final bool isDark;

  BatikPainter({
    required this.color,
    this.opacity = 0.1,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Kawung pattern (four circles forming a square)
    _drawKawungPattern(canvas, size, paint);
  }

  void _drawKawungPattern(Canvas canvas, Size size, Paint paint) {
    final spacing = 60.0;
    final radius = 20.0;

    for (double y = -radius; y < size.height + radius; y += spacing) {
      for (double x = -radius; x < size.width + radius; x += spacing) {
        // Draw the main cross pattern
        _drawKawungUnit(canvas, Offset(x, y), radius, paint);
      }
    }
  }

  void _drawKawungUnit(Canvas canvas, Offset center, double radius, Paint paint) {
    // Draw four circles in a cross pattern
    final offset = radius * 0.7;

    // Top circle
    canvas.drawCircle(
      Offset(center.dx, center.dy - offset),
      radius * 0.4,
      paint,
    );

    // Right circle
    canvas.drawCircle(
      Offset(center.dx + offset, center.dy),
      radius * 0.4,
      paint,
    );

    // Bottom circle
    canvas.drawCircle(
      Offset(center.dx, center.dy + offset),
      radius * 0.4,
      paint,
    );

    // Left circle
    canvas.drawCircle(
      Offset(center.dx - offset, center.dy),
      radius * 0.4,
      paint,
    );

    // Center ornament
    canvas.drawCircle(
      center,
      radius * 0.2,
      paint..style = PaintingStyle.fill,
    );
    paint.style = PaintingStyle.stroke;

    // Add diagonal lines for Parang effect
    final linePaint = Paint()
      ..color = color.withOpacity(opacity * 0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3),
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.3),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Widget wrapper for easy use
class BatikBackground extends StatelessWidget {
  final Widget child;
  final Color? color;
  final double opacity;
  final bool isDark;

  const BatikBackground({
    super.key,
    required this.child,
    this.color,
    this.opacity = 0.1,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final batikColor = color ?? 
        (isDark ? const Color(0xFF1565C0) : const Color(0xFF0288D1));

    return Stack(
      children: [
        CustomPaint(
          painter: BatikPainter(
            color: batikColor,
            opacity: opacity,
            isDark: isDark,
          ),
          child: Container(),
        ),
        child,
      ],
    );
  }
}

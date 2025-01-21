import 'package:flutter/material.dart';
import 'package:wolfie_sign/utils/app_colors.dart';

class HomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryColor.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    const spacing = 40.0;
    final dotRadius = 4.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        // Draw a square instead of a circle for variation
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: dotRadius * 2,
            height: dotRadius * 2,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

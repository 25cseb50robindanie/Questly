import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../core/theme/theme_manager.dart';

class QuestlyBackground extends StatelessWidget {
  final Widget child;

  const QuestlyBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager.currentTheme();

    return Container(
      decoration: BoxDecoration(
        gradient: theme.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Abstract Geometric Vector Shapes Layer
          Positioned.fill(
            child: CustomPaint(
              painter: _AbstractBackgroundPainter(accentColor: theme.primaryColor),
            ),
          ),
          // Child content layer on top
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}

class _AbstractBackgroundPainter extends CustomPainter {
  final Color? accentColor;

  _AbstractBackgroundPainter({this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 1. Soft Large Circle at Top Right
    paint.color = ColorSystem.lavender.withOpacity(0.20);
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.08),
      size.height * 0.45,
      paint,
    );

    // 2. Soft Large Circle at Bottom Left
    paint.color = ColorSystem.purple.withOpacity(0.08);
    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.92),
      size.height * 0.52,
      paint,
    );

    // 3. Diagonal Abstract Bands (various positions and thicknesses)
    final linePaint = Paint()
      ..color = ColorSystem.lavender.withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Thick Diagonal Stripe 1 (Bottom-Left toward center)
    linePaint.strokeWidth = 64;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 1.15),
      Offset(size.width * 0.65, -size.height * 0.15),
      linePaint,
    );

    // Medium Diagonal Stripe 2 (Further Right, softer opacity)
    linePaint.strokeWidth = 32;
    linePaint.color = ColorSystem.purple.withOpacity(0.06);
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 1.2),
      Offset(size.width * 0.88, -size.height * 0.1),
      linePaint,
    );

    // Fine Gold Highlight Stripe (adding splash of bright accent color)
    linePaint.strokeWidth = 8;
    linePaint.color = ColorSystem.gold.withOpacity(0.12);
    canvas.drawLine(
      Offset(size.width * 0.22, size.height * 0.9),
      Offset(size.width * 0.58, -size.height * 0.1),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

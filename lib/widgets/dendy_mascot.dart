import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';

enum DendyState {
  idle,
  thinking,
  success,
  confused,
}

class DendyMascot extends StatefulWidget {
  final DendyState state;
  final String? message;
  final double size;

  const DendyMascot({
    Key? key,
    this.state = DendyState.idle,
    this.message,
    this.size = 90.0,
  }) : super(key: key);

  @override
  _DendyMascotState createState() => _DendyMascotState();
}

class _DendyMascotState extends State<DendyMascot> with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bobAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Floating Theme-Colored Fox Mascot
              SizedBox(
                width: widget.size,
                height: widget.size + 4,
                child: Image.asset(
                  'assets/images/dendy_the_fox.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => CustomPaint(
                    painter: _DendyPainter(state: widget.state),
                  ),
                ),
              ),
              // Speech Bubble
              if (widget.message != null && widget.message!.isNotEmpty) ...[
                const SizedBox(width: 2),
                Flexible(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Speech Bubble Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ColorSystem.plum, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: ColorSystem.plum.withOpacity(0.08),
                              offset: const Offset(0, 3),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Text(
                          widget.message!,
                          style: const TextStyle(
                            color: ColorSystem.plum,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Speech Bubble Pointer
                      const Positioned(
                        left: -8,
                        top: 14,
                        child: CustomPaint(
                          painter: _SpeechTipPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DendyPainter extends CustomPainter {
  final DendyState state;

  _DendyPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.54;
    final headWidth = size.width * 0.82;
    final headHeight = size.height * 0.58;

    // Theme palette coloring for the Fox: Twilight Purple and Lavender/Cream
    final furPaint = Paint()..color = ColorSystem.purple..style = PaintingStyle.fill;
    final innerEarPaint = Paint()..color = ColorSystem.lavender..style = PaintingStyle.fill;
    final muzzlePaint = Paint()..color = const Color(0xFFFFFDF9)..style = PaintingStyle.fill;
    final blushPaint = Paint()..color = const Color(0xFFFFB5A7).withOpacity(0.7)..style = PaintingStyle.fill;
    final whiteHighlightPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final plumPaint = Paint()..color = ColorSystem.plum..style = PaintingStyle.fill;

    // 1. Shadow (flat bottom ellipse)
    final shadowPaint = Paint()..color = ColorSystem.plum.withOpacity(0.12);
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.90, size.width * 0.7, 6),
      shadowPaint,
    );

    // 2. Ears (Pointy, large triangular shapes)
    // Left Ear
    final leftEarPath = Path()
      ..moveTo(centerX - headWidth * 0.18, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX - headWidth * 0.28, centerY - headHeight * 0.75, centerX - headWidth * 0.44, centerY - headHeight * 0.92)
      ..quadraticBezierTo(centerX - headWidth * 0.43, centerY - headHeight * 0.46, centerX - headWidth * 0.40, centerY - headHeight * 0.15)
      ..close();
    canvas.drawPath(leftEarPath, furPaint);
    
    // Left Inner Ear (Lavender)
    final leftInnerEarPath = Path()
      ..moveTo(centerX - headWidth * 0.22, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX - headWidth * 0.29, centerY - headHeight * 0.68, centerX - headWidth * 0.40, centerY - headHeight * 0.82)
      ..quadraticBezierTo(centerX - headWidth * 0.39, centerY - headHeight * 0.48, centerX - headWidth * 0.36, centerY - headHeight * 0.22)
      ..close();
    canvas.drawPath(leftInnerEarPath, innerEarPaint);
    canvas.drawPath(leftEarPath, borderPaint);

    // Right Ear
    final rightEarPath = Path()
      ..moveTo(centerX + headWidth * 0.18, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX + headWidth * 0.28, centerY - headHeight * 0.75, centerX + headWidth * 0.44, centerY - headHeight * 0.92)
      ..quadraticBezierTo(centerX + headWidth * 0.43, centerY - headHeight * 0.46, centerX + headWidth * 0.40, centerY - headHeight * 0.15)
      ..close();
    canvas.drawPath(rightEarPath, furPaint);
    
    // Right Inner Ear (Lavender)
    final rightInnerEarPath = Path()
      ..moveTo(centerX + headWidth * 0.22, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX + headWidth * 0.29, centerY - headHeight * 0.68, centerX + headWidth * 0.40, centerY - headHeight * 0.82)
      ..quadraticBezierTo(centerX + headWidth * 0.39, centerY - headHeight * 0.48, centerX + headWidth * 0.36, centerY - headHeight * 0.22)
      ..close();
    canvas.drawPath(rightInnerEarPath, innerEarPaint);
    canvas.drawPath(rightEarPath, borderPaint);

    // 3. Head Body (Bezier curved wide face with cheek fur tufts pointing outwards)
    final headPath = Path()
      ..moveTo(centerX, centerY - headHeight * 0.45) // top head center
      ..quadraticBezierTo(centerX - headWidth * 0.38, centerY - headHeight * 0.45, centerX - headWidth * 0.42, centerY - headHeight * 0.1) // left forehead
      ..lineTo(centerX - headWidth * 0.52, centerY) // left tuft point
      ..lineTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1) // left tuft notch
      ..quadraticBezierTo(centerX - headWidth * 0.32, centerY + headHeight * 0.45, centerX, centerY + headHeight * 0.45) // left jaw to chin
      ..quadraticBezierTo(centerX + headWidth * 0.32, centerY + headHeight * 0.45, centerX + headWidth * 0.43, centerY + headHeight * 0.1) // right jaw to chin
      ..lineTo(centerX + headWidth * 0.52, centerY) // right tuft point
      ..lineTo(centerX + headWidth * 0.42, centerY - headHeight * 0.1) // right tuft notch
      ..quadraticBezierTo(centerX + headWidth * 0.38, centerY - headHeight * 0.45, centerX, centerY - headHeight * 0.45) // right forehead
      ..close();
    canvas.drawPath(headPath, furPaint);

    // 4. White Muzzle / Lower Face Plate (horizontal waves matching image)
    final whiteMuzzlePath = Path()
      ..moveTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1) // start at left notch
      ..quadraticBezierTo(centerX - headWidth * 0.22, centerY - headHeight * 0.05, centerX, centerY + headHeight * 0.08) // wave up and down to center
      ..quadraticBezierTo(centerX + headWidth * 0.22, centerY - headHeight * 0.05, centerX + headWidth * 0.43, centerY + headHeight * 0.1) // wave to right notch
      ..quadraticBezierTo(centerX + headWidth * 0.32, centerY + headHeight * 0.45, centerX, centerY + headHeight * 0.45) // right jaw
      ..quadraticBezierTo(centerX - headWidth * 0.32, centerY + headHeight * 0.45, centerX - headWidth * 0.43, centerY + headHeight * 0.1) // left jaw
      ..close();
    canvas.drawPath(whiteMuzzlePath, muzzlePaint);
    
    // Draw boundary line between white face and purple face
    final muzzleBorderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    
    final wavePath = Path()
      ..moveTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX - headWidth * 0.22, centerY - headHeight * 0.05, centerX, centerY + headHeight * 0.08)
      ..quadraticBezierTo(centerX + headWidth * 0.22, centerY - headHeight * 0.05, centerX + headWidth * 0.43, centerY + headHeight * 0.1);
    canvas.drawPath(wavePath, muzzleBorderPaint);
    canvas.drawPath(headPath, borderPaint);

    // 5. Forehead Glossy Shine Highlight (on top right forehead)
    canvas.save();
    canvas.translate(centerX + headWidth * 0.14, centerY - headHeight * 0.32);
    canvas.rotate(-math.pi / 7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: headWidth * 0.14, height: headHeight * 0.07),
      whiteHighlightPaint..color = Colors.white.withOpacity(0.48),
    );
    canvas.restore();

    // 6. Blush Cheeks (Rosy gold/pink ovals on cheeks)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - headWidth * 0.30, centerY + headHeight * 0.14), width: headWidth * 0.14, height: headHeight * 0.06),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + headWidth * 0.30, centerY + headHeight * 0.14), width: headWidth * 0.14, height: headHeight * 0.06),
      blushPaint,
    );

    // 7. Eyes (Huge, round, shiny black eyes with white circular highlight sparkles)
    final double eyeY = centerY - headHeight * 0.02;
    final double leftEyeX = centerX - headWidth * 0.22;
    final double rightEyeX = centerX + headWidth * 0.22;
    final double eyeRadius = headWidth * 0.105;

    switch (state) {
      case DendyState.idle:
      case DendyState.thinking:
        // Shiny black ovals/circles
        canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, plumPaint);
        canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, plumPaint);
        // Double sparkles
        canvas.drawCircle(Offset(leftEyeX - 2.5, eyeY - 2.5), 2.2, whiteHighlightPaint..color = Colors.white);
        canvas.drawCircle(Offset(leftEyeX + 2.5, eyeY + 2.5), 1.0, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX - 2.5, eyeY - 2.5), 2.2, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX + 2.5, eyeY + 2.5), 1.0, whiteHighlightPaint);

        // Gold question mark if thinking
        if (state == DendyState.thinking) {
          final qPaint = Paint()
            ..color = ColorSystem.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round;
          final qPath = Path()
            ..moveTo(centerX + headWidth * 0.44, centerY - headHeight * 0.6)
            ..quadraticBezierTo(centerX + headWidth * 0.52, centerY - headHeight * 0.75, centerX + headWidth * 0.48, centerY - headHeight * 0.85)
            ..quadraticBezierTo(centerX + headWidth * 0.38, centerY - headHeight * 0.9, centerX + headWidth * 0.34, centerY - headHeight * 0.8)
            ..moveTo(centerX + headWidth * 0.42, centerY - headHeight * 0.68)
            ..lineTo(centerX + headWidth * 0.42, centerY - headHeight * 0.62);
          canvas.drawPath(qPath, qPaint);
          canvas.drawCircle(Offset(centerX + headWidth * 0.42, centerY - headHeight * 0.56), 1.2, Paint()..color = ColorSystem.gold);
        }
        break;

      case DendyState.success:
        // Happy curved line arches
        final successPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round;
        final pathL = Path()
          ..moveTo(leftEyeX - 5.5, eyeY + 2)
          ..quadraticBezierTo(leftEyeX, eyeY - 3.5, leftEyeX + 5.5, eyeY + 2);
        final pathR = Path()
          ..moveTo(rightEyeX - 5.5, eyeY + 2)
          ..quadraticBezierTo(rightEyeX, eyeY - 3.5, rightEyeX + 5.5, eyeY + 2);
        canvas.drawPath(pathL, successPaint);
        canvas.drawPath(pathR, successPaint);
        break;

      case DendyState.confused:
        // Unequal crosses
        final dizzyPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(leftEyeX - 4.5, eyeY - 4.5), Offset(leftEyeX + 4.5, eyeY + 4.5), dizzyPaint);
        canvas.drawLine(Offset(leftEyeX + 4.5, eyeY - 4.5), Offset(leftEyeX - 4.5, eyeY + 4.5), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX - 4.5, eyeY - 4.5), Offset(rightEyeX + 4.5, eyeY + 4.5), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX + 4.5, eyeY - 4.5), Offset(rightEyeX - 4.5, eyeY + 4.5), dizzyPaint);
        break;
    }

    // 8. Dark Nose (cute oval shape placed right on the center wave)
    final double noseX = centerX;
    final double noseY = centerY + headHeight * 0.08;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(noseX, noseY), width: 10, height: 7.5),
      plumPaint,
    );

    // 9. Happy Chibi Smile Mouth
    final mouthPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final double mouthY = noseY + 3.2;

    if (state == DendyState.success) {
      final mouthPath = Path()
        ..moveTo(centerX - 6.5, mouthY)
        ..quadraticBezierTo(centerX, mouthY + 8.0, centerX + 6.5, mouthY)
        ..close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF9E9E)..style = PaintingStyle.fill);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Classic cute double-loop w shape
      final pathL = Path()
        ..moveTo(centerX - 5.0, mouthY + 1.2)
        ..quadraticBezierTo(centerX - 2.5, mouthY + 4.0, centerX, mouthY + 0.8);
      final pathR = Path()
        ..moveTo(centerX, mouthY + 0.8)
        ..quadraticBezierTo(centerX + 2.5, mouthY + 4.0, centerX + 5.0, mouthY + 1.2);
      canvas.drawPath(pathL, mouthPaint);
      canvas.drawPath(pathR, mouthPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SpeechTipPainter extends CustomPainter {
  const _SpeechTipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final plumPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.fill;
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Triangle pointing to the left
    final tipPath = Path()
      ..moveTo(0, 8)
      ..lineTo(8, 0)
      ..lineTo(8, 16)
      ..close();

    canvas.drawPath(tipPath, plumPaint);

    final innerPath = Path()
      ..moveTo(1.8, 8)
      ..lineTo(8, 2.5)
      ..lineTo(8, 13.5)
      ..close();
    canvas.drawPath(innerPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

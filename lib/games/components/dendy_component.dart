import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/theme/color_system.dart';
import '../../widgets/dendy_mascot.dart'; // import the enum DendyState

class DendyGameComponent extends PositionComponent {
  DendyState state = DendyState.idle;
  late double initialY;
  double _time = 0.0;

  DendyGameComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    initialY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Smooth bobbing motion
    _time += dt * 3.5;
    position.y = initialY + math.sin(_time) * 4.0;
  }

  @override
  void render(Canvas canvas) {
    final centerX = size.x / 2;
    final centerY = size.y * 0.54;
    final headWidth = size.x * 0.82;
    final headHeight = size.y * 0.58;

    // Theme palette coloring for the Fox: Twilight Purple and Lavender/Cream
    final furPaint = Paint()..color = ColorSystem.purple..style = PaintingStyle.fill;
    final innerEarPaint = Paint()..color = ColorSystem.lavender..style = PaintingStyle.fill;
    final muzzlePaint = Paint()..color = const Color(0xFFFFFDF9)..style = PaintingStyle.fill;
    final blushPaint = Paint()..color = const Color(0xFFFFB5A7).withOpacity(0.7)..style = PaintingStyle.fill;
    final whiteHighlightPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final plumPaint = Paint()..color = ColorSystem.plum..style = PaintingStyle.fill;

    // 1. Shadow
    final shadowPaint = Paint()..color = ColorSystem.plum.withOpacity(0.12);
    canvas.drawOval(
      Rect.fromLTWH(size.x * 0.15, size.y * 0.90, size.x * 0.7, 5),
      shadowPaint,
    );

    // 2. Ears
    // Left Ear
    final leftEarPath = Path()
      ..moveTo(centerX - headWidth * 0.18, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX - headWidth * 0.28, centerY - headHeight * 0.75, centerX - headWidth * 0.44, centerY - headHeight * 0.92)
      ..quadraticBezierTo(centerX - headWidth * 0.43, centerY - headHeight * 0.46, centerX - headWidth * 0.40, centerY - headHeight * 0.15)
      ..close();
    canvas.drawPath(leftEarPath, furPaint);
    
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
    
    final rightInnerEarPath = Path()
      ..moveTo(centerX + headWidth * 0.22, centerY - headHeight * 0.42)
      ..quadraticBezierTo(centerX + headWidth * 0.29, centerY - headHeight * 0.68, centerX + headWidth * 0.40, centerY - headHeight * 0.82)
      ..quadraticBezierTo(centerX + headWidth * 0.39, centerY - headHeight * 0.48, centerX + headWidth * 0.36, centerY - headHeight * 0.22)
      ..close();
    canvas.drawPath(rightInnerEarPath, innerEarPaint);
    canvas.drawPath(rightEarPath, borderPaint);

    // 3. Head Body (Bezier tufts)
    final headPath = Path()
      ..moveTo(centerX, centerY - headHeight * 0.45)
      ..quadraticBezierTo(centerX - headWidth * 0.38, centerY - headHeight * 0.45, centerX - headWidth * 0.42, centerY - headHeight * 0.1)
      ..lineTo(centerX - headWidth * 0.52, centerY)
      ..lineTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX - headWidth * 0.32, centerY + headHeight * 0.45, centerX, centerY + headHeight * 0.45)
      ..quadraticBezierTo(centerX + headWidth * 0.32, centerY + headHeight * 0.45, centerX + headWidth * 0.43, centerY + headHeight * 0.1)
      ..lineTo(centerX + headWidth * 0.52, centerY)
      ..lineTo(centerX + headWidth * 0.42, centerY - headHeight * 0.1)
      ..quadraticBezierTo(centerX + headWidth * 0.38, centerY - headHeight * 0.45, centerX, centerY - headHeight * 0.45)
      ..close();
    canvas.drawPath(headPath, furPaint);

    // 4. White Muzzle
    final whiteMuzzlePath = Path()
      ..moveTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX - headWidth * 0.22, centerY - headHeight * 0.05, centerX, centerY + headHeight * 0.08)
      ..quadraticBezierTo(centerX + headWidth * 0.22, centerY - headHeight * 0.05, centerX + headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX + headWidth * 0.32, centerY + headHeight * 0.45, centerX, centerY + headHeight * 0.45)
      ..quadraticBezierTo(centerX - headWidth * 0.32, centerY + headHeight * 0.45, centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..close();
    canvas.drawPath(whiteMuzzlePath, muzzlePaint);
    
    final muzzleBorderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    
    final wavePath = Path()
      ..moveTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX - headWidth * 0.22, centerY - headHeight * 0.05, centerX, centerY + headHeight * 0.08)
      ..quadraticBezierTo(centerX + headWidth * 0.22, centerY - headHeight * 0.05, centerX + headWidth * 0.43, centerY + headHeight * 0.1);
    canvas.drawPath(wavePath, muzzleBorderPaint);
    canvas.drawPath(headPath, borderPaint);

    // 5. Forehead Glossy Shine
    canvas.save();
    canvas.translate(centerX + headWidth * 0.14, centerY - headHeight * 0.32);
    canvas.rotate(-math.pi / 7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: headWidth * 0.14, height: headHeight * 0.07),
      whiteHighlightPaint..color = Colors.white.withOpacity(0.48),
    );
    canvas.restore();

    // 6. Blush Cheeks
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX - headWidth * 0.30, centerY + headHeight * 0.14), width: headWidth * 0.14, height: headHeight * 0.06),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(centerX + headWidth * 0.30, centerY + headHeight * 0.14), width: headWidth * 0.14, height: headHeight * 0.06),
      blushPaint,
    );

    // 7. Eyes
    final double eyeY = centerY - headHeight * 0.02;
    final double leftEyeX = centerX - headWidth * 0.22;
    final double rightEyeX = centerX + headWidth * 0.22;
    final double eyeRadius = headWidth * 0.105;

    switch (state) {
      case DendyState.idle:
      case DendyState.thinking:
        canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, plumPaint);
        canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, plumPaint);
        canvas.drawCircle(Offset(leftEyeX - 2.0, eyeY - 2.0), 1.8, whiteHighlightPaint..color = Colors.white);
        canvas.drawCircle(Offset(leftEyeX + 2.0, eyeY + 2.0), 0.7, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX - 2.0, eyeY - 2.0), 1.8, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX + 2.0, eyeY + 2.0), 0.7, whiteHighlightPaint);

        if (state == DendyState.thinking) {
          final qPaint = Paint()
            ..color = ColorSystem.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;
          final qPath = Path()
            ..moveTo(centerX + headWidth * 0.44, centerY - headHeight * 0.6)
            ..quadraticBezierTo(centerX + headWidth * 0.52, centerY - headHeight * 0.75, centerX + headWidth * 0.48, centerY - headHeight * 0.85)
            ..quadraticBezierTo(centerX + headWidth * 0.38, centerY - headHeight * 0.9, centerX + headWidth * 0.34, centerY - headHeight * 0.8)
            ..moveTo(centerX + headWidth * 0.42, centerY - headHeight * 0.68)
            ..lineTo(centerX + headWidth * 0.42, centerY - headHeight * 0.62);
          canvas.drawPath(qPath, qPaint);
          canvas.drawCircle(Offset(centerX + headWidth * 0.42, centerY - headHeight * 0.56), 1.0, Paint()..color = ColorSystem.gold);
        }
        break;

      case DendyState.success:
        final successPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;
        final pathL = Path()
          ..moveTo(leftEyeX - 5.0, eyeY + 1.8)
          ..quadraticBezierTo(leftEyeX, eyeY - 3.0, leftEyeX + 5.0, eyeY + 1.8);
        final pathR = Path()
          ..moveTo(rightEyeX - 5.0, eyeY + 1.8)
          ..quadraticBezierTo(rightEyeX, eyeY - 3.0, rightEyeX + 5.0, eyeY + 1.8);
        canvas.drawPath(pathL, successPaint);
        canvas.drawPath(pathR, successPaint);
        break;

      case DendyState.confused:
        final dizzyPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(leftEyeX - 4.0, eyeY - 4.0), Offset(leftEyeX + 4.0, eyeY + 4.0), dizzyPaint);
        canvas.drawLine(Offset(leftEyeX + 4.0, eyeY - 4.0), Offset(leftEyeX - 4.0, eyeY + 4.0), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX - 4.0, eyeY - 4.0), Offset(rightEyeX + 4.0, eyeY + 4.0), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX + 4.0, eyeY - 4.0), Offset(rightEyeX - 4.0, eyeY + 4.0), dizzyPaint);
        break;
    }

    // 8. Dark Nose
    final double noseX = centerX;
    final double noseY = centerY + headHeight * 0.08;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(noseX, noseY), width: 9.0, height: 6.8),
      plumPaint,
    );

    // 9. Smile Mouth
    final mouthPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double mouthY = noseY + 3.0;

    if (state == DendyState.success) {
      final mouthPath = Path()
        ..moveTo(centerX - 5.5, mouthY)
        ..quadraticBezierTo(centerX, mouthY + 7.0, centerX + 5.5, mouthY)
        ..close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF9E9E)..style = PaintingStyle.fill);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      final pathL = Path()
        ..moveTo(centerX - 4.5, mouthY + 1.0)
        ..quadraticBezierTo(centerX - 2.2, mouthY + 3.5, centerX, mouthY + 0.6);
      final pathR = Path()
        ..moveTo(centerX, mouthY + 0.6)
        ..quadraticBezierTo(centerX + 2.2, mouthY + 3.5, centerX + 4.5, mouthY + 1.0);
      canvas.drawPath(pathL, mouthPaint);
      canvas.drawPath(pathR, mouthPaint);
    }
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import 'dendy_speak_button.dart';
import 'dendy_chat_panel.dart';
import '../services/sound_service.dart';

enum DendyState {
  idle,
  thinking,
  success,
  confused,
}

enum DendyMood {
  happy,
  explaining,
  thinking,
  idle,
  success,
  confused,
}

class DendyMascot extends StatefulWidget {
  final DendyState state;
  final DendyMood? mood;
  final String? message;
  final double size;
  final String? skinId;
  final VoidCallback? onTap;
  final bool enableChatShortcut;

  const DendyMascot({
    Key? key,
    this.state = DendyState.idle,
    this.mood,
    this.message,
    this.size = 90.0,
    this.skinId,
    this.onTap,
    this.enableChatShortcut = true,
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

  DendyState get _effectiveState {
    if (widget.mood != null) {
      switch (widget.mood!) {
        case DendyMood.thinking:
        case DendyMood.explaining:
          return DendyState.thinking;
        case DendyMood.happy:
        case DendyMood.success:
          return DendyState.success;
        case DendyMood.confused:
          return DendyState.confused;
        case DendyMood.idle:
        default:
          return DendyState.idle;
      }
    }
    return widget.state;
  }

  @override
  Widget build(BuildContext context) {
    String effectiveSkin = widget.skinId ?? 'dendy_classic';
    if (widget.skinId == null) {
      try {
        final id = Locator.studentRepository.getCurrentStudent()?.equippedDendySkinId;
        if (id != null && id.isNotEmpty) {
          effectiveSkin = id;
        }
      } catch (_) {}
    }

    return AnimatedBuilder(
      animation: _bobAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Floating Theme-Colored Fox Mascot (Tap to open Ask Dendy)
              MouseRegion(
                cursor: (widget.onTap != null || widget.enableChatShortcut)
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!();
                    } else if (widget.enableChatShortcut) {
                      DendyChatPanel.open(context);
                    }
                  },
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: _DendyPainter(
                        state: _effectiveState,
                        skinId: effectiveSkin,
                      ),
                    ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                widget.message!,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  color: ColorSystem.plum,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            DendySpeakButton(
                              textToSpeak: widget.message!,
                              size: 24,
                            ),
                          ],
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
  final String skinId;

  _DendyPainter({
    required this.state,
    this.skinId = 'dendy_classic',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.52;
    final headWidth = size.width * 0.82;
    final headHeight = headWidth * 0.72;
    final strokeW = (headWidth * 0.034).clamp(1.4, 3.2);

    // Theme palette coloring for the Fox: Twilight Purple and Lavender/Cream
    final furPaint = Paint()..color = ColorSystem.purple..style = PaintingStyle.fill;
    final innerEarPaint = Paint()..color = ColorSystem.lavender..style = PaintingStyle.fill;
    final muzzlePaint = Paint()..color = const Color(0xFFFFFDF9)..style = PaintingStyle.fill;
    final blushPaint = Paint()..color = const Color(0xFFFFB5A7).withOpacity(0.7)..style = PaintingStyle.fill;
    final whiteHighlightPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final plumPaint = Paint()..color = ColorSystem.plum..style = PaintingStyle.fill;

    // 1. Shadow (flat bottom ellipse)
    final shadowPaint = Paint()..color = ColorSystem.plum.withOpacity(0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, centerY + headHeight * 0.56),
        width: headWidth * 0.78,
        height: headHeight * 0.12,
      ),
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
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    
    final muzzleBoundaryPath = Path()
      ..moveTo(centerX - headWidth * 0.43, centerY + headHeight * 0.1)
      ..quadraticBezierTo(centerX - headWidth * 0.22, centerY - headHeight * 0.05, centerX, centerY + headHeight * 0.08)
      ..quadraticBezierTo(centerX + headWidth * 0.22, centerY - headHeight * 0.05, centerX + headWidth * 0.43, centerY + headHeight * 0.1);
    canvas.drawPath(muzzleBoundaryPath, muzzleBorderPaint);

    canvas.drawPath(headPath, borderPaint);

    // 5. White Glossy Forehead Highlight
    canvas.save();
    canvas.translate(centerX + headWidth * 0.15, centerY - headHeight * 0.28);
    canvas.rotate(-math.pi / 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: headWidth * 0.14,
        height: headHeight * 0.08,
      ),
      whiteHighlightPaint..color = Colors.white.withOpacity(0.55),
    );
    canvas.restore();

    // 6. Blush Cheeks (Rosy peach ovals on cheek fur)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX - headWidth * 0.35, centerY + headHeight * 0.14),
        width: headWidth * 0.14,
        height: headHeight * 0.08,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX + headWidth * 0.35, centerY + headHeight * 0.14),
        width: headWidth * 0.14,
        height: headHeight * 0.08,
      ),
      blushPaint,
    );

    // 7. Cute Black Button Nose
    final double noseY = centerY + headHeight * 0.12;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, noseY),
        width: headWidth * 0.10,
        height: headHeight * 0.065,
      ),
      plumPaint,
    );
    // Nose highlight speck
    canvas.drawCircle(
      Offset(centerX - headWidth * 0.02, noseY - headHeight * 0.015),
      headWidth * 0.018,
      whiteHighlightPaint..color = Colors.white.withOpacity(0.85),
    );

    // 8. Eyes & Expression
    final double eyeY = centerY - headHeight * 0.02;
    final double leftEyeX = centerX - headWidth * 0.20;
    final double rightEyeX = centerX + headWidth * 0.20;
    final double eyeRadius = headWidth * 0.085;

    switch (state) {
      case DendyState.idle:
      case DendyState.thinking:
        // Shiny black ovals/circles
        canvas.drawCircle(Offset(leftEyeX, eyeY), eyeRadius, plumPaint);
        canvas.drawCircle(Offset(rightEyeX, eyeY), eyeRadius, plumPaint);
        // Double sparkles
        final sparkleL = (eyeRadius * 0.38).clamp(1.5, 4.0);
        final sparkleS = (eyeRadius * 0.2).clamp(0.8, 2.2);
        canvas.drawCircle(Offset(leftEyeX - eyeRadius * 0.3, eyeY - eyeRadius * 0.3), sparkleL, whiteHighlightPaint..color = Colors.white);
        canvas.drawCircle(Offset(leftEyeX + eyeRadius * 0.3, eyeY + eyeRadius * 0.3), sparkleS, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX - eyeRadius * 0.3, eyeY - eyeRadius * 0.3), sparkleL, whiteHighlightPaint);
        canvas.drawCircle(Offset(rightEyeX + eyeRadius * 0.3, eyeY + eyeRadius * 0.3), sparkleS, whiteHighlightPaint);

        // Gold question mark if thinking
        if (state == DendyState.thinking) {
          final qPaint = Paint()
            ..color = ColorSystem.gold
            ..style = PaintingStyle.stroke
            ..strokeWidth = (strokeW * 1.1).clamp(1.8, 3.5)
            ..strokeCap = StrokeCap.round;
          final qPath = Path()
            ..moveTo(centerX + headWidth * 0.44, centerY - headHeight * 0.6)
            ..quadraticBezierTo(centerX + headWidth * 0.52, centerY - headHeight * 0.75, centerX + headWidth * 0.48, centerY - headHeight * 0.85)
            ..quadraticBezierTo(centerX + headWidth * 0.38, centerY - headHeight * 0.9, centerX + headWidth * 0.34, centerY - headHeight * 0.8)
            ..moveTo(centerX + headWidth * 0.42, centerY - headHeight * 0.68)
            ..lineTo(centerX + headWidth * 0.42, centerY - headHeight * 0.62);
          canvas.drawPath(qPath, qPaint);
          canvas.drawCircle(Offset(centerX + headWidth * 0.42, centerY - headHeight * 0.56), strokeW * 0.6, Paint()..color = ColorSystem.gold);
        }
        break;

      case DendyState.success:
        // Happy curved line arches
        final successPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = (strokeW * 1.3).clamp(2.0, 4.0)
          ..strokeCap = StrokeCap.round;
        final archW = eyeRadius * 0.85;
        final pathL = Path()
          ..moveTo(leftEyeX - archW, eyeY + eyeRadius * 0.3)
          ..quadraticBezierTo(leftEyeX, eyeY - eyeRadius * 0.5, leftEyeX + archW, eyeY + eyeRadius * 0.3);
        final pathR = Path()
          ..moveTo(rightEyeX - archW, eyeY + eyeRadius * 0.3)
          ..quadraticBezierTo(rightEyeX, eyeY - eyeRadius * 0.5, rightEyeX + archW, eyeY + eyeRadius * 0.3);
        canvas.drawPath(pathL, successPaint);
        canvas.drawPath(pathR, successPaint);
        break;

      case DendyState.confused:
        // Unequal crosses
        final dizzyPaint = Paint()
          ..color = ColorSystem.plum
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW
          ..strokeCap = StrokeCap.round;
        final dOff = eyeRadius * 0.65;
        canvas.drawLine(Offset(leftEyeX - dOff, eyeY - dOff), Offset(leftEyeX + dOff, eyeY + dOff), dizzyPaint);
        canvas.drawLine(Offset(leftEyeX + dOff, eyeY - dOff), Offset(leftEyeX - dOff, eyeY + dOff), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX - dOff, eyeY - dOff), Offset(rightEyeX + dOff, eyeY + dOff), dizzyPaint);
        canvas.drawLine(Offset(rightEyeX + dOff, eyeY - dOff), Offset(rightEyeX - dOff, eyeY + dOff), dizzyPaint);
        break;
    }

    // 9. Happy Chibi Smile Mouth
    final mouthPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final double mouthY = noseY + headHeight * 0.06;

    if (state == DendyState.success) {
      final mouthPath = Path()
        ..moveTo(centerX - headWidth * 0.09, mouthY)
        ..quadraticBezierTo(centerX, mouthY + headHeight * 0.16, centerX + headWidth * 0.09, mouthY)
        ..close();
      canvas.drawPath(mouthPath, Paint()..color = const Color(0xFFFF9E9E)..style = PaintingStyle.fill);
      canvas.drawPath(mouthPath, mouthPaint);
    } else {
      // Classic cute double-loop w shape
      final pathL = Path()
        ..moveTo(centerX - headWidth * 0.07, mouthY + headHeight * 0.02)
        ..quadraticBezierTo(centerX - headWidth * 0.035, mouthY + headHeight * 0.08, centerX, mouthY + headHeight * 0.015);
      final pathR = Path()
        ..moveTo(centerX, mouthY + headHeight * 0.015)
        ..quadraticBezierTo(centerX + headWidth * 0.035, mouthY + headHeight * 0.08, centerX + headWidth * 0.07, mouthY + headHeight * 0.02);
      canvas.drawPath(pathL, mouthPaint);
      canvas.drawPath(pathR, mouthPaint);
    }

    // 10. Cosmetic Skin Accessories
    _drawSkinAccessories(canvas, centerX, centerY, headWidth, headHeight, strokeW);
  }

  void _drawSkinAccessories(Canvas canvas, double cx, double cy, double hw, double hh, double strokeW) {
    final plumBorder = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    switch (skinId) {
      case 'dendy_explorer':
        // Explorer Pith Safari Hat on head
        final hatPath = Path()
          ..moveTo(cx - hw * 0.38, cy - hh * 0.38)
          ..quadraticBezierTo(cx, cy - hh * 0.44, cx + hw * 0.38, cy - hh * 0.38)
          ..lineTo(cx + hw * 0.32, cy - hh * 0.58)
          ..quadraticBezierTo(cx, cy - hh * 0.72, cx - hw * 0.32, cy - hh * 0.58)
          ..close();
        canvas.drawPath(hatPath, Paint()..color = const Color(0xFFD4A373));
        // Leather band
        final bandPath = Path()
          ..moveTo(cx - hw * 0.35, cy - hh * 0.42)
          ..quadraticBezierTo(cx, cy - hh * 0.46, cx + hw * 0.35, cy - hh * 0.42)
          ..lineTo(cx + hw * 0.34, cy - hh * 0.47)
          ..quadraticBezierTo(cx, cy - hh * 0.51, cx - hw * 0.34, cy - hh * 0.47)
          ..close();
        canvas.drawPath(bandPath, Paint()..color = const Color(0xFF7F4F24));
        canvas.drawPath(hatPath, plumBorder);
        // Golden compass badge
        canvas.drawCircle(Offset(cx, cy - hh * 0.52), hw * 0.05, Paint()..color = const Color(0xFFF59E0B));
        canvas.drawCircle(Offset(cx, cy - hh * 0.52), hw * 0.02, Paint()..color = Colors.white);
        break;

      case 'dendy_scientist':
        // Cyan science safety goggles resting across forehead
        final goggleRectL = Rect.fromCenter(center: Offset(cx - hw * 0.18, cy - hh * 0.32), width: hw * 0.24, height: hh * 0.22);
        final goggleRectR = Rect.fromCenter(center: Offset(cx + hw * 0.18, cy - hh * 0.32), width: hw * 0.24, height: hh * 0.22);
        final lensPaint = Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.85);
        canvas.drawOval(goggleRectL, lensPaint);
        canvas.drawOval(goggleRectR, lensPaint);
        canvas.drawOval(goggleRectL, plumBorder);
        canvas.drawOval(goggleRectR, plumBorder);
        // Bridge strap
        canvas.drawLine(Offset(cx - hw * 0.06, cy - hh * 0.32), Offset(cx + hw * 0.06, cy - hh * 0.32), plumBorder);
        // Mini beaker icon badge
        canvas.drawCircle(Offset(cx + hw * 0.32, cy + hh * 0.3), hw * 0.06, Paint()..color = const Color(0xFF10B981));
        break;

      case 'dendy_space':
        // Cosmic Star Antenna and floating stardust aura
        canvas.drawLine(Offset(cx, cy - hh * 0.44), Offset(cx, cy - hh * 0.72), plumBorder);
        canvas.drawCircle(Offset(cx, cy - hh * 0.75), hw * 0.07, Paint()..color = const Color(0xFF06B6D4));
        canvas.drawCircle(Offset(cx, cy - hh * 0.75), hw * 0.03, Paint()..color = Colors.white);
        // Floating sparkles
        final sparklePaint = Paint()..color = const Color(0xFFFBBF24);
        canvas.drawCircle(Offset(cx - hw * 0.42, cy - hh * 0.4), hw * 0.03, sparklePaint);
        canvas.drawCircle(Offset(cx + hw * 0.42, cy - hh * 0.4), hw * 0.03, sparklePaint);
        break;

      case 'dendy_astronaut':
        // Space Bubble Halo Visor
        final domePaint = Paint()
          ..color = const Color(0xFF0284C7).withValues(alpha: 0.18)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(cx, cy - hh * 0.05), hw * 0.58, domePaint);
        final domeRim = Paint()
          ..color = const Color(0xFF38BDF8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW * 1.2;
        canvas.drawCircle(Offset(cx, cy - hh * 0.05), hw * 0.58, domeRim);
        // Star patch
        canvas.drawCircle(Offset(cx - hw * 0.34, cy + hh * 0.34), hw * 0.05, Paint()..color = const Color(0xFFF59E0B));
        break;

      case 'dendy_wizard':
        // Pointy Magic Wizard Hat with Crescent Moon
        final hatPath = Path()
          ..moveTo(cx - hw * 0.42, cy - hh * 0.36)
          ..quadraticBezierTo(cx, cy - hh * 0.42, cx + hw * 0.42, cy - hh * 0.36)
          ..quadraticBezierTo(cx + hw * 0.1, cy - hh * 0.8, cx + hw * 0.15, cy - hh * 0.95)
          ..quadraticBezierTo(cx - hw * 0.1, cy - hh * 0.7, cx - hw * 0.42, cy - hh * 0.36)
          ..close();
        canvas.drawPath(hatPath, Paint()..color = const Color(0xFF312E81));
        canvas.drawPath(hatPath, plumBorder);
        // Gold Crescent Moon on Hat
        canvas.drawCircle(Offset(cx - hw * 0.04, cy - hh * 0.55), hw * 0.06, Paint()..color = const Color(0xFFFBBF24));
        canvas.drawCircle(Offset(cx - hw * 0.02, cy - hh * 0.56), hw * 0.048, Paint()..color = const Color(0xFF312E81));
        break;

      default:
        // Classic Dendy — clean signature appearance
        break;
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

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../models/shop_item.dart';

class AvatarBadge extends StatelessWidget {
  final String avatarId;
  final double size;
  final bool showRarityBorder;
  final bool isEquipped;

  const AvatarBadge({
    Key? key,
    required this.avatarId,
    this.size = 56.0,
    this.showRarityBorder = true,
    this.isEquipped = false,
  }) : super(key: key);

  ItemRarity get rarity {
    final item = ShopCatalog.getItemById(avatarId);
    return item?.rarity ?? ItemRarity.common;
  }

  Color get rarityColor {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF64748B); // Slate Silver
      case ItemRarity.rare:
        return const Color(0xFF3B82F6); // Celestial Blue
      case ItemRarity.epic:
        return const Color(0xFF8B5CF6); // Royal Purple
      case ItemRarity.legendary:
        return const Color(0xFFF59E0B); // Radiant Gold
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanId = avatarId.toLowerCase().replaceAll('avatar_', '');

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: showRarityBorder
            ? Border.all(
                color: isEquipped ? ColorSystem.green : rarityColor,
                width: size > 60 ? 3.0 : 2.0,
              )
            : Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: (isEquipped ? ColorSystem.green : rarityColor).withValues(alpha: 0.25),
            blurRadius: isEquipped ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          size: Size(size, size),
          painter: _AvatarPainter(avatarKey: cleanId),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  final String avatarKey;

  _AvatarPainter({required this.avatarKey});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    switch (avatarKey) {
      case 'fox':
        _drawFox(canvas, cx, cy, w, h);
        break;
      case 'rabbit':
        _drawRabbit(canvas, cx, cy, w, h);
        break;
      case 'turtle':
        _drawTurtle(canvas, cx, cy, w, h);
        break;
      case 'cat':
        _drawCat(canvas, cx, cy, w, h);
        break;
      case 'panda':
        _drawPanda(canvas, cx, cy, w, h);
        break;
      case 'owl':
        _drawOwl(canvas, cx, cy, w, h);
        break;
      case 'eagle':
        _drawEagle(canvas, cx, cy, w, h);
        break;
      case 'wolf':
        _drawWolf(canvas, cx, cy, w, h);
        break;
      case 'dolphin':
        _drawDolphin(canvas, cx, cy, w, h);
        break;
      case 'tiger':
        _drawTiger(canvas, cx, cy, w, h);
        break;
      case 'dragon':
        _drawDragon(canvas, cx, cy, w, h);
        break;
      case 'space_robot':
        _drawSpaceRobot(canvas, cx, cy, w, h);
        break;
      default:
        _drawFox(canvas, cx, cy, w, h);
    }
  }

  // 1. Fox
  void _drawFox(Canvas canvas, double cx, double cy, double w, double h) {
    // Backdrop
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF3E8FF));
    final fur = Paint()..color = const Color(0xFF8B5CF6);
    final muzzle = Paint()..color = const Color(0xFFFFFDF9);
    final innerEar = Paint()..color = const Color(0xFFDDD6FE);
    final dark = Paint()..color = const Color(0xFF1E1B4B);

    // Ears
    final lEar = Path()..moveTo(cx - w * 0.35, cy - h * 0.05)..lineTo(cx - w * 0.28, cy - h * 0.42)..lineTo(cx - w * 0.08, cy - h * 0.18)..close();
    final rEar = Path()..moveTo(cx + w * 0.35, cy - h * 0.05)..lineTo(cx + w * 0.28, cy - h * 0.42)..lineTo(cx + w * 0.08, cy - h * 0.18)..close();
    canvas.drawPath(lEar, fur);
    canvas.drawPath(rEar, fur);

    final lIn = Path()..moveTo(cx - w * 0.3, cy - h * 0.08)..lineTo(cx - w * 0.26, cy - h * 0.35)..lineTo(cx - w * 0.12, cy - h * 0.18)..close();
    final rIn = Path()..moveTo(cx + w * 0.3, cy - h * 0.08)..lineTo(cx + w * 0.26, cy - h * 0.35)..lineTo(cx + w * 0.12, cy - h * 0.18)..close();
    canvas.drawPath(lIn, innerEar);
    canvas.drawPath(rIn, innerEar);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.05), w * 0.36, fur);
    // White muzzle
    final muz = Path()..moveTo(cx - w * 0.25, cy + h * 0.12)..quadraticBezierTo(cx, cy + h * 0.02, cx + w * 0.25, cy + h * 0.12)..quadraticBezierTo(cx, cy + h * 0.38, cx - w * 0.25, cy + h * 0.12);
    canvas.drawPath(muz, muzzle);

    // Eyes
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.05, dark);
    canvas.drawCircle(Offset(cx - w * 0.15, cy - h * 0.03), w * 0.018, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.05, dark);
    canvas.drawCircle(Offset(cx + w * 0.13, cy - h * 0.03), w * 0.018, Paint()..color = Colors.white);

    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.14), width: w * 0.08, height: h * 0.05), dark);
  }

  // 2. Rabbit
  void _drawRabbit(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFCE7F3));
    final fur = Paint()..color = const Color(0xFFF8FAFC);
    final pink = Paint()..color = const Color(0xFFF472B6);
    final dark = Paint()..color = const Color(0xFF1E293B);

    // Long ears
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.16, cy - h * 0.28), width: w * 0.14, height: h * 0.42), Radius.circular(w * 0.08)), fur);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.16, cy - h * 0.28), width: w * 0.14, height: h * 0.42), Radius.circular(w * 0.08)), fur);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx - w * 0.16, cy - h * 0.28), width: w * 0.07, height: h * 0.32), Radius.circular(w * 0.04)), pink);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx + w * 0.16, cy - h * 0.28), width: w * 0.07, height: h * 0.32), Radius.circular(w * 0.04)), pink);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.1), w * 0.34, fur);
    // Blush
    canvas.drawCircle(Offset(cx - w * 0.22, cy + h * 0.16), w * 0.05, Paint()..color = pink.color.withValues(alpha: 0.5));
    canvas.drawCircle(Offset(cx + w * 0.22, cy + h * 0.16), w * 0.05, Paint()..color = pink.color.withValues(alpha: 0.5));
    // Eyes
    canvas.drawCircle(Offset(cx - w * 0.12, cy + h * 0.06), w * 0.045, dark);
    canvas.drawCircle(Offset(cx - w * 0.13, cy + h * 0.05), w * 0.016, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.12, cy + h * 0.06), w * 0.045, dark);
    canvas.drawCircle(Offset(cx + w * 0.11, cy + h * 0.05), w * 0.016, Paint()..color = Colors.white);
    // Nose & mouth
    canvas.drawCircle(Offset(cx, cy + h * 0.16), w * 0.03, pink);
  }

  // 3. Turtle
  void _drawTurtle(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFDCFCE7));
    final shell = Paint()..color = const Color(0xFF15803D);
    final skin = Paint()..color = const Color(0xFF4ADE80);
    final dark = Paint()..color = const Color(0xFF14532D);

    // Shell
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.08), width: w * 0.72, height: h * 0.62), shell);
    // Shell pattern
    final ring = Paint()..color = const Color(0xFF166534)..style = PaintingStyle.stroke..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.08), width: w * 0.44, height: h * 0.38), ring);

    // Head
    canvas.drawCircle(Offset(cx, cy - h * 0.18), w * 0.22, skin);
    // Eyes
    canvas.drawCircle(Offset(cx - w * 0.08, cy - h * 0.22), w * 0.04, dark);
    canvas.drawCircle(Offset(cx + w * 0.08, cy - h * 0.22), w * 0.04, dark);
    // Smile
    final smile = Path()..moveTo(cx - w * 0.06, cy - h * 0.12)..quadraticBezierTo(cx, cy - h * 0.08, cx + w * 0.06, cy - h * 0.12);
    canvas.drawPath(smile, Paint()..color = dark.color..style = PaintingStyle.stroke..strokeWidth = 2.0..strokeCap = StrokeCap.round);
  }

  // 4. Cat
  void _drawCat(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFEF3C7));
    final fur = Paint()..color = const Color(0xFFF59E0B);
    final pink = Paint()..color = const Color(0xFFFBBF24);
    final dark = Paint()..color = const Color(0xFF78350F);

    // Triangular ears
    final lEar = Path()..moveTo(cx - w * 0.32, cy - h * 0.05)..lineTo(cx - w * 0.28, cy - h * 0.36)..lineTo(cx - w * 0.06, cy - h * 0.2)..close();
    final rEar = Path()..moveTo(cx + w * 0.32, cy - h * 0.05)..lineTo(cx + w * 0.28, cy - h * 0.36)..lineTo(cx + w * 0.06, cy - h * 0.2)..close();
    canvas.drawPath(lEar, fur);
    canvas.drawPath(rEar, fur);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.05), w * 0.35, fur);
    // Eyes (emerald cat eyes)
    final eyePaint = Paint()..color = const Color(0xFF10B981);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.13, cy), width: w * 0.09, height: h * 0.11), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.13, cy), width: w * 0.09, height: h * 0.11), eyePaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.13, cy), width: w * 0.03, height: h * 0.09), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.13, cy), width: w * 0.03, height: h * 0.09), dark);

    // Nose
    canvas.drawCircle(Offset(cx, cy + h * 0.12), w * 0.03, pink);
    // Whiskers
    final wPaint = Paint()..color = dark.color..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx - w * 0.14, cy + h * 0.14), Offset(cx - w * 0.34, cy + h * 0.11), wPaint);
    canvas.drawLine(Offset(cx + w * 0.14, cy + h * 0.14), Offset(cx + w * 0.34, cy + h * 0.11), wPaint);
  }

  // 5. Panda
  void _drawPanda(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFE2E8F0));
    final white = Paint()..color = Colors.white;
    final dark = Paint()..color = const Color(0xFF0F172A);

    // Black ears
    canvas.drawCircle(Offset(cx - w * 0.26, cy - h * 0.22), w * 0.14, dark);
    canvas.drawCircle(Offset(cx + w * 0.26, cy - h * 0.22), w * 0.14, dark);

    // White head
    canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.36, white);

    // Black eye patches
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.14, cy), width: w * 0.14, height: h * 0.18), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.14, cy), width: w * 0.14, height: h * 0.18), dark);
    // Shiny white eyes inside patches
    canvas.drawCircle(Offset(cx - w * 0.12, cy - h * 0.02), w * 0.03, white);
    canvas.drawCircle(Offset(cx + w * 0.12, cy - h * 0.02), w * 0.03, white);

    // Black button nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.14), width: w * 0.09, height: h * 0.06), dark);
  }

  // 6. Owl
  void _drawOwl(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFEFF6FF));
    final body = Paint()..color = const Color(0xFF3B82F6);
    final dark = Paint()..color = const Color(0xFF1E3A8A);
    final beak = Paint()..color = const Color(0xFFF59E0B);

    // Ear tufts
    final lTuft = Path()..moveTo(cx - w * 0.3, cy - h * 0.1)..lineTo(cx - w * 0.26, cy - h * 0.38)..lineTo(cx - w * 0.06, cy - h * 0.22)..close();
    final rTuft = Path()..moveTo(cx + w * 0.3, cy - h * 0.1)..lineTo(cx + w * 0.26, cy - h * 0.38)..lineTo(cx + w * 0.06, cy - h * 0.22)..close();
    canvas.drawPath(lTuft, body);
    canvas.drawPath(rTuft, body);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.36, body);

    // Huge golden eyes
    canvas.drawCircle(Offset(cx - w * 0.14, cy), w * 0.12, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(Offset(cx + w * 0.14, cy), w * 0.12, Paint()..color = const Color(0xFFFDE047));
    canvas.drawCircle(Offset(cx - w * 0.14, cy), w * 0.06, dark);
    canvas.drawCircle(Offset(cx + w * 0.14, cy), w * 0.06, dark);
    canvas.drawCircle(Offset(cx - w * 0.16, cy - h * 0.02), w * 0.02, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.12, cy - h * 0.02), w * 0.02, Paint()..color = Colors.white);

    // Small sharp beak
    final bPath = Path()..moveTo(cx - w * 0.04, cy + h * 0.06)..lineTo(cx + w * 0.04, cy + h * 0.06)..lineTo(cx, cy + h * 0.18)..close();
    canvas.drawPath(bPath, beak);
  }

  // 7. Eagle
  void _drawEagle(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF1F5F9));
    final white = Paint()..color = const Color(0xFFF8FAFC);
    final beak = Paint()..color = const Color(0xFFF59E0B);
    final dark = Paint()..color = const Color(0xFF0F172A);

    // White feathered head
    canvas.drawCircle(Offset(cx, cy + h * 0.02), w * 0.36, white);
    // Fierce brow
    final brow = Path()..moveTo(cx - w * 0.28, cy - h * 0.12)..lineTo(cx - w * 0.02, cy - h * 0.04)..lineTo(cx + w * 0.28, cy - h * 0.12);
    canvas.drawPath(brow, Paint()..color = dark.color..style = PaintingStyle.stroke..strokeWidth = 2.5);

    // Piercing yellow eyes
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.045, Paint()..color = const Color(0xFFEAB308));
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.045, Paint()..color = const Color(0xFFEAB308));
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.025, dark);
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.025, dark);

    // Curved hooked beak
    final hook = Path()..moveTo(cx - w * 0.08, cy + h * 0.04)..lineTo(cx + w * 0.08, cy + h * 0.04)..lineTo(cx + w * 0.02, cy + h * 0.26)..quadraticBezierTo(cx, cy + h * 0.24, cx - w * 0.04, cy + h * 0.16)..close();
    canvas.drawPath(hook, beak);
  }

  // 8. Wolf
  void _drawWolf(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFE0E7FF));
    final fur = Paint()..color = const Color(0xFF475569);
    final muzzle = Paint()..color = const Color(0xFFCBD5E1);
    final eye = Paint()..color = const Color(0xFFFBBF24);
    final dark = Paint()..color = const Color(0xFF0F172A);

    // Wolf pointy ears
    final lEar = Path()..moveTo(cx - w * 0.35, cy - h * 0.06)..lineTo(cx - w * 0.26, cy - h * 0.44)..lineTo(cx - w * 0.06, cy - h * 0.2)..close();
    final rEar = Path()..moveTo(cx + w * 0.35, cy - h * 0.06)..lineTo(cx + w * 0.26, cy - h * 0.44)..lineTo(cx + w * 0.06, cy - h * 0.2)..close();
    canvas.drawPath(lEar, fur);
    canvas.drawPath(rEar, fur);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.05), w * 0.35, fur);
    // Silver muzzle
    final muz = Path()..moveTo(cx - w * 0.2, cy + h * 0.14)..quadraticBezierTo(cx, cy + h * 0.04, cx + w * 0.2, cy + h * 0.14)..lineTo(cx, cy + h * 0.35)..close();
    canvas.drawPath(muz, muzzle);

    // Amber Wolf eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.14, cy - h * 0.02), width: w * 0.08, height: h * 0.06), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.14, cy - h * 0.02), width: w * 0.08, height: h * 0.06), eye);
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.025, dark);
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.025, dark);

    // Black nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.16), width: w * 0.08, height: h * 0.05), dark);
  }

  // 9. Dolphin
  void _drawDolphin(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFCCFBF1));
    final body = Paint()..color = const Color(0xFF0D9488);
    final belly = Paint()..color = const Color(0xFFF0FDFA);
    final dark = Paint()..color = const Color(0xFF134E4A);

    // Curved head silhouette
    canvas.drawCircle(Offset(cx, cy), w * 0.36, body);
    // Dolphin rostrum / snout
    final snout = Path()..moveTo(cx - w * 0.25, cy + h * 0.1)..quadraticBezierTo(cx - w * 0.42, cy + h * 0.18, cx - w * 0.15, cy + h * 0.28)..close();
    canvas.drawPath(snout, body);

    // White belly wave
    final bPath = Path()..moveTo(cx - w * 0.2, cy + h * 0.15)..quadraticBezierTo(cx, cy + h * 0.05, cx + w * 0.32, cy + h * 0.22)..lineTo(cx + w * 0.1, cy + h * 0.36)..close();
    canvas.drawPath(bPath, belly);

    // Joyful curved eye
    canvas.drawCircle(Offset(cx - w * 0.08, cy - h * 0.04), w * 0.04, dark);
    canvas.drawCircle(Offset(cx - w * 0.09, cy - h * 0.05), w * 0.015, Paint()..color = Colors.white);

    // Blowhole gleam
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.1, cy - h * 0.22), width: w * 0.06, height: h * 0.03), dark);
  }

  // 10. Tiger
  void _drawTiger(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFFEDD5));
    final orange = Paint()..color = const Color(0xFFEA580C);
    final white = Paint()..color = const Color(0xFFFFFBEB);
    final dark = Paint()..color = const Color(0xFF1C1917);

    // Round ears
    canvas.drawCircle(Offset(cx - w * 0.25, cy - h * 0.22), w * 0.13, orange);
    canvas.drawCircle(Offset(cx + w * 0.25, cy - h * 0.22), w * 0.13, orange);
    canvas.drawCircle(Offset(cx - w * 0.25, cy - h * 0.22), w * 0.07, white);
    canvas.drawCircle(Offset(cx + w * 0.25, cy - h * 0.22), w * 0.07, white);

    // Head
    canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.36, orange);

    // Tiger forehead stripes
    final sPaint = Paint()..color = dark.color..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, cy - h * 0.24), Offset(cx, cy - h * 0.12), sPaint);
    canvas.drawLine(Offset(cx - w * 0.1, cy - h * 0.18), Offset(cx - w * 0.04, cy - h * 0.12), sPaint);
    canvas.drawLine(Offset(cx + w * 0.1, cy - h * 0.18), Offset(cx + w * 0.04, cy - h * 0.12), sPaint);

    // White muzzle
    canvas.drawCircle(Offset(cx - w * 0.1, cy + h * 0.16), w * 0.12, white);
    canvas.drawCircle(Offset(cx + w * 0.1, cy + h * 0.16), w * 0.12, white);

    // Amber Eyes
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.045, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.045, Paint()..color = const Color(0xFFFBBF24));
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.02), w * 0.025, dark);
    canvas.drawCircle(Offset(cx + w * 0.14, cy - h * 0.02), w * 0.025, dark);

    // Black nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + h * 0.12), width: w * 0.08, height: h * 0.05), dark);
  }

  // 11. Dragon
  void _drawDragon(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFFEF2F2));
    final scale = Paint()..color = const Color(0xFFDC2626);
    final horn = Paint()..color = const Color(0xFFF59E0B);
    final dark = Paint()..color = const Color(0xFF7F1D1D);

    // Majestic Dragon Horns
    final lHorn = Path()..moveTo(cx - w * 0.28, cy - h * 0.08)..quadraticBezierTo(cx - w * 0.44, cy - h * 0.38, cx - w * 0.32, cy - h * 0.46)..quadraticBezierTo(cx - w * 0.22, cy - h * 0.3, cx - w * 0.12, cy - h * 0.18)..close();
    final rHorn = Path()..moveTo(cx + w * 0.28, cy - h * 0.08)..quadraticBezierTo(cx + w * 0.44, cy - h * 0.38, cx + w * 0.32, cy - h * 0.46)..quadraticBezierTo(cx + w * 0.22, cy - h * 0.3, cx + w * 0.12, cy - h * 0.18)..close();
    canvas.drawPath(lHorn, horn);
    canvas.drawPath(rHorn, horn);

    // Dragon Head
    canvas.drawCircle(Offset(cx, cy + h * 0.04), w * 0.36, scale);

    // Glowing Golden Flame Eyes
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.14, cy - h * 0.02), width: w * 0.09, height: h * 0.07), Paint()..color = const Color(0xFFFEF08A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.14, cy - h * 0.02), width: w * 0.09, height: h * 0.07), Paint()..color = const Color(0xFFFEF08A));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - w * 0.14, cy - h * 0.02), width: w * 0.03, height: h * 0.06), dark);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + w * 0.14, cy - h * 0.02), width: w * 0.03, height: h * 0.06), dark);

    // Nostrils with flame smoke
    canvas.drawCircle(Offset(cx - w * 0.07, cy + h * 0.18), w * 0.03, dark);
    canvas.drawCircle(Offset(cx + w * 0.07, cy + h * 0.18), w * 0.03, dark);
  }

  // 12. Space Robot
  void _drawSpaceRobot(Canvas canvas, double cx, double cy, double w, double h) {
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0F172A));
    final metal = Paint()..color = const Color(0xFF475569);
    final cyanGlow = Paint()..color = const Color(0xFF06B6D4);
    final white = Paint()..color = Colors.white;

    // Antenna
    canvas.drawLine(Offset(cx, cy - h * 0.22), Offset(cx, cy - h * 0.4), Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 3);
    canvas.drawCircle(Offset(cx, cy - h * 0.42), w * 0.06, cyanGlow);
    canvas.drawCircle(Offset(cx, cy - h * 0.42), w * 0.025, white);

    // Rounded Metallic Head
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + h * 0.04), width: w * 0.68, height: h * 0.54), Radius.circular(w * 0.14)), metal);

    // Glowing Neon Visor Screen
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.52, height: h * 0.24), Radius.circular(w * 0.08)), Paint()..color = const Color(0xFF083344));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: w * 0.52, height: h * 0.24), Radius.circular(w * 0.08)), Paint()..color = cyanGlow.color..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Glowing Pixel/Anime Eyes on Visor
    canvas.drawCircle(Offset(cx - w * 0.13, cy), w * 0.045, cyanGlow);
    canvas.drawCircle(Offset(cx + w * 0.13, cy), w * 0.045, cyanGlow);
    canvas.drawCircle(Offset(cx - w * 0.14, cy - h * 0.015), w * 0.018, white);
    canvas.drawCircle(Offset(cx + w * 0.12, cy - h * 0.015), w * 0.018, white);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) => oldDelegate.avatarKey != avatarKey;
}

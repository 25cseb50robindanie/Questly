import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';

/// 1. Pizza / Circular Fraction Model Widget
class PizzaVisualWidget extends StatelessWidget {
  final int totalSlices;
  final int selectedSlices;
  final double size;
  final bool interactive;
  final void Function(int newSelected)? onSelectionChanged;
  final String? label;

  const PizzaVisualWidget({
    Key? key,
    required this.totalSlices,
    required this.selectedSlices,
    this.size = 140,
    this.interactive = false,
    this.onSelectionChanged,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: interactive && onSelectionChanged != null
              ? () {
                  final next = (selectedSlices + 1) % (totalSlices + 1);
                  onSelectionChanged!(next == 0 ? 1 : next);
                }
              : null,
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _PizzaPainter(
                totalSlices: totalSlices.clamp(1, 12),
                selectedSlices: selectedSlices.clamp(0, totalSlices),
              ),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
        ],
      ],
    );
  }
}

class _PizzaPainter extends CustomPainter {
  final int totalSlices;
  final int selectedSlices;

  _PizzaPainter({required this.totalSlices, required this.selectedSlices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Crust Shadow & Base
    final crustPaint = Paint()
      ..color = const Color(0xFFD48B38)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, crustPaint);

    final saucePaint = Paint()
      ..color = const Color(0xFFE5533D)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 6, saucePaint);

    // Cheese layer
    final cheesePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 10, cheesePaint);

    // Draw Slices
    final sliceAngle = (2 * math.pi) / totalSlices;

    final selectedSlicePaint = Paint()
      ..color = const Color(0xFFFF7043).withOpacity(0.88)
      ..style = PaintingStyle.fill;

    final unselectedSlicePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < totalSlices; i++) {
      final startAngle = -math.pi / 2 + i * sliceAngle;
      final isSelected = i < selectedSlices;

      final slicePath = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius - 10),
          startAngle,
          sliceAngle,
          false,
        )
        ..close();

      canvas.drawPath(slicePath, isSelected ? selectedSlicePaint : unselectedSlicePaint);
      canvas.drawPath(slicePath, linePaint);

      // Add Toppings for Selected Slices
      if (isSelected) {
        final midAngle = startAngle + sliceAngle / 2;
        final topCenter = Offset(
          center.dx + (radius * 0.5) * math.cos(midAngle),
          center.dy + (radius * 0.5) * math.sin(midAngle),
        );
        final pepPaint = Paint()..color = const Color(0xFFB71C1C);
        canvas.drawCircle(topCenter, radius * 0.09, pepPaint);
      }
    }

    // Outer border
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PizzaPainter oldDelegate) =>
      oldDelegate.totalSlices != totalSlices || oldDelegate.selectedSlices != selectedSlices;
}

/// 2. Chocolate Bar / Grid Visual Model
class ChocolateBarVisualWidget extends StatelessWidget {
  final int totalRows;
  final int totalCols;
  final int selectedPieces;
  final double width;
  final double height;
  final bool interactive;
  final void Function(int newSelected)? onSelectionChanged;

  const ChocolateBarVisualWidget({
    Key? key,
    this.totalRows = 2,
    this.totalCols = 4,
    required this.selectedPieces,
    this.width = 180,
    this.height = 90,
    this.interactive = false,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = totalRows * totalCols;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF4E342E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: totalCols,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: total,
        itemBuilder: (context, index) {
          final isSelected = index < selectedPieces;
          return GestureDetector(
            onTap: interactive && onSelectionChanged != null
                ? () {
                    onSelectionChanged!(isSelected ? index : index + 1);
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8D6E63) : const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3E2723) : Colors.grey.shade400,
                  width: 1.2,
                ),
              ),
              child: Center(
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 3. Fraction Strips Comparison Widget
class FractionStripsVisualWidget extends StatelessWidget {
  final List<int> denominators;
  final int activeDenominator;
  final int activeNumerator;

  const FractionStripsVisualWidget({
    Key? key,
    this.denominators = const [1, 2, 3, 4, 6, 8],
    required this.activeDenominator,
    required this.activeNumerator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: denominators.map((den) {
        final isHighlighted = den == activeDenominator;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  '1/$den',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.bold,
                    color: isHighlighted ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.7),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isHighlighted ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.3),
                      width: isHighlighted ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: List.generate(den, (i) {
                      final isShaded = isHighlighted && i < activeNumerator;
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isShaded
                                ? ColorSystem.purple.withOpacity(0.8)
                                : (isHighlighted ? ColorSystem.lavender.withOpacity(0.2) : Colors.white),
                            border: Border(
                              right: i < den - 1
                                  ? BorderSide(color: ColorSystem.plum.withOpacity(0.25), width: 1)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '1/$den',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isShaded ? Colors.white : ColorSystem.plum.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 4. Number Line Model
class NumberLineVisualWidget extends StatelessWidget {
  final int denominator;
  final int numerator;
  final double width;

  const NumberLineVisualWidget({
    Key? key,
    required this.denominator,
    required this.numerator,
    this.width = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          height: 60,
          child: CustomPaint(
            painter: _NumberLinePainter(
              denominator: denominator.clamp(1, 12),
              numerator: numerator.clamp(0, denominator),
            ),
          ),
        ),
      ],
    );
  }
}

class _NumberLinePainter extends CustomPainter {
  final int denominator;
  final int numerator;

  _NumberLinePainter({required this.denominator, required this.numerator});

  @override
  void paint(Canvas canvas, Size size) {
    final startX = 20.0;
    final endX = size.width - 20.0;
    final y = 28.0;

    final linePaint = Paint()
      ..color = ColorSystem.plum
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw main line with arrows
    canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);

    final tickPaint = Paint()
      ..color = ColorSystem.plum
      ..strokeWidth = 2.0;

    final step = (endX - startX) / denominator;

    for (int i = 0; i <= denominator; i++) {
      final x = startX + i * step;
      final isMajor = i == 0 || i == denominator;
      final tickHeight = isMajor ? 14.0 : 8.0;

      canvas.drawLine(
        Offset(x, y - tickHeight / 2),
        Offset(x, y + tickHeight / 2),
        tickPaint,
      );

      // Label
      final label = i == 0 ? '0' : (i == denominator ? '1' : '$i/$denominator');
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isMajor ? 11 : 9.5,
            fontWeight: i == numerator ? FontWeight.w900 : FontWeight.bold,
            color: i == numerator ? ColorSystem.purple : ColorSystem.plum,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 10));
    }

    // Arc jump from 0 to target fraction
    if (numerator > 0) {
      final targetX = startX + numerator * step;
      final jumpPaint = Paint()
        ..color = ColorSystem.purple
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final arcPath = Path();
      arcPath.moveTo(startX, y);
      arcPath.quadraticBezierTo((startX + targetX) / 2, y - 24, targetX, y);
      canvas.drawPath(arcPath, jumpPaint);

      // Draw pointer dot
      final dotPaint = Paint()..color = ColorSystem.purple;
      canvas.drawCircle(Offset(targetX, y), 5.5, dotPaint);
      canvas.drawCircle(Offset(targetX, y), 3.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _NumberLinePainter oldDelegate) =>
      oldDelegate.denominator != denominator || oldDelegate.numerator != numerator;
}

/// 5. Ratio Beaker & Liquid Mixer Widget
class RatioBeakerVisualWidget extends StatelessWidget {
  final int partA;
  final int partB;
  final String labelA;
  final String labelB;
  final Color colorA;
  final Color colorB;
  final double height;
  final double width;

  const RatioBeakerVisualWidget({
    Key? key,
    required this.partA,
    required this.partB,
    this.labelA = 'Juice',
    this.labelB = 'Water',
    this.colorA = const Color(0xFFFF9800),
    this.colorB = const Color(0xFF29B6F6),
    this.height = 140,
    this.width = 110,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = partA + partB;
    final fracA = total > 0 ? partA / total : 0.5;
    final fracB = total > 0 ? partB / total : 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            border: Border.all(color: ColorSystem.plum, width: 2.5),
          ),
          child: Stack(
            children: [
              // Liquid Layer B (Water)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: (height - 6) * fracB,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorB.withOpacity(0.85),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                  ),
                  child: Center(
                    child: Text(
                      '$labelB ($partB)',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Liquid Layer A (Juice)
              Positioned(
                bottom: (height - 6) * fracB,
                left: 0,
                right: 0,
                height: (height - 6) * fracA,
                child: Container(
                  color: colorA.withOpacity(0.9),
                  child: Center(
                    child: Text(
                      '$labelA ($partA)',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ratio $labelA : $labelB = $partA : $partB',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }
}

/// 6. Fruit / Objects Ratio Collection Widget
class FruitRatioVisualWidget extends StatelessWidget {
  final int countA;
  final int countB;
  final IconData iconA;
  final IconData iconB;
  final String labelA;
  final String labelB;
  final Color colorA;
  final Color colorB;

  const FruitRatioVisualWidget({
    Key? key,
    required this.countA,
    required this.countB,
    this.iconA = Icons.apple_rounded,
    this.iconB = Icons.circle_rounded,
    this.labelA = 'Red Apples',
    this.labelB = 'Blue Berries',
    this.colorA = const Color(0xFFE53935),
    this.colorB = const Color(0xFF1E88E5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Group A
              Column(
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      countA,
                      (_) => Icon(iconA, color: colorA, size: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$countA $labelA',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorA,
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: 1.5,
                color: ColorSystem.plum.withOpacity(0.2),
              ),
              // Group B
              Column(
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: List.generate(
                      countB,
                      (_) => Icon(iconB, color: colorB, size: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$countB $labelB',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorB,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 7. Proportion Scale / Geometric Scaling Visual Model
class ProportionScaleWidget extends StatelessWidget {
  final double baseWidth;
  final double baseHeight;
  final double scaleFactor; // e.g. 1.0, 2.0, 3.0
  final String label;

  const ProportionScaleWidget({
    Key? key,
    this.baseWidth = 40,
    this.baseHeight = 50,
    required this.scaleFactor,
    this.label = 'Castle Gate',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaledW = (baseWidth * scaleFactor).clamp(30.0, 140.0);
    final scaledH = (baseHeight * scaleFactor).clamp(35.0, 120.0);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Original Shape (Scale 1x)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: baseWidth,
                height: baseHeight,
                decoration: BoxDecoration(
                  color: ColorSystem.lavender.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.purple, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.shield_rounded, color: ColorSystem.purple, size: 20),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Original (1x)\n${baseWidth.toInt()}×${baseHeight.toInt()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.plum),
              ),
            ],
          ),

          Icon(Icons.double_arrow_rounded, color: ColorSystem.purple.withOpacity(0.6), size: 20),

          // Scaled Shape (Scale k)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: scaledW,
                height: scaledH,
                decoration: BoxDecoration(
                  color: ColorSystem.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.gold, width: 2),
                ),
                child: Center(
                  child: Icon(Icons.shield_rounded, color: ColorSystem.gold, size: (18 * scaleFactor).clamp(18.0, 36.0)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Scaled (${scaleFactor.toStringAsFixed(1)}x)\n${scaledW.toInt()}×${scaledH.toInt()}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 8. Twin Balance Scale Widget for Proportions
class TwinBalanceWidget extends StatelessWidget {
  final int leftNum;
  final int leftDen;
  final int rightNum;
  final int rightDen;

  const TwinBalanceWidget({
    Key? key,
    required this.leftNum,
    required this.leftDen,
    required this.rightNum,
    required this.rightDen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBalanced = (leftNum * rightDen) == (leftDen * rightNum);
    final leftVal = leftNum / (leftDen == 0 ? 1 : leftDen);
    final rightVal = rightNum / (rightDen == 0 ? 1 : rightDen);
    final angle = isBalanced ? 0.0 : (leftVal > rightVal ? -0.08 : 0.08);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            isBalanced ? '⚖️ BALANCED PROPORTION' : '⚖️ UNBALANCED RATIOS',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isBalanced ? ColorSystem.green : ColorSystem.pink,
            ),
          ),
          const SizedBox(height: 8),
          Transform.rotate(
            angle: angle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left Pan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorSystem.lavender.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.purple, width: 1.5),
                  ),
                  child: Text('$leftNum / $leftDen', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                ),
                Text(isBalanced ? '==' : '≠', style: TextStyle(fontFamily: 'Fredoka', fontSize: 18, fontWeight: FontWeight.w900, color: isBalanced ? ColorSystem.green : ColorSystem.pink)),
                // Right Pan
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.gold, width: 1.5),
                  ),
                  child: Text('$rightNum / $rightDen', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 9. Hundred Grid Percentage Widget (10x10 = 100 Squares)
class HundredGridWidget extends StatelessWidget {
  final int percentFilled; // 0 to 100
  final double size;
  final bool interactive;
  final ValueChanged<int>? onPercentChanged;

  const HundredGridWidget({
    Key? key,
    required this.percentFilled,
    this.size = 140,
    this.interactive = false,
    this.onPercentChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final safePercent = percentFilled.clamp(0, 100);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: interactive && onPercentChanged != null
              ? () {
                  final next = (safePercent + 10) % 110;
                  onPercentChanged!(next);
                }
              : null,
          child: Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: 100,
              itemBuilder: (context, index) {
                final isShaded = index < safePercent;
                return Container(
                  decoration: BoxDecoration(
                    color: isShaded ? ColorSystem.purple : ColorSystem.lavender.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(1),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$safePercent% ($safePercent / 100)',
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }
}

/// 10. Discount Tag Widget for Percentages
class DiscountTagWidget extends StatelessWidget {
  final double originalPrice;
  final int discountPercent;

  const DiscountTagWidget({
    Key? key,
    required this.originalPrice,
    required this.discountPercent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discountAmount = originalPrice * (discountPercent / 100.0);
    final finalPrice = originalPrice - discountAmount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.pink, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.pink.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ITEM PRICE:', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
              Text('\$${originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.lineThrough)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SALE DISCOUNT ($discountPercent% OFF):', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.pink)),
              Text('-\$${discountAmount.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.pink)),
            ],
          ),
          const Divider(height: 12, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('YOU PAY:', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.green)),
              Text('\$${finalPrice.toStringAsFixed(0)}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 15, fontWeight: FontWeight.w900, color: ColorSystem.green)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 11. Blueprint Scale Map Widget for Real-World Applications
class BlueprintMapWidget extends StatelessWidget {
  final int mapCm;
  final int kmPerCm;

  const BlueprintMapWidget({
    Key? key,
    required this.mapCm,
    this.kmPerCm = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualKm = mapCm * kmPerCm;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('🗺️ KINGDOM SCALE BLUEPRINT', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('Scale: 1 cm = 5 km', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.gold)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Icon(Icons.castle_rounded, color: Colors.white, size: 24),
              Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: ColorSystem.gold,
                ),
              ),
              const Icon(Icons.fort_rounded, color: ColorSystem.gold, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Map Distance: $mapCm cm  ==>  Real Distance: $actualKm km',
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// 12. Recipe Mixer Cauldron Widget for Real-World Applications
class RecipeMixerWidget extends StatelessWidget {
  final int servings;
  final int flourCupsPerServing;
  final int sugarCupsPerServing;

  const RecipeMixerWidget({
    Key? key,
    required this.servings,
    this.flourCupsPerServing = 2,
    this.sugarCupsPerServing = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalFlour = servings * flourCupsPerServing;
    final totalSugar = servings * sugarCupsPerServing;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text('🥘 FEAST CAULDRON: $servings SERVINGS', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const Icon(Icons.grain_rounded, color: Color(0xFF8D6E63), size: 20),
                  Text('$totalFlour Cups Flour', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.cake_rounded, color: ColorSystem.pink, size: 20),
                  Text('$totalSugar Cups Sugar', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


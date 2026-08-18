import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../../core/theme/color_system.dart';

class WaterTankComponent extends PositionComponent {
  WaterTankComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    // 1. Draw the Glass Tank borders
    final borderPaint = Paint()
      ..color = ColorSystem.plum.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    // U-shaped tank outline
    final tankPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..lineTo(size.x, 0);
    canvas.drawPath(tankPath, borderPaint);

    // 2. Draw the Water Fill (fills the bottom 60% of the tank)
    final waterPaint = Paint()
      ..color = ColorSystem.blue.withOpacity(0.65)
      ..style = PaintingStyle.fill;
    
    final waterRect = Rect.fromLTWH(
      2, 
      size.y * 0.4, 
      size.x - 4, 
      size.y * 0.6 - 2
    );
    canvas.drawRect(waterRect, waterPaint);

    // 3. Draw Water Surface ripple line
    final surfacePaint = Paint()
      ..color = ColorSystem.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(2, size.y * 0.4),
      Offset(size.x - 2, size.y * 0.4),
      surfacePaint
    );
  }
}

class MaterialBlockComponent extends PositionComponent {
  double mass; // in kg
  double volume; // in L
  Color blockColor;
  bool isDropped = false;
  
  double _yVelocity = 0.0;
  final double _gravity = 400.0;
  
  late double initialY;
  late double waterSurfaceY;
  late double tankBottomY;

  MaterialBlockComponent({
    required Vector2 position,
    required Vector2 size,
    required this.mass,
    required this.volume,
    required this.blockColor,
  }) : super(position: position, size: size) {
    initialY = position.y;
  }

  double get density => mass / volume;

  void reset() {
    position.y = initialY;
    _yVelocity = 0.0;
    isDropped = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isDropped) return;

    final blockBottom = position.y + size.y;

    // 1. Air descent (above water surface)
    if (blockBottom < waterSurfaceY) {
      _yVelocity += _gravity * dt;
      position.y += _yVelocity * dt;

      // Bound bottom to water surface when crossing
      if (position.y + size.y > waterSurfaceY) {
        _yVelocity *= 0.2; // dampen speed upon splash
      }
    } 
    // 2. Hydrodynamics (sinks or floats)
    else {
      final d = density;
      if (d >= 1.0) {
        // Sinks: descend slowly to the tank bottom
        final targetBottomY = tankBottomY - size.y;
        if (position.y < targetBottomY) {
          // Slow terminal velocity in water
          final sinkSpeed = 60.0 + (d - 1.0) * 10; 
          position.y += sinkSpeed * dt;
          if (position.y > targetBottomY) {
            position.y = targetBottomY;
          }
        }
      } else {
        // Floats: Settle at buoyancy equilibrium point
        // Submerged fraction = density (d / 1.0). Top settles at: waterSurfaceY - (1 - density)*height
        final equilibriumY = waterSurfaceY - (1.0 - d) * size.y;
        
        // Elastic spring interpolation for realistic bobbing float effect
        final yDiff = equilibriumY - position.y;
        position.y += yDiff * 4.5 * dt;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Draw the geometric solid block shape
    final fillPaint = Paint()
      ..color = blockColor
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);

    // Draw mass label text on the block
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(1)}kg',
        style: const TextStyle(
          color: ColorSystem.plum,
          fontWeight: FontWeight.bold,
          fontSize: 10,
          fontFamily: 'system-ui',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas, 
      Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2)
    );
  }
}

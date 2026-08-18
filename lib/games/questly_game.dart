import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'components/components.dart';
import 'components/dendy_component.dart';
import '../core/theme/color_system.dart';
import '../widgets/dendy_mascot.dart'; // Import DendyState enum

class QuestlyGame extends FlameGame {
  final double targetDensity;
  final String targetCondition;
  final Function(double finalDensity) onGoalAchieved;

  late WaterTankComponent tank;
  late MaterialBlockComponent block;
  late DendyGameComponent dendy;

  bool isGoalResolved = false;
  bool hasSplashed = false;
  bool hasImpacted = false;

  // Canvas shake variables
  double _shakeTime = 0.0;
  double _shakeIntensity = 0.0;
  final math.Random _random = math.Random();

  QuestlyGame({
    required this.targetDensity,
    required this.targetCondition,
    required this.onGoalAchieved,
  });

  @override
  Color backgroundColor() => ColorSystem.cream;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Size the Glass Tank relative to game screen space
    final tankWidth = 260.0;
    final tankHeight = 220.0;
    final tankX = (size.x - tankWidth) / 2;
    final tankY = size.y - tankHeight - 30; // 30px offset from screen bottom

    tank = WaterTankComponent(
      position: Vector2(tankX, tankY),
      size: Vector2(tankWidth, tankHeight),
    );
    add(tank);

    // Size the material block component
    final blockWidth = 50.0;
    final blockHeight = 50.0;
    final blockX = (size.x - blockWidth) / 2;
    final blockY = tankY - blockHeight - 80;

    block = MaterialBlockComponent(
      position: Vector2(blockX, blockY),
      size: Vector2(blockWidth, blockHeight),
      mass: 3.0,
      volume: 5.0,
      blockColor: const Color(0xFF8B5A2B), // Default Wood color
    );

    // Setup coordinates boundaries for simulation physics inside the block component
    block.waterSurfaceY = tankY + (tankHeight * 0.4);
    block.tankBottomY = tankY + tankHeight;
    block.initialY = blockY;
    add(block);

    // Position Dendy the Mascot hovering to the left of the glass container
    dendy = DendyGameComponent(
      position: Vector2(tankX - 85, tankY + (tankHeight * 0.2)),
      size: Vector2(64, 75),
    );
    add(dendy);
  }

  void triggerCameraShake({double intensity = 4.5, double duration = 0.18}) {
    _shakeTime = duration;
    _shakeIntensity = intensity;
  }

  void spawnSplashParticles(Vector2 position) {
    final rand = math.Random();
    // Combined particle array shooting upwards and outwards
    final particles = List.generate(20, (index) {
      final angle = -math.pi / 4 - (rand.nextDouble() * math.pi / 2); // angle up-left to up-right
      final speed = 90.0 + rand.nextDouble() * 120.0;
      final velocity = Vector2(math.cos(angle) * speed, math.sin(angle) * speed);

      return MovingParticle(
        from: position,
        to: position + velocity * 0.35,
        child: CircleParticle(
          radius: 1.5 + rand.nextDouble() * 3.0,
          paint: Paint()..color = ColorSystem.blue.withOpacity(0.8),
        ),
        lifespan: 0.35,
      );
    });

    for (final p in particles) {
      add(ParticleSystemComponent(particle: p));
    }
  }

  void updateBlockProperties(double mass, double volume, Color color) {
    block.mass = mass;
    block.volume = volume;
    block.blockColor = color;
    block.reset();
    
    dendy.state = DendyState.idle;
    isGoalResolved = false;
    hasSplashed = false;
    hasImpacted = false;
  }

  void dropBlock() {
    block.isDropped = true;
    dendy.state = DendyState.thinking;
  }

  void resetBlock() {
    block.reset();
    dendy.state = DendyState.idle;
    isGoalResolved = false;
    hasSplashed = false;
    hasImpacted = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_shakeTime > 0) {
      _shakeTime -= dt;
    }

    if (block.isDropped && !isGoalResolved) {
      final blockBottom = block.position.y + block.size.y;
      bool isSettled = false;

      // 1. Detect entry into water to trigger particle splash
      if (!hasSplashed && blockBottom >= block.waterSurfaceY) {
        hasSplashed = true;
        spawnSplashParticles(Vector2(size.x / 2, block.waterSurfaceY));
        triggerCameraShake(intensity: 2.0, duration: 0.12);
      }

      // 2. Settle criteria
      if (block.density >= 1.0) {
        // Sunk check: Block bottom is touching the bottom floor of the tank
        if ((blockBottom - block.tankBottomY).abs() < 1.0) {
          isSettled = true;
          // Trigger shake on heavy bottom collision impact
          if (!hasImpacted) {
            hasImpacted = true;
            triggerCameraShake(intensity: 5.0, duration: 0.2);
          }
        }
      } else {
        // Float check: bobbing animation has settled near equilibrium point
        final targetY = block.waterSurfaceY - (1.0 - block.density) * block.size.y;
        if ((block.position.y - targetY).abs() < 1.5) {
          isSettled = true;
        }
      }

      // 3. Goal checking when settled
      if (isSettled) {
        final currentDensity = block.density;
        bool isTargetMet = false;

        if (targetCondition == 'float') {
          isTargetMet = currentDensity < targetDensity;
        } else if (targetCondition == 'sink') {
          isTargetMet = currentDensity > targetDensity;
        } else {
          isTargetMet = (currentDensity - targetDensity).abs() < 0.05;
        }

        if (isTargetMet) {
          isGoalResolved = true;
          dendy.state = DendyState.success;
          onGoalAchieved(currentDensity);
        } else {
          // Settled but failed the challenge goal
          if (dendy.state != DendyState.confused) {
            dendy.state = DendyState.confused;
            triggerCameraShake(intensity: 3.0, duration: 0.15);
          }
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_shakeTime > 0) {
      canvas.save();
      final dx = (_random.nextDouble() - 0.5) * _shakeIntensity;
      final dy = (_random.nextDouble() - 0.5) * _shakeIntensity;
      canvas.translate(dx, dy);
    }

    super.render(canvas);

    if (_shakeTime > 0) {
      canvas.restore();
    }
  }
}

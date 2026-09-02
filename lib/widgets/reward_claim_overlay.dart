import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/reward_definition.dart';
import '../models/roadmap_enums.dart';
import '../services/sound_service.dart';
import '../services/pending_reward_service.dart';
import 'custom_button.dart';
import 'dendy_mascot.dart';
import 'vector_asset_helper.dart';
import '../services/localization_service.dart';

// Physics-based flying particle using vector assets
class FlyingParticle {
  Offset currentPos;
  final Offset startPos;
  final Offset targetPos;
  final RewardType type;
  final String assetKey;
  final int variant;
  double speed;
  final double angle;
  double scale;
  double rotation;
  double rotationSpeed;
  bool arrived = false;

  FlyingParticle({
    required this.currentPos,
    required this.startPos,
    required this.targetPos,
    required this.type,
    this.assetKey = '',
    this.variant = 1,
    required this.speed,
    required this.angle,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.05,
  });

  void update() {
    final dx = targetPos.dx - currentPos.dx;
    final dy = targetPos.dy - currentPos.dy;
    final dist = sqrt(dx * dx + dy * dy);

    if (dist < 16) {
      arrived = true;
      return;
    }

    final dirX = dx / dist;
    final dirY = dy / dist;

    // Smooth physics acceleration & curve
    speed = (speed + 1.25).clamp(2.0, 34.0);
    rotation += rotationSpeed;

    currentPos = Offset(
      currentPos.dx + dirX * speed + sin(angle + speed * 0.1) * 1.5,
      currentPos.dy + dirY * speed,
    );
  }

  Widget buildWidget() {
    Widget child;
    switch (type) {
      case RewardType.coins:
        child = VectorAssetHelper.questCoinIcon(size: 24 * scale, variant: variant);
        break;
      case RewardType.xp:
        child = VectorAssetHelper.xpStarIcon(size: 24 * scale);
        break;
      case RewardType.collectible:
        child = VectorAssetHelper.collectibleIcon(assetKey.isNotEmpty ? assetKey : 'water', size: 30 * scale);
        break;
      default:
        child = VectorAssetHelper.questCoinIcon(size: 24 * scale);
    }

    return Transform.rotate(
      angle: rotation,
      child: Transform.scale(
        scale: scale,
        child: child,
      ),
    );
  }
}

class RewardClaimOverlay extends StatefulWidget {
  final String studentId;
  final PendingReward reward;
  final VoidCallback onDismissed;

  const RewardClaimOverlay({
    Key? key,
    required this.studentId,
    required this.reward,
    required this.onDismissed,
  }) : super(key: key);

  @override
  _RewardClaimOverlayState createState() => _RewardClaimOverlayState();
}

class _RewardClaimOverlayState extends State<RewardClaimOverlay> with TickerProviderStateMixin {
  late AnimationController _cardAnimController;
  late Animation<double> _scaleAnimation;
  late AnimationController _chestBounceController;
  late AnimationController _particleController;

  bool _isClaiming = false;
  bool _chestOpened = false;
  bool _claimedConfirmed = false;
  List<RewardDefinition> _rewardsList = [];
  final List<FlyingParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    SoundService.playRewardReveal();

    // Load rewards details
    _rewardsList = widget.reward.rewardIds
        .map((rid) => Locator.roadmapRepository.getRewardById(rid))
        .where((r) => r != null)
        .cast<RewardDefinition>()
        .toList();

    // Scale entrance animation for the card
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutBack),
    );
    _cardAnimController.forward();

    // Chest bouncing animation
    _chestBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Particle flight animation loop controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        bool allDone = true;
        setState(() {
          for (var p in _particles) {
            if (!p.arrived) {
              p.update();
              allDone = false;

              // Play soft sound upon arrival
              if (p.arrived) {
                if (p.type == RewardType.coins) {
                  SoundService.playCoinCollect();
                } else {
                  SoundService.playXpCollect();
                }
              }
            }
          }
        });

        // Auto close after all particles land
        if (_isClaiming && allDone && _particles.isNotEmpty) {
          _particleController.stop();
          setState(() {
            _claimedConfirmed = true;
          });
          SoundService.playSwitch(); // Confirmation chime
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              widget.onDismissed();
            }
          });
        }
      });
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _chestBounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  // Claim click callback
  Future<void> _claimReward() async {
    if (_isClaiming) return; // double-tap protection

    setState(() {
      _isClaiming = true;
      _chestOpened = true;
    });

    SoundService.playChestOpen();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final center = Offset(screenWidth / 2, screenHeight / 2);

    // Coordinate target locations dynamically across landscape:
    final coinsTarget = Offset(screenWidth - 200, 24); // top right Coins counter
    final xpTarget = Offset(screenWidth / 2, 24); // center header XP progress bar
    final collTarget = Offset(60, screenHeight - 60); // bottom left navigation Collection tab

    // Spawn flight particles sequentially
    final rand = Random();
    for (var reward in _rewardsList) {
      if (reward.type == RewardType.coins) {
        for (int i = 0; i < 14; i++) {
          final start = center + Offset(rand.nextDouble() * 50 - 25, rand.nextDouble() * 50 - 25);
          _particles.add(FlyingParticle(
            currentPos: start,
            startPos: start,
            targetPos: coinsTarget,
            type: RewardType.coins,
            variant: (i % 5) + 1,
            speed: rand.nextDouble() * 4 + 3,
            angle: rand.nextDouble() * pi * 2,
            scale: rand.nextDouble() * 0.4 + 0.9,
            rotationSpeed: (rand.nextDouble() - 0.5) * 0.2,
          ));
        }
      } else if (reward.type == RewardType.xp) {
        for (int i = 0; i < 12; i++) {
          final start = center + Offset(rand.nextDouble() * 40 - 20, rand.nextDouble() * 40 - 20);
          _particles.add(FlyingParticle(
            currentPos: start,
            startPos: start,
            targetPos: xpTarget,
            type: RewardType.xp,
            speed: rand.nextDouble() * 4 + 3,
            angle: rand.nextDouble() * pi * 2,
            scale: rand.nextDouble() * 0.4 + 0.9,
            rotationSpeed: (rand.nextDouble() - 0.5) * 0.15,
          ));
        }
      } else if (reward.type == RewardType.collectible) {
        _particles.add(FlyingParticle(
          currentPos: center,
          startPos: center,
          targetPos: collTarget,
          type: RewardType.collectible,
          assetKey: reward.assetPath.isNotEmpty ? reward.assetPath : reward.name,
          speed: 3.0,
          angle: 0.0,
          scale: 1.4,
          rotationSpeed: 0.05,
        ));
      }
    }

    SoundService.playCoinSpawn();
    _particleController.forward(from: 0.0);

    // Persist claims inside Database/Prefs
    await Locator.pendingRewardService.markRewardClaimed(widget.studentId, widget.reward);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isCompact = screenHeight < 360;

    return Stack(
      children: [
        // 1. Semi-transparent darkened Scrim backdrop
        Container(
          width: screenWidth,
          height: screenHeight,
          color: Colors.black.withOpacity(0.55),
        ),

        // 2. Centered Reward layout panel
        Center(
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: isCompact ? 460 : 540,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: ColorSystem.cream,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorSystem.plum, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.24),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  )
                ],
              ),
              child: Row(
                children: [
                  // Left panel: Info, Chest & Payout breakdown
                  Expanded(
                    flex: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l(widget.reward.title).toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l(widget.reward.subtitle),
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.plum.withOpacity(0.55),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Production Vector Chest Animation Container
                        SizedBox(
                          height: 70,
                          child: AnimatedBuilder(
                            animation: _chestBounceController,
                            builder: (context, child) {
                              final double scale = 1.0 + sin(_chestBounceController.value * pi) * 0.05;
                              return Transform.scale(scale: scale, child: child);
                            },
                            child: VectorAssetHelper.chestIcon(
                              size: 64,
                              isOpen: _chestOpened,
                              isEpic: widget.reward.title.contains('MASTER'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Earned items card breakdown using Production Assets
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1.2),
                          ),
                          child: Column(
                            children: _rewardsList.map((reward) {
                              Widget iconWidget = VectorAssetHelper.xpStarIcon(size: 16);
                              String text = '';

                              if (reward.type == RewardType.xp) {
                                iconWidget = VectorAssetHelper.xpStarIcon(size: 16);
                                text = '+${reward.amount} XP';
                              } else if (reward.type == RewardType.coins) {
                                iconWidget = VectorAssetHelper.questCoinIcon(size: 16);
                                text = '+${reward.amount} ${l('quest_coins')}';
                              } else if (reward.type == RewardType.collectible) {
                                iconWidget = VectorAssetHelper.collectibleIcon(
                                  reward.assetPath.isNotEmpty ? reward.assetPath : reward.name,
                                  size: 16,
                                );
                                text = l(reward.name);
                              } else if (reward.type == RewardType.badge) {
                                iconWidget = VectorAssetHelper.badgeIcon(reward.name, size: 16);
                                text = '${l(reward.name)} ${l('Badge')}';
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.5),
                                child: Row(
                                  children: [
                                    iconWidget,
                                    const SizedBox(width: 8),
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: ColorSystem.plum,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Claim Button
                        CustomButton(
                          text: _claimedConfirmed
                              ? '${l('daily_reward_claimed_msg')} ✓'
                              : (_isClaiming ? l('CLAIMING...') : l('claim_reward_btn_label')),
                          backgroundColor: _claimedConfirmed ? ColorSystem.green : ColorSystem.purple,
                          textColor: Colors.white,
                          height: 38,
                          onPressed: (_isClaiming || _claimedConfirmed) ? () {} : _claimReward,
                        ),
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.plum),

                  // Right panel: Happy Dendy Mascot SUCCESS speech
                  Expanded(
                    flex: 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const DendyMascot(
                          state: DendyState.success,
                          size: 76,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorSystem.plum, width: 1.5),
                          ),
                          child: Text(
                            l('awesome_adventure_reward_msg'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              color: ColorSystem.plum,
                              fontWeight: FontWeight.bold,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Floating Particles Flight Layer with Production SVG Assets
        if (_isClaiming)
          IgnorePointer(
            child: Stack(
              children: _particles.where((p) => !p.arrived).map((p) {
                return Positioned(
                  left: p.currentPos.dx - 12,
                  top: p.currentPos.dy - 12,
                  child: p.buildWidget(),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


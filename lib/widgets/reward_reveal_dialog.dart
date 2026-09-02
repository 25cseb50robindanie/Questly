import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/reward_definition.dart';
import '../models/roadmap_enums.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';
import '../services/localization_service.dart';

class RewardRevealDialog extends StatefulWidget {
  final String studentId;
  final List<String> rewardIds;
  final String title;
  final int? earnedStars;
  final VoidCallback onClaimed;

  const RewardRevealDialog({
    Key? key,
    required this.studentId,
    required this.rewardIds,
    this.title = 'REWARD UNLOCKED!',
    this.earnedStars,
    required this.onClaimed,
  }) : super(key: key);

  @override
  _RewardRevealDialogState createState() => _RewardRevealDialogState();
}

class _RewardRevealDialogState extends State<RewardRevealDialog> with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  late AnimationController _burstController;
  late Animation<double> _burstAnimation;

  bool _isOpened = false;
  bool _isClaiming = false;
  List<RewardDefinition> _rewardsList = [];

  @override
  void initState() {
    super.initState();
    // Load reward objects
    _rewardsList = widget.rewardIds
        .map((rid) => Locator.roadmapRepository.getRewardById(rid))
        .where((r) => r != null)
        .cast<RewardDefinition>()
        .toList();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.bounceOut),
      ),
    );

    // Shaking oscillation for chest opening anticipation
    _shakeAnimation = Tween<double>(begin: 0.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticIn),
      ),
    );

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _burstAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _burstController, curve: Curves.easeOutBack),
    );

    _animController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isOpened = true;
        });
        SoundService.playClick();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  Future<void> _claimAll() async {
    if (_isClaiming) return;
    setState(() {
      _isClaiming = true;
    });

    SoundService.playChestOpen();
    _burstController.forward();

    for (var reward in _rewardsList) {
      await Locator.rewardService.claimReward(widget.studentId, reward.id);
      if (reward.type == RewardType.coins) {
        SoundService.playCoinCollect();
      } else {
        SoundService.playXpCollect();
      }
    }

    await Future.delayed(const Duration(milliseconds: 400));
    SoundService.playSwitch();
    widget.onClaimed();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ColorSystem.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorSystem.plum, width: 2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l(widget.title).toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Production Vector Chest Container
              SizedBox(
                height: 100,
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    double angle = 0.0;
                    if (_animController.value >= 0.4 && _animController.value < 0.8) {
                      angle = _shakeAnimation.value *
                          (0.5 - ((_animController.value - 0.6).abs() * 5.0)) *
                          ((_animController.value * 100).toInt() % 2 == 0 ? 1 : -1);
                    }

                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: angle,
                        child: child,
                      ),
                    );
                  },
                  child: Center(
                    child: VectorAssetHelper.chestIcon(
                      size: 64,
                      isOpen: _isOpened,
                      isEpic: widget.title.contains('EXPEDITION'),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Rewards lists transition using Production Assets
              if (_isOpened) ...[
                // Achievement Stars display (if applicable)
                if (widget.earnedStars != null && widget.earnedStars! > 0) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: ColorSystem.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ColorSystem.gold, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              for (int s = 1; s <= 3; s++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: VectorAssetHelper.xpStarIcon(
                                    size: 16,
                                    isFilled: s <= widget.earnedStars!,
                                  ),
                                ),
                              const SizedBox(width: 6),
                              const Flexible(
                                child: Text(
                                  'Quest Performance',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: ColorSystem.plum,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.earnedStars} / 3 Stars',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Column(
                  children: _rewardsList.map((reward) {
                    Widget iconWidget = VectorAssetHelper.xpStarIcon(size: 18);
                    String details = '';

                    switch (reward.type) {
                      case RewardType.xp:
                        iconWidget = VectorAssetHelper.xpStarIcon(size: 18);
                        details = '+${reward.amount} XP';
                        break;
                      case RewardType.coins:
                        iconWidget = VectorAssetHelper.questCoinIcon(size: 18);
                        details = '+${reward.amount} ${l('quest_coins')}';
                        break;
                      case RewardType.collectible:
                        iconWidget = VectorAssetHelper.collectibleIcon(
                          reward.assetPath.isNotEmpty ? reward.assetPath : reward.name,
                          size: 18,
                        );
                        details = l(reward.name);
                        break;
                      case RewardType.badge:
                        iconWidget = VectorAssetHelper.badgeIcon(reward.name, size: 18);
                        details = '${l(reward.name)} ${l('Badge')}';
                        break;
                      case RewardType.cosmetic:
                        iconWidget = VectorAssetHelper.shopRewardIcon(reward.assetPath, size: 18);
                        details = l(reward.name);
                        break;
                      case RewardType.chest:
                        iconWidget = VectorAssetHelper.chestIcon(size: 18, isEpic: true);
                        details = l('Master Chest Unlocked');
                        break;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              iconWidget,
                              const SizedBox(width: 8),
                              Text(
                                l(reward.name),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSystem.plum,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            details,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                CustomButton(
<<<<<<< HEAD
                  text: l('claim_reward_btn_label'),
=======
                  text: _isClaiming ? 'COLLECTING...' : 'CLAIM REWARD',
>>>>>>> cdff187 (Final Fraction Dont Disturb me BYe)
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  height: 38,
                  onPressed: _claimAll,
                ),
              ] else ...[
                Text(
                  l('opening_chest'),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

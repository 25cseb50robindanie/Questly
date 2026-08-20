import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/daily_reward_service.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';

class DailyRewardOverlay extends StatefulWidget {
  final Student student;
  final VoidCallback onDismissed;

  const DailyRewardOverlay({
    Key? key,
    required this.student,
    required this.onDismissed,
  }) : super(key: key);

  static Future<void> showIfNeeded(BuildContext context, Student student) async {
    final available = Locator.dailyRewardService.isRewardAvailableToday(student.questlyId);
    if (!available) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => DailyRewardOverlay(
        student: student,
        onDismissed: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  _DailyRewardOverlayState createState() => _DailyRewardOverlayState();
}

class _DailyRewardOverlayState extends State<DailyRewardOverlay> with TickerProviderStateMixin {
  late AnimationController _dropController;
  late AnimationController _shakeController;
  late AnimationController _openController;
  late AnimationController _burstController;

  late Animation<double> _dropAnim;
  late Animation<double> _shakeAnim;
  late Animation<double> _burstAnim;

  bool _isClaimed = false;
  DailyRewardItem? _claimedReward;
  final List<Offset> _coinParticles = [];

  @override
  void initState() {
    super.initState();

    // 1. Drop & bounce animation
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _dropAnim = CurvedAnimation(parent: _dropController, curve: Curves.elasticOut);

    // 2. Continuous chest shaking
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnim = Tween<double>(begin: -0.06, end: 0.06).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    // 3. Chest burst & coins
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _burstAnim = CurvedAnimation(parent: _burstController, curve: Curves.easeOutCubic);

    // Generate random particle burst trajectories
    final rand = Random();
    for (int i = 0; i < 24; i++) {
      final angle = rand.nextDouble() * 2 * pi;
      final speed = 80 + rand.nextDouble() * 120;
      _coinParticles.add(Offset(cos(angle) * speed, sin(angle) * speed - 60));
    }

    _dropController.forward().then((_) {
      _shakeController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _dropController.dispose();
    _shakeController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    SoundService.playStarPop();
    _shakeController.stop();
    _burstController.forward();

    final reward = await Locator.dailyRewardService.claimTodayReward(widget.student.questlyId);

    setState(() {
      _isClaimed = true;
      _claimedReward = reward;
    });

    SoundService.playLevelComplete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;
    final currentStreak = Locator.dailyRewardService.getCurrentStreakDay(widget.student.questlyId);
    final todayReward = Locator.dailyRewardService.getRewardForDay(currentStreak);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Center(
        child: AnimatedBuilder(
          animation: _dropAnim,
          builder: (context, child) {
            return Transform.scale(
              scale: _dropAnim.value,
              child: child,
            );
          },
          child: Container(
            width: isShort ? 390 : 440,
            constraints: BoxConstraints(maxHeight: size.height * 0.95),
            padding: EdgeInsets.all(isShort ? 14 : 20),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ColorSystem.plum, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.gold.withOpacity(0.35),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title Banner
                  Text(
                    _isClaimed ? l('reward_claimed') : l('daily_login_reward'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 18 : 22,
                      fontWeight: FontWeight.w900,
                      color: _isClaimed ? ColorSystem.green : ColorSystem.purple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isClaimed
                      ? (currentStreak >= 7 ? l('streak_complete') : l('come_back_tomorrow', args: {'day': '${(currentStreak % 7) + 1}'}))
                      : l('day_streak', args: {'day': '$currentStreak'}),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 10 : 11.5,
                      fontWeight: FontWeight.w600,
                      color: ColorSystem.plum.withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: isShort ? 10 : 14),

                  // Center Animated Chest with Particle Burst
                  SizedBox(
                    height: isShort ? 90 : 115,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow Background
                        Container(
                          width: isShort ? 90 : 110,
                          height: isShort ? 90 : 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorSystem.gold.withOpacity(_isClaimed ? 0.35 : 0.15),
                          ),
                        ),

                        // Burst Particles on Claim
                        if (_isClaimed)
                          AnimatedBuilder(
                            animation: _burstAnim,
                            builder: (context, _) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  for (int i = 0; i < _coinParticles.length; i++) ...[
                                    Transform.translate(
                                      offset: Offset(
                                        _coinParticles[i].dx * _burstAnim.value,
                                        _coinParticles[i].dy * _burstAnim.value,
                                      ),
                                      child: Opacity(
                                        opacity: (1.0 - _burstAnim.value).clamp(0.0, 1.0),
                                        child: i % 2 == 0
                                            ? VectorAssetHelper.questCoinIcon(size: 16)
                                            : VectorAssetHelper.xpStarIcon(size: 16),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),

                        // Shaking / Open Chest
                        AnimatedBuilder(
                          animation: _shakeAnim,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _isClaimed ? 0 : _shakeAnim.value,
                              child: child,
                            );
                          },
                          child: _isClaimed
                              ? VectorAssetHelper.shopRewardIcon('reward_chest', size: isShort ? 64 : 80)
                              : VectorAssetHelper.shopRewardIcon('reward_chest', size: isShort ? 64 : 80),
                        ),
                      ],
                    ),
                  ),

                  // Payout Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorSystem.gold, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VectorAssetHelper.questCoinIcon(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+${todayReward.coins} COINS',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.gold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        VectorAssetHelper.xpStarIcon(size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+${todayReward.xp} XP',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isShort ? 10 : 14),

                  // 7-Day Streak Cycle Bar
                  _buildStreakTrack(currentStreak, isShort),
                  SizedBox(height: isShort ? 12 : 16),

                  // Action Button
                  if (!_isClaimed)
                    CustomButton(
                      text: '${l('claim_reward')}! 🎁',
                      backgroundColor: ColorSystem.green,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _handleClaim,
                    )
                  else
                    CustomButton(
                      text: "${l('continue_adventure')}! 🚀",
                      backgroundColor: ColorSystem.purple,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: widget.onDismissed,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakTrack(int activeDay, bool isShort) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int day = 1; day <= 7; day++) ...[
            _buildStreakDayItem(day, day == activeDay, day < activeDay, isShort),
          ],
        ],
      ),
    );
  }

  Widget _buildStreakDayItem(int day, bool isToday, bool isDone, bool isShort) {
    final reward = DailyRewardService.streakRewards[day - 1];

    return Container(
      width: isShort ? 44 : 50,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      decoration: BoxDecoration(
        color: isToday
            ? ColorSystem.gold.withOpacity(0.2)
            : (isDone ? ColorSystem.green.withOpacity(0.1) : ColorSystem.cream.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isToday
              ? ColorSystem.gold
              : (isDone ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15)),
          width: isToday ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            l('streak_day', args: {'day': '$day'}),
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 8 : 9,
              fontWeight: FontWeight.w900,
              color: isToday
                  ? ColorSystem.plum
                  : (isDone ? ColorSystem.green : ColorSystem.plum.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 4),
          if (isDone)
            const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 16)
          else if (day == 7)
            const Icon(Icons.card_giftcard_rounded, color: ColorSystem.purple, size: 16)
          else
            VectorAssetHelper.questCoinIcon(size: 14),
          const SizedBox(height: 2),
          Text(
            day == 7 ? 'Mystery' : '+${reward.coins}',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 7.5 : 8.5,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

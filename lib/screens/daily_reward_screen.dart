import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/daily_reward_widgets.dart';
import '../widgets/resource_counter.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/vector_asset_helper.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({Key? key}) : super(key: key);

  @override
  _DailyRewardScreenState createState() => _DailyRewardScreenState();
}

class _DailyRewardScreenState extends State<DailyRewardScreen> with TickerProviderStateMixin {
  Student? _student;
  bool _claimed = false;
  late AnimationController _bounceController;
  late AnimationController _confettiController;
  final List<Offset> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _loadState();

    // Bobbing bounce animation for "Today's" reward card
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Confetti particles controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Generate random confetti offsets
    final rand = Random();
    for (int i = 0; i < 40; i++) {
      _confettiParticles.add(Offset(
        rand.nextDouble() * 400 - 200,
        rand.nextDouble() * 250 - 200,
      ));
    }
  }

  void _loadState() {
    final s = Locator.studentRepository.getCurrentStudent();
    if (s != null) {
      final key = 'daily_claimed_${s.questlyId}';
      setState(() {
        _student = s;
        _claimed = Locator.storageService.getBool(key) ?? false;
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Claim Daily Rewards Payout
  Future<void> _handleClaim() async {
    if (_student == null || _claimed) return;

    SoundService.playClick();
    _confettiController.forward();

    // Award +200 XP, +100 Coins, unlock Rare Badge
    int newXp = _student!.xp + 200;
    int level = _student!.level;
    int xpReq = level * 200;
    while (newXp >= xpReq) {
      newXp -= xpReq;
      level++;
      xpReq = level * 200;
    }

    final updated = _student!.copyWith(
      xp: newXp,
      level: level,
      gold: _student!.gold + 100,
    );

    await Locator.studentRepository.updateStudentProfile(updated);
    await Locator.collectionRepository.unlockBadge(_student!.questlyId, 'Float Master');

    // Save claim status locally
    final key = 'daily_claimed_${_student!.questlyId}';
    await Locator.storageService.setBool(key, true);

    setState(() {
      _claimed = true;
      _student = updated;
    });

    // Alert notification banner
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Daily reward claimed! +200 XP, +100 Quest Coins added.',
          style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
        ),
        backgroundColor: ColorSystem.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isCompact = screenHeight < 360;

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    // 1. HEADER ROW
                    _buildHeaderRow(isCompact),
                    const SizedBox(height: 8),

                    // 2. MAIN LAYOUT
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left side: 7-Day track + Streak Milestone (Takes 12 flex)
                          Expanded(
                            flex: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Horizontal calendar
                                _buildCalendarTrack(isCompact),
                                const SizedBox(height: 8),
                                // Streak milestones progress
                                _buildStreakProgress(isCompact),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Right side: Today's Claim panel + Dendy Mascot (Takes 9 flex)
                          Expanded(
                            flex: 9,
                            child: _buildTodayClaimPanel(isCompact),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Confetti Overlay after claiming reward
              if (_claimed)
                IgnorePointer(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (context, child) {
                        return Stack(
                          children: _confettiParticles.map((offset) {
                            final double progress = _confettiController.value;
                            final double x = offset.dx * progress;
                            final double y = offset.dy * progress + (progress * progress * 150.0);
                            final double opacity = (1.0 - progress).clamp(0.0, 1.0);

                            return Positioned(
                              left: MediaQuery.of(context).size.width / 2 + x,
                              top: MediaQuery.of(context).size.height / 2 + y,
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: [
                                      ColorSystem.gold,
                                      ColorSystem.green,
                                      ColorSystem.purple,
                                      ColorSystem.pink,
                                      Colors.blue
                                    ][(_confettiParticles.indexOf(offset)) % 5],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(bool isCompact) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Navigation + Title
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    VectorAssetHelper.xpStarIcon(size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'Daily Reward',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
                if (!isCompact)
                  Text(
                    'Complete today\'s learning and claim your reward!',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      color: ColorSystem.plum.withOpacity(0.55),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Right side indicators (Streak, Coins, XP)
        Row(
          children: [
            // Streak Flame badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorSystem.pink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ColorSystem.pink.withOpacity(0.35), width: 1),
              ),
              child: Row(
                children: const [
                  Text('🔥 ', style: TextStyle(fontSize: 12)),
                  Text(
                    '15 Day Streak',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.pink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Coins counter
            ResourceCounter(
              iconWidget: VectorAssetHelper.questCoinIcon(size: 18),
              value: '${_student!.gold}',
            ),
            const SizedBox(width: 8),

            // XP Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorSystem.plum, width: 1.2),
              ),
              child: Row(
                children: [
                  VectorAssetHelper.xpStarIcon(size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_student!.xp} XP',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }


  // 7-day horizontal calendar track
  Widget _buildCalendarTrack(bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REWARD TRACKER',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum.withOpacity(0.55),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: isCompact ? 76 : 94,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayCard(1, '50 XP', const Icon(Icons.insights_rounded, color: ColorSystem.purple, size: 20), 'completed', isCompact),
              _buildDayCard(2, 'Shard', const KnowledgeShardWidget(size: 24), 'completed', isCompact),
              _buildDayCard(3, 'Quest Gem', const QuestGemWidget(size: 24), 'completed', isCompact),
              _buildDayCard(4, 'Potion', const FocusPotionWidget(size: 24), 'completed', isCompact),
              _buildDayCard(5, 'Epic Chest', const EpicChestWidget(size: 32), 'today', isCompact),
              _buildDayCard(6, 'Gift Box', const MysteryGiftWidget(size: 24), 'tomorrow', isCompact),
              _buildDayCard(7, 'Treasure', const BasicChestWidget(size: 24), 'locked', isCompact),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(int dayNum, String label, Widget iconWidget, String state, bool isCompact) {
    final isCompleted = state == 'completed';
    final isToday = state == 'today';
    final isTomorrow = state == 'tomorrow';

    Color borderCol = ColorSystem.plum.withOpacity(0.18);
    Color bg = Colors.white;
    if (isCompleted) {
      borderCol = ColorSystem.green;
      bg = ColorSystem.green.withOpacity(0.04);
    } else if (isToday) {
      borderCol = ColorSystem.gold;
    }

    return Expanded(
      child: AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          // Subtle bobbing bounce for the active "Today" card
          final double translation = isToday ? sin(_bounceController.value * pi) * -4.0 : 0.0;
          return Transform.translate(
            offset: Offset(0, translation),
            child: child,
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderCol, width: isToday ? 2.2 : 1.2),
            boxShadow: [
              if (isToday)
                BoxShadow(
                  color: ColorSystem.gold.withOpacity(0.18),
                  offset: const Offset(0, 3),
                  blurRadius: 4,
                )
            ],
          ),
          child: Stack(
            children: [
              // Locked blur effect on upcoming tomorrow nodes
              if (isTomorrow || state == 'locked')
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: Colors.grey.withOpacity(0.05),
                    ),
                  ),
                ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Day $dayNum',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCompact ? 8 : 9,
                      fontWeight: FontWeight.bold,
                      color: isToday ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.55),
                    ),
                  ),
                  Center(child: iconWidget),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isCompact ? 8 : 9,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ),
                ],
              ),

              // Tomorrow ribbon
              if (isTomorrow)
                Positioned(
                  bottom: 2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'TOMORROW',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 5.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              // Completed checkmark
              if (isCompleted)
                const Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Learning streak milestone trackers
  Widget _buildStreakProgress(bool isCompact) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorSystem.plum, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('🔥 ', style: TextStyle(fontSize: 14)),
                Text(
                  'learning_streak'.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '15 Days',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.pink,
                  ),
                ),
              ],
            ),

            // Milestone horizontal progress bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorSystem.cream,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.5, // 50% toward 30 Days
                        child: Container(
                          decoration: BoxDecoration(
                            color: ColorSystem.pink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Milestones chests triggers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMilestoneNode('7 Days', true, isCompact),
                _buildMilestoneNode('14 Days', true, isCompact),
                _buildMilestoneNode('30 Days', false, isCompact),
                _buildMilestoneNode('60 Days', false, isCompact),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneNode(String label, bool isUnlocked, bool isCompact) {
    return Row(
      children: [
        Icon(
          isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          color: isUnlocked ? ColorSystem.green : Colors.grey,
          size: 11,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isCompact ? 8 : 9,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }

  // Today's Epic chest claim card
  Widget _buildTodayClaimPanel(bool isCompact) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
      ),
      child: Row(
        children: [
          // Left side: Epic chest animation + claim buttons
          Expanded(
            flex: 12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TODAY\'S REWARD',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),

                // Animated Epic Chest
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    final double translation = sin(_bounceController.value * pi) * -5.0;
                    return Transform.translate(
                      offset: Offset(0, translation),
                      child: child,
                    );
                  },
                  child: const EpicChestWidget(size: 70),
                ),

                // Rewards listing description
                Column(
                  children: [
                    _buildTodayRewardItem(VectorAssetHelper.xpStarIcon(size: 14), '+200 XP'),
                    const SizedBox(height: 2),
                    _buildTodayRewardItem(VectorAssetHelper.questCoinIcon(size: 14), '+100 Quest Coins'),
                    const SizedBox(height: 2),
                    _buildTodayRewardItem(VectorAssetHelper.badgeIcon('Float Master', size: 14), 'Rare Float Badge'),
                  ],
                ),

                // Claim Actions
                CustomButton(
                  text: _claimed ? 'CLAIMED ✓' : 'CLAIM REWARD',
                  backgroundColor: _claimed ? ColorSystem.green : ColorSystem.purple,
                  textColor: Colors.white,
                  height: isCompact ? 34 : 38,
                  onPressed: _claimed ? () {} : _handleClaim,
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

          // Right side: Happy Dendy Fox
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DendyMascot(
                  state: DendyState.success, // happy ^^ eyes state
                  size: 64,
                ),
                const SizedBox(height: 6),
                // Speech Bubble Container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.plum, width: 1.5),
                  ),
                  child: Text(
                    _claimed
                        ? "Wow! You claimed today's epic rewards!"
                        : "Awesome! Complete today's lesson and this reward is yours!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 8.5,
                      color: ColorSystem.plum,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRewardItem(Widget iconWidget, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }
}


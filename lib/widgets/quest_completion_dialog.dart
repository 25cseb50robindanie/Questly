import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'level_up_dialog.dart';
import 'vector_asset_helper.dart';

class QuestCompletionDialog extends StatefulWidget {
  final int xpReward;
  final int goldReward;
  final int earnedStars;
  final String title;
  final String message;
  final VoidCallback? onContinue;

  const QuestCompletionDialog({
    Key? key,
    required this.xpReward,
    required this.goldReward,
    this.earnedStars = 3,
    this.title = 'QUEST COMPLETE!',
    this.message = 'Fantastic job! You mastered this challenge and earned rewards.',
    this.onContinue,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required int xpReward,
    required int goldReward,
    int earnedStars = 3,
    String title = 'QUEST COMPLETE!',
    String message = 'Fantastic job! You mastered this challenge and earned rewards.',
    VoidCallback? onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuestCompletionDialog(
        xpReward: xpReward,
        goldReward: goldReward,
        earnedStars: earnedStars,
        title: title,
        message: message,
        onContinue: onContinue,
      ),
    );
  }

  @override
  _QuestCompletionDialogState createState() => _QuestCompletionDialogState();
}

class _QuestCompletionDialogState extends State<QuestCompletionDialog> {
  int _visibleStars = 0;
  bool _rewardsVisible = false;

  @override
  void initState() {
    super.initState();
    _startPoppingSequence();
  }

  Future<void> _startPoppingSequence() async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    // Pop Star 1
    if (widget.earnedStars >= 1) {
      setState(() => _visibleStars = 1);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Pop Star 2
    if (!mounted) return;
    if (widget.earnedStars >= 2) {
      setState(() => _visibleStars = 2);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Pop Star 3
    if (!mounted) return;
    if (widget.earnedStars >= 3) {
      setState(() => _visibleStars = 3);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 350));
    }

    // Reveal rewards panel with full level-completion fanfare!
    if (!mounted) return;
    setState(() => _rewardsVisible = true);
    SoundService.playLevelComplete();
  }

  Future<void> _handleContinue() async {
    SoundService.playClick();

    // Check level up from current student state
    final student = Locator.studentRepository.getCurrentStudent();
    int? finalLevel;
    if (student != null) {
      final nextLevelXp = student.level * 200;
      if (student.xp >= nextLevelXp) {
        finalLevel = student.level + 1;
        await Locator.studentRepository.updateStudentProfile(
          student.copyWith(level: finalLevel, xp: student.xp - nextLevelXp),
        );
      }
    }

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Dismiss completion dialog

    if (finalLevel != null && mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => LevelUpDialog(
          newLevel: finalLevel!,
          onDismissed: () {
            _navigateToRoadmap();
          },
        ),
      );
    } else {
      _navigateToRoadmap();
    }
  }

  void _navigateToRoadmap() {
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(context, '/roadmap');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Container(
          width: isShort ? 380 : 440,
          padding: EdgeInsets.all(isShort ? 16 : 22),
          decoration: BoxDecoration(
            color: ColorSystem.cream,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: ColorSystem.plum, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.22),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Banner
              Text(
                widget.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 18 : 22,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: isShort ? 4 : 8),

              // Description Text
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 10.5 : 12,
                  fontWeight: FontWeight.w600,
                  color: ColorSystem.purple,
                  height: 1.3,
                ),
              ),
              SizedBox(height: isShort ? 10 : 16),

              // 3 Stars Animated Popping Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 3; i++) ...[
                    AnimatedScale(
                      scale: i <= _visibleStars ? (i == 2 ? 1.35 : 1.15) : 0.75,
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.elasticOut,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: VectorAssetHelper.xpStarIcon(
                          size: i == 2 ? (isShort ? 42 : 52) : (isShort ? 34 : 42),
                          color: i <= _visibleStars ? ColorSystem.gold : ColorSystem.plum.withOpacity(0.2),
                          isFilled: i <= _visibleStars,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isShort ? 10 : 16),

              // Prominent Rewards Panel & Action Button
              AnimatedOpacity(
                opacity: _rewardsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isShort ? 12 : 16,
                        vertical: isShort ? 8 : 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              VectorAssetHelper.xpStarIcon(size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.xpReward} XP',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: isShort ? 12 : 14,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: isShort ? 16 : 24),
                          Row(
                            children: [
                              VectorAssetHelper.questCoinIcon(size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.goldReward} COINS',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: isShort ? 12 : 14,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.gold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isShort ? 12 : 18),

                    // CONTINUE TO ROADMAP Button
                    CustomButton(
                      text: 'CONTINUE TO ROADMAP',
                      backgroundColor: ColorSystem.green,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _rewardsVisible ? _handleContinue : () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

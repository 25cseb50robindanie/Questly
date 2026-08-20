import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../models/roadmap_enums.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/level_up_dialog.dart';
import '../widgets/reward_claim_overlay.dart';
import '../services/sound_service.dart';

class ActivityRendererScreen extends StatefulWidget {
  const ActivityRendererScreen({Key? key}) : super(key: key);

  @override
  _ActivityRendererScreenState createState() => _ActivityRendererScreenState();
}

class _ActivityRendererScreenState extends State<ActivityRendererScreen> {
  Activity? _activity;
  Student? _student;
  bool _quizAnswered = false;
  bool _quizCorrect = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_activity == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Activity) {
        _activity = args;
      } else if (args is Lesson && args.activities.isNotEmpty) {
        _activity = args.activities.first;
      } else if (args is String) {
        // Look up by activity id
        _activity = Locator.moduleRepository.getActivityById(args);
      }
      
      // Fallback if null
      _activity ??= Activity(
        id: 'act_fallback',
        title: 'Learning Challenge',
        instruction: 'Complete this learning activity to earn rewards.',
        type: 'info',
        targetDensity: 0.0,
        targetCondition: '',
        xpReward: 20,
        goldReward: 5,
      );

      _student = Locator.studentRepository.getCurrentStudent();
      _handleRouting();
    }
  }

  void _handleRouting() {
    if (_activity!.type == 'discovery_curiosity' || _activity!.id == 'act_density_curiosity') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.pushReplacementNamed(
          context,
          '/curiosity_discovery',
          arguments: _activity,
        );
      });
      return;
    }

    if (_activity!.type == 'experiment' || _activity!.id == 'act_density_experiment') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.pushReplacementNamed(
          context,
          '/density_experiment',
          arguments: _activity,
        );
      });
      return;
    }

    if (_activity!.type == 'flameGame') {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.pushReplacementNamed(
          context,
          '/game',
          arguments: _activity,
        );
      });
    }
  }

  // Handle completed reward payouts with 3-Star Sequence & Level-Up check
  Future<void> _completeActivity() async {
    if (_student == null || _activity == null) return;

    final sId = _student!.questlyId.toLowerCase();
    
    // Resolve dynamic lesson ID to guarantee proper node unlocking
    String lessonId = 'density_les1';
    if (_student!.currentLessonId != null && _student!.currentLessonId!.isNotEmpty) {
      lessonId = _student!.currentLessonId!;
    } else if (_activity!.id.contains('les2') || _activity!.id.contains('node3')) {
      lessonId = 'density_les2';
    } else if (_activity!.id.contains('les3') || _activity!.id.contains('node5')) {
      lessonId = 'density_les3';
    } else if (_activity!.id.contains('les4') || _activity!.id.contains('node6')) {
      lessonId = 'density_les4';
    }

    // Save completed progress with 3 stars (1.0 score = 3 stars)
    await Locator.progressRepository.saveProgress(Progress(
      studentId: sId,
      lessonId: lessonId,
      status: 'completed',
      score: 1.0,
      stars: 3,
      attempts: 1,
      lastPlayed: DateTime.now(),
      completedAt: DateTime.now(),
    ));

    final oldLevel = _student!.level;

    // Award XP and Coins
    final updatedStudent = _student!.copyWith(
      xp: _student!.xp + _activity!.xpReward,
      gold: _student!.gold + _activity!.goldReward,
    );

    // Evaluate level ups
    final nextLevelXp = updatedStudent.level * 200;
    int finalLevel = updatedStudent.level;
    int finalXp = updatedStudent.xp;
    if (finalXp >= nextLevelXp) {
      finalLevel++;
      finalXp = finalXp - nextLevelXp;
    }

    await Locator.studentRepository.updateStudentProfile(
      updatedStudent.copyWith(level: finalLevel, xp: finalXp),
    );

    bool didLevelUp = finalLevel > oldLevel;

    if (!mounted) return;

    // Show Sequential Quest Completion Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return _QuestCompletionSequenceDialog(
          xpReward: _activity!.xpReward,
          goldReward: _activity!.goldReward,
          earnedStars: 3,
          onClaimed: () {
            Navigator.pop(context); // Close completion dialog

            if (didLevelUp) {
              // Trigger Level-Up Celebration modal
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => LevelUpDialog(
                  newLevel: finalLevel,
                  onDismissed: () {
                    if (mounted) Navigator.pop(context); // Return to Roadmap
                  },
                ),
              );
            } else {
              if (mounted) Navigator.pop(context); // Return to Roadmap
            }
          },
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // If routing to Flame, render blank loading loader
    if (_activity == null || _activity!.type == 'flameGame') {
      return const Scaffold(
        backgroundColor: ColorSystem.cream,
        body: Center(
          child: CircularProgressIndicator(color: ColorSystem.purple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row (Back navigation)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _activity!.title.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Main card body
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left half: Instruction card & Mascot Dendy tips
                        Expanded(
                          flex: 11,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LAB DESCRIPTION',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSystem.plum.withOpacity(0.55),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _activity!.instruction,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 14,
                                      color: ColorSystem.plum,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                              DendyMascot(
                                state: _quizAnswered && !_quizCorrect ? DendyState.confused : DendyState.idle,
                                message: _quizAnswered && !_quizCorrect
                                    ? 'Keep trying! Think about the density formula.'
                                    : 'Carefully check the parameters before selecting your answer!',
                                size: 76,
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(width: 32, thickness: 1.5, color: ColorSystem.cream),
                        // Right half: Interactive choices or Complete CTA
                        Expanded(
                          flex: 9,
                          child: _buildInteractiveInteractiveWidget(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Interactive component helper based on type
  Widget _buildInteractiveInteractiveWidget() {
    if (_activity!.type == 'flashcard') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorSystem.lavender.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
            ),
            child: const Text(
              '💡 CONCEPT TRIVIA\n\nDensity tells us how heavy a material is relative to its sizing. Wood floating is due to low buoyancy displacement matching.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 12,
                color: ColorSystem.plum,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'I UNDERSTAND',
            backgroundColor: ColorSystem.purple,
            textColor: Colors.white,
            onPressed: _completeActivity,
          ),
        ],
      );
    }

    if (_activity!.type == 'scenario') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
            ),
            child: const Text(
              '🧪 SCENARIO TEST\n\nIf you drop a stone into a cylinder containing 50 mL of water, and the level rises to 65 mL, what is the stone\'s volume?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 12,
                color: ColorSystem.plum,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: '15 mL',
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  onPressed: _completeActivity,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: '115 mL',
                  backgroundColor: ColorSystem.cream,
                  textColor: ColorSystem.plum,
                  onPressed: () {
                    setState(() {
                      _quizAnswered = true;
                      _quizCorrect = false;
                    });
                    SoundService.playSwitch();
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Default Quiz type
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'SELECT CORRECT OPTION',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: ColorSystem.purple,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildQuizOption('Density = Mass / Volume', true),
        const SizedBox(height: 10),
        _buildQuizOption('Density = Mass * Volume', false),
        const SizedBox(height: 10),
        _buildQuizOption('Density = Volume / Mass', false),
      ],
    );
  }

  Widget _buildQuizOption(String text, bool isCorrect) {
    return GestureDetector(
      onTap: () {
        if (isCorrect) {
          _completeActivity();
        } else {
          setState(() {
            _quizAnswered = true;
            _quizCorrect = false;
          });
          SoundService.playSwitch(); // Error sound
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorSystem.plum, width: 1.5),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ),
    );
  }
}

// Sequential 3-Star Quest Completion Dialog
class _QuestCompletionSequenceDialog extends StatefulWidget {
  final int xpReward;
  final int goldReward;
  final int earnedStars;
  final VoidCallback onClaimed;

  const _QuestCompletionSequenceDialog({
    Key? key,
    required this.xpReward,
    required this.goldReward,
    required this.earnedStars,
    required this.onClaimed,
  }) : super(key: key);

  @override
  _QuestCompletionSequenceDialogState createState() => _QuestCompletionSequenceDialogState();
}

class _QuestCompletionSequenceDialogState extends State<_QuestCompletionSequenceDialog> {
  int _visibleStars = 0;
  bool _rewardsVisible = false;

  @override
  void initState() {
    super.initState();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Pop star 1
    if (widget.earnedStars >= 1) {
      setState(() => _visibleStars = 1);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 320));
    }

    // Pop star 2
    if (!mounted) return;
    if (widget.earnedStars >= 2) {
      setState(() => _visibleStars = 2);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 320));
    }

    // Pop star 3
    if (!mounted) return;
    if (widget.earnedStars >= 3) {
      setState(() => _visibleStars = 3);
      SoundService.playStarPop();
      await Future.delayed(const Duration(milliseconds: 320));
    }

    // Reveal rewards panel with 3-star level completion fanfare
    if (!mounted) return;
    setState(() => _rewardsVisible = true);
    SoundService.playLevelComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ColorSystem.cream,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorSystem.plum, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.2),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Banner
              const Text(
                'QUEST COMPLETE',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // 3 Stars Row (Animates 1 by 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 1; i <= 3; i++) ...[
                    AnimatedScale(
                      scale: i <= _visibleStars ? 1.25 : 0.85,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.elasticOut,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: VectorAssetHelper.xpStarIcon(
                          size: 42,
                          isFilled: i <= _visibleStars,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 18),

              // Prominent Rewards Panel
              AnimatedOpacity(
                opacity: _rewardsVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              VectorAssetHelper.xpStarIcon(size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.xpReward} XP',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Row(
                            children: [
                              VectorAssetHelper.questCoinIcon(size: 20),
                              const SizedBox(width: 6),
                              Text(
                                '+${widget.goldReward} Quest Coins',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.plum,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    CustomButton(
                      text: 'CLAIM REWARD',
                      backgroundColor: ColorSystem.purple,
                      textColor: Colors.white,
                      height: 42,
                      onPressed: _rewardsVisible ? widget.onClaimed : () {},
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


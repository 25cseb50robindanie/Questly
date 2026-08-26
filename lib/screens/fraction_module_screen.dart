import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/interactive_sim_view.dart';

class FractionModuleScreen extends StatefulWidget {
  final Activity? activity;
  const FractionModuleScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionModuleScreen> createState() => _FractionModuleScreenState();
}

class _FractionModuleScreenState extends State<FractionModuleScreen> {
  Student? _student;
  Activity? _activeActivity;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_activeActivity == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Activity) {
        _activeActivity = args;
      } else {
        _activeActivity = widget.activity;
      }
    }
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
    });
  }

  void _onQuestlyEventReceived(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'QUESTLY_GAME_COMPLETE') {
      final sc = data['score'] as int? ?? 100;
      final stars = data['stars'] as int? ?? 3;
      _onModuleCompleted(sc, stars);
    } else if (type == 'QUESTLY_NAVIGATE_BACK') {
      _handleReturn();
    }
  }

  void _handleReturn() {
    debugPrint("FractionModuleScreen: _handleReturn triggered! mounted=$mounted");
    SoundService.playClick();
    try {
      if (Navigator.of(context).canPop()) {
        debugPrint("FractionModuleScreen: popping screen context");
        Navigator.of(context).pop();
      } else {
        debugPrint("FractionModuleScreen: pushReplacementNamed to roadmap");
        Navigator.pushReplacementNamed(context, '/roadmap', arguments: 'mod_fractions');
      }
    } catch (e, s) {
      debugPrint("FractionModuleScreen navigation ERROR: $e");
      debugPrintStack(stackTrace: s);
    }
  }

  Future<void> _onModuleCompleted(int finalScore, int stars) async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null && _activeActivity != null) {
      final sId = _student!.questlyId.toLowerCase();
      
      // Dynamically resolve lesson ID to prevent potential profile out-of-sync bugs
      String currentLessonId = 'fractions_les1';
      if (_activeActivity!.type == 'fraction_explore') {
        currentLessonId = 'fractions_les2';
      } else if (_activeActivity!.type == 'fraction_practice') {
        currentLessonId = 'fractions_les3';
      } else if (_activeActivity!.type == 'fraction_game') {
        currentLessonId = 'fractions_les4';
      } else if (_activeActivity!.type == 'fraction_challenge') {
        currentLessonId = 'fractions_les5';
      }

      final xpReward = _activeActivity!.xpReward;
      final goldReward = _activeActivity!.goldReward;

      // 1. Save Progress Record
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: currentLessonId,
        status: 'completed',
        score: finalScore / 100.0,
        stars: stars,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Award XP and Quest Coins (handling levels dynamically)
      final oldLevel = _student!.level;
      final updated = _student!.copyWith(
        xp: _student!.xp + xpReward,
        gold: _student!.gold + goldReward,
      );

      final nextLevelXp = updated.level * 200;
      int finalLevel = updated.level;
      int finalXp = updated.xp;
      if (finalXp >= nextLevelXp) {
        finalLevel++;
        finalXp = finalXp - nextLevelXp;
      }

      final studentToSave = updated.copyWith(level: finalLevel, xp: finalXp);
      await Locator.studentRepository.updateStudentProfile(studentToSave);

      if (mounted) {
        setState(() {
          _student = studentToSave;
        });
      }
    }

    SoundService.playLevelComplete();
    if (mounted) {
      _showCompletionDialog(finalScore, stars);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    String stage = 'concept';
    if (_activeActivity != null) {
      if (_activeActivity!.type == 'fraction_explore') stage = 'explore';
      else if (_activeActivity!.type == 'fraction_practice') stage = 'practice';
      else if (_activeActivity!.type == 'fraction_game') stage = 'game';
      else if (_activeActivity!.type == 'fraction_challenge') stage = 'challenge';
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isShort ? 10 : 16,
              vertical: isShort ? 6 : 10,
            ),
            child: Column(
              children: [
                // Top Header Bar matching Questly theme and Density layouts
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 6 : 8),

                // Main Area: Embedded Fraction Journey via HTML simulation
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: ColorSystem.plum.withOpacity(0.08),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox.expand(
                        child: InteractiveSimView(
                          viewKey: 'fraction_module_$stage',
                          simulationPath: '/fraction_module/index.html?stage=$stage',
                          onMessage: _onQuestlyEventReceived,
                        ),
                      ),
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

  Widget _buildHeaderBar(bool isShort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button + Title
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleReturn,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'MATHEMATICS • FRACTIONS & RATIOS',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  _activeActivity?.title.toUpperCase() ?? 'CANYON CROSSINGS',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 9 : 10,
                    color: ColorSystem.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Metrics: XP and Coins
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_student != null) ...[
              _buildMetricBadge(
                VectorAssetHelper.xpStarIcon(size: 14),
                '${_student!.xp} XP',
                ColorSystem.purple,
              ),
              const SizedBox(width: 6),
              _buildMetricBadge(
                VectorAssetHelper.questCoinIcon(size: 14),
                '${_student!.gold}',
                ColorSystem.gold,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBadge(Widget icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Activity? _getNextActivity() {
    if (_activeActivity == null) return null;
    final allLessons = Locator.moduleRepository.getModuleById('mod_fractions')?.levels.first.lessons ?? [];
    int currentIndex = -1;
    for (int i = 0; i < allLessons.length; i++) {
      if (allLessons[i].activities.any((act) => act.id == _activeActivity!.id)) {
        currentIndex = i;
        break;
      }
    }
    if (currentIndex != -1 && currentIndex + 1 < allLessons.length) {
      return allLessons[currentIndex + 1].activities.first;
    }
    return null;
  }

  void _handleContinueToNext() {
    final nextActivity = _getNextActivity();
    debugPrint("FractionModuleScreen: _handleContinueToNext. nextActivity=${nextActivity?.id}");
    if (nextActivity != null) {
      // Set currentLessonId on the student profile to the next lesson ID so the roadmap updates!
      final student = Locator.studentRepository.getCurrentStudent();
      if (student != null) {
        final allLessons = Locator.moduleRepository.getModuleById('mod_fractions')?.levels.first.lessons ?? [];
        try {
          final nextLesson = allLessons.firstWhere((l) => l.activities.any((a) => a.id == nextActivity.id));
          final updatedStudent = student.copyWith(
            currentLessonId: nextLesson.id,
          );
          Locator.studentRepository.updateStudentProfile(updatedStudent);
        } catch (_) {}
      }

      Navigator.pushReplacementNamed(
        context,
        '/fraction_module',
        arguments: nextActivity,
      );
    } else {
      if (_activeActivity?.id != 'act_fraction_challenge') {
        // Fail loudly!
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Error: Next lesson could not be resolved!"),
              backgroundColor: Colors.red,
            ),
          );
        } catch (_) {}
        print("CONSOLE.ERROR: Next lesson could not be resolved! _activeActivityId=${_activeActivity?.id}");
      }

      Navigator.pushReplacementNamed(
        context,
        '/roadmap',
        arguments: 'mod_fractions',
      );
    }
  }

  void _showCompletionDialog(int finalScore, int stars) {
    final xpReward = _activeActivity?.xpReward ?? 80;
    final goldReward = _activeActivity?.goldReward ?? 20;

    QuestCompletionDialog.show(
      context: context,
      xpReward: xpReward,
      goldReward: goldReward,
      earnedStars: stars,
      title: _activeActivity?.title.toUpperCase() ?? 'QUEST COMPLETE!',
      message: 'You completed this challenge and earned rewards!',
      onContinue: () {
        _handleContinueToNext();
      },
    );
  }
}

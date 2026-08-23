// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/interactive_sim_view.dart';

class FractionModuleScreen extends StatefulWidget {
  const FractionModuleScreen({Key? key}) : super(key: key);

  @override
  State<FractionModuleScreen> createState() => _FractionModuleScreenState();
}

class _FractionModuleScreenState extends State<FractionModuleScreen> {
  Student? _student;
  int _currentLevel = 1;
  int _score = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
    });
  }

  void _onQuestlyEventReceived(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'QUESTLY_GAME_START') {
      // Game started
    } else if (type == 'QUESTLY_GAME_PROGRESS') {
      final level = data['levelCompleted'] as int? ?? 1;
      final sc = data['score'] as int? ?? 0;
      SoundService.playStarPop();
      if (mounted) {
        setState(() {
          _currentLevel = (level + 1).clamp(1, 10);
          _score = sc;
        });
      }
    } else if (type == 'QUESTLY_GAME_COMPLETE') {
      final sc = data['score'] as int? ?? 100;
      final stars = data['stars'] as int? ?? 3;
      _onModuleCompleted(sc, stars);
    } else if (type == 'QUESTLY_NAVIGATE_BACK') {
      _handleReturn();
    }
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _onModuleCompleted(int finalScore, int stars) async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Progress Record
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'math_fractions_1',
        status: 'completed',
        score: finalScore / 100.0,
        stars: stars,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Award XP (+80) and Quest Coins (+20)
      final updated = _student!.copyWith(
        xp: _student!.xp + 80,
        gold: _student!.gold + 20,
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
          _score = finalScore;
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
                // Top Header Bar
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 6 : 8),

                // Main Area: Embedded Fraction Journey
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
                          viewKey: 'fraction_module_game',
                          simulationPath: '/fraction_module/index.html',
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

  // ==========================================
  // TOP HEADER BAR
  // ==========================================
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
                  'MATHEMATICS',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  'FRACTIONS & RATIOS (CANYON CROSSINGS)',
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

        // Metrics: Level, Score, XP, Coins
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_score > 0) ...[
              _buildMetricBadge(
                const Icon(Icons.emoji_events_rounded, size: 14, color: ColorSystem.gold),
                '$_score PTS',
                ColorSystem.plum,
              ),
              const SizedBox(width: 6),
            ],
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

  // ==========================================
  // COMPLETION CELEBRATION MODAL
  // ==========================================
  void _showCompletionDialog(int finalScore, int stars) {
    QuestCompletionDialog.show(
      context: context,
      xpReward: 80,
      goldReward: 20,
      earnedStars: stars,
      title: 'FRACTION MODULE COMPLETE!',
      message: 'You mastered Fractions, Simplification & Ratio Bridges with a score of $finalScore!',
      onContinue: () {
        _handleReturn();
      },
    );
  }
}

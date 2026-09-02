import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';

enum RevisionGame {
  memorySpark,
  fixTheGlitch,
  predictionPortal,
  complete,
}

class DensityRevisionScreen extends StatefulWidget {
  final bool isTab;
  final VoidCallback? onReturnHome;

  const DensityRevisionScreen({
    Key? key,
    this.isTab = false,
    this.onReturnHome,
  }) : super(key: key);

  @override
  State<DensityRevisionScreen> createState() => _DensityRevisionScreenState();
}

class _DensityRevisionScreenState extends State<DensityRevisionScreen> {
  Student? _student;
  RevisionGame _currentGame = RevisionGame.memorySpark;

  // Completed games tracking
  final Set<RevisionGame> _completedGames = {};

  // Progress counters (0 to 5)
  int _game1Progress = 0;
  int _game2Progress = 0;
  int _game3Progress = 0;

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ??
        Locator.authService.getCurrentStudent();
  }

  void _handleGameCompleted(RevisionGame completedGame) {
    SoundService.playLevelComplete();
    setState(() {
      _completedGames.add(completedGame);
      switch (completedGame) {
        case RevisionGame.memorySpark:
          _currentGame = RevisionGame.fixTheGlitch;
          break;
        case RevisionGame.fixTheGlitch:
          _currentGame = RevisionGame.predictionPortal;
          break;
        case RevisionGame.predictionPortal:
          _currentGame = RevisionGame.complete;
          break;
        case RevisionGame.complete:
          break;
      }
    });
  }

  void _resetRevision() {
    SoundService.playClick();
    Locator.readAloudService.stop();
    setState(() {
      _completedGames.clear();
      _currentGame = RevisionGame.memorySpark;
      _game1Progress = 0;
      _game2Progress = 0;
      _game3Progress = 0;
    });
  }

  void _handleExit() {
    SoundService.playClick();
    Locator.readAloudService.stop();
    if (widget.onReturnHome != null) {
      widget.onReturnHome!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isCompact = screenHeight < 450;

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Mission Progress Header
              _buildMissionHeader(isCompact),

              // Active Activity Body
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.02, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _buildCurrentActivity(isCompact),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionHeader(bool isCompact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        border: Border(
          bottom: BorderSide(color: ColorSystem.plum.withOpacity(0.2), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: _handleExit,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorSystem.cream,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorSystem.plum.withOpacity(0.3), width: 1.2),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: ColorSystem.plum,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorSystem.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ColorSystem.purple, width: 1),
                    ),
                    child: Text(
                      'DENSITY REVISION',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isCompact ? 8 : 9,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Interactive Revision Lab',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCompact ? 12 : 14,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // 3 Step Pills
          _buildStepPill('1. SPARK', RevisionGame.memorySpark, _game1Progress, isCompact),
          const SizedBox(width: 6),
          _buildStepPill('2. FLASHCARDS', RevisionGame.fixTheGlitch, _game2Progress, isCompact),
          const SizedBox(width: 6),
          _buildStepPill('3. IMMERSION LAB', RevisionGame.predictionPortal, _game3Progress, isCompact),
        ],
      ),
    );
  }

  Widget _buildStepPill(String title, RevisionGame game, int progress, bool isCompact) {
    final bool isCompleted = _completedGames.contains(game);
    final bool isActive = _currentGame == game;
    final bool isLocked = !isCompleted && !isActive && !_isGameUnlocked(game);

    Color bg;
    Color border;
    Color text;

    if (isCompleted) {
      bg = ColorSystem.mint.withOpacity(0.2);
      border = ColorSystem.mint;
      text = ColorSystem.lightGreen;
    } else if (isActive) {
      bg = ColorSystem.purple.withOpacity(0.15);
      border = ColorSystem.purple;
      text = ColorSystem.purple;
    } else if (isLocked) {
      bg = Colors.grey.withOpacity(0.1);
      border = ColorSystem.plum.withOpacity(0.15);
      text = ColorSystem.plum.withOpacity(0.35);
    } else {
      bg = Colors.transparent;
      border = ColorSystem.plum.withOpacity(0.2);
      text = ColorSystem.plum.withOpacity(0.6);
    }

    String labelText;
    if (isCompleted) {
      labelText = '$title 5/5 ✓';
    } else if (isActive) {
      labelText = '$title ${progress + 1}/5';
    } else if (isLocked) {
      labelText = '$title 🔒';
    } else {
      labelText = '$title 0/5';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5 : 8,
        vertical: isCompact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: isActive || isCompleted ? 1.5 : 1),
      ),
      child: Text(
        labelText,
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: isCompact ? 7.5 : 9,
          fontWeight: FontWeight.w900,
          color: text,
        ),
      ),
    );
  }

  bool _isGameUnlocked(RevisionGame game) {
    switch (game) {
      case RevisionGame.memorySpark:
        return true;
      case RevisionGame.fixTheGlitch:
        return _completedGames.contains(RevisionGame.memorySpark);
      case RevisionGame.predictionPortal:
        return _completedGames.contains(RevisionGame.fixTheGlitch);
      case RevisionGame.complete:
        return _completedGames.contains(RevisionGame.predictionPortal);
    }
  }

  Widget _buildCurrentActivity(bool isCompact) {
    switch (_currentGame) {
      case RevisionGame.memorySpark:
        return _MemorySparkActivity(
          key: const ValueKey('activity_memory_spark'),
          isCompact: isCompact,
          initialIndex: _game1Progress,
          onProgressChanged: (idx) => setState(() => _game1Progress = idx),
          onCompleted: () => _handleGameCompleted(RevisionGame.memorySpark),
        );
      case RevisionGame.fixTheGlitch:
        return _FixTheGlitchFlashcardsActivity(
          key: const ValueKey('activity_fix_glitch'),
          isCompact: isCompact,
          initialIndex: _game2Progress,
          onProgressChanged: (idx) => setState(() => _game2Progress = idx),
          onCompleted: () => _handleGameCompleted(RevisionGame.fixTheGlitch),
        );
      case RevisionGame.predictionPortal:
        return _PredictionPortalActivity(
          key: const ValueKey('activity_prediction_portal'),
          isCompact: isCompact,
          initialIndex: _game3Progress,
          onProgressChanged: (idx) => setState(() => _game3Progress = idx),
          onCompleted: () => _handleGameCompleted(RevisionGame.predictionPortal),
        );
      case RevisionGame.complete:
        return _RevisionCompleteView(
          key: const ValueKey('activity_complete'),
          isCompact: isCompact,
          onReplay: _resetRevision,
          onExit: _handleExit,
        );
    }
  }
}

// ============================================================================
// GAME 1: MEMORY SPARK (Quick Recall - Speaks ONLY on Wrong)
// ============================================================================

class _MemorySparkActivity extends StatefulWidget {
  final bool isCompact;
  final int initialIndex;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onCompleted;

  const _MemorySparkActivity({
    Key? key,
    required this.isCompact,
    required this.initialIndex,
    required this.onProgressChanged,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<_MemorySparkActivity> createState() => _MemorySparkActivityState();
}

class _MemorySparkActivityState extends State<_MemorySparkActivity> {
  late int _currentChallengeIndex;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  bool _isCorrect = false;
  String _currentFeedbackText = '';

  final List<Map<String, dynamic>> _challenges = [
    // Challenge 1 -> Option B
    {
      'question': 'Two objects have the same volume. Object A has more mass. Which object is denser?',
      'visualType': 'same_volume_particles',
      'options': [
        {'title': 'Object B', 'subtitle': 'Less mass in 1 Liter (0.8 kg)', 'isCorrect': false},
        {'title': 'Object A', 'subtitle': 'More mass in 1 Liter (2.0 kg)', 'isCorrect': true},
      ],
      'correctFeedback':
          'Memory Spark restored! Object A packs more mass into the exact same volume, making its density higher.',
      'wrongFeedback':
          'When two objects have the same volume, the one with more mass has greater density. Notice Object A packs 2.0 kg into the same 1 Liter!',
    },
    // Challenge 2 -> Option C
    {
      'question': 'What two quantities are needed to determine density?',
      'visualType': 'formula_cards',
      'options': [
        {'title': 'Size and Colour', 'subtitle': 'Visual appearance only', 'isCorrect': false},
        {'title': 'Mass and Weight', 'subtitle': 'Both measure gravitational amount', 'isCorrect': false},
        {'title': 'Mass and Volume', 'subtitle': 'Density = Mass ÷ Volume', 'isCorrect': true},
        {'title': 'Volume and Temp', 'subtitle': 'Space and thermal energy', 'isCorrect': false},
      ],
      'correctFeedback':
          'Spot on! Density is calculated by dividing mass by volume (Density = Mass ÷ Volume).',
      'wrongFeedback':
          'To understand density, we need both mass (how heavy) and volume (how much space it fills). Mass and volume are the key variables!',
    },
    // Challenge 3 -> Option A
    {
      'question': 'Two objects have the same mass (1 kg). Which one is less dense?',
      'visualType': 'same_mass_scale',
      'options': [
        {'title': 'The object with larger volume', 'subtitle': 'Mass spread across 2000 cm³', 'isCorrect': true},
        {'title': 'The object with smaller volume', 'subtitle': 'Mass tightly packed in 130 cm³', 'isCorrect': false},
      ],
      'correctFeedback':
          'Correct! Spreading the same mass across a much larger volume lowers particle packing and reduces density.',
      'wrongFeedback':
          'If the same mass is spread across a larger volume, the material is less tightly packed. That produces lower density!',
    },
    // Challenge 4 -> Option D
    {
      'question': 'Which statement about density is correct?',
      'visualType': 'concept_triangle',
      'options': [
        {'title': 'Heavier objects are always denser.', 'subtitle': 'Misconception (Ship floats)', 'isCorrect': false},
        {'title': 'Bigger objects are always denser.', 'subtitle': 'Misconception (Balloons float)', 'isCorrect': false},
        {'title': 'Only volume decides density.', 'subtitle': 'Misconception (Ignores mass)', 'isCorrect': false},
        {'title': 'Density depends on both mass and volume.', 'subtitle': 'Fundamental Scientific Law', 'isCorrect': true},
      ],
      'correctFeedback':
          'Exact! Density is strictly the ratio of mass to volume, so both physical properties are always required.',
      'wrongFeedback':
          'Weight or size alone cannot tell us density. Remember: Density depends on both mass and volume together!',
    },
    // Challenge 5 -> Option B
    {
      'question': 'Which everyday object is most likely to help demonstrate that being heavier does not automatically mean sinking?',
      'visualType': 'ship_vs_pebble',
      'options': [
        {'title': 'A small pebble', 'subtitle': '50 Grams (Sinks to seabed)', 'isCorrect': false},
        {'title': 'A large ship', 'subtitle': '50,000 Tonnes (Floats on surface)', 'isCorrect': true},
        {'title': 'A feather', 'subtitle': 'Lightweight material', 'isCorrect': false},
      ],
      'correctFeedback':
          'Memory Spark restored! A giant ship weighs thousands of tonnes but floats because its hollow hull gives it low average density.',
      'wrongFeedback':
          'A giant ship is thousands of tonnes heavier than a small pebble, yet it floats! Weight alone does not cause sinking.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentChallengeIndex = widget.initialIndex.clamp(0, _challenges.length - 1);
    _currentFeedbackText = 'Examine the visual diagram and select the correct answer to proceed.';
  }

  void _speakOnlyOnWrong(String text) {
    final student = Locator.studentRepository.getCurrentStudent();
    final lang = student?.language ?? 'en';
    Locator.readAloudService.speak(text, languageCode: lang);
  }

  void _selectOption(int index) {
    SoundService.playClick();
    final challenge = _challenges[_currentChallengeIndex];
    final isOptionCorrect = (challenge['options'][index]['isCorrect'] as bool);

    setState(() {
      _selectedOptionIndex = index;
      _isAnswerChecked = true;
      _isCorrect = isOptionCorrect;

      if (_isCorrect) {
        SoundService.playSuccess();
        Locator.readAloudService.stop();
        _currentFeedbackText = challenge['correctFeedback'] as String;
      } else {
        SoundService.playPop();
        _currentFeedbackText = challenge['wrongFeedback'] as String;
        _speakOnlyOnWrong('Incorrect. ' + _currentFeedbackText);
      }
    });
  }

  void _nextChallenge() {
    if (!_isCorrect) return;
    Locator.readAloudService.stop();
    SoundService.playClick();
    if (_currentChallengeIndex < _challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
        _isCorrect = false;
        _currentFeedbackText = 'Examine the visual diagram and select the correct answer to proceed.';
      });
      widget.onProgressChanged(_currentChallengeIndex);
    } else {
      widget.onProgressChanged(5);
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _challenges[_currentChallengeIndex];
    final options = challenge['options'] as List<Map<String, dynamic>>;
    final isCompact = widget.isCompact;
    final bool isLast = _currentChallengeIndex == _challenges.length - 1;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Challenge Header
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorSystem.plum, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: ColorSystem.gold, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GAME 1: MEMORY SPARK  •  CHALLENGE ${_currentChallengeIndex + 1} OF 5',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 9 : 10.5,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        challenge['question'] as String,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                DendySpeakButton(textToSpeak: challenge['question'] as String, size: 30),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Interactive Visual Diagram Card
          _buildMemorySparkVisual(challenge['visualType'] as String, isCompact),

          const SizedBox(height: 12),

          // Interactive Option Choices
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(options.length, (index) {
                  final opt = options[index];
                  final isSelected = _selectedOptionIndex == index;
                  final bool isOptCorrect = opt['isCorrect'] as bool;
                  final bool isChecked = _isAnswerChecked && isSelected;

                  Color cardBg = Colors.white;
                  Color borderCol = ColorSystem.plum.withOpacity(0.25);
                  if (isChecked) {
                    if (isOptCorrect) {
                      cardBg = ColorSystem.mint.withOpacity(0.2);
                      borderCol = ColorSystem.mint;
                    } else {
                      cardBg = ColorSystem.coral.withOpacity(0.12);
                      borderCol = ColorSystem.coral;
                    }
                  } else if (isSelected) {
                    cardBg = ColorSystem.purple.withOpacity(0.1);
                    borderCol = ColorSystem.purple;
                  }

                  final double cardWidth = (constraints.maxWidth - (options.length > 2 ? 30 : 10)) /
                      (options.length > 2 ? (constraints.maxWidth > 600 ? 4 : 2) : 2);

                  return SizedBox(
                    width: cardWidth.clamp(120.0, 420.0),
                    child: GestureDetector(
                      onTap: () => _selectOption(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 10 : 14,
                          vertical: isCompact ? 10 : 14,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCol, width: isChecked ? 2.5 : 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: ColorSystem.plum.withOpacity(0.04),
                              offset: const Offset(0, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isChecked
                                    ? (isOptCorrect ? ColorSystem.mint : ColorSystem.coral)
                                    : ColorSystem.purple.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: isChecked
                                    ? Icon(
                                        isOptCorrect ? Icons.check_rounded : Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      )
                                    : Text(
                                        String.fromCharCode(65 + index),
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: ColorSystem.purple,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt['title'] as String,
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: isCompact ? 11.5 : 13,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSystem.plum,
                                    ),
                                  ),
                                  if (opt['subtitle'] != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      opt['subtitle'] as String,
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: isCompact ? 9.5 : 10.5,
                                        color: ColorSystem.plum.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 12),

          // Feedback & Strict Progression Action Bar
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAnswerChecked
                    ? (_isCorrect ? ColorSystem.mint : ColorSystem.coral)
                    : ColorSystem.plum.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DendyMascot(
                      size: isCompact ? 44 : 54,
                      mood: _isAnswerChecked
                          ? (_isCorrect ? DendyMood.success : DendyMood.confused)
                          : DendyMood.explaining,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentFeedbackText,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 11 : 12.5,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DendySpeakButton(textToSpeak: _currentFeedbackText, size: 28),
                  ],
                ),

                // UNLOCKED ONLY ON CORRECT ANSWER
                if (_isAnswerChecked && _isCorrect) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _nextChallenge,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: ColorSystem.plum),
                      label: Text(
                        isLast ? 'UNLOCK GAME 2: FLASHCARDS ➔' : 'NEXT CHALLENGE ➔',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSystem.mint,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ] else if (_isAnswerChecked && !_isCorrect) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorSystem.coral.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up_rounded, color: ColorSystem.coral, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Listen to Dendy & choose the correct option to unlock Next!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemorySparkVisual(String type, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorSystem.purple.withOpacity(0.04),
            ColorSystem.cream.withOpacity(0.6),
          ],
        ),
      ),
      child: _renderDiagram(type, isCompact),
    );
  }

  Widget _renderDiagram(String type, bool isCompact) {
    switch (type) {
      case 'same_volume_particles':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildVolumeCube('OBJECT A', '1.0 Liter', '2.0 kg (Dense)', 16, ColorSystem.purple),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ColorSystem.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                children: [
                  Icon(Icons.compare_arrows_rounded, color: ColorSystem.purple, size: 20),
                  Text(
                    'SAME VOLUME (1L)',
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                  ),
                ],
              ),
            ),
            _buildVolumeCube('OBJECT B', '1.0 Liter', '0.8 kg (Less Dense)', 6, ColorSystem.blue),
          ],
        );

      case 'formula_cards':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFormulaBadge('MASS (m)', 'Digital Scale', Icons.fitness_center_rounded, ColorSystem.gold),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('÷', style: TextStyle(fontFamily: 'Fredoka', fontSize: 24, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
            ),
            _buildFormulaBadge('VOLUME (V)', 'Beaker Cylinder', Icons.science_rounded, ColorSystem.blue),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('=', style: TextStyle(fontFamily: 'Fredoka', fontSize: 24, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
            ),
            _buildFormulaBadge('DENSITY (ρ)', 'Mass ÷ Volume', Icons.auto_awesome_rounded, ColorSystem.mint),
          ],
        );

      case 'same_mass_scale':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildScaleSide('Iron Block', 'Mass: 1.0 kg', 'Volume: 130 cm³ (Dense)', 42, ColorSystem.plum),
            Column(
              children: [
                const Icon(Icons.balance_rounded, size: 36, color: ColorSystem.gold),
                const SizedBox(height: 2),
                Text('EQUAL MASS (1.0 kg)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
            _buildScaleSide('Sponge Block', 'Mass: 1.0 kg', 'Volume: 2000 cm³ (Light)', 75, ColorSystem.coral),
          ],
        );

      case 'concept_triangle':
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: ColorSystem.mint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.mint, width: 1.5),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hub_rounded, color: ColorSystem.lightGreen, size: 24),
                SizedBox(width: 12),
                Text(
                  'Density is NOT just Mass. Density is NOT just Volume.\nIt is the RATIO of Mass to Volume (D = M ÷ V)!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.bold, color: ColorSystem.plum),
                ),
              ],
            ),
          ),
        );

      case 'ship_vs_pebble':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBuoyancyItem('🚢 STEEL SHIP', 'Mass: 50,000 Tonnes', 'FLOATS (Hollow Air Hull)', ColorSystem.mint, true),
            Container(height: 45, width: 1.5, color: ColorSystem.plum.withOpacity(0.2)),
            _buildBuoyancyItem('🪨 SMALL PEBBLE', 'Mass: 50 Grams', 'SINKS (Dense Solid Rock)', ColorSystem.coral, false),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVolumeCube(String title, String vol, String mass, int particleCount, Color col) {
    return Container(
      width: 115,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: col, width: 1.5),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: col)),
          const SizedBox(height: 6),
          Container(
            height: 45,
            width: 75,
            decoration: BoxDecoration(
              color: col.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: col.withOpacity(0.4)),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 3,
              runSpacing: 3,
              children: List.generate(
                particleCount,
                (i) => Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(mass, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
          Text(vol, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, color: ColorSystem.plum.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildFormulaBadge(String title, String unit, IconData icon, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: col, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: col, size: 20),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: col)),
          Text(unit, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildScaleSide(String name, String mass, String vol, double size, Color col) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: col.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: col, width: 1.5),
          ),
          child: Center(
            child: Text(name, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: col)),
          ),
        ),
        const SizedBox(height: 4),
        Text(mass, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
        Text(vol, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildBuoyancyItem(String title, String mass, String state, Color col, bool isFloat) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
        const SizedBox(height: 3),
        Text(mass, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum.withOpacity(0.7))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: col.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
          child: Text(state, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: col)),
        ),
      ],
    );
  }
}

// ============================================================================
// GAME 2: FIX THE GLITCH — 3D FLASHCARDS (Speaks ONLY on Wrong)
// ============================================================================

class _FixTheGlitchFlashcardsActivity extends StatefulWidget {
  final bool isCompact;
  final int initialIndex;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onCompleted;

  const _FixTheGlitchFlashcardsActivity({
    Key? key,
    required this.isCompact,
    required this.initialIndex,
    required this.onProgressChanged,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<_FixTheGlitchFlashcardsActivity> createState() =>
      _FixTheGlitchFlashcardsActivityState();
}

class _FixTheGlitchFlashcardsActivityState
    extends State<_FixTheGlitchFlashcardsActivity>
    with SingleTickerProviderStateMixin {
  late int _currentGlitchIndex;
  int? _selectedRepairIndex;
  bool _isAnswerChecked = false;
  bool _isRepaired = false;
  String _currentFeedbackText = '';

  late AnimationController _flipController;
  bool _isCardFlipped = false;

  final List<Map<String, dynamic>> _glitches = [
    // Flashcard 1 -> Option B
    {
      'glitchTitle': 'Weight vs Density Glitch',
      'glitchStatement': '“Heavier objects always sink.”',
      'mythBadge': 'COMMON MYTH: Heavy = Sink',
      'truthSummary': 'Objects float or sink based on DENSITY (Mass ÷ Volume), not raw weight!',
      'repairOptions': [
        {
          'text': 'Heavier objects only sink if the water is freezing cold.',
          'isCorrect': false,
        },
        {
          'text': 'Objects float or sink based on their density compared with the surrounding fluid, not simply their weight.',
          'isCorrect': true,
        },
        {
          'text': 'All objects weighing above 1 kg sink automatically.',
          'isCorrect': false,
        },
      ],
      'correctExplanation':
          'Glitch repaired! Weight alone does not decide sinking. A huge hollow steel ship floats while a tiny stone sinks.',
      'wrongExplanation':
          'This is a common misconception. Think about a ship and a stone. A ship is heavier, but it floats because its overall density is lower than water.',
    },
    // Flashcard 2 -> Option C
    {
      'glitchTitle': 'Size vs Density Glitch',
      'glitchStatement': '“Bigger objects are always denser.”',
      'mythBadge': 'COMMON MYTH: Large = Dense',
      'truthSummary': 'Size (volume) is only half the formula. Density is the ratio of Mass to Volume!',
      'repairOptions': [
        {
          'text': 'Bigger objects have more internal gravity pulling them down.',
          'isCorrect': false,
        },
        {
          'text': 'Small objects have zero volume so they cannot be dense.',
          'isCorrect': false,
        },
        {
          'text': 'Size alone does not determine density. Both mass and volume must be considered.',
          'isCorrect': true,
        },
      ],
      'correctExplanation':
          'Glitch repaired! Size alone does not determine density. A giant wooden log is much less dense than a small iron bolt.',
      'wrongExplanation':
          'Imagine a large hot-air balloon and a tiny lead pellet. The balloon is huge, but the lead pellet is far denser!',
    },
    // Flashcard 3 -> Option A
    {
      'glitchTitle': 'Equal Mass Glitch',
      'glitchStatement': '“If two objects have the same mass, they have the same density.”',
      'mythBadge': 'COMMON MYTH: 1kg = Same Density',
      'truthSummary': '1kg of Gold (52 cm³) is 200x denser than 1kg of fluffy Cotton (10,000 cm³)!',
      'repairOptions': [
        {
          'text': 'Objects with the same mass can have different densities if their volumes are different.',
          'isCorrect': true,
        },
        {
          'text': 'Same mass always produces identical density regardless of shape.',
          'isCorrect': false,
        },
        {
          'text': 'Volume does not affect density when mass is equal.',
          'isCorrect': false,
        },
      ],
      'correctExplanation':
          'Glitch repaired! If the volume is different, the density changes even if the mass is identical.',
      'wrongExplanation':
          'Take 1 kg of cotton and 1 kg of gold. The masses are identical, but their volumes and densities are totally different!',
    },
    // Flashcard 4 -> Option B
    {
      'glitchTitle': 'Single Variable Glitch',
      'glitchStatement': '“Only mass is needed to understand density.”',
      'mythBadge': 'COMMON MYTH: Only Mass Matters',
      'truthSummary': 'Density = Mass ÷ Volume. Both variables are strictly required!',
      'repairOptions': [
        {
          'text': 'Mass and weight are all that is needed to calculate buoyancy.',
          'isCorrect': false,
        },
        {
          'text': 'Density depends on the relationship between mass and volume.',
          'isCorrect': true,
        },
        {
          'text': 'Volume is only needed for liquids, not solids.',
          'isCorrect': false,
        },
      ],
      'correctExplanation':
          'Glitch repaired! Density is strictly the ratio of mass divided by volume.',
      'wrongExplanation':
          'Mass only tells how much matter there is. Without knowing how much space (volume) it occupies, density cannot be known.',
    },
    // Flashcard 5 -> Option C
    {
      'glitchTitle': 'Absolute Buoyancy Glitch',
      'glitchStatement': '“All heavy objects sink and all light objects float.”',
      'mythBadge': 'COMMON MYTH: Light Floats, Heavy Sinks',
      'truthSummary': 'Buoyancy depends strictly on RELATIVE DENSITY compared to the surrounding fluid!',
      'repairOptions': [
        {
          'text': 'Light objects float only if they contain air pockets.',
          'isCorrect': false,
        },
        {
          'text': 'Heavy objects float only in salty ocean water.',
          'isCorrect': false,
        },
        {
          'text': 'Floating and sinking depend on relative density, not simply whether an object is heavy or light.',
          'isCorrect': true,
        },
      ],
      'correctExplanation':
          'Glitch repaired! Relative density to the fluid determines whether an object floats or sinks.',
      'wrongExplanation':
          'A tiny metal pin sinks, while a giant aircraft carrier floats. Relative density determines buoyancy, not weight!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentGlitchIndex = widget.initialIndex.clamp(0, _glitches.length - 1);
    _currentFeedbackText = 'Tap the 3D Flashcard to flip it and select the correct scientific repair.';

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    SoundService.playClick();
    if (_isCardFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
  }

  void _speakOnlyOnWrong(String text) {
    final student = Locator.studentRepository.getCurrentStudent();
    final lang = student?.language ?? 'en';
    Locator.readAloudService.speak(text, languageCode: lang);
  }

  void _selectRepair(int index) {
    SoundService.playClick();
    final glitch = _glitches[_currentGlitchIndex];
    final isCorrect = glitch['repairOptions'][index]['isCorrect'] as bool;

    setState(() {
      _selectedRepairIndex = index;
      _isAnswerChecked = true;
      _isRepaired = isCorrect;

      if (isCorrect) {
        SoundService.playSuccess();
        Locator.readAloudService.stop();
        _currentFeedbackText = glitch['correctExplanation'] as String;
      } else {
        SoundService.playPop();
        _currentFeedbackText = glitch['wrongExplanation'] as String;
        _speakOnlyOnWrong('Incorrect explanation. ' + _currentFeedbackText);
      }
    });
  }

  void _nextGlitch() {
    if (!_isRepaired) return;
    Locator.readAloudService.stop();
    SoundService.playClick();
    if (_currentGlitchIndex < _glitches.length - 1) {
      _flipController.reset();
      setState(() {
        _currentGlitchIndex++;
        _isCardFlipped = false;
        _selectedRepairIndex = null;
        _isAnswerChecked = false;
        _isRepaired = false;
        _currentFeedbackText = 'Tap the 3D Flashcard to flip it and select the correct scientific repair.';
      });
      widget.onProgressChanged(_currentGlitchIndex);
    } else {
      widget.onProgressChanged(5);
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final glitch = _glitches[_currentGlitchIndex];
    final repairOptions = glitch['repairOptions'] as List<Map<String, dynamic>>;
    final isCompact = widget.isCompact;
    final bool isLast = _currentGlitchIndex == _glitches.length - 1;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorSystem.coral.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.coral, width: 1.2),
                ),
                child: Text(
                  'GAME 2: FLASHCARDS  •  CARD ${_currentGlitchIndex + 1} OF 5',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isCompact ? 9 : 10.5,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.coral,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _toggleFlip,
                icon: const Icon(Icons.flip_camera_android_rounded, size: 16, color: ColorSystem.plum),
                label: Text(
                  _isCardFlipped ? 'SEE MISCONCEPTION' : 'FLIP TO REPAIR 🔄',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorSystem.gold,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // 3D Animated Flip Flashcard
          GestureDetector(
            onTap: _toggleFlip,
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, child) {
                final double angle = _flipController.value * math.pi;
                final bool isBack = _flipController.value >= 0.5;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: isBack
                      ? Transform(
                          transform: Matrix4.identity()..rotateY(math.pi),
                          alignment: Alignment.center,
                          child: _buildCardBack(glitch, repairOptions, isCompact),
                        )
                      : _buildCardFront(glitch, isCompact),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Feedback & Strict Progression Action Bar
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAnswerChecked
                    ? (_isRepaired ? ColorSystem.mint : ColorSystem.coral)
                    : ColorSystem.plum.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DendyMascot(
                      size: isCompact ? 44 : 54,
                      mood: _isAnswerChecked
                          ? (_isRepaired ? DendyMood.success : DendyMood.confused)
                          : DendyMood.explaining,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentFeedbackText,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 11 : 12.5,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DendySpeakButton(textToSpeak: _currentFeedbackText, size: 28),
                  ],
                ),

                // UNLOCKED ONLY ON SUCCESS
                if (_isAnswerChecked && _isRepaired) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _nextGlitch,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: ColorSystem.plum),
                      label: Text(
                        isLast ? 'UNLOCK GAME 3: IMMERSION LAB ➔' : 'NEXT FLASHCARD ➔',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSystem.mint,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ] else if (_isAnswerChecked && !_isRepaired) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorSystem.coral.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up_rounded, color: ColorSystem.coral, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Listen to Dendy & choose the correct repair to unlock Next!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> glitch, bool isCompact) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: EdgeInsets.all(isCompact ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRepaired ? ColorSystem.mint : ColorSystem.coral,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isRepaired ? ColorSystem.mint : ColorSystem.coral).withOpacity(0.15),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorSystem.coral.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  glitch['mythBadge'] as String,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.coral,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.touch_app_rounded, color: ColorSystem.gold, size: 20),
              const SizedBox(width: 4),
              const Text(
                'TAP TO FLIP',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.gold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            glitch['glitchStatement'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isCompact ? 16 : 20,
              fontWeight: FontWeight.w900,
              color: ColorSystem.coral,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Is this statement scientifically correct? Tap to flip the flashcard and choose the scientific repair!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isCompact ? 10.5 : 12,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(
      Map<String, dynamic> glitch, List<Map<String, dynamic>> repairOptions, bool isCompact) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRepaired ? ColorSystem.mint : ColorSystem.purple,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.purple.withOpacity(0.12),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorSystem.purple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SCIENTIFIC REPAIR TERMINAL',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
              ),
              const Spacer(),
              const Icon(Icons.flip_to_front_rounded, color: ColorSystem.purple, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            glitch['truthSummary'] as String,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isCompact ? 10.5 : 12,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 10),

          // Options
          ...List.generate(repairOptions.length, (index) {
            final opt = repairOptions[index];
            final isSelected = _selectedRepairIndex == index;
            final bool isOptCorrect = opt['isCorrect'] as bool;
            final bool isChecked = _isAnswerChecked && isSelected;

            Color cardBg = ColorSystem.cream.withOpacity(0.5);
            Color borderCol = ColorSystem.plum.withOpacity(0.2);

            if (isChecked) {
              if (isOptCorrect) {
                cardBg = ColorSystem.mint.withOpacity(0.2);
                borderCol = ColorSystem.mint;
              } else {
                cardBg = ColorSystem.coral.withOpacity(0.12);
                borderCol = ColorSystem.coral;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: GestureDetector(
                onTap: () => _selectRepair(index),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 12,
                    vertical: isCompact ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderCol, width: isChecked ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isChecked
                              ? (isOptCorrect ? ColorSystem.mint : ColorSystem.coral)
                              : ColorSystem.purple.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isChecked
                              ? Icon(
                                  isOptCorrect ? Icons.check_rounded : Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : Text(
                                  String.fromCharCode(65 + index),
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: ColorSystem.purple,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          opt['text'] as String,
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: isCompact ? 10.5 : 12,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.plum,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// GAME 3: PREDICTION PORTAL — INTERACTIVE IMMERSION LAB (Speaks ONLY on Wrong)
// ============================================================================

class _PredictionPortalActivity extends StatefulWidget {
  final bool isCompact;
  final int initialIndex;
  final ValueChanged<int> onProgressChanged;
  final VoidCallback onCompleted;

  const _PredictionPortalActivity({
    Key? key,
    required this.isCompact,
    required this.initialIndex,
    required this.onProgressChanged,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<_PredictionPortalActivity> createState() => _PredictionPortalActivityState();
}

class _PredictionPortalActivityState extends State<_PredictionPortalActivity>
    with TickerProviderStateMixin {
  late int _currentScenarioIndex;
  int? _selectedChoiceIndex;
  bool _hasRevealed = false;
  bool _isPredictionCorrect = false;
  String _currentFeedbackText = '';

  late AnimationController _dropAnimationController;
  late AnimationController _waveAnimationController;

  final List<Map<String, dynamic>> _predictions = [
    // Prediction 1 -> Option A (FLOAT)
    {
      'scenario': 'A block has a density of 0.6 kg/L (lower than water at 1.0 kg/L) and is placed in water.',
      'question': 'What do you predict will happen?',
      'objectIcon': '🪵',
      'objectName': 'WOOD BLOCK',
      'massLabel': '0.6 kg',
      'volumeLabel': '1.0 L',
      'densityValue': '0.6 kg/L',
      'isObjectDense': false,
      'options': [
        {'title': 'FLOAT', 'subtitle': 'Density < Water (1.0 kg/L)', 'isCorrect': true, 'outcomeFloat': true},
        {'title': 'SINK', 'subtitle': 'Density > Water (1.0 kg/L)', 'isCorrect': false, 'outcomeFloat': false},
      ],
      'correctFeedback':
          'Spot-on prediction! When an object\'s density (0.6 kg/L) is lower than water (1.0 kg/L), buoyant forces push it upward to float.',
      'wrongFeedback':
          'When an object\'s density is lower than water, it floats. Notice: 0.6 kg/L is lower than 1.0 kg/L, so it floats!',
    },
    // Prediction 2 -> Option B (Object A is denser)
    {
      'scenario': 'Two objects have the same volume (1 Liter). Object A has twice the mass (2 kg vs 1 kg).',
      'question': 'Which object do you predict is denser?',
      'objectIcon': '⚖️',
      'objectName': 'OBJECT A vs OBJECT B',
      'massLabel': '2.0 kg vs 1.0 kg',
      'volumeLabel': '1.0 L each',
      'densityValue': '2.0 vs 1.0 kg/L',
      'isObjectDense': true,
      'options': [
        {'title': 'Object B', 'subtitle': 'Less mass in same 1L volume (1.0 kg)', 'isCorrect': false, 'outcomeFloat': true},
        {'title': 'Object A', 'subtitle': 'Twice the mass in same 1L volume (2.0 kg)', 'isCorrect': true, 'outcomeFloat': false},
      ],
      'correctFeedback':
          'Correct! Because both objects occupy the same volume, Object A packs twice as much mass, making it denser.',
      'wrongFeedback':
          'Because both occupy 1 Liter, the one containing more mass (Object A) has higher density. Object A is denser!',
    },
    // Prediction 3 -> Option A (Object A has lower density)
    {
      'scenario': 'Two objects have the same mass (1 kg). Object A occupies a much larger volume.',
      'question': 'Which object do you predict has lower density?',
      'objectIcon': '📦',
      'objectName': 'EXPANDED vs COMPACT',
      'massLabel': '1.0 kg each',
      'volumeLabel': '2.0 L vs 0.2 L',
      'densityValue': '0.5 vs 5.0 kg/L',
      'isObjectDense': false,
      'options': [
        {'title': 'Object A (Larger Volume)', 'subtitle': 'Mass spread over larger space', 'isCorrect': true, 'outcomeFloat': true},
        {'title': 'Object B (Smaller Volume)', 'subtitle': 'Mass packed tightly', 'isCorrect': false, 'outcomeFloat': false},
      ],
      'correctFeedback':
          'Correct! The same mass spread over more space means lower particle density.',
      'wrongFeedback':
          'The same mass spread across more space means less mass per unit volume. Object A has lower density!',
    },
    // Prediction 4 -> Option B
    {
      'scenario': 'A small metal ball (high density) and a large wooden log (low density) are placed in water.',
      'question': 'What do you predict?',
      'objectIcon': '🔩',
      'objectName': 'STEEL BALL & WOOD LOG',
      'massLabel': 'Metal vs Wood',
      'volumeLabel': 'Small vs Giant',
      'densityValue': '7.8 vs 0.7 g/cm³',
      'isObjectDense': false,
      'options': [
        {'title': 'The wooden log sinks because it is bigger and heavier.', 'subtitle': 'Weight Misconception', 'isCorrect': false, 'outcomeFloat': false},
        {'title': 'The metal ball sinks while the wooden log floats.', 'subtitle': 'Material Density comparison', 'isCorrect': true, 'outcomeFloat': true},
      ],
      'correctFeedback':
          'Spot on! Size does not decide floating. The materials have different densities compared with water.',
      'wrongFeedback':
          'Don\'t use size alone! Wood has a lower density than water (floats), while metal has higher density (sinks).',
    },
    // Prediction 5 -> Option C
    {
      'scenario': 'A huge steel ship is floating on water.',
      'question': 'Which explanation best predicts why it floats?',
      'objectIcon': '🚢',
      'objectName': 'HOLLOW CARGO SHIP',
      'massLabel': '50,000 Tonnes',
      'volumeLabel': 'Massive Air Hull',
      'densityValue': '0.85 kg/L (avg)',
      'isObjectDense': false,
      'options': [
        {'title': 'Steel is naturally lighter than water.', 'subtitle': 'Incorrect premise', 'isCorrect': false, 'outcomeFloat': false},
        {'title': 'The ship floats only because of engine speed.', 'subtitle': 'Hydrodynamic myth', 'isCorrect': false, 'outcomeFloat': false},
        {'title': 'Its overall average density is lower than water.', 'subtitle': 'Hollow Hull + Air Cavity', 'isCorrect': true, 'outcomeFloat': true},
      ],
      'correctFeedback':
          'Perfect! The hollow shape of a ship traps air, lowering the overall average density below 1.0 kg/L.',
      'wrongFeedback':
          'Even though steel is dense, a ship is hollow and filled with air. Its AVERAGE density is lower than water!',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentScenarioIndex = widget.initialIndex.clamp(0, _predictions.length - 1);
    _currentFeedbackText = 'Examine the object\'s mass & volume specs, then tap your prediction to drop it!';

    _dropAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _waveAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dropAnimationController.dispose();
    _waveAnimationController.dispose();
    super.dispose();
  }

  void _speakOnlyOnWrong(String text) {
    final student = Locator.studentRepository.getCurrentStudent();
    final lang = student?.language ?? 'en';
    Locator.readAloudService.speak(text, languageCode: lang);
  }

  void _makePrediction(int index) {
    SoundService.playClick();
    final item = _predictions[_currentScenarioIndex];
    final isCorrect = item['options'][index]['isCorrect'] as bool;

    setState(() {
      _selectedChoiceIndex = index;
      _hasRevealed = true;
      _isPredictionCorrect = isCorrect;

      if (isCorrect) {
        SoundService.playWaterSplash();
        Locator.readAloudService.stop();
        _currentFeedbackText = item['correctFeedback'] as String;
      } else {
        SoundService.playPop();
        _currentFeedbackText = item['wrongFeedback'] as String;
        _speakOnlyOnWrong('Incorrect prediction. ' + _currentFeedbackText);
      }
    });

    _dropAnimationController.forward(from: 0.0);
  }

  void _nextScenario() {
    if (!_isPredictionCorrect) return;
    Locator.readAloudService.stop();
    SoundService.playClick();
    if (_currentScenarioIndex < _predictions.length - 1) {
      _dropAnimationController.reset();
      setState(() {
        _currentScenarioIndex++;
        _selectedChoiceIndex = null;
        _hasRevealed = false;
        _isPredictionCorrect = false;
        _currentFeedbackText = 'Examine the object\'s mass & volume specs, then tap your prediction to drop it!';
      });
      widget.onProgressChanged(_currentScenarioIndex);
    } else {
      widget.onProgressChanged(5);
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _predictions[_currentScenarioIndex];
    final options = item['options'] as List<Map<String, dynamic>>;
    final isCompact = widget.isCompact;
    final bool isLast = _currentScenarioIndex == _predictions.length - 1;

    final bool shouldFloat = _hasRevealed &&
        ((options[_selectedChoiceIndex ?? 0]['outcomeFloat'] as bool?) ?? true);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 14 : 20,
        vertical: isCompact ? 8 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scenario Header
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorSystem.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ColorSystem.blue, width: 1),
                  ),
                  child: Text(
                    'PORTAL ${_currentScenarioIndex + 1}/5',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCompact ? 9 : 10.5,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['scenario'] as String,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 11.5 : 13,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['question'] as String,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 10.5 : 12,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                DendySpeakButton(textToSpeak: '${item['scenario']} ${item['question']}', size: 28),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Object Specification & Density Gauge Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpecItem('OBJECT', item['objectIcon'] + ' ' + item['objectName'], ColorSystem.purple),
                _buildSpecItem('MASS', item['massLabel'] as String, ColorSystem.gold),
                _buildSpecItem('VOLUME', item['volumeLabel'] as String, ColorSystem.blue),
                _buildSpecItem('DENSITY', item['densityValue'] as String, ColorSystem.mint),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Laboratory Water Tank Immersion Arena
          Container(
            height: isCompact ? 140 : 170,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorSystem.plum, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  // Animated Water Fluid Body
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: isCompact ? 90 : 115,
                    child: AnimatedBuilder(
                      animation: _waveAnimationController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                ColorSystem.brightTeal.withOpacity(0.45),
                                ColorSystem.blue.withOpacity(0.65),
                              ],
                            ),
                            border: const Border(
                              top: BorderSide(color: ColorSystem.blue, width: 2.5),
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Water Line Marker
                              Positioned(
                                left: 10,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'WATER SURFACE (ρ = 1.0 kg/L)',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: ColorSystem.blue,
                                    ),
                                  ),
                                ),
                              ),

                              // Sandy Tank Bed
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorSystem.gold.withOpacity(0.4),
                                    border: Border(top: BorderSide(color: ColorSystem.gold.withOpacity(0.7), width: 1)),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'TANK BED (High Density Materials Rest Here)',
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 7.5,
                                        fontWeight: FontWeight.w900,
                                        color: ColorSystem.plum,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Rising Animated Air Bubbles
                              ...List.generate(4, (i) {
                                final double bubbleOffset =
                                    ((_waveAnimationController.value + (i * 0.25)) % 1.0);
                                return Positioned(
                                  left: 30.0 + (i * 65.0),
                                  bottom: 16.0 + (bubbleOffset * 70.0),
                                  child: Opacity(
                                    opacity: 1.0 - bubbleOffset,
                                    child: Container(
                                      width: 6 + (i % 3) * 2,
                                      height: 6 + (i % 3) * 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.7),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: ColorSystem.blue.withOpacity(0.4)),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Mechanical Dropper Arm at the top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorSystem.plum.withOpacity(0.85),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Animated Dropping & Bobbing Test Object
                  AnimatedBuilder(
                    animation: Listenable.merge([_dropAnimationController, _waveAnimationController]),
                    builder: (context, child) {
                      final double tankH = isCompact ? 140.0 : 170.0;
                      final double startY = 8.0;
                      final double floatBaseY = tankH - (isCompact ? 82.0 : 102.0);
                      final double sinkY = tankH - (isCompact ? 40.0 : 46.0);

                      // Floating harmonic buoyancy wave bobbing
                      final double bobbing = shouldFloat
                          ? math.sin(_waveAnimationController.value * 2 * math.pi) * 3.5
                          : 0.0;

                      final double targetY = shouldFloat ? floatBaseY + bobbing : sinkY;
                      final double t = CurvedAnimation(
                        parent: _dropAnimationController,
                        curve: Curves.bounceOut,
                      ).value;

                      final double currentY = _hasRevealed ? startY + (t * (targetY - startY)) : startY;

                      return Positioned(
                        top: currentY,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              if (!_hasRevealed && options.isNotEmpty) {
                                _makePrediction(0);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _hasRevealed
                                    ? (shouldFloat ? ColorSystem.mint : ColorSystem.coral)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _hasRevealed
                                      ? (_isPredictionCorrect ? ColorSystem.mint : ColorSystem.coral)
                                      : ColorSystem.plum,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorSystem.plum.withOpacity(0.2),
                                    offset: const Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item['objectIcon'] as String,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _hasRevealed
                                        ? (shouldFloat ? 'FLOATS ON SURFACE! 🌊' : 'SINKS TO BED! ⬇')
                                        : 'TEST: ${item['objectName']}',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: isCompact ? 10.5 : 12,
                                      fontWeight: FontWeight.w900,
                                      color: _hasRevealed ? Colors.white : ColorSystem.plum,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Prediction Choices
          Column(
            children: List.generate(options.length, (idx) {
              final opt = options[idx];
              final isSelected = _selectedChoiceIndex == idx;
              final bool isOptCorrect = opt['isCorrect'] as bool;
              final bool isChecked = _hasRevealed && isSelected;

              Color bg = Colors.white;
              Color borderCol = ColorSystem.plum.withOpacity(0.25);

              if (isChecked) {
                if (isOptCorrect) {
                  bg = ColorSystem.mint.withOpacity(0.2);
                  borderCol = ColorSystem.mint;
                } else {
                  bg = ColorSystem.coral.withOpacity(0.12);
                  borderCol = ColorSystem.coral;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: GestureDetector(
                  onTap: () => _makePrediction(idx),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 14,
                      vertical: isCompact ? 8 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderCol, width: isChecked ? 2.2 : 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isChecked
                              ? (isOptCorrect ? Icons.check_circle_rounded : Icons.refresh_rounded)
                              : Icons.radio_button_unchecked_rounded,
                          color: isChecked
                              ? (isOptCorrect ? ColorSystem.lightGreen : ColorSystem.coral)
                              : ColorSystem.plum,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: isCompact ? 11.5 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSystem.plum,
                                ),
                              ),
                              if (opt['subtitle'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  opt['subtitle'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: isCompact ? 9.5 : 10.5,
                                    color: ColorSystem.plum.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          // Feedback & Strict Progression Action Bar
          Container(
            padding: EdgeInsets.all(isCompact ? 10 : 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasRevealed
                    ? (_isPredictionCorrect ? ColorSystem.mint : ColorSystem.coral)
                    : ColorSystem.plum.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DendyMascot(
                      size: isCompact ? 44 : 54,
                      mood: _hasRevealed
                          ? (_isPredictionCorrect ? DendyMood.success : DendyMood.confused)
                          : DendyMood.explaining,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentFeedbackText,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isCompact ? 11 : 12.5,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DendySpeakButton(textToSpeak: _currentFeedbackText, size: 28),
                  ],
                ),

                // UNLOCKED ONLY ON SUCCESS
                if (_hasRevealed && _isPredictionCorrect) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _nextScenario,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: ColorSystem.plum),
                      label: Text(
                        isLast ? 'FINISH REVISION ➔' : 'NEXT PREDICTION ➔',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorSystem.mint,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ] else if (_hasRevealed && !_isPredictionCorrect) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorSystem.coral.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.volume_up_rounded, color: ColorSystem.coral, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Listen to Dendy & choose the correct prediction to unlock Next!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.coral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, Color col) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: ColorSystem.plum.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: col.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: col.withOpacity(0.5)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: col,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// REVISION COMPLETION SUMMARY (3 Interactive Modules)
// ============================================================================

class _RevisionCompleteView extends StatelessWidget {
  final bool isCompact;
  final VoidCallback onReplay;
  final VoidCallback onExit;

  const _RevisionCompleteView({
    Key? key,
    required this.isCompact,
    required this.onReplay,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        margin: EdgeInsets.all(isCompact ? 10 : 20),
        padding: EdgeInsets.all(isCompact ? 14 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColorSystem.plum, width: 2),
          boxShadow: [
            BoxShadow(
              color: ColorSystem.plum.withOpacity(0.08),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DendyMascot(
              size: 64,
              mood: DendyMood.success,
            ),
            const SizedBox(height: 10),
            Text(
              'Density Revision Complete! 🎉',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isCompact ? 18 : 22,
                fontWeight: FontWeight.w900,
                color: ColorSystem.purple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You successfully completed all 15 revision challenges across the 3 interactive labs!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isCompact ? 11 : 12.5,
                color: ColorSystem.plum.withOpacity(0.75),
              ),
            ),
            const SizedBox(height: 16),

            // 3 Checkmarks List
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ColorSystem.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  _buildCheckRow('Memory Spark', '5/5 Quick recall challenges completed'),
                  const Divider(height: 10),
                  _buildCheckRow('Flashcard Glitch Lab', '5/5 Density flashcards repaired'),
                  const Divider(height: 10),
                  _buildCheckRow('Prediction Immersion Lab', '5/5 Density predictions tested'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'REPLAY REVISION',
                  backgroundColor: ColorSystem.cream,
                  textColor: ColorSystem.plum,
                  onPressed: onReplay,
                ),
                const SizedBox(width: 14),
                CustomButton(
                  text: 'RETURN TO DASHBOARD',
                  backgroundColor: ColorSystem.mint,
                  textColor: ColorSystem.plum,
                  onPressed: onExit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String title, String subtitle) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: ColorSystem.mint, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  color: ColorSystem.plum.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

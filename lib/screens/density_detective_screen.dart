import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';

class DensityDetectiveScreen extends StatefulWidget {
  final Activity? activity;

  const DensityDetectiveScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityDetectiveScreen> createState() => _DensityDetectiveScreenState();
}

enum _DetectiveStage {
  intro,
  caseA,
  caseB,
  caseC,
  trickCase,
  caseClosed,
}

class _DensityDetectiveScreenState extends State<DensityDetectiveScreen> {
  Student? _student;
  _DetectiveStage _stage = _DetectiveStage.intro;

  // Clues revealed for current case (0 to 3)
  int _revealedClues = 0;
  int? _selectedOptionIndex;
  bool _hasCheckedDeduction = false;
  bool _isDeductionCorrect = false;
  String _feedbackMessage = '';
  int _attemptsForCurrentCase = 0;

  // Trick case two-step tracking
  int? _trickPart1Selection;
  int? _trickPart2Selection;
  bool _trickSubmitted = false;

  // Structured Learning Signals
  final Map<String, dynamic> _learningSignals = {
    'case_attempts': 0,
    'correct_deductions': 0,
    'incorrect_deductions': 0,
    'clues_used_per_case': <String, int>{},
    'confused_same_mass': false,
    'confused_same_volume': false,
    'selected_heavy_objects_sink': false,
    'selected_size_determines_floating': false,
    'trick_case_solved': false,
  };

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap');
    }
  }

  void _startInvestigation() {
    SoundService.playClick();
    setState(() {
      _stage = _DetectiveStage.caseA;
      _revealedClues = 0;
      _selectedOptionIndex = null;
      _hasCheckedDeduction = false;
      _isDeductionCorrect = false;
      _feedbackMessage = '';
      _attemptsForCurrentCase = 0;
    });
  }

  void _revealNextClue() {
    if (_revealedClues < 3) {
      SoundService.playStarPop();
      setState(() {
        _revealedClues++;
      });
    }
  }

  void _selectDeduction(int index) {
    if (_hasCheckedDeduction && _isDeductionCorrect) return;
    SoundService.playClick();
    setState(() {
      _selectedOptionIndex = index;
      _hasCheckedDeduction = false;
      _feedbackMessage = '';
    });
  }

  void _checkDeduction() {
    if (_selectedOptionIndex == null) return;
    _attemptsForCurrentCase++;
    _learningSignals['case_attempts'] = (_learningSignals['case_attempts'] as int) + 1;

    final caseData = _getCurrentCaseData();
    final isCorrect = caseData['options'][_selectedOptionIndex!]['isCorrect'] as bool;
    final feedback = caseData['options'][_selectedOptionIndex!]['feedback'] as String;

    // Record misconception signals
    final misconceptionKey = caseData['options'][_selectedOptionIndex!]['misconception'] as String?;
    if (misconceptionKey != null) {
      _learningSignals[misconceptionKey] = true;
    }

    if (isCorrect) {
      SoundService.playSuccess();
      _learningSignals['correct_deductions'] = (_learningSignals['correct_deductions'] as int) + 1;
      _learningSignals['clues_used_per_case'][_stage.name] = _revealedClues;
      setState(() {
        _hasCheckedDeduction = true;
        _isDeductionCorrect = true;
        _feedbackMessage = feedback;
      });
    } else {
      SoundService.playDrop();
      _learningSignals['incorrect_deductions'] = (_learningSignals['incorrect_deductions'] as int) + 1;
      setState(() {
        _hasCheckedDeduction = true;
        _isDeductionCorrect = false;
        _feedbackMessage = feedback;
      });
    }
  }

  void _advanceToNextCase() {
    SoundService.playClick();
    setState(() {
      if (_stage == _DetectiveStage.caseA) {
        _stage = _DetectiveStage.caseB;
      } else if (_stage == _DetectiveStage.caseB) {
        _stage = _DetectiveStage.caseC;
      } else if (_stage == _DetectiveStage.caseC) {
        _stage = _DetectiveStage.trickCase;
      } else if (_stage == _DetectiveStage.trickCase) {
        _stage = _DetectiveStage.caseClosed;
      }
      _revealedClues = 0;
      _selectedOptionIndex = null;
      _hasCheckedDeduction = false;
      _isDeductionCorrect = false;
      _feedbackMessage = '';
      _attemptsForCurrentCase = 0;
    });
  }

  void _submitTrickCase() {
    if (_trickPart1Selection == null || _trickPart2Selection == null) return;
    _learningSignals['case_attempts'] = (_learningSignals['case_attempts'] as int) + 1;

    final isPart1Correct = _trickPart1Selection == 1; // Object B (large volume)
    final isPart2Correct = _trickPart2Selection == 2; // Relationship between mass and volume affects density

    if (_trickPart2Selection == 0) {
      _learningSignals['selected_heavy_objects_sink'] = true;
    } else if (_trickPart2Selection == 1) {
      _learningSignals['selected_size_determines_floating'] = true;
    }

    if (isPart1Correct && isPart2Correct) {
      SoundService.playSuccess();
      _learningSignals['trick_case_solved'] = true;
      setState(() {
        _trickSubmitted = true;
        _isDeductionCorrect = true;
      });
    } else {
      SoundService.playDrop();
      setState(() {
        _trickSubmitted = true;
        _isDeductionCorrect = false;
      });
    }
  }

  Future<void> _completeLesson() async {
    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Lesson 4 Progress
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les4',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Mark explicit direct storage keys
      await Locator.storageService.setBool('lesson_comp_${sId}_density_les4', true);
      await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les5', true);

      // 3. Save structured learning signals
      await Locator.storageService.setString('learning_signals_${sId}_density_les4', jsonEncode(_learningSignals));

      // 4. Award XP (+80) and Coins (+15)
      final updated = _student!.copyWith(
        xp: _student!.xp + 80,
        gold: _student!.gold + 15,
        currentLessonId: 'density_les5',
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
        });
      }
    }

    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: 80,
        goldReward: 15,
        earnedStars: 3,
        title: 'CASE CLOSED!',
        message: 'You used evidence from mass, volume, and buoyancy to solve every mystery case!',
        buttonText: 'CONTINUE TO NEXT LESSON',
        onContinue: () {
          SoundService.playClick();
          Navigator.pushReplacementNamed(context, '/density_teach_back');
        },
      );
    }
  }

  Map<String, dynamic> _getCurrentCaseData() {
    switch (_stage) {
      case _DetectiveStage.caseA:
        return {
          'caseName': 'CASE A: MYSTERY SOLID',
          'caseObjective': 'Identify the material of the unlabeled mystery block.',
          'silhouetteLabel': 'UNKNOWN SOLID CUBE',
          'clues': [
            'CLUE 1: Mass measurement on scale = 2.0 kg',
            'CLUE 2: Water displacement volume = 4.0 L',
            'CLUE 3: Placed in water tank: Floats with 50% submerged (Density = 0.50 kg/L)',
          ],
          'options': [
            {
              'text': 'Pine Wood (~0.50 kg/L)',
              'isCorrect': true,
              'feedback': 'CASE SOLVED! 2 kg ÷ 4 L = 0.50 kg/L. Pine wood is less dense than water (1.00 kg/L), so it floats!',
            },
            {
              'text': 'Solid Steel (7.80 kg/L)',
              'isCorrect': false,
              'feedback': 'Not quite. Solid steel is 7.80 kg/L and would sink immediately to the bottom.',
            },
            {
              'text': 'Solid Copper (8.90 kg/L)',
              'isCorrect': false,
              'feedback': 'Look at the evidence again. Copper is dense and heavy; a 4 L copper block would weigh ~35.6 kg!',
            },
          ],
          'dendyPrompt': 'Examine the clues! Calculate Mass ÷ Volume and see if it matches the floating observation.',
        };

      case _DetectiveStage.caseB:
        return {
          'caseName': 'CASE B: THE EQUAL MASS PARADOX',
          'caseObjective': 'Explain why two blocks of the exact same mass behave differently.',
          'silhouetteLabel': 'BLOCK A (0.5 L) vs. BLOCK B (8.0 L)',
          'clues': [
            'CLUE 1: Both Block A and Block B have the exact same mass: 4.0 kg on the scale.',
            'CLUE 2: Block A is a compact cube (0.5 L). Block B is a large hollow container (8.0 L).',
            'CLUE 3: In the tank: Block A sinks to the bottom (8.0 kg/L), but Block B floats high on top (0.5 kg/L).',
          ],
          'options': [
            {
              'text': 'Block B spreads its 4 kg across a huge 8 L volume, lowering its average density to 0.50 kg/L.',
              'isCorrect': true,
              'feedback': 'CASE SOLVED! Equal mass does NOT mean equal density. Larger volume drops density below 1.00 kg/L!',
            },
            {
              'text': 'Having the same mass means they must have the same density.',
              'isCorrect': false,
              'misconception': 'confused_same_mass',
              'feedback': 'Careful! Density depends on both mass AND volume. Spreading mass over more volume decreases density.',
            },
            {
              'text': 'Water applies zero buoyancy force to Block A because it is small.',
              'isCorrect': false,
              'feedback': 'Buoyancy acts on all submerged objects, but Block A is too dense for buoyancy to hold it up.',
            },
          ],
          'dendyPrompt': 'Both blocks weigh 4 kg! Why does Block B float while Block A sinks like a stone?',
        };

      case _DetectiveStage.caseC:
        return {
          'caseName': 'CASE C: THE EQUAL VOLUME ENIGMA',
          'caseObjective': 'Explain why two containers with the exact same volume behave differently.',
          'silhouetteLabel': 'CYLINDER X vs. CYLINDER Y (Both 2.0 L)',
          'clues': [
            'CLUE 1: Both Cylinder X and Cylinder Y take up the exact same volume: 2.0 L.',
            'CLUE 2: On the digital scale: Cylinder X weighs 1.2 kg. Cylinder Y weighs 5.4 kg.',
            'CLUE 3: In the water tank: Cylinder X floats (0.60 kg/L), but Cylinder Y sinks (2.70 kg/L).',
          ],
          'options': [
            {
              'text': 'Cylinder Y packs 5.4 kg of matter into 2 L (2.70 kg/L), making it denser than water (1.00 kg/L).',
              'isCorrect': true,
              'feedback': 'CASE SOLVED! Equal volume does NOT mean equal density. More mass packed in the same space makes it sink!',
            },
            {
              'text': 'Having the exact same 2.0 L volume guarantees both containers float identically.',
              'isCorrect': false,
              'misconception': 'confused_same_volume',
              'feedback': 'Check the scale reading! Cylinder Y contains much more mass packed tightly inside the same 2 L space.',
            },
            {
              'text': 'Cylinder X floats because it has negative mass.',
              'isCorrect': false,
              'feedback': 'Cylinder X has a positive mass of 1.2 kg. Its density (0.6 kg/L) is simply less than water (1.0 kg/L).',
            },
          ],
          'dendyPrompt': 'Both containers are 2.0 L! Why does Cylinder Y sink while Cylinder X floats on the surface?',
        };

      default:
        return {};
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
              horizontal: isShort ? 12 : 20,
              vertical: isShort ? 8 : 12,
            ),
            child: Column(
              children: [
                // Top Header Bar
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 8 : 12),

                // Main Stage View
                Expanded(
                  child: _buildStageContent(isShort),
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
        // Back Button & Badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleReturn,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorSystem.purple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'LESSON 4: CHALLENGE',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Density Detective',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isShort ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: ColorSystem.plum,
              ),
            ),
          ],
        ),

        // Case Tracker
        if (_stage != _DetectiveStage.intro && _stage != _DetectiveStage.caseClosed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCaseTrackerDot('CASE A', _stage == _DetectiveStage.caseA, _stage.index > _DetectiveStage.caseA.index),
              const SizedBox(width: 4),
              _buildCaseTrackerDot('CASE B', _stage == _DetectiveStage.caseB, _stage.index > _DetectiveStage.caseB.index),
              const SizedBox(width: 4),
              _buildCaseTrackerDot('CASE C', _stage == _DetectiveStage.caseC, _stage.index > _DetectiveStage.caseC.index),
              const SizedBox(width: 4),
              _buildCaseTrackerDot('TRICK', _stage == _DetectiveStage.trickCase, _stage == _DetectiveStage.caseClosed),
            ],
          ),

        // XP & Coins Counters
        if (_student != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          ),
      ],
    );
  }

  Widget _buildCaseTrackerDot(String label, bool isActive, bool isDone) {
    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.25);
    Color textColor = ColorSystem.plum.withOpacity(0.6);

    if (isDone) {
      bg = ColorSystem.green;
      border = ColorSystem.green;
      textColor = Colors.white;
    } else if (isActive) {
      bg = ColorSystem.purple;
      border = ColorSystem.purple;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildMetricBadge(Widget icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STAGE ROUTER
  // ==========================================
  Widget _buildStageContent(bool isShort) {
    switch (_stage) {
      case _DetectiveStage.intro:
        return _buildIntroView(isShort);
      case _DetectiveStage.caseA:
      case _DetectiveStage.caseB:
      case _DetectiveStage.caseC:
        return _buildCaseInvestigationView(isShort);
      case _DetectiveStage.trickCase:
        return _buildTrickCaseView(isShort);
      case _DetectiveStage.caseClosed:
        return _buildCaseClosedView(isShort);
    }
  }

  // ==========================================
  // 1. INTRO VIEW
  // ==========================================
  Widget _buildIntroView(bool isShort) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          padding: EdgeInsets.all(isShort ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorSystem.plum, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorSystem.lavender,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  l('MYSTERY INVESTIGATION'),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Text(
                l('DENSITY DETECTIVE'),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                l('Three mystery objects have lost their laboratory labels. Can you deduce what they are using mass, volume, and floating evidence?'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 11 : 12.5,
                  color: ColorSystem.plum.withOpacity(0.8),
                  height: 1.35,
                ),
              ),
              SizedBox(height: isShort ? 12 : 16),

              // Dendy Mascot Quote
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ColorSystem.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorSystem.gold.withOpacity(0.6), width: 1.2),
                ),
                child: DendyMascot(
                  size: isShort ? 44 : 50,
                  state: DendyState.thinking,
                  message: l('Use the clues carefully! A good detective does not guess — they look at mass, volume, and buoyancy evidence.'),
                ),
              ),
              SizedBox(height: isShort ? 14 : 20),

              CustomButton(
                text: l('START INVESTIGATION'),
                backgroundColor: ColorSystem.purple,
                textColor: Colors.white,
                height: 42,
                onPressed: _startInvestigation,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. CASE INVESTIGATION VIEW (Case A, B, C)
  // ==========================================
  Widget _buildCaseInvestigationView(bool isShort) {
    final caseData = _getCurrentCaseData();
    final clues = caseData['clues'] as List<String>;
    final options = caseData['options'] as List<Map<String, dynamic>>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Case File & Clue Board
        Expanded(
          flex: 11,
          child: Column(
            children: [
              // Case File Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            caseData['caseName'] as String,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: ColorSystem.cream,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ColorSystem.gold, width: 1.1),
                            ),
                            child: Text(
                              'CLUES FOUND: $_revealedClues / 3',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        caseData['caseObjective'] as String,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10.5,
                          color: ColorSystem.plum.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Progressive Clues List
                      Expanded(
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            for (int i = 0; i < 3; i++) ...[
                              _buildClueCard(clues[i], i < _revealedClues, i + 1, isShort),
                              const SizedBox(height: 6),
                            ],
                          ],
                        ),
                      ),

                      // Reveal Next Clue Button
                      if (_revealedClues < 3)
                        CustomButton(
                          text: 'REVEAL CLUE ${_revealedClues + 1}',
                          backgroundColor: ColorSystem.lavender,
                          textColor: ColorSystem.purple,
                          height: isShort ? 32 : 36,
                          onPressed: _revealNextClue,
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isShort ? 6 : 8),

              // Dendy Mascot Tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorSystem.plum, width: 1.4),
                ),
                child: DendyMascot(
                  size: isShort ? 40 : 46,
                  state: _hasCheckedDeduction
                      ? (_isDeductionCorrect ? DendyState.success : DendyState.thinking)
                      : DendyState.idle,
                  message: caseData['dendyPrompt'] as String,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column: Deduction Panel
        Expanded(
          flex: 13,
          child: Container(
            padding: EdgeInsets.all(isShort ? 12 : 16),
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'WHAT DO YOU DEDUCE?',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review the clues found on the left and select your deduction:',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      color: ColorSystem.plum.withOpacity(0.75),
                    ),
                  ),
                  SizedBox(height: isShort ? 8 : 12),

                  // Option Cards
                  for (int i = 0; i < options.length; i++) ...[
                    _buildDeductionOption(options[i], i, isShort),
                    const SizedBox(height: 6),
                  ],

                  SizedBox(height: isShort ? 8 : 12),

                  // Feedback Message Banner
                  if (_hasCheckedDeduction)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _isDeductionCorrect ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFFFEBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDeductionCorrect ? ColorSystem.green : Colors.redAccent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isDeductionCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                            color: _isDeductionCorrect ? ColorSystem.green : Colors.redAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _feedbackMessage,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: _isDeductionCorrect ? ColorSystem.green : Colors.redAccent.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Action Buttons
                  if (!_isDeductionCorrect)
                    CustomButton(
                      text: 'CHECK DEDUCTION',
                      backgroundColor: _selectedOptionIndex != null ? ColorSystem.purple : Colors.grey.shade400,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _selectedOptionIndex != null ? _checkDeduction : () {},
                    )
                  else
                    CustomButton(
                      text: _stage == _DetectiveStage.caseC ? 'PROCEED TO FINAL TRICK CASE' : 'NEXT CASE',
                      backgroundColor: ColorSystem.green,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _advanceToNextCase,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClueCard(String text, bool isRevealed, int clueNum, bool isShort) {
    if (!isRevealed) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isShort ? 6 : 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1.1),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              'CLUE $clueNum: HIDDEN EVIDENCE',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isShort ? 6 : 8),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorSystem.gold, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: ColorSystem.gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_rounded, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                color: ColorSystem.plum,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionOption(Map<String, dynamic> opt, int index, bool isShort) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = opt['isCorrect'] as bool;

    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.18);
    Color textColor = ColorSystem.plum;

    if (_hasCheckedDeduction) {
      if (isCorrect && _isDeductionCorrect) {
        bg = ColorSystem.green.withOpacity(0.12);
        border = ColorSystem.green;
        textColor = ColorSystem.green;
      } else if (isSelected && !_isDeductionCorrect) {
        bg = const Color(0xFFFFEBEB);
        border = Colors.redAccent;
        textColor = Colors.redAccent.shade700;
      }
    } else if (isSelected) {
      bg = ColorSystem.purple.withOpacity(0.08);
      border = ColorSystem.purple;
      textColor = ColorSystem.purple;
    }

    return GestureDetector(
      onTap: () => _selectDeduction(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isShort ? 8 : 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: isSelected || (_hasCheckedDeduction && isCorrect) ? 1.8 : 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? ColorSystem.purple : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.4),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : ColorSystem.plum,
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
                  fontSize: isShort ? 10.5 : 11.5,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. FINAL TRICK CASE VIEW
  // ==========================================
  Widget _buildTrickCaseView(bool isShort) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: EdgeInsets.all(isShort ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorSystem.plum, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ONE LAST CASE: THE MASSIVE DUO',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorSystem.lavender,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FINAL TRICK CASE',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  'Two objects have the EXACT SAME heavy mass of 10.0 kg:',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    color: ColorSystem.plum.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 6),

                // Side-by-side Object Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildObjectProfileCard('OBJECT A', 'Small compact metal ball', 'Mass: 10.0 kg\nVolume: 1.0 L\nDensity: 10.0 kg/L', ColorSystem.plum),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildObjectProfileCard('OBJECT B', 'Large hollow raft frame', 'Mass: 10.0 kg\nVolume: 25.0 L\nDensity: 0.40 kg/L', ColorSystem.purple),
                    ),
                  ],
                ),
                SizedBox(height: isShort ? 8 : 12),

                // Question 1: Which is more likely to float?
                const Text(
                  '1. Which object is more likely to float on water?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _buildChoiceChip('Object A (Small)', _trickPart1Selection == 0, () {
                        setState(() => _trickPart1Selection = 0);
                      }),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildChoiceChip('Object B (Large)', _trickPart1Selection == 1, () {
                        setState(() => _trickPart1Selection = 1);
                      }),
                    ),
                  ],
                ),
                SizedBox(height: isShort ? 8 : 12),

                // Question 2: Why?
                const Text(
                  '2. Why does that object float while the other sinks?',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(height: 4),
                _buildChoiceChip('A. Heavy objects always sink regardless of anything else.', _trickPart2Selection == 0, () {
                  setState(() => _trickPart2Selection = 0);
                }),
                const SizedBox(height: 4),
                _buildChoiceChip('B. Size alone determines floating behavior without regard to mass.', _trickPart2Selection == 1, () {
                  setState(() => _trickPart2Selection = 1);
                }),
                const SizedBox(height: 4),
                _buildChoiceChip('C. The relationship between mass and volume determines density (Mass ÷ Volume).', _trickPart2Selection == 2, () {
                  setState(() => _trickPart2Selection = 2);
                }),
                SizedBox(height: isShort ? 10 : 14),

                if (!_trickSubmitted)
                  CustomButton(
                    text: 'SUBMIT FINAL DEDUCTION',
                    backgroundColor: (_trickPart1Selection != null && _trickPart2Selection != null) ? ColorSystem.purple : Colors.grey.shade400,
                    textColor: Colors.white,
                    height: 38,
                    onPressed: (_trickPart1Selection != null && _trickPart2Selection != null) ? _submitTrickCase : () {},
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isDeductionCorrect ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFFFEBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isDeductionCorrect ? ColorSystem.green : Colors.redAccent),
                    ),
                    child: Text(
                      _isDeductionCorrect
                          ? 'EXCELLENT REASONING! Object B spreads 10 kg over 25 L (0.40 kg/L < 1.00 kg/L). Density is the relationship between mass and volume!'
                          : 'Check your reasoning: Both objects weigh 10 kg, but Object B has a huge volume, bringing its density down to 0.40 kg/L!',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: _isDeductionCorrect ? ColorSystem.green : Colors.redAccent.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    text: 'CLOSE ALL CASES',
                    backgroundColor: ColorSystem.green,
                    textColor: Colors.white,
                    height: 38,
                    onPressed: _advanceToNextCase,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectProfileCard(String title, String subtitle, String details, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: color)),
          Text(subtitle, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, color: ColorSystem.plum.withOpacity(0.7))),
          const SizedBox(height: 4),
          Text(details, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? ColorSystem.purple.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.2), width: isSelected ? 1.6 : 1.1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected ? ColorSystem.purple : ColorSystem.plum,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 4. CASE CLOSED SUMMARY VIEW
  // ==========================================
  Widget _buildCaseClosedView(bool isShort) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Container(
          padding: EdgeInsets.all(isShort ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorSystem.plum, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorSystem.green.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'ALL MYSTERIES SOLVED',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.green,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              const Text(
                'DENSITY DETECTIVE: CASE CLOSED',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'You used evidence from mass, volume, and floating behaviour to solve all the cases! You proved that density is the true relationship between mass and space.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 11 : 12.5,
                  color: ColorSystem.plum.withOpacity(0.8),
                  height: 1.35,
                ),
              ),
              SizedBox(height: isShort ? 12 : 16),

              // Dendy Mascot Success
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: ColorSystem.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorSystem.gold, width: 1.2),
                ),
                child: DendyMascot(
                  size: isShort ? 44 : 50,
                  state: DendyState.success,
                  message: 'Outstanding detective work! You deduced every mystery using scientific evidence!',
                ),
              ),
              SizedBox(height: isShort ? 14 : 20),

              CustomButton(
                text: 'CLAIM REWARDS & UNLOCK TEACH-BACK',
                backgroundColor: ColorSystem.green,
                textColor: Colors.white,
                height: 42,
                onPressed: _completeLesson,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

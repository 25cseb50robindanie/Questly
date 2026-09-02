import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/adaptive_learning_engine.dart';
import '../services/misconception_engine.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/fraction_visual_models.dart';
import '../widgets/misconception_remediation_dialog.dart';

class FractionPracticeScreen extends StatefulWidget {
  final Activity? activity;

  const FractionPracticeScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionPracticeScreen> createState() => _FractionPracticeScreenState();
}

class _FractionPracticeScreenState extends State<FractionPracticeScreen> {
  Student? _student;
  Activity? _activeActivity;
  bool _isRatios = false;

  final AdaptiveLearningEngine _adaptiveEngine = AdaptiveLearningEngine();
  final MisconceptionEngine _misconceptionEngine = MisconceptionEngine();
  late AdaptiveSessionState _sessionState;

  int _currentProblemIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _isCompleted = false;

  List<AdaptiveProblem> _problemPool = [];

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _initProblemPool();
  }

  void _loadStudent() {
    try {
      _student = Locator.studentRepository.getCurrentStudent() ??
          Locator.authService.getCurrentStudent();
    } catch (_) {
      _student = null;
    }
    _sessionState = _adaptiveEngine.getSession(
      _student?.questlyId ?? 'stu_demo',
      _isRatios ? 'ratios' : 'fractions',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Activity) {
      _activeActivity = args;
    } else if (widget.activity != null) {
      _activeActivity = widget.activity;
    }
    
    final wasRatios = _isRatios;
    _isRatios = _activeActivity?.type == 'ratio_practice' ||
        _activeActivity?.id.contains('ratio') == true;
        
    if (_problemPool.isEmpty || wasRatios != _isRatios) {
      _initProblemPool();
      _sessionState = _adaptiveEngine.getSession(
        _student?.questlyId ?? 'stu_demo',
        _isRatios ? 'ratios' : 'fractions',
      );
    }
  }

  void _initProblemPool() {
    if (!_isRatios) {
      _problemPool = [
        // Level 1: Beginner (Identification)
        const AdaptiveProblem(
          id: 'frac_p1',
          topic: 'fractions',
          category: 'identification',
          difficulty: DifficultyLevel.beginner,
          question: 'What fraction of the pizza is remaining (orange slices)?',
          subtitle: 'Count the selected orange slices on top, and ALL total slices on bottom.',
          visualData: {'type': 'pizza', 'total': 4, 'selected': 3},
          options: ['3/4', '3/1', '1/4', '4/3'],
          correctIndex: 0,
          explanation: '3 slices are selected out of 4 total slices in the pizza, which is 3/4!',
          misconceptionTriggers: {
            1: 'denominator_confusion', // 3/1 counting unshaded as denominator
            2: 'numerator_confusion',   // 1/4 counting unshaded as numerator
          },
          hint: 'Denominator = Total slices (4). Numerator = Orange slices (3).',
        ),

        // Level 2: Comparison & Denominator Fallacy
        const AdaptiveProblem(
          id: 'frac_p2',
          topic: 'fractions',
          category: 'comparison',
          difficulty: DifficultyLevel.beginner,
          question: 'Which fraction of a pizza gives you a BIGGER slice?',
          subtitle: 'Think: Does cutting into more pieces make slices bigger or smaller?',
          visualData: {'type': 'comparison_pizza'},
          options: ['1/4 is bigger', '1/8 is bigger', 'Both are equal', 'Neither'],
          correctIndex: 0,
          explanation: '1/4 is bigger because cutting into fewer pieces (4) leaves larger slices than cutting into 8 pieces!',
          misconceptionTriggers: {
            1: 'larger_denominator_fallacy', // Thinking 8 > 4 means 1/8 > 1/4
          },
          hint: 'More slices = Smaller slice size. 4 slices is bigger than 8 slices!',
        ),

        // Level 3: Intermediate (Equivalent Fractions)
        const AdaptiveProblem(
          id: 'frac_p3',
          topic: 'fractions',
          category: 'equivalent',
          difficulty: DifficultyLevel.intermediate,
          question: 'Which fraction is EQUIVALENT to 1/2?',
          subtitle: 'Multiply both top and bottom by the same number (2).',
          visualData: {'type': 'strips', 'den': 4, 'num': 2},
          options: ['2/4', '2/3', '1/4', '3/4'],
          correctIndex: 0,
          explanation: '1/2 is equal to 2/4 because 1×2 = 2 and 2×2 = 4 (both cover exactly half the bar)!',
          misconceptionTriggers: {
            1: 'equivalent_additive_fallacy', // Adding 1 to top and bottom
          },
          hint: 'Multiply numerator and denominator by 2: (1×2) / (2×2).',
        ),

        // Level 4: Advanced (Number Line & Benchmark)
        const AdaptiveProblem(
          id: 'frac_p4',
          topic: 'fractions',
          category: 'comparison',
          difficulty: DifficultyLevel.advanced,
          question: 'Where does the fraction 3/4 sit on the number line?',
          subtitle: 'Is 3/4 closer to 0, closer to 1/2, or closer to 1?',
          visualData: {'type': 'number_line', 'den': 4, 'num': 3},
          options: ['Between 1/2 and 1 (Closer to 1)', 'Between 0 and 1/2 (Closer to 0)', 'Exactly at 1/2', 'Past 1'],
          correctIndex: 0,
          explanation: '3/4 is 75%, which is past 1/2 (50%) and very close to the whole 1 (100%)!',
          hint: '1/2 is 2/4. Since 3/4 is more than 2/4, it is closer to 1.',
        ),

        // Level 5: Master (Chocolate Bar Word Problem)
        const AdaptiveProblem(
          id: 'frac_p5',
          topic: 'fractions',
          category: 'word_problem',
          difficulty: DifficultyLevel.master,
          question: 'Nova has a chocolate bar with 8 pieces. She eats 2 pieces and gives 2 pieces to Dendy. What fraction of the bar is left?',
          subtitle: 'Total pieces = 8. Eaten = 4 pieces.',
          visualData: {'type': 'chocolate', 'total': 8, 'selected': 4},
          options: ['4/8 (which simplifies to 1/2)', '2/8', '6/8', '4/4'],
          correctIndex: 0,
          explanation: 'Total eaten = 2 + 2 = 4. Remaining = 8 - 4 = 4 pieces out of 8, which is 4/8 = 1/2!',
          hint: 'Subtract 4 pieces from 8 total pieces: 4 pieces remain out of 8.',
        ),
      ];
    } else {
      _problemPool = [
        // Ratios Problem 1: Order & Identification
        const AdaptiveProblem(
          id: 'ratio_p1',
          topic: 'ratios',
          category: 'identification',
          difficulty: DifficultyLevel.beginner,
          question: 'There are 3 red apples and 5 blue berries. What is the ratio of APPLES to BERRIES?',
          subtitle: 'Order matters: Name the apples count first, then berries count.',
          visualData: {'type': 'fruits', 'a': 3, 'b': 5},
          options: ['3 : 5', '5 : 3', '3 : 8', '8 : 3'],
          correctIndex: 0,
          explanation: 'Apples is 3 and Berries is 5, so the ratio of Apples to Berries is 3 : 5!',
          misconceptionTriggers: {
            1: 'ratio_order_inversion', // Inverted order
          },
          hint: 'Apples come first in the question (3), Berries come second (5).',
        ),

        // Ratios Problem 2: Simplification
        const AdaptiveProblem(
          id: 'ratio_p2',
          topic: 'ratios',
          category: 'simplification',
          difficulty: DifficultyLevel.intermediate,
          question: 'Simplify the ratio 4 : 6 by dividing both numbers by their common factor (2):',
          subtitle: 'Divide 4 by 2, and divide 6 by 2.',
          visualData: {'type': 'beaker', 'a': 4, 'b': 6},
          options: ['2 : 3', '2 : 4', '1 : 3', '3 : 2'],
          correctIndex: 0,
          explanation: '4÷2 = 2 and 6÷2 = 3. The simplified ratio is 2 : 3!',
          misconceptionTriggers: {
            1: 'ratio_simplification_subtraction',
          },
          hint: 'Divide BOTH numbers by 2.',
        ),

        // Ratios Problem 3: Proportional Scaling
        const AdaptiveProblem(
          id: 'ratio_p3',
          topic: 'ratios',
          category: 'equivalent',
          difficulty: DifficultyLevel.advanced,
          question: 'A potion recipe requires 2 cups juice for every 3 cups water (2 : 3). If you use 6 cups juice, how many cups of water do you need?',
          subtitle: 'Juice was multiplied by 3 (2 × 3 = 6). Multiply water by 3 too!',
          visualData: {'type': 'beaker', 'a': 6, 'b': 9},
          options: ['9 cups of water', '6 cups of water', '7 cups of water', '12 cups of water'],
          correctIndex: 0,
          explanation: 'Since juice tripled (2 × 3 = 6), water must also triple (3 × 3 = 9 cups)!',
          hint: 'Scale up: 2 × 3 = 6, so 3 × 3 = ?',
        ),
      ];
    }
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap', arguments: 'mod_fractions');
    }
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _isAnswered || _problemPool.isEmpty) return;

    final currentProblem = _problemPool[_currentProblemIndex];
    final isCorrect = (_selectedOptionIndex == currentProblem.correctIndex);

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      _sessionState = _adaptiveEngine.recordAnswer(
        studentId: _student?.questlyId ?? 'stu_demo',
        topic: _isRatios ? 'ratios' : 'fractions',
        isCorrect: isCorrect,
        problemDifficulty: currentProblem.difficulty,
      );
    });

    if (isCorrect) {
      SoundService.playSuccess();
    } else {
      SoundService.playSwitch();

      // Check for misconception trigger
      final trigger = currentProblem.misconceptionTriggers?[_selectedOptionIndex!];
      final diagnosis = _misconceptionEngine.diagnose(
        explicitTrigger: trigger,
        topic: _isRatios ? 'ratios' : 'fractions',
        selectedOption: currentProblem.options[_selectedOptionIndex!],
        correctOption: currentProblem.options[currentProblem.correctIndex],
      );

      if (diagnosis != null) {
        // Open Remediation Dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MisconceptionRemediationDialog.show(
            context: context,
            diagnosis: diagnosis,
            onResolved: () {
              setState(() {});
            },
          );
        });
      }
    }
  }

  void _nextProblem() {
    SoundService.playClick();
    if (_currentProblemIndex < _problemPool.length - 1) {
      setState(() {
        _currentProblemIndex++;
        _selectedOptionIndex = null;
        _isAnswered = false;
        _isCorrect = false;
      });
    } else {
      _completePracticeLesson();
    }
  }

  Future<void> _completePracticeLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = _isRatios ? 'ratios_les3' : 'fractions_les3';
      final xp = _activeActivity?.xpReward ?? 60;
      final gold = _activeActivity?.goldReward ?? 10;

      try {
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

        final updated = student.copyWith(
          xp: student.xp + xp,
          gold: student.gold + gold,
          currentLessonId: _isRatios ? 'ratios_les4' : 'fractions_les4',
        );
        await Locator.studentRepository.updateStudentProfile(updated);
      } catch (_) {}
    }

    SoundService.playLevelComplete();
    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: _activeActivity?.xpReward ?? 60,
        goldReward: _activeActivity?.goldReward ?? 10,
        earnedStars: 3,
        title: 'GUIDED PRACTICE MASTERED!',
        message: 'Your adaptive confidence is soaring! Next up: The Challenge Arena!',
        onContinue: () {
          Navigator.pushReplacementNamed(
            context,
            '/fraction_challenge',
            arguments: _activeActivity,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_problemPool.isEmpty) {
      return const Scaffold(
        backgroundColor: ColorSystem.cream,
        body: Center(
          child: CircularProgressIndicator(color: ColorSystem.purple),
        ),
      );
    }

    final safeIndex = _currentProblemIndex.clamp(0, _problemPool.length - 1);
    final problem = _problemPool[safeIndex];

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth >= 600;
              final isShort = constraints.maxHeight < 450;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isShort ? 12 : 18,
                  vertical: isShort ? 6 : 10,
                ),
                child: Column(
                  children: [
                    _buildHeader(isShort),
                    SizedBox(height: isShort ? 4 : 8),
                    _buildAdaptiveMetricsBar(),
                    SizedBox(height: isShort ? 6 : 8),

                    // Main Problem Container
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isShort ? 10 : 16),
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
                        child: isLandscape
                            ? _buildLandscapeLayout(problem, isShort)
                            : _buildPortraitLayout(problem),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(AdaptiveProblem problem, bool isShort) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Visual problem representation
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorSystem.purple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'QUESTION ${_currentProblemIndex + 1} OF ${_problemPool.length}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ),
                  DendySpeakButton(textToSpeak: '${problem.question} ${problem.subtitle ?? ''}', size: 22),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                problem.question,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 14 : 16,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
              if (problem.subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  problem.subtitle!,
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, color: ColorSystem.plum.withOpacity(0.7)),
                ),
              ],
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildProblemVisual(problem),
                  ),
                ),
              ),
              // Hint box if student made mistake
              if (_isAnswered && !_isCorrect)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.gold, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded, color: ColorSystem.gold, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          problem.hint,
                          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.bold, color: ColorSystem.plum),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right Column: Interactive Options + Submit/Next Button
        Expanded(
          flex: 11,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'SELECT YOUR ANSWER',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(problem.options.length, (i) {
                        return _buildOptionTile(problem, i);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              CustomButton(
                text: _isAnswered
                    ? (_currentProblemIndex < _problemPool.length - 1 ? 'NEXT QUESTION →' : 'FINISH PRACTICE ✓')
                    : 'CHECK ANSWER',
                backgroundColor: _selectedOptionIndex == null
                    ? Colors.grey.shade400
                    : (_isAnswered ? ColorSystem.green : ColorSystem.purple),
                textColor: Colors.white,
                height: 40,
                onPressed: _selectedOptionIndex == null
                    ? () {}
                    : (_isAnswered ? _nextProblem : _submitAnswer),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(AdaptiveProblem problem) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorSystem.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'QUESTION ${_currentProblemIndex + 1} OF ${_problemPool.length}',
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
              ),
              DendySpeakButton(textToSpeak: '${problem.question} ${problem.subtitle ?? ''}', size: 22),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            problem.question,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.plum),
          ),
          if (problem.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(problem.subtitle!, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, color: ColorSystem.plum.withOpacity(0.7))),
          ],
          const SizedBox(height: 12),
          Center(child: _buildProblemVisual(problem)),
          const SizedBox(height: 12),
          ...List.generate(problem.options.length, (i) {
            return _buildOptionTile(problem, i);
          }),
          if (_isAnswered && !_isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ColorSystem.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorSystem.gold, width: 1),
              ),
              child: Text(problem.hint, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
            ),
          ],
          const SizedBox(height: 14),
          CustomButton(
            text: _isAnswered
                ? (_currentProblemIndex < _problemPool.length - 1 ? 'NEXT QUESTION →' : 'FINISH PRACTICE ✓')
                : 'CHECK ANSWER',
            backgroundColor: _selectedOptionIndex == null
                ? Colors.grey.shade400
                : (_isAnswered ? ColorSystem.green : ColorSystem.purple),
            textColor: Colors.white,
            height: 42,
            onPressed: _selectedOptionIndex == null
                ? () {}
                : (_isAnswered ? _nextProblem : _submitAnswer),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(AdaptiveProblem problem, int i) {
    final option = problem.options[i];
    final isSelected = _selectedOptionIndex == i;
    final isCorrectOption = i == problem.correctIndex;

    Color optBg = Colors.white;
    Color optBorder = ColorSystem.plum.withOpacity(0.2);

    if (_isAnswered) {
      if (isCorrectOption) {
        optBg = ColorSystem.green.withOpacity(0.15);
        optBorder = ColorSystem.green;
      } else if (isSelected && !isCorrectOption) {
        optBg = ColorSystem.pink.withOpacity(0.15);
        optBorder = ColorSystem.pink;
      }
    } else if (isSelected) {
      optBg = ColorSystem.purple.withOpacity(0.12);
      optBorder = ColorSystem.purple;
    }

    return GestureDetector(
      onTap: _isAnswered
          ? null
          : () {
              SoundService.playClick();
              setState(() {
                _selectedOptionIndex = i;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: optBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: optBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              _isAnswered && isCorrectOption
                  ? Icons.check_circle_rounded
                  : (_isAnswered && isSelected
                      ? Icons.cancel_rounded
                      : (isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded)),
              color: _isAnswered && isCorrectOption
                  ? ColorSystem.green
                  : (_isAnswered && isSelected ? ColorSystem.pink : ColorSystem.plum),
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12.5,
                  fontWeight: isSelected || (_isAnswered && isCorrectOption)
                      ? FontWeight.w900
                      : FontWeight.bold,
                  color: ColorSystem.plum,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdaptiveMetricsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: ColorSystem.gold, size: 15),
              const SizedBox(width: 4),
              Text(
                'DIFFICULTY: ${_sessionState.currentDifficulty.name.toUpperCase()}',
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: ColorSystem.pink, size: 15),
              const SizedBox(width: 4),
              Text(
                'STREAK: ${_sessionState.streak}',
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.pink),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: ColorSystem.green, size: 15),
              const SizedBox(width: 4),
              Text(
                'CONFIDENCE: ${(_sessionState.confidenceScore * 100).toInt()}%',
                style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProblemVisual(AdaptiveProblem problem) {
    final type = problem.visualData?['type'] as String?;
    if (type == 'pizza') {
      return PizzaVisualWidget(
        totalSlices: problem.visualData['total'] ?? 4,
        selectedSlices: problem.visualData['selected'] ?? 3,
        size: 120,
      );
    } else if (type == 'comparison_pizza') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          PizzaVisualWidget(totalSlices: 4, selectedSlices: 1, size: 80, label: '1/4'),
          Text('VS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
          PizzaVisualWidget(totalSlices: 8, selectedSlices: 1, size: 80, label: '1/8'),
        ],
      );
    } else if (type == 'strips') {
      return const FractionStripsVisualWidget(
        denominators: [2, 4],
        activeDenominator: 4,
        activeNumerator: 2,
      );
    } else if (type == 'number_line') {
      return const NumberLineVisualWidget(denominator: 4, numerator: 3, width: 220);
    } else if (type == 'chocolate') {
      return const ChocolateBarVisualWidget(totalRows: 2, totalCols: 4, selectedPieces: 4, width: 140, height: 70);
    } else if (type == 'fruits') {
      return FruitRatioVisualWidget(countA: problem.visualData['a'] ?? 3, countB: problem.visualData['b'] ?? 5, labelA: 'Apples', labelB: 'Berries');
    } else if (type == 'beaker') {
      return RatioBeakerVisualWidget(partA: problem.visualData['a'] ?? 4, partB: problem.visualData['b'] ?? 6, height: 105, width: 85);
    }

    return const DendyMascot(size: 55, mood: DendyMood.explaining);
  }

  Widget _buildHeader(bool isShort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
              onPressed: _handleReturn,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isRatios ? 'RATIOS • LEVEL 2' : 'FRACTIONS • LEVEL 1',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: isShort ? 10 : 12, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                Text(
                  'LESSON 3: GUIDED PRACTICE',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: isShort ? 12 : 14, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                ),
              ],
            ),
          ],
        ),
        if (_student != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
            ),
            child: Row(
              children: [
                VectorAssetHelper.xpStarIcon(size: 14),
                const SizedBox(width: 4),
                Text('${_student!.xp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              ],
            ),
          ),
      ],
    );
  }
}

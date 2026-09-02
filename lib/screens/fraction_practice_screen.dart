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
  String _topic = 'fractions'; // 'fractions', 'ratios', 'proportions', 'percentages', 'applications'

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
      _topic,
    );
  }

  String _detectTopic(Activity? act) {
    if (act == null) return 'fractions';
    final id = act.id.toLowerCase();
    final type = act.type.toLowerCase();
    if (type.contains('ratio') || id.contains('ratio')) return 'ratios';
    if (type.contains('proportion') || id.contains('proportion')) return 'proportions';
    if (type.contains('percentage') || id.contains('percentage') || type.contains('percent') || id.contains('percent')) return 'percentages';
    if (type.contains('application') || id.contains('application')) return 'applications';
    return 'fractions';
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

    final newTopic = _detectTopic(_activeActivity);
    if (_problemPool.isEmpty || newTopic != _topic) {
      _topic = newTopic;
      _initProblemPool();
      _sessionState = _adaptiveEngine.getSession(
        _student?.questlyId ?? 'stu_demo',
        _topic,
      );
    }
  }

  void _initProblemPool() {
    switch (_topic) {
      case 'ratios':
        _problemPool = [
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
              1: 'ratio_order_inversion',
            },
            hint: 'Apples come first in the question (3), Berries come second (5).',
          ),
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
          const AdaptiveProblem(
            id: 'ratio_p3',
            topic: 'ratios',
            category: 'equivalent',
            difficulty: DifficultyLevel.advanced,
            question: 'A potion requires 2 cups juice for every 3 cups water (2 : 3). If you use 6 cups juice, how many cups water are needed?',
            subtitle: 'Juice tripled (2 × 3 = 6). Multiply water by 3 too!',
            visualData: {'type': 'beaker', 'a': 6, 'b': 9},
            options: ['9 cups of water', '6 cups of water', '7 cups of water', '12 cups of water'],
            correctIndex: 0,
            explanation: 'Since juice tripled (2 × 3 = 6), water must also triple (3 × 3 = 9 cups)!',
            hint: 'Scale up: 2 × 3 = 6, so 3 × 3 = ?',
          ),
          const AdaptiveProblem(
            id: 'ratio_p4',
            topic: 'ratios',
            category: 'simplification',
            difficulty: DifficultyLevel.advanced,
            question: 'Which ratio is in its SIMPLEST form?',
            subtitle: 'Check if both numbers can still be divided by a common factor.',
            options: ['3 : 7', '4 : 8', '6 : 9', '10 : 15'],
            correctIndex: 0,
            explanation: '3 and 7 share no common factor other than 1, so 3:7 is already in simplest form!',
            hint: '4:8 simplifies to 1:2, 6:9 simplifies to 2:3, 10:15 simplifies to 2:3.',
          ),
          const AdaptiveProblem(
            id: 'ratio_p5',
            topic: 'ratios',
            category: 'word_problem',
            difficulty: DifficultyLevel.master,
            question: 'In a guild of 24 adventurers, the ratio of Mages to Knights is 1 : 3. How many Mages are in the guild?',
            subtitle: 'Total parts = 1 + 3 = 4 parts. 24 ÷ 4 = 6 per part.',
            options: ['6 Mages', '8 Mages', '18 Mages', '4 Mages'],
            correctIndex: 0,
            explanation: 'Total ratio parts = 4. Each part = 24 / 4 = 6. Mages = 1 × 6 = 6!',
            hint: 'Add the ratio terms 1 + 3 = 4 parts, then divide 24 by 4.',
          ),
        ];
        break;

      case 'proportions':
        _problemPool = [
          const AdaptiveProblem(
            id: 'prop_p1',
            topic: 'proportions',
            category: 'scaling',
            difficulty: DifficultyLevel.beginner,
            question: 'A map uses the scale 1 cm = 5 km. If two castles are 3 cm apart on the map, what is the actual distance?',
            subtitle: 'Multiply map cm by scale factor (3 × 5).',
            visualData: {'type': 'blueprint', 'cm': 3},
            options: ['15 km', '8 km', '10 km', '25 km'],
            correctIndex: 0,
            explanation: '3 cm × 5 km per cm = 15 km in the kingdom!',
            misconceptionTriggers: {
              1: 'additive_scaling_fallacy',
            },
            hint: 'Multiply 3 by 5.',
          ),
          const AdaptiveProblem(
            id: 'prop_p2',
            topic: 'proportions',
            category: 'equivalent',
            difficulty: DifficultyLevel.intermediate,
            question: 'Solve for x in the proportion: 2/5 = x/10',
            subtitle: 'Notice the denominator doubled (5 × 2 = 10). Double the numerator too!',
            visualData: {'type': 'balance', 'lNum': 2, 'lDen': 5, 'rNum': 4, 'rDen': 10},
            options: ['x = 4', 'x = 7', 'x = 5', 'x = 8'],
            correctIndex: 0,
            explanation: '2/5 = (2×2)/(5×2) = 4/10. Therefore x = 4!',
            misconceptionTriggers: {
              1: 'additive_scaling_fallacy',
            },
            hint: 'Cross-multiply: 2 × 10 = 20, then 20 ÷ 5 = 4.',
          ),
          const AdaptiveProblem(
            id: 'prop_p3',
            topic: 'proportions',
            category: 'scaling',
            difficulty: DifficultyLevel.advanced,
            question: 'A toy castle tower is 4 cm wide and 6 cm tall. An enlarged tower is 12 cm wide. How tall is it?',
            subtitle: 'Width tripled (4 × 3 = 12). Multiply height by 3 too!',
            visualData: {'type': 'scale', 'k': 3.0},
            options: ['18 cm tall (6 × 3)', '14 cm tall (6 + 8)', '12 cm tall', '24 cm tall'],
            correctIndex: 0,
            explanation: 'Scale factor k = 12 / 4 = 3. Scaled height = 6 × 3 = 18 cm!',
            misconceptionTriggers: {
              1: 'additive_scaling_fallacy',
            },
            hint: 'Find scale factor: 12 ÷ 4 = 3. Multiply 6 by 3.',
          ),
          const AdaptiveProblem(
            id: 'prop_p4',
            topic: 'proportions',
            category: 'equivalent',
            difficulty: DifficultyLevel.advanced,
            question: 'Which of the following pairs of ratios forms a TRUE proportion?',
            subtitle: 'Test cross-products: a × d must equal b × c.',
            options: ['3/4 and 9/12 (36 = 36)', '2/3 and 4/5', '1/2 and 2/5', '3/5 and 6/8'],
            correctIndex: 0,
            explanation: '3 × 12 = 36 and 4 × 9 = 36. Since cross-products match, 3/4 = 9/12 is a true proportion!',
            hint: 'Multiply diagonally and check if products are equal.',
          ),
          const AdaptiveProblem(
            id: 'prop_p5',
            topic: 'proportions',
            category: 'word_problem',
            difficulty: DifficultyLevel.master,
            question: '5 alchemists can brew 15 potions in 2 hours. At this rate, how many potions can 10 alchemists brew in 2 hours?',
            subtitle: 'Alchemists doubled (5 × 2 = 10). Potions double too!',
            options: ['30 potions', '20 potions', '25 potions', '45 potions'],
            correctIndex: 0,
            explanation: 'Since the number of alchemists doubled, the potions produced also double: 15 × 2 = 30 potions!',
            hint: 'Proportional scaling: 15 × (10 / 5) = 30.',
          ),
        ];
        break;

      case 'percentages':
        _problemPool = [
          const AdaptiveProblem(
            id: 'perc_p1',
            topic: 'percentages',
            category: 'identification',
            difficulty: DifficultyLevel.beginner,
            question: 'What percentage of a 100-grid is shaded if 25 squares are colored?',
            subtitle: 'Percent literally means "parts per hundred".',
            visualData: {'type': 'hundred_grid', 'percent': 25},
            options: ['25%', '2.5%', '50%', '75%'],
            correctIndex: 0,
            explanation: '25 squares out of 100 squares is 25/100 = 25%!',
            misconceptionTriggers: {
              1: 'base_100_misinterpretation',
            },
            hint: 'Squares shaded out of 100 = Percentage directly.',
          ),
          const AdaptiveProblem(
            id: 'perc_p2',
            topic: 'percentages',
            category: 'conversion',
            difficulty: DifficultyLevel.intermediate,
            question: 'Convert the fraction 3/4 into a percentage:',
            subtitle: 'Scale 3/4 so denominator is 100: (3 × 25) / (4 × 25).',
            options: ['75%', '34%', '30%', '80%'],
            correctIndex: 0,
            explanation: '3/4 = 75/100 = 75%!',
            misconceptionTriggers: {
              1: 'base_100_misinterpretation',
            },
            hint: 'Divide 3 by 4 = 0.75. Multiply 0.75 × 100 = 75%.',
          ),
          const AdaptiveProblem(
            id: 'perc_p3',
            topic: 'percentages',
            category: 'discount',
            difficulty: DifficultyLevel.advanced,
            question: 'An enchanted bow costs 80 gold coins and is on sale for 25% off. How much is the discount?',
            subtitle: 'Calculate 25% of 80 (or 1/4 of 80).',
            visualData: {'type': 'discount', 'price': 80, 'percent': 25},
            options: ['20 gold coins (1/4 of 80)', '25 gold coins', '55 gold coins', '15 gold coins'],
            correctIndex: 0,
            explanation: '25% of 80 = 0.25 × 80 = 20 gold coins discount!',
            misconceptionTriggers: {
              1: 'discount_subtraction_fallacy',
            },
            hint: '25% = 1/4. Find 80 ÷ 4 = 20.',
          ),
          const AdaptiveProblem(
            id: 'perc_p4',
            topic: 'percentages',
            category: 'discount',
            difficulty: DifficultyLevel.advanced,
            question: 'A potion costs 50 gold. After a 10% discount, what is the FINAL price you pay?',
            subtitle: 'Discount = 10% of 50 = 5 gold. Final price = 50 - 5.',
            options: ['45 gold coins', '40 gold coins', '55 gold coins', '35 gold coins'],
            correctIndex: 0,
            explanation: 'Discount = 5 gold. Final price = 50 - 5 = 45 gold coins!',
            hint: 'Subtract discount (5) from original price (50).',
          ),
          const AdaptiveProblem(
            id: 'perc_p5',
            topic: 'percentages',
            category: 'word_problem',
            difficulty: DifficultyLevel.master,
            question: 'In a kingdom quiz of 40 questions, Nova answered 36 correctly. What was her percentage score?',
            subtitle: 'Score = (36 / 40) × 100.',
            options: ['90%', '85%', '92%', '36%'],
            correctIndex: 0,
            explanation: '36 / 40 = 0.90 = 90% accuracy!',
            hint: 'Simplify 36/40 to 9/10, which equals 90/100 = 90%.',
          ),
        ];
        break;

      case 'applications':
        _problemPool = [
          const AdaptiveProblem(
            id: 'app_p1',
            topic: 'applications',
            category: 'word_problem',
            difficulty: DifficultyLevel.beginner,
            question: 'A feast recipe for 4 knights uses 2 cups flour. How much flour is needed for 12 knights?',
            subtitle: 'Knights tripled (4 × 3 = 12). Multiply flour by 3.',
            visualData: {'type': 'recipe', 'servings': 12},
            options: ['6 cups of flour', '4 cups of flour', '8 cups of flour', '10 cups of flour'],
            correctIndex: 0,
            explanation: '12 / 4 = 3 batches. 3 batches × 2 cups = 6 cups flour!',
            misconceptionTriggers: {
              1: 'multi_step_order_confusion',
            },
            hint: 'Multiply 2 cups by 3.',
          ),
          const AdaptiveProblem(
            id: 'app_p2',
            topic: 'applications',
            category: 'word_problem',
            difficulty: DifficultyLevel.intermediate,
            question: 'On a royal map (scale 1 cm = 10 km), the distance to the dragon mountain is 6 cm. If your horse travels 20 km per hour, how many hours does the journey take?',
            subtitle: 'Step 1: Find real distance (6 × 10 = 60 km). Step 2: Time = 60 ÷ 20.',
            visualData: {'type': 'blueprint', 'cm': 6},
            options: ['3 hours', '6 hours', '2 hours', '4 hours'],
            correctIndex: 0,
            explanation: 'Total distance = 6 × 10 = 60 km. Travel time = 60 km ÷ 20 km/h = 3 hours!',
            misconceptionTriggers: {
              1: 'multi_step_order_confusion',
            },
            hint: 'Real distance = 60 km. Divide 60 by speed (20).',
          ),
          const AdaptiveProblem(
            id: 'app_p3',
            topic: 'applications',
            category: 'word_problem',
            difficulty: DifficultyLevel.advanced,
            question: 'To build the Grand Bridge requires 100 stone pillars costing 4 gold each. The King gives a 25% discount. What is the total discounted cost?',
            subtitle: 'Step 1: Total price = 100 × 4 = 400 gold. Step 2: 25% off 400 = 100 gold. Step 3: 400 - 100 = 300 gold.',
            options: ['300 gold coins', '375 gold coins', '250 gold coins', '400 gold coins'],
            correctIndex: 0,
            explanation: 'Base cost = 400 gold. 25% discount saves 100 gold. Total = 300 gold coins!',
            misconceptionTriggers: {
              1: 'multi_step_order_confusion',
            },
            hint: 'Find full cost (400), then take 25% off (save 100).',
          ),
          const AdaptiveProblem(
            id: 'app_p4',
            topic: 'applications',
            category: 'word_problem',
            difficulty: DifficultyLevel.advanced,
            question: 'A water reservoir is 3/5 full. After adding 200 liters, it becomes 4/5 full. What is the total capacity of the reservoir?',
            subtitle: 'The 200 liters added corresponds to 1/5 of the reservoir (4/5 - 3/5 = 1/5). Total = 200 × 5.',
            options: ['1,000 liters (200 × 5)', '800 liters', '600 liters', '500 liters'],
            correctIndex: 0,
            explanation: '1/5 of capacity = 200 L. Total capacity = 200 × 5 = 1,000 L!',
            hint: '4/5 - 3/5 = 1/5. If 1/5 is 200 liters, multiply by 5.',
          ),
          const AdaptiveProblem(
            id: 'app_p5',
            topic: 'applications',
            category: 'word_problem',
            difficulty: DifficultyLevel.master,
            question: 'An army of 80 soldiers has rations for 30 days. If 20 more soldiers join (total 100), how many days will the same rations last?',
            subtitle: 'Total soldier-days = 80 × 30 = 2,400. Divide by 100 soldiers.',
            options: ['24 days (2,400 ÷ 100)', '20 days', '28 days', '15 days'],
            correctIndex: 0,
            explanation: 'Total food supply = 80 × 30 = 2,400 rations. 2,400 ÷ 100 soldiers = 24 days!',
            hint: 'Inverse proportion: (80 × 30) / 100 = 24 days.',
          ),
        ];
        break;

      case 'fractions':
      default:
        _problemPool = [
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
              1: 'denominator_confusion',
              2: 'numerator_confusion',
            },
            hint: 'Denominator = Total slices (4). Numerator = Orange slices (3).',
          ),
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
              1: 'larger_denominator_fallacy',
            },
            hint: 'More slices = Smaller slice size. 4 slices is bigger than 8 slices!',
          ),
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
              1: 'equivalent_additive_fallacy',
            },
            hint: 'Multiply numerator and denominator by 2: (1×2) / (2×2).',
          ),
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
        break;
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
    final String? trigger = (!isCorrect && _selectedOptionIndex != null && currentProblem.misconceptionTriggers != null)
        ? currentProblem.misconceptionTriggers![_selectedOptionIndex!]
        : null;

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      _sessionState = _adaptiveEngine.recordAnswer(
        studentId: _student?.questlyId ?? 'stu_demo',
        topic: _topic,
        isCorrect: isCorrect,
        problemDifficulty: currentProblem.difficulty,
        triggeredMisconception: trigger,
      );
    });

    if (isCorrect) {
      SoundService.playSuccess();
    } else {
      SoundService.playSwitch();

      final diagnosis = _misconceptionEngine.diagnose(
        explicitTrigger: trigger,
        topic: _topic,
        selectedOption: currentProblem.options[_selectedOptionIndex!],
        correctOption: currentProblem.options[currentProblem.correctIndex],
      );

      if (diagnosis != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          MisconceptionRemediationDialog.show(
            context: context,
            diagnosis: diagnosis,
            onResolved: () {
              _adaptiveEngine.resolveMisconception(
                _student?.questlyId ?? 'stu_demo',
                _topic,
                diagnosis.id,
              );
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
      _evaluateMasteryAndComplete();
    }
  }

  Future<void> _evaluateMasteryAndComplete() async {
    final sId = _student?.questlyId ?? 'stu_demo';
    final isMastered = _adaptiveEngine.isMasteryAchieved(sId, _topic);

    if (!isMastered) {
      // Show instructional feedback and dynamically cycle questions so learner keeps practicing
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.psychology_rounded, color: ColorSystem.purple, size: 24),
              SizedBox(width: 8),
              Text('MASTERY REQUIRED', style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To unlock Lesson 4 (Challenge), you must achieve full conceptual mastery:',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: 12.5, color: ColorSystem.plum),
              ),
              const SizedBox(height: 10),
              _buildMasteryCheckItem('Accuracy >= 80%', _sessionState.accuracy >= 0.80, '${(_sessionState.accuracy * 100).toInt()}%'),
              _buildMasteryCheckItem('Mastery Score >= 80%', _sessionState.masteryScore >= 0.80, '${(_sessionState.masteryScore * 100).toInt()}%'),
              _buildMasteryCheckItem('5 Consecutive Correct Answers', _sessionState.streak >= 5, '${_sessionState.streak}/5 streak'),
              _buildMasteryCheckItem('Zero Active Misconceptions', _sessionState.activeMisconceptions.isEmpty, '${_sessionState.activeMisconceptions.length} active'),
              const SizedBox(height: 12),
              const Text(
                'Keep practicing! The adaptive system will continue generating targeted questions.',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.bold, color: ColorSystem.purple),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSystem.purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _currentProblemIndex = 0;
                  _selectedOptionIndex = null;
                  _isAnswered = false;
                  _isCorrect = false;
                });
              },
              child: const Text('CONTINUE PRACTICING →', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = '${_topic}_les3';
      final xp = _activeActivity?.xpReward ?? 60;
      final gold = _activeActivity?.goldReward ?? 10;

      try {
        await Locator.progressRepository.saveProgress(Progress(
          studentId: sId,
          lessonId: lessonId,
          status: 'completed',
          score: _sessionState.accuracy,
          stars: 3,
          attempts: _sessionState.totalAnswered,
          lastPlayed: DateTime.now(),
          completedAt: DateTime.now(),
        ));

        final updated = student.copyWith(
          xp: student.xp + xp,
          gold: student.gold + gold,
          currentLessonId: '${_topic}_les4',
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
        title: 'GUIDED PRACTICE MASTERED! 🎯',
        message: 'You have achieved full conceptual mastery! The Challenge Arena is now UNLOCKED!',
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

  Widget _buildMasteryCheckItem(String label, bool isSatisfied, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isSatisfied ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, size: 16, color: isSatisfied ? ColorSystem.green : Colors.grey),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, color: ColorSystem.plum)),
            ],
          ),
          Text(detail, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: isSatisfied ? ColorSystem.green : ColorSystem.pink)),
        ],
      ),
    );
  }

  String _getQuestTitle() {
    switch (_topic) {
      case 'ratios':
        return 'RATIOS • QUEST 2';
      case 'proportions':
        return 'PROPORTIONS • QUEST 3';
      case 'percentages':
        return 'PERCENTAGES • QUEST 4';
      case 'applications':
        return 'APPLICATIONS • QUEST 5';
      case 'fractions':
      default:
        return 'FRACTIONS • QUEST 1';
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
                'LEVEL: ${_sessionState.currentDifficulty.name.toUpperCase()}',
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
                'MASTERY: ${(_sessionState.masteryScore * 100).toInt()}%',
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
    } else if (type == 'scale') {
      return ProportionScaleWidget(scaleFactor: problem.visualData['k'] ?? 2.0);
    } else if (type == 'balance') {
      return TwinBalanceWidget(
        leftNum: problem.visualData['lNum'] ?? 2,
        leftDen: problem.visualData['lDen'] ?? 5,
        rightNum: problem.visualData['rNum'] ?? 4,
        rightDen: problem.visualData['rDen'] ?? 10,
      );
    } else if (type == 'hundred_grid') {
      return HundredGridWidget(percentFilled: problem.visualData['percent'] ?? 50, size: 110);
    } else if (type == 'discount') {
      return DiscountTagWidget(
        originalPrice: (problem.visualData['price'] as num?)?.toDouble() ?? 100,
        discountPercent: problem.visualData['percent'] ?? 20,
      );
    } else if (type == 'blueprint') {
      return BlueprintMapWidget(mapCm: problem.visualData['cm'] ?? 5);
    } else if (type == 'recipe') {
      return RecipeMixerWidget(servings: problem.visualData['servings'] ?? 6);
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
                  _getQuestTitle(),
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

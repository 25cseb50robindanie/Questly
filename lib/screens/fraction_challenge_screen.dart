import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/adaptive_learning_engine.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/flashcard_widget.dart';

class FractionChallengeScreen extends StatefulWidget {
  final Activity? activity;

  const FractionChallengeScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionChallengeScreen> createState() => _FractionChallengeScreenState();
}

enum _ChallengeMode {
  miniGame,
  flashcards,
  speedQuiz,
  memoryMatrix,
}

class _FractionChallengeScreenState extends State<FractionChallengeScreen> with TickerProviderStateMixin {
  Student? _student;
  Activity? _activeActivity;
  String _topic = 'fractions'; // 'fractions', 'ratios', 'proportions', 'percentages', 'applications'

  final AdaptiveLearningEngine _adaptiveEngine = AdaptiveLearningEngine();

  _ChallengeMode _activeMode = _ChallengeMode.miniGame;
  int _score = 0;
  int _earnedCoins = 0;
  int _earnedXp = 0;
  bool _isCompleted = false;

  // 1. Mini-Game State
  final int _bridgeTargetDenominator = 4;
  final int _bridgeTargetNumerator = 3;
  int? _selectedPlankIndex;
  bool _miniGameSolved = false;

  // 2. Flashcards State
  int _currentFlashcardIndex = 0;
  List<FlashcardData> _flashcards = [];

  // 3. Speed Quiz State
  int _comboCount = 0;

  // 4. Memory Matrix State
  List<String> _memoryCards = [];
  final List<int> _flippedCardIndices = [];
  final Set<int> _matchedCardIndices = {};

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _initChallengeData();
  }

  void _loadStudent() {
    try {
      _student = Locator.studentRepository.getCurrentStudent() ??
          Locator.authService.getCurrentStudent();
    } catch (_) {
      _student = null;
    }
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
    if (_flashcards.isEmpty || newTopic != _topic) {
      _topic = newTopic;
      _initChallengeData();
    }
  }

  void _initChallengeData() {
    switch (_topic) {
      case 'ratios':
        _flashcards = [
          const FlashcardData(
            id: 'rc1',
            category: 'Ratio Notation',
            question: 'Name three ways to write the ratio of 3 to 4:',
            answer: '3 : 4  •  3 to 4  •  3/4',
            rule: 'All three forms express the exact same relationship.',
          ),
          const FlashcardData(
            id: 'rc2',
            category: 'Simplification',
            question: 'What is the simplest form of 6 : 9?',
            answer: '2 : 3',
            rule: 'Divide both 6 and 9 by their GCD (3): 6÷3 = 2, 9÷3 = 3.',
          ),
          const FlashcardData(
            id: 'rc3',
            category: 'Proportions',
            question: 'If 1 cup syrup mixes with 4 cups soda, how much syrup for 8 cups soda?',
            answer: '2 CUPS SYRUP',
            rule: 'Soda doubled (4 × 2 = 8), so syrup doubles (1 × 2 = 2).',
          ),
        ];
        _memoryCards = ['2:3', '4:6', '1:2', '3:6', '3:4', '6:8'];
        break;

      case 'proportions':
        _flashcards = [
          const FlashcardData(
            id: 'pc1',
            category: 'Proportion Rule',
            question: 'What is the Cross-Product Property for a/b = c/d?',
            answer: 'a × d = b × c',
            rule: 'The cross-products of a true proportion are always equal.',
          ),
          const FlashcardData(
            id: 'pc2',
            category: 'Scaling',
            question: 'If a 2×3 rectangle is enlarged with scale factor k = 4, what is the new size?',
            answer: '8 × 12',
            rule: 'Multiply BOTH dimensions by 4 (2×4=8 and 3×4=12).',
          ),
          const FlashcardData(
            id: 'pc3',
            category: 'Unit Rate',
            question: 'If 3 shields cost 15 gold, what is the cost of 1 shield (Unit Rate)?',
            answer: '5 GOLD EACH',
            rule: 'Divide 15 by 3 = 5 gold per shield.',
          ),
        ];
        _memoryCards = ['2/5=4/10', '1/3=3/9', '3/4=6/8', '20=20', '9=9', '24=24'];
        break;

      case 'percentages':
        _flashcards = [
          const FlashcardData(
            id: 'pct1',
            category: 'Definitions',
            question: 'What does "percent" mean literally?',
            answer: 'PARTS PER HUNDRED (/100)',
            rule: '50% = 50/100 = 0.50.',
          ),
          const FlashcardData(
            id: 'pct2',
            category: 'Benchmark',
            question: 'What is 3/4 as a percentage?',
            answer: '75%',
            rule: '3/4 = (3×25)/(4×25) = 75/100 = 75%.',
          ),
          const FlashcardData(
            id: 'pct3',
            category: 'Discount',
            question: 'What is 10% off a \$50 item?',
            answer: '\$5 DISCOUNT (PAY \$45)',
            rule: '10% of 50 = 0.10 × 50 = \$5 discount.',
          ),
        ];
        _memoryCards = ['1/2', '50%', '1/4', '25%', '3/4', '75%'];
        break;

      case 'applications':
        _flashcards = [
          const FlashcardData(
            id: 'app1',
            category: 'Blueprint Scale',
            question: 'On a 1 cm = 5 km map, how far is 4 cm?',
            answer: '20 KILOMETERS',
            rule: 'Multiply map distance by scale factor (4 × 5 = 20 km).',
          ),
          const FlashcardData(
            id: 'app2',
            category: 'Multi-Batch',
            question: 'If 1 feast serving takes 2 eggs, how many for 25 knights?',
            answer: '50 EGGS',
            rule: 'Multiply 25 × 2 = 50 eggs.',
          ),
        ];
        _memoryCards = ['1cm=5km', '4cm=20km', '25% off 100', 'Pay 75', '2 cups flour', '4 knights'];
        break;

      case 'fractions':
      default:
        _flashcards = [
          const FlashcardData(
            id: 'fc1',
            category: 'Definitions',
            question: 'What is the top number of a fraction called?',
            answer: 'NUMERATOR',
            rule: 'The numerator shows how many equal parts you have.',
          ),
          const FlashcardData(
            id: 'fc2',
            category: 'Definitions',
            question: 'What is the bottom number of a fraction called?',
            answer: 'DENOMINATOR',
            rule: 'The denominator represents total parts that make the whole.',
          ),
          const FlashcardData(
            id: 'fc3',
            category: 'Equivalent',
            question: 'Is 2/4 equal to 1/2?',
            answer: 'YES! (2/4 = 1/2)',
            rule: 'Dividing top and bottom of 2/4 by 2 gives 1/2.',
          ),
          const FlashcardData(
            id: 'fc4',
            category: 'Comparison',
            question: 'Which is bigger: 1/3 or 1/6?',
            answer: '1/3 IS BIGGER',
            rule: 'Cutting into 3 pieces gives much larger slices than 6 pieces.',
          ),
        ];
        _memoryCards = ['1/2', '2/4', '3/4', '6/8', '1/3', '2/6'];
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

  void _handleChallengeFailure() {
    SoundService.playSwitch();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.replay_rounded, color: ColorSystem.pink, size: 24),
            SizedBox(width: 8),
            Text('CHALLENGE FAILED', style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.pink)),
          ],
        ),
        content: const Text(
          'You need more preparation to defeat this arena! Returning to Guided Practice to reinforce your skills before retrying.',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, color: ColorSystem.plum),
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
              Navigator.pushReplacementNamed(
                context,
                '/fraction_practice',
                arguments: _activeActivity,
              );
            },
            child: const Text('BACK TO GUIDED PRACTICE →', style: TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _completeChallengeLesson() async {
    // If student didn't solve the mini-game, trigger failure flow
    if (!_miniGameSolved && _score < 50) {
      _handleChallengeFailure();
      return;
    }

    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = '${_topic}_les4';
      final xp = _activeActivity?.xpReward ?? 80;
      final gold = _activeActivity?.goldReward ?? 15;

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
          xp: student.xp + xp + _earnedXp,
          gold: student.gold + gold + _earnedCoins,
          currentLessonId: '${_topic}_les5',
        );
        await Locator.studentRepository.updateStudentProfile(updated);
      } catch (_) {}
    }

    SoundService.playLevelComplete();
    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: (_activeActivity?.xpReward ?? 80) + _earnedXp,
        goldReward: (_activeActivity?.goldReward ?? 15) + _earnedCoins,
        earnedStars: 3,
        title: 'CHALLENGE CONQUERED!',
        message: 'Magnificent performance! Final stage unlocked: Teach Dendy!',
        onContinue: () {
          Navigator.pushReplacementNamed(
            context,
            '/fraction_teach_dendy',
            arguments: _activeActivity,
          );
        },
      );
    }
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
                    _buildModeTabs(),
                    SizedBox(height: isShort ? 6 : 8),

                    // Main Challenge Arena
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
                        child: _buildActiveChallengeMode(isShort, isLandscape),
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

  Widget _buildModeTabs() {
    final modes = [
      {'mode': _ChallengeMode.miniGame, 'label': '🎮 Quest Arena', 'icon': Icons.sports_esports_rounded},
      {'mode': _ChallengeMode.flashcards, 'label': '🗂️ Flashcards', 'icon': Icons.flip_rounded},
      {'mode': _ChallengeMode.speedQuiz, 'label': '⚡ Speed Quiz', 'icon': Icons.timer_rounded},
      {'mode': _ChallengeMode.memoryMatrix, 'label': '🧠 Memory Match', 'icon': Icons.grid_view_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: modes.map((m) {
          final isSelected = _activeMode == m['mode'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                m['label'] as String,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                  color: isSelected ? Colors.white : ColorSystem.plum,
                ),
              ),
              selected: isSelected,
              selectedColor: ColorSystem.purple,
              backgroundColor: ColorSystem.cream,
              side: BorderSide(color: isSelected ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.2)),
              onSelected: (val) {
                SoundService.playClick();
                setState(() {
                  _activeMode = m['mode'] as _ChallengeMode;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveChallengeMode(bool isShort, bool isLandscape) {
    switch (_activeMode) {
      case _ChallengeMode.miniGame:
        return _buildMiniGameMode(isShort, isLandscape);
      case _ChallengeMode.flashcards:
        return _buildFlashcardsMode(isShort);
      case _ChallengeMode.speedQuiz:
        return _buildSpeedQuizMode(isShort);
      case _ChallengeMode.memoryMatrix:
      default:
        return _buildMemoryMatrixMode(isShort);
    }
  }

  // 1. Topic Specific Mini-Game Mode
  Widget _buildMiniGameMode(bool isShort, bool isLandscape) {
    final plankOptions = _topic == 'ratios'
        ? ['2 : 3', '3 : 5', '4 : 7', '1 : 2']
        : (_topic == 'proportions'
            ? ['x = 6', 'x = 8', 'x = 4', 'x = 10']
            : (_topic == 'percentages'
                ? ['\$75', '\$80', '\$60', '\$85']
                : ['6/8', '2/4', '4/8', '3/6']));

    if (!isLandscape) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'CONQUER THE QUEST ARENA',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.purple),
            ),
            const SizedBox(height: 10),
            _buildVisualArena(),
            const SizedBox(height: 12),
            const Text('CHOOSE MATCHING PIECE', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
            const SizedBox(height: 6),
            ...List.generate(plankOptions.length, (i) {
              return _buildPlankOptionTile(plankOptions[i], i);
            }),
            const SizedBox(height: 12),
            CustomButton(
              text: 'COMPLETE CHALLENGE ✓',
              backgroundColor: ColorSystem.green,
              textColor: Colors.white,
              height: 40,
              onPressed: _completeChallengeLesson,
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // Left: Arena Visualization
        Expanded(
          flex: 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUEST ARENA: SPAN THE SPAN',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: isShort ? 12 : 14, fontWeight: FontWeight.w900, color: ColorSystem.purple),
              ),
              Expanded(
                child: Center(
                  child: _buildVisualArena(),
                ),
              ),
              Text(
                _miniGameSolved
                    ? '🎉 Target Achieved Successfully! (+25 XP)'
                    : 'Select the matching equivalent solution to conquer the arena!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _miniGameSolved ? ColorSystem.green : ColorSystem.plum,
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right: Available Options
        Expanded(
          flex: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('CHOOSE MATCHING PIECE', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                      const SizedBox(height: 8),
                      ...List.generate(plankOptions.length, (i) {
                        return _buildPlankOptionTile(plankOptions[i], i);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              CustomButton(
                text: 'COMPLETE CHALLENGE ✓',
                backgroundColor: ColorSystem.green,
                textColor: Colors.white,
                height: 40,
                onPressed: _completeChallengeLesson,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVisualArena() {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.3), width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 45,
            child: Container(color: const Color(0xFF795548)),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 45,
            child: Container(color: const Color(0xFF795548)),
          ),
          if (_miniGameSolved)
            Container(
              height: 22,
              width: 170,
              decoration: BoxDecoration(
                color: ColorSystem.green,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ColorSystem.plum, width: 2),
              ),
              child: const Center(
                child: Text('TARGET MATCH ✓', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          else
            const Text(
              'TARGET SPAN: SELECT CORRECT EQUIVALENT',
              style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          Positioned(
            left: _miniGameSolved ? 180 : 10,
            bottom: 35,
            child: const DendyMascot(size: 32, mood: DendyMood.happy),
          ),
        ],
      ),
    );
  }

  Widget _buildPlankOptionTile(String plank, int i) {
    final isSelected = _selectedPlankIndex == i;
    final isWinningOption = i == 0; // First option configured as match

    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() {
          _selectedPlankIndex = i;
          if (isWinningOption) {
            _miniGameSolved = true;
            _earnedXp += 25;
            _earnedCoins += 5;
            SoundService.playSuccess();
          } else {
            _miniGameSolved = false;
            SoundService.playSwitch();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? (_miniGameSolved ? ColorSystem.green.withOpacity(0.15) : ColorSystem.pink.withOpacity(0.15)) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (_miniGameSolved ? ColorSystem.green : ColorSystem.pink) : ColorSystem.plum.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          plank,
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12.5, fontWeight: FontWeight.w900, color: ColorSystem.plum),
        ),
      ),
    );
  }

  // 2. Flashcards Deck
  Widget _buildFlashcardsMode(bool isShort) {
    if (_flashcards.isEmpty) return const SizedBox();
    final safeIndex = _currentFlashcardIndex.clamp(0, _flashcards.length - 1);
    final card = _flashcards[safeIndex];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CARD ${safeIndex + 1} OF ${_flashcards.length}',
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple),
            ),
            const SizedBox(height: 8),
            FlashcardWidget(
              card: card,
              onMastered: () {
                setState(() {
                  _earnedXp += 10;
                  _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _flashcards.length;
                });
              },
              onReviewAgain: () {
                setState(() {
                  _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _flashcards.length;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // 3. Speed Quiz Mode
  Widget _buildSpeedQuizMode(bool isShort) {
    final qText = _topic == 'ratios'
        ? 'What is 3 : 5 in simplest terms?'
        : (_topic == 'proportions'
            ? 'If 2/3 = x/6, what is x?'
            : (_topic == 'percentages'
                ? 'What is 50% of 60?'
                : 'What is 2/3 of 12?'));

    final opt1 = _topic == 'percentages' ? '30' : (_topic == 'proportions' ? '4' : (_topic == 'ratios' ? '3 : 5' : '8'));
    final opt2 = _topic == 'percentages' ? '25' : '6';
    final opt3 = _topic == 'percentages' ? '15' : '10';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('SCORE: $_score', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              Text('COMBO: $_comboCount🔥', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.pink)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColorSystem.lavender.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'Speed Blitz: $qText',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSpeedQuizOption(opt1, true),
                    _buildSpeedQuizOption(opt2, false),
                    _buildSpeedQuizOption(opt3, false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedQuizOption(String text, bool isCorrect) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: ColorSystem.plum,
        side: const BorderSide(color: ColorSystem.purple, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900)),
      onPressed: () {
        if (isCorrect) {
          SoundService.playSuccess();
          setState(() {
            _score += 50;
            _comboCount++;
            _earnedXp += 20;
          });
        } else {
          SoundService.playSwitch();
          setState(() {
            _comboCount = 0;
          });
        }
      },
    );
  }

  // 4. Memory Matrix Mode
  Widget _buildMemoryMatrixMode(bool isShort) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MATCH EQUIVALENT PAIRS',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.purple),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_memoryCards.length, (i) {
              final isMatched = _matchedCardIndices.contains(i);
              final isFlipped = _flippedCardIndices.contains(i) || isMatched;

              return GestureDetector(
                onTap: isMatched
                    ? null
                    : () {
                        SoundService.playClick();
                        if (_flippedCardIndices.length < 2 && !_flippedCardIndices.contains(i)) {
                          setState(() {
                            _flippedCardIndices.add(i);
                          });

                          if (_flippedCardIndices.length == 2) {
                            final idx1 = _flippedCardIndices[0];
                            final idx2 = _flippedCardIndices[1];
                            final card1 = _memoryCards[idx1];
                            final card2 = _memoryCards[idx2];
                            bool matched = (idx1 % 2 == 0 && idx2 == idx1 + 1) ||
                                (idx2 % 2 == 0 && idx1 == idx2 + 1) ||
                                (card1 == '1/2' && card2 == '2/4') ||
                                (card1 == '2/4' && card2 == '1/2') ||
                                (card1 == '3/4' && card2 == '6/8') ||
                                (card1 == '6/8' && card2 == '3/4');

                            if (matched) {
                              SoundService.playSuccess();
                              setState(() {
                                _matchedCardIndices.addAll([idx1, idx2]);
                                _flippedCardIndices.clear();
                                _earnedXp += 20;
                              });
                            } else {
                              Future.delayed(const Duration(milliseconds: 600), () {
                                if (mounted) {
                                  setState(() {
                                    _flippedCardIndices.clear();
                                  });
                                }
                              });
                            }
                          }
                        }
                      },
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isMatched
                        ? ColorSystem.green.withOpacity(0.2)
                        : (isFlipped ? ColorSystem.purple.withOpacity(0.15) : ColorSystem.plum),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isMatched ? ColorSystem.green : ColorSystem.purple,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isFlipped
                        ? FittedBox(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                _memoryCards[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isMatched ? ColorSystem.green : ColorSystem.purple,
                                ),
                              ),
                            ),
                          )
                        : const Icon(Icons.help_outline_rounded, color: Colors.white, size: 24),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
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
                  'LESSON 4: CHALLENGE ARENA',
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
                Text('${_student!.xp + _earnedXp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              ],
            ),
          ),
      ],
    );
  }
}

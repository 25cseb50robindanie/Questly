import 'dart:async';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
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
  bridgeBuilder,
  flashcards,
  speedQuiz,
  memoryMatrix,
}

class _FractionChallengeScreenState extends State<FractionChallengeScreen> with TickerProviderStateMixin {
  Student? _student;
  Activity? _activeActivity;
  bool _isRatios = false;

  _ChallengeMode _activeMode = _ChallengeMode.bridgeBuilder;
  int _score = 0;
  int _earnedCoins = 0;
  int _earnedXp = 0;
  bool _isCompleted = false;

  // 1. Bridge Builder Mini-Game State
  final int _bridgeTargetDenominator = 4;
  final int _bridgeTargetNumerator = 3;
  int? _selectedPlankIndex;
  bool _bridgeConstructed = false;

  // 2. Flashcards State
  int _currentFlashcardIndex = 0;
  List<FlashcardData> _flashcards = [];

  // 3. Speed Quiz State
  int _comboCount = 0;

  // 4. Memory Matrix State
  final List<String> _memoryCards = ['1/2', '2/4', '3/4', '6/8', '1/3', '2/6'];
  final List<int> _flippedCardIndices = [];
  final Set<int> _matchedCardIndices = {};

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _initFlashcards();
  }

  void _loadStudent() {
    try {
      _student = Locator.studentRepository.getCurrentStudent() ??
          Locator.authService.getCurrentStudent();
    } catch (_) {
      _student = null;
    }
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
    _isRatios = _activeActivity?.type == 'ratio_challenge' ||
        _activeActivity?.id.contains('ratio') == true;
        
    if (_flashcards.isEmpty || wasRatios != _isRatios) {
      _initFlashcards();
    }
  }

  void _initFlashcards() {
    if (!_isRatios) {
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
    } else {
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

  Future<void> _completeChallengeLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = _isRatios ? 'ratios_les4' : 'fractions_les4';
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
          currentLessonId: _isRatios ? 'ratios_les5' : 'fractions_les5',
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
      {'mode': _ChallengeMode.bridgeBuilder, 'label': '🌉 Bridge Builder', 'icon': Icons.construction_rounded},
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
      case _ChallengeMode.bridgeBuilder:
        return _buildBridgeBuilderMode(isShort, isLandscape);
      case _ChallengeMode.flashcards:
        return _buildFlashcardsMode(isShort);
      case _ChallengeMode.speedQuiz:
        return _buildSpeedQuizMode(isShort);
      case _ChallengeMode.memoryMatrix:
      default:
        return _buildMemoryMatrixMode(isShort);
    }
  }

  // 1. Canyon Bridge Builder Mini-Game
  Widget _buildBridgeBuilderMode(bool isShort, bool isLandscape) {
    final plankOptions = ['6/8', '2/4', '4/8', '3/6']; // 6/8 is equivalent to 3/4!

    if (!isLandscape) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BUILD THE BRIDGE SPAN: $_bridgeTargetNumerator/$_bridgeTargetDenominator',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.purple),
            ),
            const SizedBox(height: 10),
            _buildCanyonVisual(),
            const SizedBox(height: 12),
            const Text('AVAILABLE PLANKS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
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
        // Left: Canyon Visualization
        Expanded(
          flex: 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BUILD THE BRIDGE SPAN: $_bridgeTargetNumerator/$_bridgeTargetDenominator',
                style: TextStyle(fontFamily: 'Fredoka', fontSize: isShort ? 12 : 14, fontWeight: FontWeight.w900, color: ColorSystem.purple),
              ),
              Expanded(
                child: Center(
                  child: _buildCanyonVisual(),
                ),
              ),
              Text(
                _bridgeConstructed
                    ? '🎉 Bridge Crossed Successfully! (+25 XP)'
                    : 'Select an equivalent plank to span the canyon safely!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _bridgeConstructed ? ColorSystem.green : ColorSystem.plum,
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right: Available Planks Selection & Finish
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
                      const Text('AVAILABLE PLANKS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
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

  Widget _buildCanyonVisual() {
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
          if (_bridgeConstructed)
            Container(
              height: 20,
              width: 170,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB300),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ColorSystem.plum, width: 2),
              ),
              child: const Center(
                child: Text('6/8 PLANK MATCH ✓', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            )
          else
            Text(
              'GAP REQUIRES EQUIVALENT PLANK: $_bridgeTargetNumerator/$_bridgeTargetDenominator',
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          Positioned(
            left: _bridgeConstructed ? 180 : 10,
            bottom: 35,
            child: const DendyMascot(size: 32, mood: DendyMood.happy),
          ),
        ],
      ),
    );
  }

  Widget _buildPlankOptionTile(String plank, int i) {
    final isSelected = _selectedPlankIndex == i;
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() {
          _selectedPlankIndex = i;
          if (plank == '6/8') {
            _bridgeConstructed = true;
            _earnedXp += 25;
            _earnedCoins += 5;
            SoundService.playSuccess();
          } else {
            _bridgeConstructed = false;
            SoundService.playSwitch();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? (_bridgeConstructed ? ColorSystem.green.withOpacity(0.15) : ColorSystem.pink.withOpacity(0.15)) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (_bridgeConstructed ? ColorSystem.green : ColorSystem.pink) : ColorSystem.plum.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          'Plank $plank',
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
                const Text(
                  'Speed Question: What is 2/3 of 12?',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSpeedQuizOption('8', true),
                    _buildSpeedQuizOption('6', false),
                    _buildSpeedQuizOption('4', false),
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

  // 4. Memory Matrix Card Matching Mode
  Widget _buildMemoryMatrixMode(bool isShort) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'MATCH EQUIVALENT PAIRS (e.g. 1/2 == 2/4)',
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
                            bool matched = (card1 == '1/2' && card2 == '2/4') ||
                                (card1 == '2/4' && card2 == '1/2') ||
                                (card1 == '3/4' && card2 == '6/8') ||
                                (card1 == '6/8' && card2 == '3/4') ||
                                (card1 == '1/3' && card2 == '2/6') ||
                                (card1 == '2/6' && card2 == '1/3');

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
                        ? Text(
                            _memoryCards[i],
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isMatched ? ColorSystem.green : ColorSystem.purple,
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
                  _isRatios ? 'RATIOS • LEVEL 2' : 'FRACTIONS • LEVEL 1',
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

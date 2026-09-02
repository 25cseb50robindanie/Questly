import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../services/speech_recognition_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/fraction_visual_models.dart';

class FractionTeachDendyScreen extends StatefulWidget {
  final Activity? activity;

  const FractionTeachDendyScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionTeachDendyScreen> createState() => _FractionTeachDendyScreenState();
}

enum _TeachStage {
  dendyDoubt,
  studentExplaining,
  dendyAha,
  coSolvingProblem,
  masteryAchieved,
}

class _FractionTeachDendyScreenState extends State<FractionTeachDendyScreen> {
  Student? _student;
  Activity? _activeActivity;
  bool _isRatios = false;

  _TeachStage _stage = _TeachStage.dendyDoubt;
  int? _selectedChipIndex;
  final TextEditingController _customExplanationController = TextEditingController();
  bool _isListening = false;
  bool _isCompleted = false;

  int? _selectedCoSolveIndex;

  @override
  void initState() {
    super.initState();
    _loadStudent();
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
    _isRatios = _activeActivity?.type == 'ratio_teach_dendy' ||
        _activeActivity?.id.contains('ratio') == true;
  }

  @override
  void dispose() {
    _customExplanationController.dispose();
    super.dispose();
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap', arguments: 'mod_fractions');
    }
  }

  void _toggleListening() {
    SoundService.playClick();
    if (!SpeechRecognitionHelper.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice input is not supported in this browser. Please use the quick chips or type!')),
      );
      return;
    }

    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _customExplanationController.text = _isRatios
            ? 'Order matters in ratios because the first item corresponds to the first number!'
            : 'More slices means each slice is smaller, so 1/4 is bigger than 1/8!';
      }
    });
  }

  Future<void> _completeTeachDendyLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = _isRatios ? 'ratios_les5' : 'fractions_les5';
      final xp = _activeActivity?.xpReward ?? 100;
      final gold = _activeActivity?.goldReward ?? 20;

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

        final nodeId = _isRatios ? 'fractions_node3' : 'fractions_node1';
        await Locator.progressionService.markNodeCompleted(sId, nodeId, stars: 3);

        final badgeName = _isRatios ? 'Ratio Alchemist' : 'Fractions Explorer';
        await Locator.collectionRepository.unlockBadge(sId, badgeName);

        final updated = student.copyWith(
          xp: student.xp + xp,
          gold: student.gold + gold,
        );
        await Locator.studentRepository.updateStudentProfile(updated);
      } catch (_) {}
    }

    SoundService.playLevelComplete();
    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: _activeActivity?.xpReward ?? 100,
        goldReward: _activeActivity?.goldReward ?? 20,
        earnedStars: 3,
        title: _isRatios ? 'RATIOS QUEST MASTERED! 🏆' : 'FRACTIONS QUEST MASTERED! 🏆',
        message: 'You successfully taught Dendy and conquered this entire Quest! You earned the Mastery Badge!',
        onContinue: () {
          Navigator.pushReplacementNamed(
            context,
            '/roadmap',
            arguments: 'mod_fractions',
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
                    SizedBox(height: isShort ? 6 : 10),

                    // Main Stage Content
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
                        child: _buildStageBody(isShort, isLandscape),
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

  Widget _buildStageBody(bool isShort, bool isLandscape) {
    switch (_stage) {
      case _TeachStage.dendyDoubt:
      case _TeachStage.studentExplaining:
        return _buildDoubtAndExplanationStage(isShort, isLandscape);
      case _TeachStage.dendyAha:
        return _buildDendyAhaStage(isShort);
      case _TeachStage.coSolvingProblem:
      case _TeachStage.masteryAchieved:
      default:
        return _buildCoSolveStage(isShort);
    }
  }

  Widget _buildDoubtAndExplanationStage(bool isShort, bool isLandscape) {
    final chips = !_isRatios
        ? [
            'Because cutting into 8 slices makes each slice smaller than cutting into 4 slices!',
            'Denominator is the number of pieces. More pieces = Smaller slice!',
            '1/4 is two 1/8 slices combined (2/8), so 1/4 is bigger!',
          ]
        : [
            'Order matters! The first word (Apples) must match the first number!',
            '3:5 means 3 apples for every 5 bananas. 5:3 would mean 5 apples!',
            'In ratios, reversing the numbers changes who has more!',
          ];

    if (!isLandscape) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ColorSystem.pink.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('DENDY\'S CONFUSION 🦊', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.pink)),
            ),
            const SizedBox(height: 6),
            Text(
              !_isRatios
                  ? '"Teacher! I thought 1/8 is bigger than 1/4 because 8 is bigger than 4! Why is that wrong?"'
                  : '"Teacher! If there are 3 apples and 5 bananas, why can\'t I just write the ratio as 5 : 3?"',
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.plum, height: 1.3),
            ),
            const SizedBox(height: 10),
            Center(
              child: !_isRatios
                  ? const PizzaVisualWidget(totalSlices: 8, selectedSlices: 1, size: 90, label: '1/8 Slice')
                  : const FruitRatioVisualWidget(countA: 3, countB: 5, labelA: 'Apples', labelB: 'Bananas'),
            ),
            const SizedBox(height: 12),
            const Text('HOW WILL YOU TEACH DENDY?', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
            const SizedBox(height: 6),
            ...List.generate(chips.length, (i) {
              return _buildChipOptionTile(chips[i], i);
            }),
            const SizedBox(height: 12),
            CustomButton(
              text: 'EXPLAIN TO DENDY →',
              backgroundColor: _selectedChipIndex != null ? ColorSystem.purple : Colors.grey.shade400,
              textColor: Colors.white,
              height: 40,
              onPressed: _selectedChipIndex == null
                  ? () {}
                  : () {
                      SoundService.playSuccess();
                      setState(() {
                        _stage = _TeachStage.dendyAha;
                      });
                    },
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Dendy's Confusion Card
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorSystem.pink.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('DENDY\'S CONFUSION 🦊', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.pink)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    !_isRatios
                        ? '"Teacher! I thought 1/8 is bigger than 1/4 because 8 is bigger than 4! Why is that wrong?"'
                        : '"Teacher! If there are 3 apples and 5 bananas, why can\'t I just write the ratio as 5 : 3?"',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 13 : 15,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
              Center(
                child: !_isRatios
                    ? const PizzaVisualWidget(totalSlices: 8, selectedSlices: 1, size: 95, label: '1/8 Slice')
                    : const FruitRatioVisualWidget(countA: 3, countB: 5, labelA: 'Apples', labelB: 'Bananas'),
              ),
              const Center(child: DendyMascot(size: 50, mood: DendyMood.confused)),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right Column: Student Teacher's Response
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'HOW WILL YOU TEACH DENDY?',
                            style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                          ),
                          IconButton(
                            icon: Icon(_isListening ? Icons.mic_rounded : Icons.mic_none_rounded, color: _isListening ? ColorSystem.pink : ColorSystem.purple, size: 20),
                            onPressed: _toggleListening,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...List.generate(chips.length, (i) {
                        return _buildChipOptionTile(chips[i], i);
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              CustomButton(
                text: 'EXPLAIN TO DENDY →',
                backgroundColor: _selectedChipIndex != null ? ColorSystem.purple : Colors.grey.shade400,
                textColor: Colors.white,
                height: 40,
                onPressed: _selectedChipIndex == null
                    ? () {}
                    : () {
                        SoundService.playSuccess();
                        setState(() {
                          _stage = _TeachStage.dendyAha;
                        });
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChipOptionTile(String chip, int i) {
    final isSelected = _selectedChipIndex == i;
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() {
          _selectedChipIndex = i;
          _customExplanationController.text = chip;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ColorSystem.purple.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Text(
          chip,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ),
    );
  }

  // Stage 3: Dendy's Aha Moment
  Widget _buildDendyAhaStage(bool isShort) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DendyMascot(size: 70, mood: DendyMood.happy),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: ColorSystem.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorSystem.gold, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '💡 DENDY UNDERSTANDS!',
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    !_isRatios
                        ? '"Aha! Now I get it! The denominator is how many cuts we made. More cuts means smaller slices, so 1/4 is bigger than 1/8! Thank you teacher!"'
                        : '"Aha! Now I get it! Order matters in ratios because Apples came first (3) and Bananas second (5), so it must be 3 : 5! Thank you teacher!"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12.5, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'SOLVE THE FINAL PUZZLE TOGETHER →',
              backgroundColor: ColorSystem.green,
              textColor: Colors.white,
              height: 40,
              onPressed: () {
                SoundService.playClick();
                setState(() {
                  _stage = _TeachStage.coSolvingProblem;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Stage 4: Co-solving Final Graduation Puzzle
  Widget _buildCoSolveStage(bool isShort) {
    final options = !_isRatios
        ? ['3/4 is bigger than 3/8', '3/8 is bigger than 3/4', 'Both are equal']
        : ['2 : 4 simplifies to 1 : 2', '2 : 4 simplifies to 2 : 2', '2 : 4 cannot be simplified'];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              !_isRatios
                  ? 'FINAL TEAM CHALLENGE: Compare 3/4 and 3/8 with Dendy!'
                  : 'FINAL TEAM CHALLENGE: Simplify 2 : 4 with Dendy!',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Fredoka', fontSize: isShort ? 13 : 15, fontWeight: FontWeight.w900, color: ColorSystem.purple),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: List.generate(options.length, (i) {
                final isSelected = _selectedCoSolveIndex == i;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? ColorSystem.green : Colors.white,
                    foregroundColor: isSelected ? Colors.white : ColorSystem.plum,
                    side: const BorderSide(color: ColorSystem.purple, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  child: Text(options[i], style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900)),
                  onPressed: () {
                    SoundService.playClick();
                    setState(() {
                      _selectedCoSolveIndex = i;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: 'CLAIM QUEST MASTERY 🏆',
              backgroundColor: _selectedCoSolveIndex == 0 ? ColorSystem.green : Colors.grey.shade400,
              textColor: Colors.white,
              height: 42,
              onPressed: _selectedCoSolveIndex == 0 ? _completeTeachDendyLesson : () {},
            ),
          ],
        ),
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
                  'LESSON 5: TEACH DENDY',
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

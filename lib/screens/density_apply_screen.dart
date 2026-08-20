import 'dart:math' as math;
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

class DensityApplyScreen extends StatefulWidget {
  final Activity? activity;

  const DensityApplyScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityApplyScreen> createState() => _DensityApplyScreenState();
}

class _DensityApplyScreenState extends State<DensityApplyScreen> {
  Student? _student;
  int _currentScenarioIndex = 0; // 0 = Ships, 1 = Ice, 2 = Oil & Water, 3 = Summary
  int? _selectedOptionIndex;
  bool _hasSubmittedAnswer = false;
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _scenarios = [
    {
      'title': 'The Floating Steel Ship',
      'subtitle': 'Hollow Volume & Average Density',
      'question': 'Steel is much denser than water (7.8 kg/L vs 1.0 kg/L). So how can a massive steel cargo ship float?',
      'dendyIntro': 'Look at this huge cargo ship! Solid steel sinks like a rock, so why does this gigantic ship stay afloat?',
      'dendyExplained': 'The hollow hull is filled with air! The giant volume drops the average density below water.',
      'options': [
        {
          'text': 'Steel magically becomes lighter when touching saltwater.',
          'isCorrect': false,
          'feedback': 'Steel never changes its own material density, regardless of the water it touches.',
        },
        {
          'text': "The ship's hollow hull encloses a giant volume of air, making its average density lower than water.",
          'isCorrect': true,
          'feedback': 'Correct! The steel and massive air pockets together create an average density of only ~0.85 kg/L, so it floats!',
        },
        {
          'text': 'Heavy objects always float if they travel fast enough.',
          'isCorrect': false,
          'feedback': 'A solid block of steel sinks whether it is stationary or moving.',
        },
      ],
      'visualType': 'ship',
      'keyInsight': 'Average Density = Total Mass (Steel + Cargo + Air) ÷ Giant Total Volume.',
    },
    {
      'title': 'The Floating Iceberg',
      'subtitle': 'Water vs. Solid Ice',
      'question': 'Most solids sink in their own liquid. Why does solid ice float on liquid water?',
      'dendyIntro': 'Watch the ice cube in the glass. Why is solid ice floating on top of liquid water?',
      'dendyExplained': 'Water expands as it freezes! The molecules spread apart, so ice has a lower density than liquid water.',
      'options': [
        {
          'text': 'Ice contains tiny invisible helium bubbles created by cold temperatures.',
          'isCorrect': false,
          'feedback': 'Ice is made entirely of pure water molecules (H2O), with no extra gases.',
        },
        {
          'text': 'When water freezes into ice, molecules expand into an open lattice (0.92 kg/L), making it less dense than liquid water (1.00 kg/L).',
          'isCorrect': true,
          'feedback': 'Spot on! Ice expands by ~9% when freezing. Because 0.92 kg/L < 1.00 kg/L, about 90% stays submerged and 10% floats above!',
        },
        {
          'text': 'Cold temperatures remove all gravitational force from frozen matter.',
          'isCorrect': false,
          'feedback': 'Gravity acts equally on cold and warm matter. Density alone governs buoyancy.',
        },
      ],
      'visualType': 'ice',
      'keyInsight': 'Ice Density (0.92 kg/L) < Liquid Water Density (1.00 kg/L).',
    },
    {
      'title': 'Oil & Water Separation',
      'subtitle': 'Layering of Different Liquids',
      'question': 'When vegetable oil and water are mixed together in a beaker, why does the oil always rise to the top layer?',
      'dendyIntro': 'Pour oil into water and watch them separate. Why does oil refuse to sink to the bottom?',
      'dendyExplained': 'Oil has a density of ~0.92 kg/L, while water is 1.00 kg/L. The denser liquid sinks, pushing the lighter oil to the top!',
      'options': [
        {
          'text': 'Vegetable oil has a lower density (~0.92 kg/L) than water (1.00 kg/L), so water sinks below it.',
          'isCorrect': true,
          'feedback': 'Excellent deduction! Liquids with different densities layer themselves naturally: denser on bottom, less dense on top.',
        },
        {
          'text': 'Oil has zero mass, so gravity cannot pull it downward.',
          'isCorrect': false,
          'feedback': 'Oil has real mass and weight, but its mass per unit of volume is lower than water.',
        },
        {
          'text': 'Water molecules are slippery and repel any liquid with a yellow color.',
          'isCorrect': false,
          'feedback': 'Color has no effect on buoyancy. Only density and molecular solubility matter.',
        },
      ],
      'visualType': 'oil',
      'keyInsight': 'Lighter Liquid (~0.92 kg/L) floats above Denser Liquid (1.00 kg/L).',
    },
  ];

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

  void _selectOption(int index) {
    if (_hasSubmittedAnswer) return;
    SoundService.playClick();
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _submitAnswer() {
    if (_selectedOptionIndex == null || _hasSubmittedAnswer) return;
    final currentScenario = _scenarios[_currentScenarioIndex];
    final isCorrect = currentScenario['options'][_selectedOptionIndex!]['isCorrect'] as bool;

    if (isCorrect) {
      SoundService.playSuccess();
    } else {
      SoundService.playDrop();
    }

    setState(() {
      _hasSubmittedAnswer = true;
    });
  }

  void _nextStep() {
    SoundService.playClick();
    if (_currentScenarioIndex < _scenarios.length) {
      setState(() {
        _currentScenarioIndex++;
        _selectedOptionIndex = null;
        _hasSubmittedAnswer = false;
      });
    }
  }

  Future<void> _completeLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Lesson 3 Progress
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les3',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Mark explicit direct storage key
      await Locator.storageService.setBool('lesson_comp_${sId}_density_les3', true);
      await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les4', true);

      // 3. Award XP (+60) and Coins (+10)
      final updated = _student!.copyWith(
        xp: _student!.xp + 60,
        gold: _student!.gold + 10,
        currentLessonId: 'density_les4',
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
        xpReward: 60,
        goldReward: 10,
        earnedStars: 3,
        title: 'APPLY LESSON COMPLETE!',
        message: 'You discovered how density explains giant floating ships, icebergs, and liquid layers in the real world!',
        onContinue: () {
          _handleReturn();
        },
      );
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

                // Main Content View (Scenario OR Summary)
                Expanded(
                  child: _currentScenarioIndex < _scenarios.length
                      ? _buildScenarioView(isShort)
                      : _buildSummaryView(isShort),
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
        // Back Button & Lesson Badge
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
                'LESSON 3: APPLY',
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
              'Density in the Real World',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isShort ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: ColorSystem.plum,
              ),
            ),
          ],
        ),

        // 4-Step Progress Indicators
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i <= 3; i++) ...[
              Container(
                width: i == _currentScenarioIndex ? 22 : 10,
                height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: i < _currentScenarioIndex
                      ? ColorSystem.green
                      : (i == _currentScenarioIndex ? ColorSystem.purple : Colors.white),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: i <= _currentScenarioIndex ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
              ),
            ],
          ],
        ),

        // XP and Coins Badges
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
  // SCENARIO VIEW (Observe -> Predict -> Explain)
  // ==========================================
  Widget _buildScenarioView(bool isShort) {
    final scenario = _scenarios[_currentScenarioIndex];
    final dendyMsg = _hasSubmittedAnswer
        ? scenario['dendyExplained'] as String
        : scenario['dendyIntro'] as String;
    final dendyState = _hasSubmittedAnswer
        ? (_selectedOptionIndex != null && scenario['options'][_selectedOptionIndex!]['isCorrect'] == true
            ? DendyState.success
            : DendyState.thinking)
        : DendyState.thinking;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Visual Illustration & Dendy Mascot
        Expanded(
          flex: 11,
          child: Column(
            children: [
              // Visual Illustration Canvas Card
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
                    children: [
                      // Scenario Header Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ColorSystem.lavender,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SCENARIO ${_currentScenarioIndex + 1} OF 3',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.purple,
                              ),
                            ),
                          ),
                          Text(
                            scenario['subtitle'] as String,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.plum.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Custom Responsive Diagram
                      Expanded(
                        child: _buildScenarioDiagram(scenario['visualType'] as String, isShort),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isShort ? 6 : 10),

              // Dendy Mascot Speech Dock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorSystem.plum, width: 1.5),
                ),
                child: DendyMascot(
                  size: isShort ? 44 : 52,
                  state: dendyState,
                  message: dendyMsg,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column: Investigation Question, Options & Confirmation
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
                  // Title & Question
                  Text(
                    scenario['title'] as String,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 14 : 17,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scenario['question'] as String,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 11 : 12.5,
                      fontWeight: FontWeight.w600,
                      color: ColorSystem.plum,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: isShort ? 8 : 12),

                  const Text(
                    'CHOOSE THE SCIENTIFIC EXPLANATION:',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Option Cards
                  for (int i = 0; i < (scenario['options'] as List).length; i++) ...[
                    _buildOptionCard(scenario['options'][i] as Map<String, dynamic>, i, isShort),
                    const SizedBox(height: 6),
                  ],

                  SizedBox(height: isShort ? 8 : 12),

                  // Bottom Action Button
                  if (!_hasSubmittedAnswer)
                    CustomButton(
                      text: 'CHECK MY PREDICTION',
                      backgroundColor: _selectedOptionIndex != null ? ColorSystem.purple : Colors.grey.shade400,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _selectedOptionIndex != null ? _submitAnswer : () {},
                    )
                  else ...[
                    // Key Insight Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: ColorSystem.cream,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.gold, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          VectorAssetHelper.xpStarIcon(size: 16, isFilled: true),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              scenario['keyInsight'] as String,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: _currentScenarioIndex < _scenarios.length - 1
                          ? 'CONTINUE TO NEXT SCENARIO'
                          : 'SEE LESSON SUMMARY',
                      backgroundColor: ColorSystem.green,
                      textColor: Colors.white,
                      height: isShort ? 36 : 42,
                      onPressed: _nextStep,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> opt, int index, bool isShort) {
    final isSelected = _selectedOptionIndex == index;
    final isCorrect = opt['isCorrect'] as bool;

    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.18);
    Color textColor = ColorSystem.plum;

    if (_hasSubmittedAnswer) {
      if (isCorrect) {
        bg = ColorSystem.green.withOpacity(0.12);
        border = ColorSystem.green;
        textColor = ColorSystem.green;
      } else if (isSelected) {
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
      onTap: () => _selectOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isShort ? 6 : 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: isSelected || (_hasSubmittedAnswer && isCorrect) ? 1.8 : 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? (_hasSubmittedAnswer ? (isCorrect ? ColorSystem.green : Colors.redAccent) : ColorSystem.purple) : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: border, width: 1.4),
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : ColorSystem.plum,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
            if (_hasSubmittedAnswer && (isSelected || isCorrect)) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  opt['feedback'] as String,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? ColorSystem.green : Colors.redAccent.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CUSTOM VECTOR DIAGRAMS (No Emojis)
  // ==========================================
  Widget _buildScenarioDiagram(String visualType, bool isShort) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScenarioDiagramPainter(
            visualType: visualType,
            hasRevealed: _hasSubmittedAnswer,
          ),
        );
      },
    );
  }

  // ==========================================
  // LESSON SUMMARY VIEW
  // ==========================================
  Widget _buildSummaryView(bool isShort) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: EdgeInsets.all(isShort ? 16 : 22),
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
              children: [
                // Top Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorSystem.lavender,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LESSON 3 SUMMARY',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'WHAT YOU DISCOVERED',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Density is the master key to how materials behave throughout nature and engineering.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11.5,
                    color: ColorSystem.plum.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 14),

                // 3 Key Discoveries Cards
                _buildSummaryBullet(
                  'Average Density Governs Giant Vessels',
                  'A hollow steel ship floats because the air trapped inside its massive hull lowers its total average density below 1.00 kg/L.',
                  ColorSystem.purple,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  'Ice Expands & Defies Normal Solids',
                  'Water expands when freezing, giving ice a density of 0.92 kg/L. That is why ice floats and supports Arctic life.',
                  ColorSystem.coral,
                ),
                const SizedBox(height: 8),
                _buildSummaryBullet(
                  'Liquids Naturally Layer by Density',
                  'When immiscible fluids meet, lighter fluids (like oil at ~0.92 kg/L) float on top of denser fluids (like water at 1.00 kg/L).',
                  ColorSystem.gold,
                ),
                const SizedBox(height: 18),

                // Claim Rewards & Continue CTA
                CustomButton(
                  text: 'COMPLETE & UNLOCK CHALLENGE',
                  backgroundColor: ColorSystem.green,
                  textColor: Colors.white,
                  height: 42,
                  onPressed: _completeLesson,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBullet(String title, String body, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4, right: 8),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    color: ColorSystem.plum.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCENARIO DIAGRAM PAINTER (Custom Canvas Graphics)
// ==========================================
class _ScenarioDiagramPainter extends CustomPainter {
  final String visualType;
  final bool hasRevealed;

  _ScenarioDiagramPainter({
    required this.visualType,
    required this.hasRevealed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (visualType) {
      case 'ship':
        _drawShipScenario(canvas, size);
        break;
      case 'ice':
        _drawIceScenario(canvas, size);
        break;
      case 'oil':
        _drawOilScenario(canvas, size);
        break;
    }
  }

  void _drawShipScenario(Canvas canvas, Size size) {
    final waterY = size.height * 0.58;
    final waterPaint = Paint()..color = const Color(0xFF4A90E2).withOpacity(0.35);
    final deepWaterPaint = Paint()..color = const Color(0xFF2C5E9E).withOpacity(0.65);
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw Water Background
    final waterRect = Rect.fromLTRB(0, waterY, size.width, size.height);
    canvas.drawRect(waterRect, waterPaint);

    // Deep water waves
    final wavePath = Path()
      ..moveTo(0, waterY)
      ..quadraticBezierTo(size.width * 0.25, waterY - 4, size.width * 0.5, waterY)
      ..quadraticBezierTo(size.width * 0.75, waterY + 4, size.width, waterY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wavePath, deepWaterPaint);
    canvas.drawLine(Offset(0, waterY), Offset(size.width, waterY), borderPaint);

    // Draw Cargo Ship Hull
    final shipCenter = size.width * 0.5;
    final shipW = size.width * 0.68;
    final shipH = size.height * 0.38;
    final shipTop = waterY - shipH * 0.55;

    final hullPath = Path()
      ..moveTo(shipCenter - shipW * 0.45, shipTop)
      ..lineTo(shipCenter + shipW * 0.38, shipTop)
      ..lineTo(shipCenter + shipW * 0.48, shipTop - 8)
      ..lineTo(shipCenter + shipW * 0.42, shipTop + shipH * 0.75)
      ..quadraticBezierTo(shipCenter, shipTop + shipH * 0.95, shipCenter - shipW * 0.40, shipTop + shipH * 0.75)
      ..close();

    final steelPaint = Paint()..color = const Color(0xFF475569);
    canvas.drawPath(hullPath, steelPaint);

    // If revealed, draw hollow cutaway interior with air label
    if (hasRevealed) {
      final interiorPath = Path()
        ..moveTo(shipCenter - shipW * 0.38, shipTop + 6)
        ..lineTo(shipCenter + shipW * 0.32, shipTop + 6)
        ..lineTo(shipCenter + shipW * 0.35, shipTop + shipH * 0.65)
        ..quadraticBezierTo(shipCenter, shipTop + shipH * 0.82, shipCenter - shipW * 0.32, shipTop + shipH * 0.65)
        ..close();
      canvas.drawPath(interiorPath, Paint()..color = const Color(0xFFE2E8F0));
      canvas.drawPath(interiorPath, borderPaint..strokeWidth = 1.5);

      // Air Label inside cutaway
      _drawText(canvas, 'HUGE AIR VOLUME', Offset(shipCenter - 48, shipTop + shipH * 0.3), const Color(0xFF1E293B), 9.5, true);
      _drawText(canvas, 'Density ~0.85 kg/L', Offset(shipCenter - 42, shipTop + shipH * 0.48), ColorSystem.purple, 9.0, true);
    }

    canvas.drawPath(hullPath, borderPaint..strokeWidth = 2.0);

    // Ship Cabin & Mast
    final cabinRect = Rect.fromLTWH(shipCenter - shipW * 0.35, shipTop - 18, shipW * 0.22, 18);
    canvas.drawRect(cabinRect, Paint()..color = Colors.white);
    canvas.drawRect(cabinRect, borderPaint);
    canvas.drawLine(Offset(shipCenter + shipW * 0.1, shipTop), Offset(shipCenter + shipW * 0.1, shipTop - 24), borderPaint..strokeWidth = 2.2);

    // Buoyancy Upward Force Arrows
    final arrowPaint = Paint()
      ..color = ColorSystem.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = -1; i <= 1; i++) {
      final ax = shipCenter + (i * shipW * 0.22);
      final ay = waterY + shipH * 0.55;
      canvas.drawLine(Offset(ax, ay + 14), Offset(ax, ay), arrowPaint);
      canvas.drawLine(Offset(ax - 4, ay + 6), Offset(ax, ay), arrowPaint);
      canvas.drawLine(Offset(ax + 4, ay + 6), Offset(ax, ay), arrowPaint);
    }
  }

  void _drawIceScenario(Canvas canvas, Size size) {
    final waterY = size.height * 0.45;
    final waterPaint = Paint()..color = const Color(0xFF38BDF8).withOpacity(0.35);
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw Ocean Water
    canvas.drawRect(Rect.fromLTRB(0, waterY, size.width, size.height), waterPaint);
    canvas.drawLine(Offset(0, waterY), Offset(size.width, waterY), borderPaint);

    // Draw Iceberg Shape (10% above, 90% below)
    final cx = size.width * 0.5;
    final icePath = Path()
      ..moveTo(cx - 35, waterY)
      ..lineTo(cx - 15, waterY - 26) // Top tip
      ..lineTo(cx + 8, waterY - 32)
      ..lineTo(cx + 30, waterY)
      ..lineTo(cx + 55, waterY + 45) // Submerged body
      ..lineTo(cx + 40, waterY + 85)
      ..lineTo(cx, waterY + 98)
      ..lineTo(cx - 45, waterY + 80)
      ..lineTo(cx - 60, waterY + 38)
      ..close();

    final icePaint = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawPath(icePath, icePaint);
    canvas.drawPath(icePath, borderPaint..strokeWidth = 2.0);

    // Labels
    _drawText(canvas, '10% ABOVE WATER', Offset(cx + 38, waterY - 22), ColorSystem.purple, 9.0, true);
    _drawText(canvas, '90% SUBMERGED (0.92 kg/L)', Offset(cx + 45, waterY + 50), ColorSystem.plum, 9.0, true);

    if (hasRevealed) {
      // Comparison Box at bottom
      final boxRect = Rect.fromLTWH(size.width * 0.1, size.height * 0.78, size.width * 0.8, size.height * 0.18);
      canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(8)), Paint()..color = Colors.white);
      canvas.drawRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(8)), borderPaint..strokeWidth = 1.2);
      _drawText(canvas, 'Water (1.00 kg/L) is denser than Ice (0.92 kg/L)', Offset(size.width * 0.15, size.height * 0.83), ColorSystem.green, 9.5, true);
    }
  }

  void _drawOilScenario(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final beakerW = size.width * 0.45;
    final beakerH = size.height * 0.78;
    final beakerL = (size.width - beakerW) / 2;
    final beakerT = size.height * 0.12;

    // Beaker Glass Outline
    final beakerPath = Path()
      ..moveTo(beakerL - 6, beakerT)
      ..lineTo(beakerL, beakerT + 10)
      ..lineTo(beakerL, beakerT + beakerH - 10)
      ..quadraticBezierTo(beakerL, beakerT + beakerH, beakerL + 10, beakerT + beakerH)
      ..lineTo(beakerL + beakerW - 10, beakerT + beakerH)
      ..quadraticBezierTo(beakerL + beakerW, beakerT + beakerH, beakerL + beakerW, beakerT + beakerH - 10)
      ..lineTo(beakerL + beakerW, beakerT + 10)
      ..lineTo(beakerL + beakerW + 6, beakerT);

    // Fill Layers: Bottom = Water, Top = Oil
    final layerH = (beakerH - 14) / 2;
    final waterRect = Rect.fromLTWH(beakerL + 2, beakerT + 10 + layerH, beakerW - 4, layerH);
    final oilRect = Rect.fromLTWH(beakerL + 2, beakerT + 10, beakerW - 4, layerH);

    // Oil Fill (Golden Yellow)
    canvas.drawRect(oilRect, Paint()..color = const Color(0xFFFBBF24).withOpacity(0.75));
    // Water Fill (Sky Blue)
    canvas.drawRect(waterRect, Paint()..color = const Color(0xFF38BDF8).withOpacity(0.75));

    // Separation line
    canvas.drawLine(Offset(beakerL, beakerT + 10 + layerH), Offset(beakerL + beakerW, beakerT + 10 + layerH), borderPaint..strokeWidth = 1.8);

    // Beaker Glass outline on top
    canvas.drawPath(beakerPath, borderPaint..strokeWidth = 2.4);

    // Labels on right
    _drawText(canvas, 'OIL (0.92 kg/L)', Offset(beakerL + beakerW + 8, beakerT + 10 + layerH * 0.35), const Color(0xFFD97706), 9.5, true);
    _drawText(canvas, 'WATER (1.00 kg/L)', Offset(beakerL + beakerW + 8, beakerT + 10 + layerH * 1.35), const Color(0xFF0284C7), 9.5, true);
  }

  void _drawText(Canvas canvas, String text, Offset offset, Color color, double fontSize, bool isBold) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.w900 : FontWeight.normal,
        color: color,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ScenarioDiagramPainter oldDelegate) =>
      oldDelegate.visualType != visualType || oldDelegate.hasRevealed != hasRevealed;
}

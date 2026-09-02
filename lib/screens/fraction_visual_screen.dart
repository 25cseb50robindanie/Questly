import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/fraction_visual_models.dart';

class FractionVisualScreen extends StatefulWidget {
  final Activity? activity;

  const FractionVisualScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionVisualScreen> createState() => _FractionVisualScreenState();
}

class _FractionVisualScreenState extends State<FractionVisualScreen> {
  Student? _student;
  Activity? _activeActivity;
  String _topic = 'fractions'; // 'fractions', 'ratios', 'proportions', 'percentages', 'applications'
  int _selectedModelTab = 0;

  // Fractions Controls
  int _numerator = 3;
  int _denominator = 4;

  // Ratio Controls
  int _ratioPartA = 2;
  int _ratioPartB = 3;

  // Proportions Controls
  double _scaleFactor = 2.0;
  int _propRightNum = 4;
  int _propRightDen = 6;

  // Percentages Controls
  int _percentFilled = 50;
  int _discountPercent = 25;

  // Applications Controls
  int _mapDistanceCm = 4;
  int _feastServings = 4;

  bool _isCompleted = false;

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
    _topic = _detectTopic(_activeActivity);
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap', arguments: 'mod_fractions');
    }
  }

  Future<void> _completeVisualLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = '${_topic}_les2';
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
          currentLessonId: '${_topic}_les3',
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
        title: 'VISUAL MASTERY UNLOCKED!',
        message: 'You have mastered visual representations! Next up: Guided Practice!',
        onContinue: () {
          Navigator.pushReplacementNamed(
            context,
            '/fraction_practice',
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
                  vertical: isShort ? 6 : 12,
                ),
                child: Column(
                  children: [
                    _buildHeader(isShort),
                    SizedBox(height: isShort ? 6 : 10),

                    // Main Content
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
                            ? _buildLandscapeLayout(isShort)
                            : _buildPortraitLayout(),
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

  Widget _buildLandscapeLayout(bool isShort) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Interactive visual canvas & model selector tabs
        Expanded(
          flex: 13,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModelTabs(),
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildVisualModel(),
                  ),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right Column: Sliders, live calculations, and complete button
        Expanded(
          flex: 10,
          child: Column(
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
                          Text(
                            'INTERACTIVE CONTROLS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: isShort ? 10 : 11,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          DendySpeakButton(
                            textToSpeak: 'Adjust the controls and watch the mathematical visual model update live!',
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildInteractiveControls(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'PROCEED TO PRACTICE →',
                backgroundColor: ColorSystem.green,
                textColor: Colors.white,
                height: 40,
                onPressed: _completeVisualLesson,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModelTabs(),
          const SizedBox(height: 12),
          Center(
            child: _buildVisualModel(),
          ),
          const SizedBox(height: 14),
          _buildInteractiveControls(),
          const SizedBox(height: 16),
          CustomButton(
            text: 'PROCEED TO PRACTICE →',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            height: 42,
            onPressed: _completeVisualLesson,
          ),
        ],
      ),
    );
  }

  Widget _buildModelTabs() {
    final List<String> tabs;
    switch (_topic) {
      case 'ratios':
        tabs = ['🧪 Juice Mixer', '🍎 Fruit Sorter'];
        break;
      case 'proportions':
        tabs = ['🏰 Castle Scale', '⚖️ Twin Balance'];
        break;
      case 'percentages':
        tabs = ['🔟 100-Grid', '🏷️ Discount Tag'];
        break;
      case 'applications':
        tabs = ['🗺️ Blueprint Map', '🥘 Feast Cauldron'];
        break;
      case 'fractions':
      default:
        tabs = ['🍕 Pizza', '🍫 Chocolate', '📏 Strips', '📈 Number Line'];
        break;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _selectedModelTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                tabs[i],
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
                  _selectedModelTab = i;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVisualModel() {
    switch (_topic) {
      case 'ratios':
        return _selectedModelTab == 0
            ? RatioBeakerVisualWidget(partA: _ratioPartA, partB: _ratioPartB, height: 130, width: 100)
            : FruitRatioVisualWidget(countA: _ratioPartA, countB: _ratioPartB, labelA: 'Apples', labelB: 'Bananas');

      case 'proportions':
        return _selectedModelTab == 0
            ? ProportionScaleWidget(scaleFactor: _scaleFactor)
            : TwinBalanceWidget(leftNum: 2, leftDen: 3, rightNum: _propRightNum, rightDen: _propRightDen);

      case 'percentages':
        return _selectedModelTab == 0
            ? HundredGridWidget(percentFilled: _percentFilled, size: 130)
            : DiscountTagWidget(originalPrice: 100, discountPercent: _discountPercent);

      case 'applications':
        return _selectedModelTab == 0
            ? BlueprintMapWidget(mapCm: _mapDistanceCm, kmPerCm: 5)
            : RecipeMixerWidget(servings: _feastServings);

      case 'fractions':
      default:
        switch (_selectedModelTab) {
          case 0:
            return PizzaVisualWidget(totalSlices: _denominator, selectedSlices: _numerator, size: 135, label: '$_numerator / $_denominator of Pizza');
          case 1:
            return ChocolateBarVisualWidget(totalRows: 2, totalCols: _denominator ~/ 2 > 0 ? _denominator ~/ 2 : 2, selectedPieces: _numerator, width: 170, height: 85);
          case 2:
            return FractionStripsVisualWidget(activeDenominator: _denominator, activeNumerator: _numerator);
          case 3:
          default:
            return NumberLineVisualWidget(denominator: _denominator, numerator: _numerator, width: 250);
        }
    }
  }

  Widget _buildInteractiveControls() {
    switch (_topic) {
      case 'ratios':
        return Column(
          children: [
            _buildSliderRow(
              label: 'Part A (Juice / Apples)',
              value: _ratioPartA,
              min: 1,
              max: 8,
              color: const Color(0xFFFF9800),
              onChanged: (val) => setState(() => _ratioPartA = val),
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Part B (Water / Bananas)',
              value: _ratioPartB,
              min: 1,
              max: 8,
              color: const Color(0xFF29B6F6),
              onChanged: (val) => setState(() => _ratioPartB = val),
            ),
            const SizedBox(height: 10),
            _buildRatioLiveBadge(),
          ],
        );

      case 'proportions':
        return Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Scale Factor (k)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
                    Text('${_scaleFactor.toStringAsFixed(1)}x', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(activeTrackColor: ColorSystem.purple, thumbColor: ColorSystem.purple, trackHeight: 4),
                  child: Slider(
                    value: _scaleFactor,
                    min: 1.0,
                    max: 3.0,
                    divisions: 4,
                    onChanged: (val) => setState(() => _scaleFactor = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Right Denominator (Target = 6 for 2/3)',
              value: _propRightDen,
              min: 3,
              max: 9,
              color: ColorSystem.gold,
              onChanged: (val) => setState(() {
                _propRightDen = val;
                _propRightNum = (val * 2) ~/ 3;
              }),
            ),
          ],
        );

      case 'percentages':
        return Column(
          children: [
            _buildSliderRow(
              label: 'Grid Percentage Fill',
              value: _percentFilled,
              min: 0,
              max: 100,
              color: ColorSystem.purple,
              onChanged: (val) => setState(() => _percentFilled = val),
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Discount Percentage (%)',
              value: _discountPercent,
              min: 5,
              max: 50,
              color: ColorSystem.pink,
              onChanged: (val) => setState(() => _discountPercent = val),
            ),
          ],
        );

      case 'applications':
        return Column(
          children: [
            _buildSliderRow(
              label: 'Blueprint Map Distance (cm)',
              value: _mapDistanceCm,
              min: 1,
              max: 10,
              color: const Color(0xFF1A237E),
              onChanged: (val) => setState(() => _mapDistanceCm = val),
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Feast Servings Count',
              value: _feastServings,
              min: 1,
              max: 12,
              color: ColorSystem.gold,
              onChanged: (val) => setState(() => _feastServings = val),
            ),
          ],
        );

      case 'fractions':
      default:
        return Column(
          children: [
            _buildSliderRow(
              label: 'Numerator (Top)',
              value: _numerator,
              min: 1,
              max: _denominator,
              color: ColorSystem.purple,
              onChanged: (val) => setState(() => _numerator = val),
            ),
            const SizedBox(height: 8),
            _buildSliderRow(
              label: 'Denominator (Bottom)',
              value: _denominator,
              min: 2,
              max: 8,
              color: ColorSystem.gold,
              onChanged: (val) => setState(() {
                _denominator = val;
                if (_numerator > _denominator) _numerator = _denominator;
              }),
            ),
            const SizedBox(height: 10),
            _buildFractionLiveBadge(),
          ],
        );
    }
  }

  Widget _buildSliderRow({
    required String label,
    required int value,
    required int min,
    required int max,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
            Text('$value', style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.toDouble().clamp(min.toDouble(), max.toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min > 0 ? max - min : 1,
            onChanged: (val) => onChanged(val.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildFractionLiveBadge() {
    final percent = ((_numerator / _denominator) * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorSystem.lavender.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.purple.withOpacity(0.2), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Live Value:', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
          Text('$_numerator/$_denominator = $percent%', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12.5, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
        ],
      ),
    );
  }

  Widget _buildRatioLiveBadge() {
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final divisor = gcd(_ratioPartA, _ratioPartB);
    final simpA = _ratioPartA ~/ divisor;
    final simpB = _ratioPartB ~/ divisor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorSystem.gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.gold.withOpacity(0.3), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Simplest Form:', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
          Text('$_ratioPartA : $_ratioPartB = $simpA : $simpB', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
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
                  'LESSON 2: VISUAL UNDERSTANDING',
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

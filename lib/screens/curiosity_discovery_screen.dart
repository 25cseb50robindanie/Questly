import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/vector_asset_helper.dart';
import '../services/sound_service.dart';

enum PredictionChoice { float, sink }

enum LessonStage {
  intro,
  predicting,
  testing,
  reflection,
  completed,
}

class DiscoveryObject {
  final String id;
  final String name;
  final String description;
  final bool actuallyFloats;
  final Widget illustration;

  const DiscoveryObject({
    required this.id,
    required this.name,
    required this.description,
    required this.actuallyFloats,
    required this.illustration,
  });
}

class CuriosityDiscoveryScreen extends StatefulWidget {
  const CuriosityDiscoveryScreen({Key? key}) : super(key: key);

  @override
  _CuriosityDiscoveryScreenState createState() => _CuriosityDiscoveryScreenState();
}

class _CuriosityDiscoveryScreenState extends State<CuriosityDiscoveryScreen> with TickerProviderStateMixin {
  Student? _student;
  LessonStage _stage = LessonStage.intro;

  // Predictions map: objectId -> PredictionChoice
  final Map<String, PredictionChoice> _predictions = {};

  // Sequential testing state
  int _currentTestingIndex = -1;
  final Set<String> _testedObjectIds = {};
  String? _feedbackMessage;

  // Selected reflection prompt
  int _selectedReflectionIndex = -1;

  // Animation controllers for water waves and object physics
  late AnimationController _waveController;
  late AnimationController _dropController;
  late AnimationController _bobController;
  late AnimationController _splashController;

  // Objects in Lesson 1
  late final List<DiscoveryObject> _objects;

  @override
  void initState() {
    super.initState();
    _loadStudent();

    _objects = [
      const DiscoveryObject(
        id: 'wood_block',
        name: 'WOODEN BLOCK',
        description: 'Solid oak wood',
        actuallyFloats: true,
        illustration: _ObjectCustomPainterWidget(type: _ObjectType.woodBlock, size: 40),
      ),
      const DiscoveryObject(
        id: 'metal_cube',
        name: 'METAL CUBE',
        description: 'Solid iron/steel',
        actuallyFloats: false,
        illustration: _ObjectCustomPainterWidget(type: _ObjectType.metalCube, size: 40),
      ),
      const DiscoveryObject(
        id: 'plastic_ball',
        name: 'PLASTIC BALL',
        description: 'Hollow lightweight plastic',
        actuallyFloats: true,
        illustration: _ObjectCustomPainterWidget(type: _ObjectType.plasticBall, size: 40),
      ),
      const DiscoveryObject(
        id: 'river_stone',
        name: 'RIVER STONE',
        description: 'Dense granite rock',
        actuallyFloats: false,
        illustration: _ObjectCustomPainterWidget(type: _ObjectType.riverStone, size: 40),
      ),
      const DiscoveryObject(
        id: 'empty_bottle',
        name: 'EMPTY BOTTLE',
        description: 'Capped air-filled bottle',
        actuallyFloats: true,
        illustration: _ObjectCustomPainterWidget(type: _ObjectType.emptyBottle, size: 40),
      ),
    ];

    // Continuous wave animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Gentle bobbing for floating objects
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Drop animation for the active object
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Splash animation
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _dropController.dispose();
    _bobController.dispose();
    _splashController.dispose();
    super.dispose();
  }

  // Handle prediction selection
  void _selectPrediction(String objectId, PredictionChoice choice) {
    if (_stage != LessonStage.predicting) return;
    SoundService.playClick();
    setState(() {
      _predictions[objectId] = choice;
    });
  }

  // Start sequential testing
  Future<void> _startTesting() async {
    if (_predictions.length < _objects.length) return;

    SoundService.playSwitch();
    setState(() {
      _stage = LessonStage.testing;
      _currentTestingIndex = 0;
      _testedObjectIds.clear();
      _feedbackMessage = 'Testing ${_objects[0].name}...';
    });

    for (int i = 0; i < _objects.length; i++) {
      if (!mounted) return;

      setState(() {
        _currentTestingIndex = i;
        _feedbackMessage = 'Testing ${_objects[i].name}...';
      });

      // Reset and trigger drop
      _dropController.reset();
      await _dropController.forward();

      // Trigger splash at water impact
      _splashController.reset();
      SoundService.playWaterSplash();
      _splashController.forward();

      // Settle time
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;

      final currentObj = _objects[i];
      final pred = _predictions[currentObj.id];
      final matched = (pred == PredictionChoice.float && currentObj.actuallyFloats) ||
          (pred == PredictionChoice.sink && !currentObj.actuallyFloats);

      setState(() {
        _testedObjectIds.add(currentObj.id);
        if (matched) {
          _feedbackMessage = '✓ Result: ${currentObj.actuallyFloats ? "FLOATS" : "SINKS"} — Matched your prediction!';
        } else {
          _feedbackMessage = 'Observation: ${currentObj.actuallyFloats ? "FLOATS" : "SINKS"} — Different from prediction! Take a closer look.';
        }
      });

      await Future.delayed(const Duration(milliseconds: 1200));
    }

    // All objects tested -> transition to reflection
    if (!mounted) return;
    setState(() {
      _stage = LessonStage.reflection;
      _feedbackMessage = null;
    });
  }

  // Finish Lesson and persist rewards
  Future<void> _completeLesson() async {
    if (_student == null) return;
    final sId = _student!.questlyId.toLowerCase();

    // 1. Persist Progress record with 1 Star (Concept portion)
    await Locator.progressRepository.saveProgress(Progress(
      studentId: sId,
      lessonId: 'density_les1',
      status: 'completed',
      score: 1.0,
      stars: 1,
      attempts: 1,
      lastPlayed: DateTime.now(),
      completedAt: DateTime.now(),
    ));

    // 2. Persist explicit flags
    await Locator.storageService.setBool('lesson1Completed', true);
    await Locator.storageService.setBool('lesson_comp_${sId}_density_les1', true);
    await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les2', true);

    // 3. Award XP (+40) and Quest Coins (+5)
    final updated = _student!.copyWith(
      xp: _student!.xp + 40,
      gold: _student!.gold + 5,
      currentLessonId: 'density_les2', // Progress pointer to Lesson 2!
    );
    await Locator.studentRepository.updateStudentProfile(updated);

    SoundService.playLevelComplete();
    if (!mounted) return;
    setState(() {
      _stage = LessonStage.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            child: Column(
              children: [
                // 1. Persistent Top Header with 5-step Lesson Tracker
                _buildTopBar(),
                const SizedBox(height: 10),

                // 2. Main Content View according to current Stage
                Expanded(
                  child: _stage == LessonStage.intro
                      ? _buildIntroView()
                      : _stage == LessonStage.completed
                          ? _buildCompletedView()
                          : _buildExperimentAndHypothesisView(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top Bar with Level Info & 5-Step Lesson Indicator
  Widget _buildTopBar() {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isShort ? 10 : 16, vertical: isShort ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.06),
            offset: const Offset(0, 3),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button + Level title
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LEVEL 1 • DISCOVER DENSITY',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 11 : 13,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    'LESSON 1 OF 5',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 9 : 10,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Center / Right: Five-Step Lesson Tracker with Horizontal Scroll & FittedBox
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStepIndicator(0, 'CURIOSITY', isCurrent: true, isCompleted: _stage == LessonStage.completed),
                  _buildStepDivider(),
                  _buildStepIndicator(1, 'EXPERIMENT', isCurrent: false, isCompleted: false),
                  _buildStepDivider(),
                  _buildStepIndicator(2, 'APPLY', isCurrent: false, isCompleted: false),
                  _buildStepDivider(),
                  _buildStepIndicator(3, 'CHALLENGE', isCurrent: false, isCompleted: false),
                  _buildStepDivider(),
                  _buildStepIndicator(4, 'TEACH DENDY', isCurrent: false, isCompleted: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index, String label, {required bool isCurrent, required bool isCompleted}) {
    Color bg = Colors.transparent;
    Color border = ColorSystem.plum.withOpacity(0.25);
    Color textColor = ColorSystem.plum.withOpacity(0.5);

    if (isCompleted) {
      bg = ColorSystem.green.withOpacity(0.2);
      border = ColorSystem.green;
      textColor = ColorSystem.green;
    } else if (isCurrent) {
      bg = ColorSystem.purple;
      border = ColorSystem.purple;
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? ColorSystem.green
                  : (isCurrent ? Colors.white : ColorSystem.plum.withOpacity(0.3)),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 6,
      height: 1.5,
      color: ColorSystem.plum.withOpacity(0.2),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  // 1. Short Intro View (Mobile Responsive)
  Widget _buildIntroView() {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isShort ? 14 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.08),
            offset: const Offset(0, 6),
            blurRadius: 10,
          )
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: Title, subtitle, and intro mission
            Expanded(
              flex: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ColorSystem.lavender.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'DISCOVERY LAB • STEP 1',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isShort ? 6 : 10),
                  Text(
                    'DISCOVER DENSITY',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 22 : 26,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '"Why do some objects float while others sink?"',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 13 : 15,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: ColorSystem.purple,
                    ),
                  ),
                  SizedBox(height: isShort ? 6 : 10),
                  Text(
                    'Before testing, predict what will happen when different materials are placed in water. Observe the physical results and notice what happens.',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 11 : 12.5,
                      color: ColorSystem.plum.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: isShort ? 12 : 18),
                  SizedBox(
                    width: 200,
                    child: CustomButton(
                      text: 'START DISCOVERY',
                      backgroundColor: ColorSystem.purple,
                      textColor: Colors.white,
                      height: isShort ? 38 : 42,
                      onPressed: () {
                        SoundService.playClick();
                        setState(() {
                          _stage = LessonStage.predicting;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const VerticalDivider(width: 28, thickness: 1.5, color: ColorSystem.cream),

            // Right: Dendy Companion Preview
            Expanded(
              flex: 8,
              child: Center(
                child: DendyMascot(
                  state: DendyState.thinking,
                  message: "Let's make a prediction before we test anything!",
                  size: isShort ? 75 : 90,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Main Discovery View: Left (Water Tank), Right (Hypothesis Station / Reflection)
  Widget _buildExperimentAndHypothesisView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Interactive Water Tank Simulation Area
        Expanded(
          flex: 11,
          child: _buildWaterTankCard(),
        ),
        const SizedBox(width: 12),

        // Right Column: Hypothesis Station or Reflection
        Expanded(
          flex: 10,
          child: _stage == LessonStage.reflection
              ? _buildReflectionCard()
              : _buildHypothesisStationCard(),
        ),
      ],
    );
  }

  // Water Tank Simulation Card
  Widget _buildWaterTankCard() {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      padding: EdgeInsets.all(isShort ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Lab Tank Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.science_outlined, color: ColorSystem.purple, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    'WATER TANK LABORATORY',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 10 : 11,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (_feedbackMessage != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ColorSystem.lavender.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _feedbackMessage!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 9 : 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),

          // Live Animated Water Tank Surface
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: Listenable.merge([_waveController, _bobController, _dropController, _splashController]),
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WaterTankPainter(
                      wavePhase: _waveController.value * 2 * math.pi,
                      bobOffset: math.sin(_bobController.value * math.pi) * 3.5,
                      dropProgress: _dropController.value,
                      splashProgress: _splashController.value,
                      currentTestingIndex: _currentTestingIndex,
                      testedObjectIds: _testedObjectIds,
                      objects: _objects,
                      stage: _stage,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hypothesis Station Card
  Widget _buildHypothesisStationCard() {
    final allSelected = _predictions.length == _objects.length;
    final isTesting = _stage == LessonStage.testing;
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      padding: EdgeInsets.all(isShort ? 10 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station Title & Question
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HYPOTHESIS STATION',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 11.5 : 13,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: allSelected ? ColorSystem.green.withOpacity(0.15) : ColorSystem.cream,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: allSelected ? ColorSystem.green : ColorSystem.plum.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${_predictions.length} / ${_objects.length} PREDICTED',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 8.5 : 9.5,
                    fontWeight: FontWeight.bold,
                    color: allSelected ? ColorSystem.green : ColorSystem.plum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Which object will float?',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 10.5 : 12,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 6),

          // 5 Object Rows
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: _objects.length,
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemBuilder: (context, index) {
                final obj = _objects[index];
                final isCurrent = isTesting && _currentTestingIndex == index;
                final isTested = _testedObjectIds.contains(obj.id);
                final selectedChoice = _predictions[obj.id];

                return _buildObjectPredictionRow(
                  obj: obj,
                  selectedChoice: selectedChoice,
                  isCurrentTesting: isCurrent,
                  isTested: isTested,
                  disabled: isTesting,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Test Button CTA
          CustomButton(
            text: isTesting
                ? 'TESTING IN PROGRESS...'
                : (allSelected ? 'TEST PREDICTIONS' : 'SELECT ALL PREDICTIONS (${_predictions.length}/5)'),
            backgroundColor: allSelected && !isTesting ? ColorSystem.purple : Colors.grey.shade400,
            textColor: Colors.white,
            height: isShort ? 36 : 40,
            onPressed: allSelected && !isTesting ? _startTesting : () {},
          ),
        ],
      ),
    );
  }

  // Single Object Prediction Row
  Widget _buildObjectPredictionRow({
    required DiscoveryObject obj,
    required PredictionChoice? selectedChoice,
    required bool isCurrentTesting,
    required bool isTested,
    required bool disabled,
  }) {
    final matched = isTested &&
        ((selectedChoice == PredictionChoice.float && obj.actuallyFloats) ||
            (selectedChoice == PredictionChoice.sink && !obj.actuallyFloats));

    Color borderColor = ColorSystem.plum.withOpacity(0.15);
    Color bgColor = Colors.white;

    if (isCurrentTesting) {
      borderColor = ColorSystem.purple;
      bgColor = ColorSystem.purple.withOpacity(0.06);
    } else if (isTested) {
      borderColor = matched ? ColorSystem.green : ColorSystem.gold;
      bgColor = matched ? ColorSystem.green.withOpacity(0.05) : ColorSystem.gold.withOpacity(0.05);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: isCurrentTesting ? 1.8 : 1.0),
      ),
      child: Row(
        children: [
          // Vector Illustration
          SizedBox(
            width: 30,
            height: 30,
            child: obj.illustration,
          ),
          const SizedBox(width: 6),

          // Name & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  obj.name,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  obj.description,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 8.5,
                    color: ColorSystem.plum.withOpacity(0.65),
                  ),
                ),
                // After-test badge
                if (isTested) ...[
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: obj.actuallyFloats ? ColorSystem.blue.withOpacity(0.2) : ColorSystem.plum.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          obj.actuallyFloats ? 'FLOATED' : 'SUNK',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        matched ? '✓ Match' : 'Different',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 7.5,
                          fontWeight: FontWeight.bold,
                          color: matched ? ColorSystem.green : ColorSystem.plum.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // FLOAT / SINK Prediction Toggle Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChoiceChip(
                label: 'FLOAT',
                isSelected: selectedChoice == PredictionChoice.float,
                isCorrect: isTested && obj.actuallyFloats,
                isTested: isTested,
                disabled: disabled,
                onTap: () => _selectPrediction(obj.id, PredictionChoice.float),
              ),
              const SizedBox(width: 4),
              _buildChoiceChip(
                label: 'SINK',
                isSelected: selectedChoice == PredictionChoice.sink,
                isCorrect: isTested && !obj.actuallyFloats,
                isTested: isTested,
                disabled: disabled,
                onTap: () => _selectPrediction(obj.id, PredictionChoice.sink),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required bool isCorrect,
    required bool isTested,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.25);
    Color textColor = ColorSystem.plum;

    if (isSelected && !isTested) {
      bg = ColorSystem.purple;
      border = ColorSystem.purple;
      textColor = Colors.white;
    } else if (isTested) {
      if (isSelected) {
        bg = isCorrect ? ColorSystem.green : ColorSystem.plum.withOpacity(0.7);
        border = isCorrect ? ColorSystem.green : ColorSystem.plum;
        textColor = Colors.white;
      }
    }

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: isSelected ? 1.6 : 1.0),
            boxShadow: isSelected && !isTested
                ? [
                    BoxShadow(
                      color: ColorSystem.purple.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // 3. Reflection Stage Card
  Widget _buildReflectionCard() {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Container(
      padding: EdgeInsets.all(isShort ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: ColorSystem.gold, size: 18),
              const SizedBox(width: 5),
              Text(
                'OBSERVATION & REFLECTION',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShort ? 11 : 12,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: isShort ? 4 : 8),

          Text(
            'Some objects floated while others sank.',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 13 : 15,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          Text(
            '"Why do you think that happened?"',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 12 : 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: ColorSystem.purple,
            ),
          ),
          SizedBox(height: isShort ? 6 : 10),

          // Observation Prompts
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildReflectionOption(
                  index: 0,
                  title: 'Material Composition',
                  subtitle: 'Is it because of what the material is made of?',
                ),
                const SizedBox(height: 6),
                _buildReflectionOption(
                  index: 1,
                  title: 'Trapped Air & Shape',
                  subtitle: 'Does having air inside (like the bottle) help it float?',
                ),
                const SizedBox(height: 6),
                _buildReflectionOption(
                  index: 2,
                  title: 'Heaviness vs Size',
                  subtitle: 'Is it how heavy an object is compared to how much space it takes up?',
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Companion Note
          Row(
            children: [
              DendyMascot(
                state: DendyState.thinking,
                size: isShort ? 36 : 44,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We will investigate the exact reasons and measurements in the next experiment lab!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 9.5 : 10.5,
                    color: ColorSystem.plum.withOpacity(0.8),
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const DendySpeakButton(
                textToSpeak: 'We will investigate the exact reasons and measurements in the next experiment lab!',
                size: 24,
              ),
            ],
          ),
          SizedBox(height: isShort ? 6 : 10),

          // Complete Button
          CustomButton(
            text: 'COMPLETE DISCOVERY',
            backgroundColor: ColorSystem.purple,
            textColor: Colors.white,
            height: isShort ? 36 : 40,
            onPressed: _completeLesson,
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionOption({required int index, required String title, required String subtitle}) {
    final isSelected = _selectedReflectionIndex == index;
    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() {
          _selectedReflectionIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? ColorSystem.purple.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.15),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? ColorSystem.purple : Colors.white,
                border: Border.all(
                  color: isSelected ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9,
                      color: ColorSystem.plum.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 4. Completion View (Mobile Responsive)
  Widget _buildCompletedView() {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: size.height * 0.94,
        ),
        child: Container(
          padding: EdgeInsets.all(isShort ? 14 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ColorSystem.plum, width: 2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.15),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Mascot cheering
                DendyMascot(
                  state: DendyState.success,
                  size: isShort ? 60 : 75,
                ),
                SizedBox(height: isShort ? 6 : 10),

                Text(
                  'DISCOVERY COMPLETE!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You made your predictions and tested them.',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 11 : 12.5,
                    color: ColorSystem.plum.withOpacity(0.75),
                  ),
                ),
                SizedBox(height: isShort ? 10 : 14),

                // Concept Mastery Star Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorSystem.cream,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorSystem.gold, width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      VectorAssetHelper.xpStarIcon(size: 20, isFilled: true),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LEVEL 1 CONCEPT STAR EARNED',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.plum,
                            ),
                          ),
                          Text(
                            '1 of 3 Stars (Complete all 5 lessons for full 3-star mastery)',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              color: ColorSystem.plum.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isShort ? 8 : 12),

                // Rewards Row (+40 XP, +5 Quest Coins)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          VectorAssetHelper.xpStarIcon(size: 16),
                          const SizedBox(width: 5),
                          const Text(
                            '+40 XP',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Row(
                        children: [
                          VectorAssetHelper.questCoinIcon(size: 16),
                          const SizedBox(width: 5),
                          const Text(
                            '+5 Quest Coins',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.plum,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isShort ? 12 : 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'ROADMAP',
                        backgroundColor: ColorSystem.cream,
                        textColor: ColorSystem.plum,
                        height: isShort ? 36 : 40,
                        onPressed: () {
                          SoundService.playClick();
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          } else {
                            Navigator.pushReplacementNamed(context, '/roadmap');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: 'CONTINUE TO NEXT LESSON',
                        backgroundColor: ColorSystem.purple,
                        textColor: Colors.white,
                        height: isShort ? 36 : 40,
                        onPressed: () {
                          SoundService.playClick();
                          Navigator.pushReplacementNamed(context, '/density_experiment');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// WATER TANK CUSTOM PAINTER
// ==========================================

class _WaterTankPainter extends CustomPainter {
  final double wavePhase;
  final double bobOffset;
  final double dropProgress;
  final double splashProgress;
  final int currentTestingIndex;
  final Set<String> testedObjectIds;
  final List<DiscoveryObject> objects;
  final LessonStage stage;

  _WaterTankPainter({
    required this.wavePhase,
    required this.bobOffset,
    required this.dropProgress,
    required this.splashProgress,
    required this.currentTestingIndex,
    required this.testedObjectIds,
    required this.objects,
    required this.stage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tankRect = Rect.fromLTWH(12, 10, size.width - 24, size.height - 20);
    final waterLevelY = size.height * 0.42;

    // 1. Tank Background (Laboratory interior)
    final bgPaint = Paint()..color = const Color(0xFFF9F6F0);
    canvas.drawRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(12)), bgPaint);

    // 2. Water Body Fill (Soft Gradient)
    final waterRect = Rect.fromLTRB(tankRect.left + 2, waterLevelY, tankRect.right - 2, tankRect.bottom - 2);
    final waterGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF81D4FA), // Light surface cyan
        Color(0xFF29B6F6), // Mid water
        Color(0xFF0288D1), // Deep blue bottom
      ],
    ).createShader(waterRect);

    final waterPaint = Paint()..shader = waterGradient;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        waterRect,
        bottomLeft: const Radius.circular(10),
        bottomRight: const Radius.circular(10),
      ),
      waterPaint,
    );

    // 3. Animated Surface Wave Line
    final wavePath = Path();
    wavePath.moveTo(tankRect.left + 2, waterLevelY);
    for (double x = tankRect.left + 2; x <= tankRect.right - 2; x += 4) {
      final y = waterLevelY + math.sin((x / 24.0) + wavePhase) * 2.5;
      wavePath.lineTo(x, y);
    }
    final waveBorderPaint = Paint()
      ..color = const Color(0xFFE1F5FE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(wavePath, waveBorderPaint);

    // 4. Measuring Scale Ticks on Left Wall
    final tickPaint = Paint()
      ..color = ColorSystem.plum.withOpacity(0.35)
      ..strokeWidth = 1.2;
    for (double y = waterLevelY - 20; y <= tankRect.bottom - 15; y += 18) {
      canvas.drawLine(Offset(tankRect.left + 6, y), Offset(tankRect.left + 14, y), tickPaint);
    }

    // 5. Draw Objects in the Tank
    // Tested objects resting in their physical states
    final floatPositions = [
      Offset(tankRect.left + tankRect.width * 0.20, waterLevelY - 6 + bobOffset),
      Offset(tankRect.left + tankRect.width * 0.50, waterLevelY - 8 + (bobOffset * 0.8)),
      Offset(tankRect.left + tankRect.width * 0.80, waterLevelY - 10 + (bobOffset * 1.2)),
    ];

    final sinkPositions = [
      Offset(tankRect.left + tankRect.width * 0.35, tankRect.bottom - 26),
      Offset(tankRect.left + tankRect.width * 0.65, tankRect.bottom - 24),
    ];

    int floatIdx = 0;
    int sinkIdx = 0;

    for (int i = 0; i < objects.length; i++) {
      final obj = objects[i];

      // If object has already been tested
      if (testedObjectIds.contains(obj.id)) {
        Offset pos;
        if (obj.actuallyFloats) {
          pos = floatPositions[floatIdx % floatPositions.length];
          floatIdx++;
        } else {
          pos = sinkPositions[sinkIdx % sinkPositions.length];
          sinkIdx++;
        }
        _drawObjectOnCanvas(canvas, _getObjectTypeFromId(obj.id), pos, size: 28);
      }
      // If currently being tested, animate drop/settle
      else if (i == currentTestingIndex && stage == LessonStage.testing) {
        final startY = 24.0;
        final targetY = obj.actuallyFloats
            ? (waterLevelY - 6 + bobOffset)
            : (tankRect.bottom - 26);

        final currentY = startY + (targetY - startY) * dropProgress;
        final currentX = tankRect.left + tankRect.width * (0.2 + i * 0.15);

        _drawObjectOnCanvas(canvas, _getObjectTypeFromId(obj.id), Offset(currentX, currentY), size: 28);

        // Splash ring at water impact
        if (dropProgress > 0.45 && splashProgress > 0.0 && splashProgress < 1.0) {
          final splashRadius = 12.0 * splashProgress;
          final splashOpacity = (1.0 - splashProgress).clamp(0.0, 1.0);
          final splashPaint = Paint()
            ..color = Colors.white.withOpacity(splashOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawCircle(Offset(currentX + 14, waterLevelY), splashRadius, splashPaint);
        }
      }
    }

    // 6. Glass Tank Outer Border
    final tankBorderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(12)), tankBorderPaint);

    // 7. Glass Specular Light Reflection (Diagonal white glare)
    final reflectionPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(tankRect.right - 24, tankRect.top + 16),
      Offset(tankRect.right - 8, tankRect.top + 36),
      reflectionPaint,
    );
  }

  _ObjectType _getObjectTypeFromId(String id) {
    switch (id) {
      case 'wood_block':
        return _ObjectType.woodBlock;
      case 'metal_cube':
        return _ObjectType.metalCube;
      case 'plastic_ball':
        return _ObjectType.plasticBall;
      case 'river_stone':
        return _ObjectType.riverStone;
      case 'empty_bottle':
        return _ObjectType.emptyBottle;
      default:
        return _ObjectType.woodBlock;
    }
  }

  void _drawObjectOnCanvas(Canvas canvas, _ObjectType type, Offset position, {double size = 28}) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    _paintObjectGraphics(canvas, Size(size, size), type);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WaterTankPainter oldDelegate) => true;
}

// ==========================================
// STRICT NO-EMOJIS: CUSTOM OBJECT PAINTERS
// ==========================================

enum _ObjectType {
  woodBlock,
  metalCube,
  plasticBall,
  riverStone,
  emptyBottle,
}

class _ObjectCustomPainterWidget extends StatelessWidget {
  final _ObjectType type;
  final double size;

  const _ObjectCustomPainterWidget({
    Key? key,
    required this.type,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ObjectVectorPainter(type: type),
      ),
    );
  }
}

class _ObjectVectorPainter extends CustomPainter {
  final _ObjectType type;

  _ObjectVectorPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    _paintObjectGraphics(canvas, size, type);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _paintObjectGraphics(Canvas canvas, Size size, _ObjectType type) {
  final borderPaint = Paint()
    ..color = ColorSystem.plum
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  switch (type) {
    // 1. WOODEN BLOCK (Natural oak wood plank with grain lines and bevel)
    case _ObjectType.woodBlock:
      final woodFill = Paint()..color = const Color(0xFFD4A373)..style = PaintingStyle.fill;
      final woodGrain = Paint()
        ..color = const Color(0xFFA5734A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      final rect = Rect.fromLTWH(2, 4, size.width - 4, size.height - 8);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), woodFill);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), borderPaint);

      // Wood Grain Lines
      canvas.drawLine(Offset(rect.left + 5, rect.top + 6), Offset(rect.right - 5, rect.top + 6), woodGrain);
      canvas.drawLine(Offset(rect.left + 5, rect.top + 13), Offset(rect.right - 9, rect.top + 13), woodGrain);
      canvas.drawLine(Offset(rect.left + 8, rect.top + 20), Offset(rect.right - 5, rect.top + 20), woodGrain);
      break;

    // 2. METAL CUBE (Polished steel/iron with 3D bevel and specular highlight)
    case _ObjectType.metalCube:
      final metalFill = Paint()..color = const Color(0xFF78909C)..style = PaintingStyle.fill;
      final metalTop = Paint()..color = const Color(0xFFB0BEC5)..style = PaintingStyle.fill;
      final metalSide = Paint()..color = const Color(0xFF546E7A)..style = PaintingStyle.fill;

      final cubeRect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
      canvas.drawRRect(RRect.fromRectAndRadius(cubeRect, const Radius.circular(3)), metalFill);

      // Top bevel highlight
      final topPath = Path()
        ..moveTo(cubeRect.left, cubeRect.top)
        ..lineTo(cubeRect.right, cubeRect.top)
        ..lineTo(cubeRect.right - 4, cubeRect.top + 4)
        ..lineTo(cubeRect.left + 4, cubeRect.top + 4)
        ..close();
      canvas.drawPath(topPath, metalTop);

      // Right bevel shade
      final rightPath = Path()
        ..moveTo(cubeRect.right, cubeRect.top)
        ..lineTo(cubeRect.right, cubeRect.bottom)
        ..lineTo(cubeRect.right - 4, cubeRect.bottom - 4)
        ..lineTo(cubeRect.right - 4, cubeRect.top + 4)
        ..close();
      canvas.drawPath(rightPath, metalSide);

      canvas.drawRRect(RRect.fromRectAndRadius(cubeRect, const Radius.circular(3)), borderPaint);
      break;

    // 3. PLASTIC BALL (Vibrant hollow smooth sphere with curved light gloss)
    case _ObjectType.plasticBall:
      final center = Offset(size.width / 2, size.height / 2);
      final radius = (size.width - 6) / 2;

      final ballPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.3),
          colors: [
            Color(0xFFFF8A80), // Bright coral red
            Color(0xFFE53935), // Mid red
            Color(0xFFB71C1C), // Deep shadow
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawCircle(center, radius, ballPaint);
      canvas.drawCircle(center, radius, borderPaint);

      // Glossy highlight shine
      final glossPaint = Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.35), width: radius * 0.5, height: radius * 0.3),
        glossPaint,
      );
      break;

    // 4. RIVER STONE (Smooth organic granite pebble with subtle speckles)
    case _ObjectType.riverStone:
      final stoneFill = Paint()..color = const Color(0xFF9E9E9E)..style = PaintingStyle.fill;
      final stonePath = Path()
        ..moveTo(size.width * 0.25, size.height * 0.3)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.15, size.width * 0.8, size.height * 0.3)
        ..quadraticBezierTo(size.width * 0.95, size.height * 0.6, size.width * 0.75, size.height * 0.85)
        ..quadraticBezierTo(size.width * 0.4, size.height * 0.92, size.width * 0.15, size.height * 0.75)
        ..quadraticBezierTo(size.width * 0.05, size.height * 0.45, size.width * 0.25, size.height * 0.3)
        ..close();

      canvas.drawPath(stonePath, stoneFill);

      // Speckles
      final specklePaint = Paint()..color = const Color(0xFF616161)..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width * 0.4, size.height * 0.45), 1.5, specklePaint);
      canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.55), 1.2, specklePaint);
      canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.68), 1.4, specklePaint);

      canvas.drawPath(stonePath, borderPaint);
      break;

    // 5. EMPTY BOTTLE (Translucent laboratory bottle with dark rim and screw cap)
    case _ObjectType.emptyBottle:
      final glassFill = Paint()..color = const Color(0xFFE0F7FA).withOpacity(0.85)..style = PaintingStyle.fill;
      final capFill = Paint()..color = ColorSystem.purple..style = PaintingStyle.fill;

      // Bottle body
      final bottlePath = Path()
        ..moveTo(size.width * 0.38, size.height * 0.28) // neck left
        ..lineTo(size.width * 0.38, size.height * 0.4) // body start
        ..quadraticBezierTo(size.width * 0.2, size.height * 0.45, size.width * 0.2, size.height * 0.6)
        ..lineTo(size.width * 0.2, size.height * 0.85)
        ..quadraticBezierTo(size.width * 0.2, size.height * 0.92, size.width * 0.3, size.height * 0.92)
        ..lineTo(size.width * 0.7, size.height * 0.92)
        ..quadraticBezierTo(size.width * 0.8, size.height * 0.92, size.width * 0.8, size.height * 0.85)
        ..lineTo(size.width * 0.8, size.height * 0.6)
        ..quadraticBezierTo(size.width * 0.8, size.height * 0.45, size.width * 0.62, size.height * 0.4)
        ..lineTo(size.width * 0.62, size.height * 0.28) // neck right
        ..close();

      canvas.drawPath(bottlePath, glassFill);
      canvas.drawPath(bottlePath, borderPaint);

      // Screw Cap
      final capRect = Rect.fromLTWH(size.width * 0.34, size.height * 0.16, size.width * 0.32, size.height * 0.12);
      canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(2)), capFill);
      canvas.drawRRect(RRect.fromRectAndRadius(capRect, const Radius.circular(2)), borderPaint);

      // Glass specular reflection line
      final glassLine = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(size.width * 0.3, size.height * 0.55), Offset(size.width * 0.3, size.height * 0.82), glassLine);
      break;
  }
}

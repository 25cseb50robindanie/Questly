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

class _ConceptSlide {
  final String title;
  final String dialogue;
  final String keyTakeaway;
  final Widget illustration;

  const _ConceptSlide({
    required this.title,
    required this.dialogue,
    required this.keyTakeaway,
    required this.illustration,
  });
}

class FractionConceptScreen extends StatefulWidget {
  final Activity? activity;

  const FractionConceptScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<FractionConceptScreen> createState() => _FractionConceptScreenState();
}

class _FractionConceptScreenState extends State<FractionConceptScreen> {
  Student? _student;
  Activity? _activeActivity;
  int _currentSlideIndex = 0;
  bool _isCompleted = false;
  bool _isRatios = false;

  // Initialized with safe defaults immediately to prevent any uninitialized state
  List<_ConceptSlide> _slides = [];

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _initSlides();
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
    _isRatios = _activeActivity?.type == 'ratio_concept' ||
        _activeActivity?.id.contains('ratio') == true;
    
    if (_slides.isEmpty || wasRatios != _isRatios) {
      _initSlides();
    }
  }

  void _initSlides() {
    if (!_isRatios) {
      // Quest 1: Fractions Story & Concept Slides
      _slides = [
        _ConceptSlide(
          title: 'The Great Canyon Feast',
          dialogue: 'Welcome adventurer! Nova and Dendy baked a giant magical pizza to celebrate our quest. But to share it equally, we must divide the whole into equal pieces!',
          keyTakeaway: 'A Fraction represents equal parts of a whole.',
          illustration: const PizzaVisualWidget(totalSlices: 4, selectedSlices: 4, size: 120, label: '1 Whole Pizza'),
        ),
        _ConceptSlide(
          title: 'Numerator & Denominator',
          dialogue: 'Look closely at the fraction 3/4:\n• Top Number (Numerator): The 3 slices we eat.\n• Bottom Number (Denominator): The 4 equal slices the whole pizza was cut into.',
          keyTakeaway: 'Top (Numerator) = Parts taken.\nBottom (Denominator) = Total equal parts.',
          illustration: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '3\n—\n4',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 24, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('← Numerator (3 Parts we have)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
                    SizedBox(height: 10),
                    Text('← Denominator (4 Total Parts)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.purple)),
                  ],
                ),
              ],
            ),
          ),
        ),
        _ConceptSlide(
          title: 'The Golden Secret of Denominators',
          dialogue: 'Here is a secret that confuses many adventurers: If you cut a pizza into MORE pieces (like 8 instead of 4), each slice gets SMALLER! So 1/4 is bigger than 1/8!',
          keyTakeaway: 'Larger Denominator = Smaller Individual Slices.',
          illustration: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              PizzaVisualWidget(totalSlices: 4, selectedSlices: 1, size: 85, label: '1/4 (Bigger Slice)'),
              Icon(Icons.arrow_forward_rounded, color: ColorSystem.purple, size: 20),
              PizzaVisualWidget(totalSlices: 8, selectedSlices: 1, size: 85, label: '1/8 (Smaller Slice)'),
            ],
          ),
        ),
        _ConceptSlide(
          title: 'Fractions in the Real World',
          dialogue: 'Fractions are all around us! Half-time in football (1/2), quarter past three on a clock (1/4), or breaking a chocolate bar into squares to share with friends.',
          keyTakeaway: 'Fractions help us share, measure, and build with precision!',
          illustration: const ChocolateBarVisualWidget(totalRows: 2, totalCols: 3, selectedPieces: 3, width: 140, height: 75),
        ),
      ];
    } else {
      // Quest 2: Ratios Story & Concept Slides
      _slides = [
        _ConceptSlide(
          title: 'The Alchemist\'s Recipe',
          dialogue: 'Greetings! Today we explore Ratios. In the kingdom workshop, to make the sweetest health potion, we mix 2 cups of Berry Juice with 3 cups of Sparkle Water!',
          keyTakeaway: 'A Ratio is a comparison between two or more quantities.',
          illustration: const RatioBeakerVisualWidget(partA: 2, partB: 3, labelA: 'Juice', labelB: 'Water'),
        ),
        _ConceptSlide(
          title: 'Ways to Write a Ratio',
          dialogue: 'We can write the ratio of 2 cups juice to 3 cups water in three ways:\n1. With a colon: 2 : 3\n2. With words: 2 to 3\n3. As a fraction: 2/3',
          keyTakeaway: 'All three forms (2:3, 2 to 3, 2/3) mean the exact same relationship!',
          illustration: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.purple, width: 2),
            ),
            child: Column(
              children: const [
                Text('2 : 3', style: TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                Text('2 to 3  •  2/3', style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
              ],
            ),
          ),
        ),
        _ConceptSlide(
          title: 'Order Matters in Ratios!',
          dialogue: 'If we have 3 red apples and 5 yellow bananas, the ratio of Apples to Bananas is 3 : 5. But the ratio of Bananas to Apples is 5 : 3!',
          keyTakeaway: 'Always match the order of words to the order of numbers.',
          illustration: const FruitRatioVisualWidget(countA: 3, countB: 5, labelA: 'Apples', labelB: 'Bananas'),
        ),
        _ConceptSlide(
          title: 'Scaling & Equivalent Ratios',
          dialogue: 'What if we want to make a double batch of our potion? We multiply BOTH ingredients by 2! 2 : 3 becomes 4 : 6. The taste stays identically sweet!',
          keyTakeaway: 'Multiply or divide both terms by the same number to find equivalent ratios.',
          illustration: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              RatioBeakerVisualWidget(partA: 2, partB: 3, height: 95, width: 75),
              Icon(Icons.double_arrow_rounded, color: ColorSystem.purple, size: 20),
              RatioBeakerVisualWidget(partA: 4, partB: 6, height: 95, width: 75),
            ],
          ),
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

  Future<void> _completeConceptLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final student = _student;
    if (student != null) {
      final sId = student.questlyId.toLowerCase();
      final lessonId = _isRatios ? 'ratios_les1' : 'fractions_les1';
      final xp = _activeActivity?.xpReward ?? 40;
      final gold = _activeActivity?.goldReward ?? 5;

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
          currentLessonId: _isRatios ? 'ratios_les2' : 'fractions_les2',
        );
        await Locator.studentRepository.updateStudentProfile(updated);
      } catch (_) {}
    }

    SoundService.playLevelComplete();
    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: _activeActivity?.xpReward ?? 40,
        goldReward: _activeActivity?.goldReward ?? 5,
        earnedStars: 3,
        title: 'CONCEPT DISCOVERED!',
        message: 'You have mastered the core fundamentals! Next up: Visual Understanding!',
        onContinue: () {
          Navigator.pushReplacementNamed(
            context,
            '/fraction_visual',
            arguments: _activeActivity,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) {
      return const Scaffold(
        backgroundColor: ColorSystem.cream,
        body: Center(
          child: CircularProgressIndicator(color: ColorSystem.purple),
        ),
      );
    }

    final safeIndex = _currentSlideIndex.clamp(0, _slides.length - 1);
    final slide = _slides[safeIndex];

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth >= 600;
              final isShortScreen = constraints.maxHeight < 450;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isShortScreen ? 12 : 18,
                  vertical: isShortScreen ? 6 : 12,
                ),
                child: Column(
                  children: [
                    // Header Bar
                    _buildHeader(isShortScreen),
                    SizedBox(height: isShortScreen ? 6 : 10),

                    // Main Card Body
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isShortScreen ? 10 : 16),
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
                            ? _buildLandscapeLayout(slide, isShortScreen)
                            : _buildPortraitLayout(slide),
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

  Widget _buildLandscapeLayout(_ConceptSlide slide, bool isShortScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Story dialogue & takeaway
        Expanded(
          flex: 12,
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
                      'PART ${_currentSlideIndex + 1} OF ${_slides.length}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ),
                  DendySpeakButton(
                    textToSpeak: '${slide.title}. ${slide.dialogue}',
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                slide.title,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isShortScreen ? 16 : 20,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.dialogue,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isShortScreen ? 12 : 13.5,
                          color: ColorSystem.plum.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ColorSystem.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ColorSystem.gold, width: 1.2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: ColorSystem.gold, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                slide.keyTakeaway,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.plum,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const VerticalDivider(width: 24, thickness: 1.5, color: ColorSystem.cream),

        // Right Column: Visual illustration & next/prev navigation
        Expanded(
          flex: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: slide.illustration,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (_currentSlideIndex > 0)
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorSystem.cream,
                          foregroundColor: ColorSystem.plum,
                          elevation: 0,
                          side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: () {
                          SoundService.playClick();
                          setState(() {
                            _currentSlideIndex--;
                          });
                        },
                        child: const Text(
                          'PREVIOUS',
                          style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    const Spacer(flex: 4),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 6,
                    child: CustomButton(
                      text: _currentSlideIndex < _slides.length - 1 ? 'NEXT PART →' : 'FINISH LESSON ✓',
                      backgroundColor: _currentSlideIndex < _slides.length - 1 ? ColorSystem.purple : ColorSystem.green,
                      textColor: Colors.white,
                      height: 38,
                      onPressed: () {
                        SoundService.playClick();
                        if (_currentSlideIndex < _slides.length - 1) {
                          setState(() {
                            _currentSlideIndex++;
                          });
                        } else {
                          _completeConceptLesson();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(_ConceptSlide slide) {
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
                  'PART ${_currentSlideIndex + 1} OF ${_slides.length}',
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
              ),
              DendySpeakButton(textToSpeak: '${slide.title}. ${slide.dialogue}', size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            slide.title,
            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 18, fontWeight: FontWeight.w900, color: ColorSystem.plum),
          ),
          const SizedBox(height: 8),
          Text(
            slide.dialogue,
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, color: ColorSystem.plum.withOpacity(0.9), height: 1.4),
          ),
          const SizedBox(height: 12),
          Center(child: slide.illustration),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorSystem.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.gold, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: ColorSystem.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    slide.keyTakeaway,
                    style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if (_currentSlideIndex > 0) ...[
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorSystem.cream,
                      foregroundColor: ColorSystem.plum,
                      elevation: 0,
                      side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    onPressed: () {
                      SoundService.playClick();
                      setState(() {
                        _currentSlideIndex--;
                      });
                    },
                    child: const Text('PREV', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                flex: 6,
                child: CustomButton(
                  text: _currentSlideIndex < _slides.length - 1 ? 'NEXT PART →' : 'FINISH LESSON ✓',
                  backgroundColor: _currentSlideIndex < _slides.length - 1 ? ColorSystem.purple : ColorSystem.green,
                  textColor: Colors.white,
                  height: 38,
                  onPressed: () {
                    SoundService.playClick();
                    if (_currentSlideIndex < _slides.length - 1) {
                      setState(() {
                        _currentSlideIndex++;
                      });
                    } else {
                      _completeConceptLesson();
                    }
                  },
                ),
              ),
            ],
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
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 10 : 12,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
                Text(
                  'LESSON 1: CONCEPT LEARNING',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 12 : 14,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
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
                Text(
                  '${_student!.xp} XP',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

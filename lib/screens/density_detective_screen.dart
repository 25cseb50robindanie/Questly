import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_chat_panel.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';

/// Reusable Density Tower Liquid Model
class DensityLiquid {
  final String id;
  final String nameKey;
  final double density; // kg/L
  final Color color;
  final Color darkColor;
  final IconData icon;
  final String emoji;

  const DensityLiquid({
    required this.id,
    required this.nameKey,
    required this.density,
    required this.color,
    required this.darkColor,
    required this.icon,
    required this.emoji,
  });
}

const List<DensityLiquid> kDensityLiquids = [
  DensityLiquid(
    id: 'honey',
    nameKey: 'liquid_honey',
    density: 1.42,
    color: Color(0xFFF59E0B),
    darkColor: Color(0xFFB45309),
    icon: Icons.hive_rounded,
    emoji: '🍯',
  ),
  DensityLiquid(
    id: 'water',
    nameKey: 'liquid_water',
    density: 1.00,
    color: Color(0xFF38BDF8),
    darkColor: Color(0xFF0284C7),
    icon: Icons.water_drop_rounded,
    emoji: '💧',
  ),
  DensityLiquid(
    id: 'oil',
    nameKey: 'liquid_oil',
    density: 0.91,
    color: Color(0xFFFDE047),
    darkColor: Color(0xFFCA8A04),
    icon: Icons.opacity_rounded,
    emoji: '🛢️',
  ),
  DensityLiquid(
    id: 'alcohol',
    nameKey: 'liquid_alcohol',
    density: 0.79,
    color: Color(0xFFF472B6),
    darkColor: Color(0xFFDB2777),
    icon: Icons.science_rounded,
    emoji: '🍷',
  ),
];

class DensityDetectiveScreen extends StatefulWidget {
  final Activity? activity;

  const DensityDetectiveScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityDetectiveScreen> createState() => _DensityDetectiveScreenState();
}

class _DensityDetectiveScreenState extends State<DensityDetectiveScreen> with TickerProviderStateMixin {
  Student? _student;

  // Liquids state
  final List<String> _pouredLiquidIds = [];
  final List<String> _settledLiquidIds = [];
  String? _currentlyPouringId;
  bool _isPouring = false;
  bool _isReordering = false;

  // Gamification & Rewards
  int _sessionXp = 0;
  int _sessionCoins = 0;
  bool _perfectPourEarned = false;
  bool _showPerfectPourBadge = false;
  bool _allLayersComplete = false;
  bool _showCompletionModal = false;
  int _glowingLayerIndex = -1;

  // Interactive Rising Bubbles
  final List<_BubbleParticle> _bubbles = [];
  Timer? _bubbleTimer;

  // Adaptive Engine State
  int _attemptCount = 0;
  int _wrongChoiceCount = 0;
  int _supportLevel = 0;
  String? _adaptiveHintMessage;
  bool _showEasyPracticeMode = false;
  final List<String> _easyPracticePoured = [];

  // Floating Dendy Idle Controller
  late AnimationController _dendyFloatController;
  late Animation<double> _dendyFloatAnimation;

  // Continuous Wave & Liquid Surface Controller
  late AnimationController _waveController;

  // Pouring Animation Controller
  late AnimationController _pourAnimationController;

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();

    // Dendy Idle Float
    _dendyFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _dendyFloatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _dendyFloatController, curve: Curves.easeInOut),
    );

    // Wave motion
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Pouring stream controller
    _pourAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Continuous rising bubbles generator
    _bubbleTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_pouredLiquidIds.isNotEmpty && mounted) {
        setState(() {
          _bubbles.add(_BubbleParticle(
            x: 0.2 + math.Random().nextDouble() * 0.6,
            y: 0.85,
            radius: 4.0 + math.Random().nextDouble() * 5.0,
            speed: 0.015 + math.Random().nextDouble() * 0.02,
          ));
          _bubbles.removeWhere((b) => b.y < 0.15 || b.popped);
        });
      }
    });
  }

  @override
  void dispose() {
    _dendyFloatController.dispose();
    _waveController.dispose();
    _pourAnimationController.dispose();
    _bubbleTimer?.cancel();
    super.dispose();
  }

  // --- POUR INTERACTION LOGIC ---

  void _handleBottleTap(DensityLiquid liquid) {
    if (_isPouring || _isReordering || _pouredLiquidIds.contains(liquid.id) || _allLayersComplete) {
      return;
    }

    _attemptCount++;
    SoundService.playClick();

    setState(() {
      _isPouring = true;
      _currentlyPouringId = liquid.id;
    });

    // Check for Perfect Pour (first liquid poured should be heaviest Honey)
    if (_pouredLiquidIds.isEmpty) {
      if (liquid.id == 'honey') {
        _triggerPerfectPour();
      } else {
        _recordMisconception(liquid.id);
      }
    } else {
      // Check relative placement
      final previousLiquid = kDensityLiquids.firstWhere((l) => l.id == _pouredLiquidIds.last);
      if (liquid.density > previousLiquid.density) {
        // Poured heavier liquid on top -> will trigger sinking observation
        _recordMisconception(liquid.id);
      }
    }

    SoundService.playWaterSplash();
    _pourAnimationController.forward(from: 0.0).then((_) {
      if (!mounted) return;

      setState(() {
        _isPouring = false;
        _pouredLiquidIds.add(liquid.id);
        _settledLiquidIds.add(liquid.id);
      });

      // Animate Sinking / Floating Reordering
      _animateLiquidSettling();
    });
  }

  void _triggerPerfectPour() {
    _perfectPourEarned = true;
    _sessionXp += 5;
    SoundService.playCorrect();
    setState(() {
      _showPerfectPourBadge = true;
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showPerfectPourBadge = false;
        });
      }
    });
  }

  void _animateLiquidSettling() {
    setState(() {
      _isReordering = true;
    });

    SoundService.playBubble();

    // Settle into natural relative density order (highest density at bottom)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      setState(() {
        _settledLiquidIds.sort((a, b) {
          final da = kDensityLiquids.firstWhere((l) => l.id == a).density;
          final db = kDensityLiquids.firstWhere((l) => l.id == b).density;
          return db.compareTo(da); // Descending (heaviest at index 0 = bottom)
        });
        _isReordering = false;
      });

      // Check if all 4 liquids are poured
      if (_settledLiquidIds.length == kDensityLiquids.length) {
        _triggerSequentialLayerGlow();
      }
    });
  }

  void _triggerSequentialLayerGlow() async {
    setState(() {
      _allLayersComplete = true;
    });

    SoundService.playDiscoveryMoment();

    // Sequential layer glow bottom to top: Honey -> Water -> Oil -> Alcohol
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() {
        _glowingLayerIndex = i;
      });
      SoundService.playPop();
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;
    setState(() {
      _glowingLayerIndex = -1;
      _showCompletionModal = true;
    });

    _saveLesson4Completion();
  }

  Future<void> _saveLesson4Completion() async {
    SoundService.playAchievementUnlocked();
    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Progress
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les4',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: _attemptCount > 0 ? _attemptCount : 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Mark storage keys
      await Locator.storageService.setBool('lesson4Completed', true);
      await Locator.storageService.setBool('lesson_comp_${sId}_density_les4', true);
      await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les5', true);

      // 3. Award XP (+80 + Perfect Pour bonus) & Coins (+15)
      final totalXpGained = 80 + (_perfectPourEarned ? 5 : 0);
      _sessionXp = totalXpGained;
      _sessionCoins = 15;

      final updated = _student!.copyWith(
        xp: _student!.xp + totalXpGained,
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
  }

  // --- ADAPTIVE ENGINE ---

  void _recordMisconception(String liquidId) {
    _wrongChoiceCount++;
    if (_wrongChoiceCount == 1) {
      // Mistake 1: "Watch where it settles."
      _supportLevel = 1;
      SoundService.playHintReveal();
      setState(() {
        _adaptiveHintMessage = l('dt_hint_mistake1');
      });
    } else if (_wrongChoiceCount == 2) {
      // Mistake 2: "The heavier liquid settles lower."
      _supportLevel = 2;
      SoundService.playDiscoveryMoment();
      setState(() {
        _adaptiveHintMessage = l('dt_hint_mistake2');
      });
    } else if (_wrongChoiceCount >= 3) {
      // Mistake 3: Easy Practice Mode with just 2 liquids (Water & Oil)
      _supportLevel = 3;
      SoundService.playSupportUnlocked();
      setState(() {
        _showEasyPracticeMode = true;
        _easyPracticePoured.clear();
      });
    }
  }

  void _resetTower() {
    SoundService.playClick();
    setState(() {
      _pouredLiquidIds.clear();
      _settledLiquidIds.clear();
      _currentlyPouringId = null;
      _isPouring = false;
      _isReordering = false;
      _allLayersComplete = false;
      _showCompletionModal = false;
      _adaptiveHintMessage = null;
      _bubbles.clear();
    });
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap');
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
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isShort ? 12 : 20,
                  vertical: isShort ? 6 : 10,
                ),
                child: Column(
                  children: [
                    // Top Header Bar
                    _buildHeaderBar(isShort),
                    SizedBox(height: isShort ? 4 : 8),

                    // Dendy Dialogue & Instruction Guide Banner
                    _buildDendyGuideBanner(isShort),
                    SizedBox(height: isShort ? 6 : 10),

                    // Main Laboratory Stage: Cylinder + Pouring Stream + Bottles
                    Expanded(
                      child: Row(
                        children: [
                          // Left side: Science Cylinder & Pouring Physics
                          Expanded(
                            flex: 6,
                            child: _buildCylinderStage(isShort),
                          ),

                          // Right side: Liquid Bottles Shelf
                          Expanded(
                            flex: 5,
                            child: _buildLiquidBottlesShelf(isShort),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Single Floating Dendy Companion (Bottom-Right Corner)
              _buildFloatingDendyCompanion(isShort),

              // Perfect Pour Bonus Overlay Badge
              if (_showPerfectPourBadge) _buildPerfectPourOverlay(),

              // Easy Practice Mode Modal (2 liquids scaffolding)
              if (_showEasyPracticeMode) _buildEasyPracticeModal(isShort),

              // Final Layer Master Celebration Modal
              if (_showCompletionModal) _buildCompletionModal(isShort),
            ],
          ),
        ),
      ),
    );
  }

  // --- TOP HEADER BAR ---

  Widget _buildHeaderBar(bool isShort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: _handleReturn,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 20),
          ),
        ),

        // Lesson Title Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorSystem.purple.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_rounded, color: ColorSystem.purple, size: 16),
              const SizedBox(width: 6),
              Text(
                '${l('lesson')} 4 ${l('of')} 5 • ${l('density_tower_title').toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),

        // XP & Coins Counter Row
        Row(
          children: [
            // Coins Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorSystem.gold, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: ColorSystem.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${(_student?.gold ?? 0) + _sessionCoins}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // XP Counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorSystem.purple, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: ColorSystem.gold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${(_student?.xp ?? 0) + _sessionXp} XP',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- DENDY GUIDE BANNER ---

  Widget _buildDendyGuideBanner(bool isShort) {
    final String currentPrompt = _adaptiveHintMessage ??
        (_pouredLiquidIds.isEmpty
            ? l('dt_prompt_intro')
            : (_isReordering ? l('dt_prompt_settling') : l('density_tower_desc')));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: isShort ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l('density_tower_title').toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentPrompt,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 10.5 : 12,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DendySpeakButton(textToSpeak: currentPrompt, size: 18),
        ],
      ),
    );
  }

  // --- SCIENCE CYLINDER STAGE ---

  Widget _buildCylinderStage(bool isShort) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Graduated Cylinder
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(isShort ? 140 : 170, isShort ? 220 : 270),
                painter: _DensityCylinderPainter(
                  settledLiquidIds: _settledLiquidIds,
                  wavePhase: _waveController.value * 2 * math.pi,
                  glowingLayerIndex: _glowingLayerIndex,
                  isReordering: _isReordering,
                ),
              );
            },
          ),

          // Pouring Stream Animation
          if (_isPouring && _currentlyPouringId != null)
            Positioned(
              top: 20,
              child: AnimatedBuilder(
                animation: _pourAnimationController,
                builder: (context, child) {
                  final liquid = kDensityLiquids.firstWhere((l) => l.id == _currentlyPouringId);
                  return CustomPaint(
                    size: const Size(60, 120),
                    painter: _PourStreamPainter(
                      progress: _pourAnimationController.value,
                      color: liquid.color,
                    ),
                  );
                },
              ),
            ),

          // Interactive Tap-to-Pop Rising Bubbles
          ..._bubbles.map((bubble) {
            return Positioned(
              left: 30 + bubble.x * 120,
              top: 40 + bubble.y * 180,
              child: GestureDetector(
                onTap: () {
                  SoundService.playPop();
                  setState(() {
                    bubble.popped = true;
                  });
                },
                child: Container(
                  width: bubble.radius * 2,
                  height: bubble.radius * 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            );
          }),

          // Empty cylinder hint
          if (_settledLiquidIds.isEmpty)
            Center(
              child: Text(
                l('empty_cylinder'),
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: ColorSystem.plum.withOpacity(0.4),
                ),
              ),
            ),

          // Reset Button
          if (_settledLiquidIds.isNotEmpty && !_allLayersComplete)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: _resetTower,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorSystem.cream,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh_rounded, size: 13, color: ColorSystem.plum),
                      const SizedBox(width: 4),
                      Text(
                        l('dt_reset'),
                        style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.plum),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- LIQUID BOTTLES SHELF ---

  Widget _buildLiquidBottlesShelf(bool isShort) {
    return Container(
      padding: EdgeInsets.all(isShort ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shelf Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l('dt_tap_to_pour').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                ),
              ),
              Text(
                '${_pouredLiquidIds.length} / 4 Poured',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: ColorSystem.plum.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: isShort ? 6 : 10),

          // 4 Bottle Cards
          Expanded(
            child: ListView.separated(
              itemCount: kDensityLiquids.length,
              separatorBuilder: (context, index) => SizedBox(height: isShort ? 6 : 8),
              itemBuilder: (context, index) {
                final liquid = kDensityLiquids[index];
                final bool isPoured = _pouredLiquidIds.contains(liquid.id);
                final bool isCurrentlyPouring = _currentlyPouringId == liquid.id;

                return GestureDetector(
                  onTap: () => _handleBottleTap(liquid),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: isShort ? 6 : 8),
                    decoration: BoxDecoration(
                      color: isPoured ? Colors.grey.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentlyPouring
                            ? liquid.color
                            : (isPoured ? Colors.grey.shade300 : liquid.color.withOpacity(0.6)),
                        width: isCurrentlyPouring ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        if (!isPoured)
                          BoxShadow(
                            color: liquid.color.withOpacity(0.18),
                            offset: const Offset(0, 3),
                            blurRadius: 3,
                          ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Bottle Graphic Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: isCurrentlyPouring
                              ? (Matrix4.identity()..rotateZ(-0.4)..translate(0.0, -4.0))
                              : Matrix4.identity(),
                          width: isShort ? 32 : 38,
                          height: isShort ? 32 : 38,
                          decoration: BoxDecoration(
                            color: isPoured ? Colors.grey.shade300 : liquid.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isPoured ? Colors.grey : liquid.darkColor, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              liquid.emoji,
                              style: TextStyle(fontSize: isShort ? 16 : 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l(liquid.nameKey),
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: isShort ? 12 : 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isPoured ? Colors.grey : ColorSystem.plum,
                                ),
                              ),
                              Text(
                                '${liquid.density.toStringAsFixed(2)} kg/L',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 9.5,
                                  color: isPoured ? Colors.grey : ColorSystem.plum.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Indicator
                        if (isPoured)
                          const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 18)
                        else
                          Icon(Icons.arrow_forward_ios_rounded, color: liquid.darkColor, size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- FLOATING DENDY COMPANION (SINGLE PERSISTENT BUTTON) ---

  Widget _buildFloatingDendyCompanion(bool isShort) {
    return Positioned(
      bottom: isShort ? 8 : 16,
      right: isShort ? 8 : 16,
      child: AnimatedBuilder(
        animation: _dendyFloatAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _dendyFloatAnimation.value),
            child: child,
          );
        },
        child: GestureDetector(
          onTap: () {
            SoundService.playClick();
            DendyChatPanel.open(context);
          },
          child: Container(
            width: isShort ? 46 : 56,
            height: isShort ? 46 : 56,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ColorSystem.purple, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.purple.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: DendyMascot(
                state: DendyState.idle,
                mood: DendyMood.explaining,
                size: 38,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- PERFECT POUR OVERLAY BADGE ---

  Widget _buildPerfectPourOverlay() {
    return Positioned(
      top: 90,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: ColorSystem.gold,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.gold.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                l('dt_perfect_pour'),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- EASY PRACTICE MODE MODAL (2 LIQUIDS SCAFFOLDING) ---

  Widget _buildEasyPracticeModal(bool isShort) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.gold, width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l('dt_easy_practice_title').toUpperCase(),
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                const SizedBox(height: 4),
                Text(
                  l('dt_easy_practice_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Water Card
                    GestureDetector(
                      onTap: () {
                        SoundService.playPop();
                        setState(() {
                          if (!_easyPracticePoured.contains('water')) _easyPracticePoured.add('water');
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _easyPracticePoured.contains('water') ? const Color(0xFF38BDF8).withOpacity(0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text('💧', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(l('liquid_water'), style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    // Oil Card
                    GestureDetector(
                      onTap: () {
                        SoundService.playPop();
                        setState(() {
                          if (!_easyPracticePoured.contains('oil')) _easyPracticePoured.add('oil');
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _easyPracticePoured.contains('oil') ? const Color(0xFFFDE047).withOpacity(0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFCA8A04), width: 2),
                        ),
                        child: Column(
                          children: [
                            const Text('🛢️', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(l('liquid_oil'), style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_easyPracticePoured.length >= 2)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: l('adapt_wildcard_continue').toUpperCase(),
                      backgroundColor: ColorSystem.purple,
                      textColor: Colors.white,
                      height: 38,
                      onPressed: () {
                        SoundService.playContinue();
                        setState(() {
                          _showEasyPracticeMode = false;
                          _supportLevel = 0;
                          _wrongChoiceCount = 0;
                          _adaptiveHintMessage = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FINAL COMPLETION MODAL ---

  Widget _buildCompletionModal(bool isShort) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65),
        child: Center(
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.gold, width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DendyMascot(state: DendyState.success, size: 54),
                const SizedBox(height: 8),

                // Layer Master Badge Sticker
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.gold, width: 1.5),
                  ),
                  child: Text(
                    l('dt_layer_master').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  l('dt_complete_title'),
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                const SizedBox(height: 4),
                Text(
                  l('dt_complete_msg'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),

                // Rewards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorSystem.cream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: ColorSystem.gold, size: 18),
                      const SizedBox(width: 4),
                      Text('+${_sessionXp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                      const SizedBox(width: 14),
                      const Icon(Icons.monetization_on_rounded, color: ColorSystem.gold, size: 16),
                      const SizedBox(width: 4),
                      Text('+${_sessionCoins} Coins', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: l('dt_btn_continue_les5').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    height: 40,
                    onPressed: () {
                      SoundService.playClick();
                      Navigator.pushReplacementNamed(context, '/density_teach_back');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- PARTICLES & CUSTOM PAINTERS ---

class _BubbleParticle {
  double x;
  double y;
  double radius;
  double speed;
  bool popped = false;

  _BubbleParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });
}

class _DensityCylinderPainter extends CustomPainter {
  final List<String> settledLiquidIds;
  final double wavePhase;
  final int glowingLayerIndex;
  final bool isReordering;

  _DensityCylinderPainter({
    required this.settledLiquidIds,
    required this.wavePhase,
    required this.glowingLayerIndex,
    required this.isReordering,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double padX = 14.0;
    final double cylinderTop = 20.0;
    final double cylinderBottom = size.height - 20.0;
    final double cylinderLeft = padX;
    final double cylinderRight = size.width - padX;
    final double cylinderWidth = cylinderRight - cylinderLeft;
    final double cylinderHeight = cylinderBottom - cylinderTop;

    // Draw Cylinder Glass Body Background
    final glassRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cylinderLeft, cylinderTop, cylinderWidth, cylinderHeight),
      const Radius.circular(16),
    );

    final glassBg = Paint()..color = const Color(0xFFF1F5F9).withOpacity(0.5);
    canvas.drawRRect(glassRect, glassBg);

    // Draw Liquid Layers (from bottom upward)
    final int count = settledLiquidIds.length;
    if (count > 0) {
      final double layerHeight = cylinderHeight / 4.0; // 4 layers total capacity

      for (int i = 0; i < count; i++) {
        final liquidId = settledLiquidIds[i];
        final liquid = kDensityLiquids.firstWhere((l) => l.id == liquidId);

        final double layerBottom = cylinderBottom - (i * layerHeight);
        final double layerTop = layerBottom - layerHeight;

        final isGlowing = glowingLayerIndex == i;

        // Wave path on top of layer
        final path = Path();
        path.moveTo(cylinderLeft, layerBottom);
        path.lineTo(cylinderRight, layerBottom);
        path.lineTo(cylinderRight, layerTop);

        // Sinusoidal top surface wave
        for (double x = cylinderRight; x >= cylinderLeft; x -= 6) {
          final double y = layerTop + math.sin(wavePhase + (x * 0.05) + i) * (isReordering ? 3.0 : 1.5);
          path.lineTo(x, y);
        }
        path.close();

        final layerPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isGlowing
                ? [Colors.white, liquid.color]
                : [liquid.color.withOpacity(0.9), liquid.darkColor.withOpacity(0.95)],
          ).createShader(Rect.fromLTWH(cylinderLeft, layerTop, cylinderWidth, layerHeight));

        canvas.drawPath(path, layerPaint);

        // Layer Name Label in Center
        final textSpan = TextSpan(
          text: '${liquid.nameKey.replaceAll('liquid_', '').toUpperCase()} (${liquid.density.toStringAsFixed(2)})',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.black.withOpacity(0.75),
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, Offset(cylinderLeft + (cylinderWidth - tp.width) / 2, layerTop + (layerHeight - tp.height) / 2));
      }
    }

    // Draw Measurement Ticks on Left Side
    final tickPaint = Paint()
      ..color = ColorSystem.plum.withOpacity(0.4)
      ..strokeWidth = 1.5;

    for (int t = 1; t <= 8; t++) {
      final double ty = cylinderBottom - (t * (cylinderHeight / 8.0));
      final double tickLen = (t % 2 == 0) ? 12.0 : 6.0;
      canvas.drawLine(Offset(cylinderLeft, ty), Offset(cylinderLeft + tickLen, ty), tickPaint);
    }

    // Draw Glass Border & Base
    final borderPaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(glassRect, borderPaint);

    // Cylinder Heavy Base
    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cylinderLeft - 10, cylinderBottom, cylinderWidth + 20, 12),
      const Radius.circular(6),
    );
    canvas.drawRRect(baseRect, Paint()..color = ColorSystem.plum);
  }

  @override
  bool shouldRepaint(covariant _DensityCylinderPainter oldDelegate) => true;
}

class _PourStreamPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PourStreamPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final streamPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final double streamHeight = size.height * progress;

    final path = Path();
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width * 0.6, 0);
    path.lineTo(size.width * 0.55, streamHeight);
    path.lineTo(size.width * 0.45, streamHeight);
    path.close();

    canvas.drawPath(path, streamPaint);

    // Droplets
    if (progress > 0.3) {
      canvas.drawCircle(Offset(size.width * 0.5, streamHeight + 4), 3.0, streamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PourStreamPainter oldDelegate) => true;
}

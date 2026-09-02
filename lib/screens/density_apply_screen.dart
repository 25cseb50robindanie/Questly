import 'dart:async';
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

enum ApplyMissionId { boat, oil, treasure, factory }

class DensityApplyScreen extends StatefulWidget {
  final Activity? activity;

  const DensityApplyScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityApplyScreen> createState() => _DensityApplyScreenState();
}

class _DensityApplyScreenState extends State<DensityApplyScreen> with TickerProviderStateMixin {
  Student? _student;
  ApplyMissionId? _activeMission;
  final Set<ApplyMissionId> _completedMissions = {};

  int _sessionXp = 0;
  int _sessionCoins = 0;
  bool _isFinalCelebrationShown = false;

  // Floating Dendy Idle Animation
  late AnimationController _dendyFloatController;
  late Animation<double> _dendyFloatAnimation;

  // Wave & Physics Animation Controller
  late AnimationController _waveController;

  // Shared Adaptive Engine State
  int _attemptCount = 0;
  int _wrongChoiceCount = 0;
  int _supportLevel = 0;
  String? _adaptiveHintMessage;
  bool _showMiniPracticeOverlay = false;
  bool _miniShipDropped = false;
  bool _miniStoneDropped = false;

  // Mission 1: Save Boat State
  int _boatCrateCount = 6;
  final int _boatSafeCapacity = 3;
  bool _boatMissionCompleted = false;

  // Mission 2: Oil Spill State
  bool _oilCleaned = false;
  String? _oilSelectedTool;
  bool _oilMissionCompleted = false;

  // Mission 3: Treasure Lift State
  int _treasureBalloonCount = 0;
  bool _treasureLiftCompleted = false;
  bool _treasureAutoDemoPlaying = false;

  // Mission 4: Factory Sorting State
  int _factorySortedCount = 0;
  int _factoryCombo = 0;
  int _factoryMaxCombo = 0;
  double _conveyorSpeed = 1.0;
  int _factoryCurrentItemIndex = 0;
  bool _factoryMissionCompleted = false;

  final List<Map<String, dynamic>> _factoryItems = [
    {'name': 'Wood Block', 'density': 0.60, 'floats': true, 'color': Color(0xFFD97706), 'icon': Icons.park_rounded},
    {'name': 'Steel Bolt', 'density': 7.80, 'floats': false, 'color': Color(0xFF64748B), 'icon': Icons.build_rounded},
    {'name': 'Ice Cube', 'density': 0.92, 'floats': true, 'color': Color(0xFF38BDF8), 'icon': Icons.ac_unit_rounded},
    {'name': 'Gold Ingot', 'density': 19.30, 'floats': false, 'color': Color(0xFFF59E0B), 'icon': Icons.monetization_on_rounded},
    {'name': 'Plastic Bottle', 'density': 0.90, 'floats': true, 'color': Color(0xFFEC4899), 'icon': Icons.bubble_chart_rounded},
    {'name': 'Cork Plug', 'density': 0.24, 'floats': true, 'color': Color(0xFFB45309), 'icon': Icons.circle_rounded},
    {'name': 'Iron Wrench', 'density': 7.87, 'floats': false, 'color': Color(0xFF475569), 'icon': Icons.hardware_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();

    // Dendy Idle Floating / Breathing Animation
    _dendyFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _dendyFloatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _dendyFloatController, curve: Curves.easeInOut),
    );

    // Continuous Water Waves & Conveyor movement
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _dendyFloatController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  // --- ADAPTIVE LEARNING ENGINE HELPERS ---

  void _recordAttempt({required bool isCorrect, required String misconceptionPattern}) {
    _attemptCount++;
    if (isCorrect) {
      SoundService.playCorrect();
      _adaptiveHintMessage = null;
      _wrongChoiceCount = 0;
      _supportLevel = 0; // Reset support after student exhibits mastery
    } else {
      _wrongChoiceCount++;
      _detectMisconception(misconceptionPattern);
    }
  }

  void _detectMisconception(String pattern) {
    SoundService.playWrong();
    if (_wrongChoiceCount == 1) {
      // Level 1: Conceptual Hint
      _supportLevel = 1;
      _showConceptHint(pattern);
    } else if (_wrongChoiceCount == 2) {
      // Level 2: Real-world Analogy
      _supportLevel = 2;
      _showRealWorldExample(pattern);
    } else if (_wrongChoiceCount >= 3) {
      // Level 3: Inline Mini Practice Overlay
      _supportLevel = 3;
      _launchMiniPractice();
    }
  }

  void _showConceptHint(String pattern) {
    SoundService.playHintReveal();
    setState(() {
      if (pattern == 'heavy_sinks') {
        _adaptiveHintMessage = l('m1_hint_attempt1');
      } else if (pattern == 'oil_tool') {
        _adaptiveHintMessage = l('m2_wrong1');
      } else if (pattern == 'treasure_weight') {
        _adaptiveHintMessage = l('m3_wrong_rocks');
      } else {
        _adaptiveHintMessage = l('m4_hint');
      }
    });
  }

  void _showRealWorldExample(String pattern) {
    SoundService.playDiscoveryMoment();
    setState(() {
      if (pattern == 'heavy_sinks') {
        _adaptiveHintMessage = l('m1_hint_attempt2');
      } else if (pattern == 'oil_tool') {
        _adaptiveHintMessage = l('m2_wrong2');
      } else if (pattern == 'treasure_weight') {
        _treasureAutoDemoPlaying = true;
        _adaptiveHintMessage = l('m3_success');
      } else {
        _conveyorSpeed = 0.6; // Slow down conveyor to scaffold student
        _adaptiveHintMessage = l('m4_hint');
      }
    });
  }

  void _launchMiniPractice() {
    SoundService.playSupportUnlocked();
    setState(() {
      _showMiniPracticeOverlay = true;
      _miniShipDropped = false;
      _miniStoneDropped = false;
    });
  }

  void _completeMiniPractice() {
    SoundService.playContinue();
    setState(() {
      _showMiniPracticeOverlay = false;
      _supportLevel = 0;
      _wrongChoiceCount = 0;
      _adaptiveHintMessage = null;
    });
  }

  void _completeMission(ApplyMissionId mission, int xp, int coins) {
    if (_completedMissions.contains(mission)) return;

    SoundService.playAchievementUnlocked();
    setState(() {
      _completedMissions.add(mission);
      _sessionXp += xp;
      _sessionCoins += coins;
    });

    // Check if all 4 missions are completed
    if (_completedMissions.length == ApplyMissionId.values.length) {
      _triggerFinalCelebration();
    }
  }

  Future<void> _triggerFinalCelebration() async {
    if (_isFinalCelebrationShown) return;
    _isFinalCelebrationShown = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Lesson 3 Progress with 3 Stars
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les3',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: _attemptCount > 0 ? _attemptCount : 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Mark storage keys
      await Locator.storageService.setBool('lesson3Completed', true);
      await Locator.storageService.setBool('lesson_comp_${sId}_density_les3', true);
      await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les4', true);

      // 3. Award 100 XP and 25 Coins
      final updated = _student!.copyWith(
        xp: _student!.xp + 100,
        gold: _student!.gold + 25,
        currentLessonId: 'density_les4',
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
        });
      }
    }
  }

  void _handleReturn() {
    SoundService.playClick();
    if (_activeMission != null) {
      setState(() {
        _activeMission = null;
        _adaptiveHintMessage = null;
      });
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.pushReplacementNamed(context, '/roadmap');
      }
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
                    // Header Bar
                    _buildHeaderBar(isShort),
                    SizedBox(height: isShort ? 6 : 10),

                    // Content View: Active Mission OR 2x2 Mission Rescue Board
                    Expanded(
                      child: _activeMission == null
                          ? _buildMissionBoardView(isShort)
                          : _buildActiveMissionView(isShort),
                    ),
                  ],
                ),
              ),

              // Single Floating Dendy Companion (Bottom-Right Corner)
              _buildFloatingDendyCompanion(isShort),

              // Mini Practice Overlay (when 3 repeated mistakes happen)
              if (_showMiniPracticeOverlay) _buildMiniPracticeModal(isShort),

              // All 4 Missions Complete Celebration Dialog
              if (_completedMissions.length == ApplyMissionId.values.length && _activeMission == null)
                _buildFinalCelebrationModal(isShort),
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
                '${l('lesson')} 3 ${l('of')} 5 • ${l('apply').toUpperCase()}',
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

  // --- MISSION RESCUE BOARD (2x2 GRID) ---

  Widget _buildMissionBoardView(bool isShort) {
    return Column(
      children: [
        // Title Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            children: [
              Text(
                l('mission_rescue_board').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l('mission_rescue_desc'),
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  color: ColorSystem.plum.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isShort ? 6 : 10),

        // 2x2 Grid of Mission Cards
        Expanded(
          child: Row(
            children: [
              // Column 1
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMissionCard(
                        id: ApplyMissionId.boat,
                        title: l('mission_boat_title'),
                        subtitle: l('mission_boat_sub'),
                        icon: Icons.directions_boat_rounded,
                        accentColor: const Color(0xFF0284C7),
                        xp: 25,
                        coins: 5,
                        isShort: isShort,
                      ),
                    ),
                    SizedBox(height: isShort ? 8 : 12),
                    Expanded(
                      child: _buildMissionCard(
                        id: ApplyMissionId.treasure,
                        title: l('mission_treasure_title'),
                        subtitle: l('mission_treasure_sub'),
                        icon: Icons.inventory_2_rounded,
                        accentColor: const Color(0xFFEAB308),
                        xp: 25,
                        coins: 5,
                        isShort: isShort,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: isShort ? 8 : 12),

              // Column 2
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: _buildMissionCard(
                        id: ApplyMissionId.oil,
                        title: l('mission_oil_title'),
                        subtitle: l('mission_oil_sub'),
                        icon: Icons.water_drop_rounded,
                        accentColor: const Color(0xFFD97706),
                        xp: 20,
                        coins: 5,
                        isShort: isShort,
                      ),
                    ),
                    SizedBox(height: isShort ? 8 : 12),
                    Expanded(
                      child: _buildMissionCard(
                        id: ApplyMissionId.factory,
                        title: l('mission_factory_title'),
                        subtitle: l('mission_factory_sub'),
                        icon: Icons.precision_manufacturing_rounded,
                        accentColor: const Color(0xFF8B5CF6),
                        xp: 30,
                        coins: 10,
                        isShort: isShort,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMissionCard({
    required ApplyMissionId id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required int xp,
    required int coins,
    required bool isShort,
  }) {
    final isDone = _completedMissions.contains(id);

    return GestureDetector(
      onTap: () {
        SoundService.playWhoosh();
        setState(() {
          _activeMission = id;
          _adaptiveHintMessage = null;
          _wrongChoiceCount = 0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(isShort ? 10 : 14),
        decoration: BoxDecoration(
          color: isDone ? Colors.white : Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? ColorSystem.gold : ColorSystem.plum.withOpacity(0.25),
            width: isDone ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDone ? ColorSystem.gold.withOpacity(0.2) : ColorSystem.plum.withOpacity(0.06),
              offset: const Offset(0, 4),
              blurRadius: isDone ? 8 : 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: isShort ? 44 : 52,
              height: isShort ? 44 : 52,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
              ),
              child: Icon(icon, size: isShort ? 24 : 28, color: accentColor),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: isShort ? 13 : 15,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                      ),
                      if (isDone)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: ColorSystem.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 9.5 : 11,
                      color: ColorSystem.plum.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Reward Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorSystem.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+$xp XP',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColorSystem.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '+$coins Coins',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  // --- ACTIVE MISSION ROUTER ---

  Widget _buildActiveMissionView(bool isShort) {
    switch (_activeMission!) {
      case ApplyMissionId.boat:
        return _buildBoatMission(isShort);
      case ApplyMissionId.oil:
        return _buildOilMission(isShort);
      case ApplyMissionId.treasure:
        return _buildTreasureMission(isShort);
      case ApplyMissionId.factory:
        return _buildFactoryMission(isShort);
    }
  }

  // --- MISSION 1: SAVE THE BOAT ---

  Widget _buildBoatMission(bool isShort) {
    final bool isSafe = _boatCrateCount <= _boatSafeCapacity;
    final String currentPrompt = _adaptiveHintMessage ?? (isSafe ? l('m1_success') : l('m1_intro'));

    return Column(
      children: [
        // Dendy Mission Banner
        _buildMissionGuideBanner(
          title: l('mission_boat_title'),
          message: currentPrompt,
          isShort: isShort,
        ),
        SizedBox(height: isShort ? 6 : 10),

        // Live Animated Boat Physics Stage
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Animated Wave Tank with Boat
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _BoatScenePainter(
                            wavePhase: _waveController.value * 2 * math.pi,
                            crateCount: _boatCrateCount,
                            isSafe: isSafe,
                          ),
                        );
                      },
                    ),
                  ),

                  // Cargo Dock on Left / Top
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.brown.shade400, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l('m1_dock'),
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.brown.shade800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${6 - _boatCrateCount} / 3 Crates Unloaded',
                            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Waterline Legend (Safe vs Danger)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSafe ? ColorSystem.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isSafe ? ColorSystem.green : Colors.redAccent, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Icon(isSafe ? Icons.check_circle_rounded : Icons.warning_rounded, size: 14, color: isSafe ? ColorSystem.green : Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(
                            isSafe ? l('m1_safe_line') : l('m1_danger_line'),
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isSafe ? ColorSystem.green : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Crates Control Area at bottom
                  Positioned(
                    bottom: 12,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isSafe) ...[
                          GestureDetector(
                            onTap: () {
                              SoundService.playSliderTick();
                              setState(() {
                                if (_boatCrateCount > 0) {
                                  _boatCrateCount--;
                                }
                                if (_boatCrateCount <= _boatSafeCapacity && !_boatMissionCompleted) {
                                  _boatMissionCompleted = true;
                                  _recordAttempt(isCorrect: true, misconceptionPattern: 'heavy_sinks');
                                  _completeMission(ApplyMissionId.boat, 25, 5);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: ColorSystem.purple,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorSystem.plum.withOpacity(0.2),
                                    offset: const Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.inventory_2_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'TAP TO UNLOAD 1 CARGO CRATE',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorSystem.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'BOAT IS FLOATING SAFELY! (+25 XP)',
                                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            text: l('mission_back_board').toUpperCase(),
                            backgroundColor: ColorSystem.purple,
                            textColor: Colors.white,
                            height: 38,
                            onPressed: () {
                              SoundService.playClick();
                              setState(() {
                                _activeMission = null;
                                _adaptiveHintMessage = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MISSION 2: OIL SPILL RESCUE ---

  Widget _buildOilMission(bool isShort) {
    final String currentPrompt = _adaptiveHintMessage ?? (_oilCleaned ? l('m2_success') : l('m2_intro'));

    final tools = [
      {'name': l('m2_tool_sponge'), 'id': 'sponge', 'icon': Icons.cleaning_services_rounded},
      {'name': l('m2_tool_magnet'), 'id': 'magnet', 'icon': Icons.attractions_rounded},
      {'name': l('m2_tool_skimmer'), 'id': 'skimmer', 'icon': Icons.filter_alt_rounded},
      {'name': l('m2_tool_net'), 'id': 'net', 'icon': Icons.grid_goldenratio_rounded},
    ];

    return Column(
      children: [
        _buildMissionGuideBanner(
          title: l('mission_oil_title'),
          message: currentPrompt,
          isShort: isShort,
        ),
        SizedBox(height: isShort ? 6 : 10),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Ocean with Oil Layer
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _OilScenePainter(
                            wavePhase: _waveController.value * 2 * math.pi,
                            oilCleaned: _oilCleaned,
                          ),
                        );
                      },
                    ),
                  ),

                  // Draggable Tools Tray
                  if (!_oilCleaned)
                    Positioned(
                      bottom: 12,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: tools.map((tool) {
                          return GestureDetector(
                            onTap: () {
                              if (tool['id'] == 'skimmer') {
                                setState(() {
                                  _oilCleaned = true;
                                  _oilMissionCompleted = true;
                                });
                                _recordAttempt(isCorrect: true, misconceptionPattern: 'oil_tool');
                                _completeMission(ApplyMissionId.oil, 20, 5);
                              } else {
                                _recordAttempt(isCorrect: false, misconceptionPattern: 'oil_tool');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ColorSystem.purple, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorSystem.plum.withOpacity(0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(tool['icon'] as IconData, size: 22, color: ColorSystem.purple),
                                  const SizedBox(height: 4),
                                  Text(
                                    tool['name'] as String,
                                    style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 12,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorSystem.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'OIL SPILL CLEANED! (+20 XP)',
                                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            text: l('mission_back_board').toUpperCase(),
                            backgroundColor: ColorSystem.purple,
                            textColor: Colors.white,
                            height: 38,
                            onPressed: () {
                              SoundService.playClick();
                              setState(() {
                                _activeMission = null;
                                _adaptiveHintMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MISSION 3: TREASURE LIFT ---

  Widget _buildTreasureMission(bool isShort) {
    final bool isLifted = _treasureBalloonCount >= 3;
    final String currentPrompt = _adaptiveHintMessage ?? (isLifted ? l('m3_success') : l('m3_intro'));

    return Column(
      children: [
        _buildMissionGuideBanner(
          title: l('mission_treasure_title'),
          message: currentPrompt,
          isShort: isShort,
        ),
        SizedBox(height: isShort ? 6 : 10),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Deep Underwater Scene with Treasure Chest & Balloons
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _TreasureScenePainter(
                            wavePhase: _waveController.value * 2 * math.pi,
                            balloonCount: _treasureBalloonCount,
                          ),
                        );
                      },
                    ),
                  ),

                  // Balloons Counter Badge
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.gold, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.bubble_chart_rounded, color: Colors.pinkAccent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Balloons: $_treasureBalloonCount / 3',
                            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Actions Panel
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isLifted) ...[
                          // Action 1: Attach Balloon (Correct)
                          GestureDetector(
                            onTap: () {
                              SoundService.playPop();
                              setState(() {
                                _treasureBalloonCount++;
                                if (_treasureBalloonCount >= 3 && !_treasureLiftCompleted) {
                                  _treasureLiftCompleted = true;
                                  _recordAttempt(isCorrect: true, misconceptionPattern: 'treasure_weight');
                                  _completeMission(ApplyMissionId.treasure, 25, 5);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: ColorSystem.purple,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorSystem.plum.withOpacity(0.2),
                                    offset: const Offset(0, 2),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    l('m3_action_balloon').toUpperCase(),
                                    style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action 2: Add Rocks (Wrong choice -> demonstrates weight sink)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_treasureBalloonCount > 0) _treasureBalloonCount--;
                              });
                              _recordAttempt(isCorrect: false, misconceptionPattern: 'treasure_weight');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle_rounded, color: Colors.grey, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    l('m3_action_rocks').toUpperCase(),
                                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Action 3: Push Down
                          GestureDetector(
                            onTap: () {
                              _recordAttempt(isCorrect: false, misconceptionPattern: 'treasure_weight');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l('m3_action_push').toUpperCase(),
                                style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                              ),
                            ),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: ColorSystem.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'TREASURE LIFTED TO SURFACE! (+25 XP)',
                                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          CustomButton(
                            text: l('mission_back_board').toUpperCase(),
                            backgroundColor: ColorSystem.purple,
                            textColor: Colors.white,
                            height: 38,
                            onPressed: () {
                              SoundService.playClick();
                              setState(() {
                                _activeMission = null;
                                _adaptiveHintMessage = null;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MISSION 4: FACTORY SORTING (ARCADE MODE) ---

  Widget _buildFactoryMission(bool isShort) {
    final String currentPrompt = _adaptiveHintMessage ?? (_factorySortedCount >= 6 ? l('m4_success') : l('m4_intro'));
    final currentItem = _factoryItems[_factoryCurrentItemIndex % _factoryItems.length];

    return Column(
      children: [
        _buildMissionGuideBanner(
          title: '${l('mission_factory_title')} (Score: $_factorySortedCount/6)',
          message: currentPrompt,
          isShort: isShort,
        ),
        SizedBox(height: isShort ? 6 : 10),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2),
            ),
            child: Column(
              children: [
                // Combo & Speed Metric Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _factoryCombo > 2 ? ColorSystem.gold.withOpacity(0.2) : ColorSystem.cream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _factoryCombo > 2 ? '🔥 ${l('m4_perfect')} (${_factoryCombo}x)' : '${l('m4_combo')}: ${_factoryCombo}x',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _factoryCombo > 2 ? ColorSystem.plum : ColorSystem.purple,
                        ),
                      ),
                    ),
                    Text(
                      'Speed: ${_conveyorSpeed.toStringAsFixed(1)}x',
                      style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.bold, color: ColorSystem.plum),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Active Conveyor Object Card
                if (_factorySortedCount < 6)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 140,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (currentItem['color'] as Color).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: currentItem['color'] as Color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: ColorSystem.plum.withOpacity(0.08),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(currentItem['icon'] as IconData, size: 36, color: currentItem['color'] as Color),
                            const SizedBox(height: 6),
                            Text(
                              currentItem['name'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(currentItem['density'] as double).toStringAsFixed(2)} kg/L',
                              style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 48),
                          const SizedBox(height: 8),
                          const Text(
                            'FACTORY SORTING COMPLETE! (+30 XP) 🌟',
                            style: TextStyle(fontFamily: 'Fredoka', fontSize: 15, fontWeight: FontWeight.w900, color: ColorSystem.green),
                          ),
                          const SizedBox(height: 14),
                          CustomButton(
                            text: l('mission_back_board').toUpperCase(),
                            backgroundColor: ColorSystem.purple,
                            textColor: Colors.white,
                            height: 38,
                            onPressed: () {
                              SoundService.playClick();
                              setState(() {
                                _activeMission = null;
                                _adaptiveHintMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // 2 Bins: FLOAT & SINK
                if (_factorySortedCount < 6)
                  Row(
                    children: [
                      // FLOAT BIN
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (currentItem['floats'] as bool) {
                              _handleFactoryItemSorted(true);
                            } else {
                              _handleFactoryItemSorted(false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF38BDF8),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorSystem.plum.withOpacity(0.15),
                                  offset: const Offset(0, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                l('m4_bin_float'),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // SINK BIN
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!(currentItem['floats'] as bool)) {
                              _handleFactoryItemSorted(true);
                            } else {
                              _handleFactoryItemSorted(false);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0369A1),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: ColorSystem.plum.withOpacity(0.15),
                                  offset: const Offset(0, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                l('m4_bin_sink'),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleFactoryItemSorted(bool isCorrect) {
    if (isCorrect) {
      _recordAttempt(isCorrect: true, misconceptionPattern: 'density_sort');
      setState(() {
        _factorySortedCount++;
        _factoryCombo++;
        _factoryCurrentItemIndex++;
        if (_factoryCombo > 2) {
          _conveyorSpeed = 1.3; // Speed up conveyor for good performance
        }
        if (_factorySortedCount >= 6 && !_factoryMissionCompleted) {
          _factoryMissionCompleted = true;
          _completeMission(ApplyMissionId.factory, 30, 10);
        }
      });
    } else {
      _recordAttempt(isCorrect: false, misconceptionPattern: 'density_sort');
      setState(() {
        _factoryCombo = 0;
      });
    }
  }

  // --- MISSION GUIDE BANNER ---

  Widget _buildMissionGuideBanner({
    required String title,
    required String message,
    required bool isShort,
  }) {
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
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 10.5 : 11.5,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DendySpeakButton(textToSpeak: message, size: 18),
        ],
      ),
    );
  }

  // --- MINI PRACTICE OVERLAY MODAL ---

  Widget _buildMiniPracticeModal(bool isShort) {
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
                  l('mini_practice_title').toUpperCase(),
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                const SizedBox(height: 4),
                Text(
                  l('mini_practice_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          SoundService.playCorrect();
                          setState(() {
                            _miniShipDropped = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _miniShipDropped ? ColorSystem.green.withOpacity(0.15) : ColorSystem.cream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _miniShipDropped ? ColorSystem.green : ColorSystem.plum.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.directions_boat_rounded, size: 24, color: ColorSystem.purple),
                              const SizedBox(height: 4),
                              Text(l('ship_floats'), style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          SoundService.playCorrect();
                          setState(() {
                            _miniStoneDropped = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _miniStoneDropped ? ColorSystem.pink.withOpacity(0.15) : ColorSystem.cream,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _miniStoneDropped ? ColorSystem.pink : ColorSystem.plum.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.circle_rounded, size: 24, color: ColorSystem.plum),
                              const SizedBox(height: 4),
                              Text(l('stone_sinks'), style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_miniShipDropped && _miniStoneDropped)
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: l('adapt_wildcard_continue').toUpperCase(),
                      backgroundColor: ColorSystem.purple,
                      textColor: Colors.white,
                      height: 36,
                      onPressed: _completeMiniPractice,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FINAL CELEBRATION MODAL ---

  Widget _buildFinalCelebrationModal(bool isShort) {
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
                Text(
                  l('l3_all_complete_title'),
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.purple),
                ),
                const SizedBox(height: 4),
                Text(
                  l('l3_all_complete_msg'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, color: ColorSystem.plum),
                ),
                const SizedBox(height: 12),

                // Total Rewards
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: ColorSystem.cream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: ColorSystem.gold, size: 18),
                      SizedBox(width: 4),
                      Text('+100 XP', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                      SizedBox(width: 14),
                      Icon(Icons.monetization_on_rounded, color: ColorSystem.gold, size: 16),
                      SizedBox(width: 4),
                      Text('+25 Coins', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: l('l3_btn_continue_les4').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    height: 40,
                    onPressed: () {
                      SoundService.playClick();
                      Navigator.pushReplacementNamed(context, '/density_detective');
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

// --- CUSTOM SCENE PAINTERS ---

class _BoatScenePainter extends CustomPainter {
  final double wavePhase;
  final int crateCount;
  final bool isSafe;

  _BoatScenePainter({
    required this.wavePhase,
    required this.crateCount,
    required this.isSafe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double waterSurfaceY = size.height * 0.55;

    // Draw Water
    final waterPath = Path();
    waterPath.moveTo(0, waterSurfaceY);
    for (double x = 0; x <= size.width; x += 10) {
      final y = waterSurfaceY + math.sin(wavePhase + (x * 0.03)) * 4.0;
      waterPath.lineTo(x, y);
    }
    waterPath.lineTo(size.width, size.height);
    waterPath.lineTo(0, size.height);
    waterPath.close();

    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
      ).createShader(Rect.fromLTWH(0, waterSurfaceY, size.width, size.height - waterSurfaceY));

    canvas.drawPath(waterPath, waterPaint);

    // Boat Position Calculation (Continuous Offset based on crate weight)
    final double boatCenterY = waterSurfaceY + (crateCount * 7.0) - 20.0;
    final double boatCenterX = size.width * 0.55;

    // Danger / Safe Waterline line
    final dangerPaint = Paint()
      ..color = isSafe ? ColorSystem.green : Colors.redAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.35, waterSurfaceY), Offset(size.width * 0.75, waterSurfaceY), dangerPaint);

    // Draw Wooden Boat Hull
    final hullPath = Path();
    hullPath.moveTo(boatCenterX - 60, boatCenterY);
    hullPath.lineTo(boatCenterX - 45, boatCenterY + 32);
    hullPath.lineTo(boatCenterX + 45, boatCenterY + 32);
    hullPath.lineTo(boatCenterX + 60, boatCenterY);
    hullPath.close();

    final hullPaint = Paint()..color = const Color(0xFF854D0E);
    canvas.drawPath(hullPath, hullPaint);

    // Draw Crates on Boat
    final cratePaint = Paint()..color = const Color(0xFFD97706);
    final crateBorder = Paint()
      ..color = const Color(0xFF78350F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 0; i < crateCount; i++) {
      final double cx = (boatCenterX - 35) + (i % 3) * 24;
      final double cy = (boatCenterY - 16) - (i ~/ 3) * 18;
      final rect = Rect.fromLTWH(cx, cy, 20, 16);
      canvas.drawRect(rect, cratePaint);
      canvas.drawRect(rect, crateBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _BoatScenePainter oldDelegate) => true;
}

class _OilScenePainter extends CustomPainter {
  final double wavePhase;
  final bool oilCleaned;

  _OilScenePainter({required this.wavePhase, required this.oilCleaned});

  @override
  void paint(Canvas canvas, Size size) {
    final double waterSurfaceY = size.height * 0.50;

    // Draw Ocean Water
    final waterPath = Path();
    waterPath.moveTo(0, waterSurfaceY);
    for (double x = 0; x <= size.width; x += 10) {
      final y = waterSurfaceY + math.sin(wavePhase + (x * 0.03)) * 4.0;
      waterPath.lineTo(x, y);
    }
    waterPath.lineTo(size.width, size.height);
    waterPath.lineTo(0, size.height);
    waterPath.close();

    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF38BDF8), Color(0xFF0369A1)],
      ).createShader(Rect.fromLTWH(0, waterSurfaceY, size.width, size.height - waterSurfaceY));

    canvas.drawPath(waterPath, waterPaint);

    // Draw Floating Golden Oil Patch (less dense, sits on surface)
    if (!oilCleaned) {
      final oilPaint = Paint()
        ..color = const Color(0xFFCA8A04).withOpacity(0.85)
        ..style = PaintingStyle.fill;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, waterSurfaceY + 2),
          width: size.width * 0.6,
          height: 18,
        ),
        oilPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OilScenePainter oldDelegate) => true;
}

class _TreasureScenePainter extends CustomPainter {
  final double wavePhase;
  final int balloonCount;

  _TreasureScenePainter({required this.wavePhase, required this.balloonCount});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Deep underwater gradient background with light rays
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0284C7), Color(0xFF075985), Color(0xFF082F49)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Sun rays filtering down
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    final rayPath = Path();
    rayPath.moveTo(size.width * 0.2, 0);
    rayPath.lineTo(size.width * 0.35, 0);
    rayPath.lineTo(size.width * 0.55, size.height);
    rayPath.lineTo(size.width * 0.35, size.height);
    rayPath.close();
    canvas.drawPath(rayPath, rayPaint);

    // 2. Sandy Seabed (positioned at size.height - 70 so it stays above bottom buttons)
    final double seabedY = size.height - 68.0;

    final sandPath = Path();
    sandPath.moveTo(0, seabedY);
    for (double x = 0; x <= size.width; x += 15) {
      final double y = seabedY + math.sin((x * 0.02) + 1.2) * 5.0;
      sandPath.lineTo(x, y);
    }
    sandPath.lineTo(size.width, size.height);
    sandPath.lineTo(0, size.height);
    sandPath.close();

    final sandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD97706), Color(0xFF92400E)],
      ).createShader(Rect.fromLTWH(0, seabedY, size.width, size.height - seabedY));
    canvas.drawPath(sandPath, sandPaint);

    // Green Seaweeds on seabed
    final weedPaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.7)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int w = 0; w < 4; w++) {
      final double wx = size.width * (0.12 + (w * 0.24));
      final double sway = math.sin(wavePhase + w) * 6.0;
      final weedPath = Path();
      weedPath.moveTo(wx, seabedY + 4);
      weedPath.quadraticBezierTo(wx + sway, seabedY - 18, wx - sway * 0.5, seabedY - 36);
      canvas.drawPath(weedPath, weedPaint);
    }

    // 3. Floating Ambient Bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int b = 0; b < 6; b++) {
      final double bx = size.width * (0.18 + (b * 0.14));
      final double by = (seabedY - 20) - ((wavePhase * 25.0 + b * 40.0) % (seabedY - 30));
      canvas.drawCircle(Offset(bx, by), 3.0 + (b % 3), bubblePaint);
    }

    // 4. Height of treasure chest based on balloons attached (0 = on seabed, 3 = surface)
    final double maxLift = seabedY - 80.0;
    final double liftProgress = (balloonCount / 3.0).clamp(0.0, 1.0);
    final double chestY = (seabedY - 36.0) - (liftProgress * maxLift);
    final double chestX = size.width * 0.5;

    // 5. Draw Balloons if any
    final balloonColors = [
      const Color(0xFFEF4444), // Red
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFFF59E0B), // Gold
    ];

    for (int i = 0; i < balloonCount; i++) {
      final double bx = (chestX - 32.0) + (i * 32.0);
      final double by = chestY - 55.0 - (math.sin(wavePhase + i) * 3.0);
      final Color bColor = balloonColors[i % balloonColors.length];

      // Tether String to chest
      final stringPaint = Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..strokeWidth = 1.4;
      canvas.drawLine(Offset(bx, by + 16), Offset(chestX - 20 + (i * 20), chestY - 14), stringPaint);

      // Balloon Body
      final bPaint = Paint()..color = bColor;
      canvas.drawOval(Rect.fromCenter(center: Offset(bx, by), width: 24, height: 30), bPaint);

      // Balloon Highlight
      final highlightPaint = Paint()..color = Colors.white.withOpacity(0.5);
      canvas.drawCircle(Offset(bx - 4, by - 6), 3.5, highlightPaint);

      // Balloon Knot
      final knotPath = Path();
      knotPath.moveTo(bx - 3, by + 14);
      knotPath.lineTo(bx + 3, by + 14);
      knotPath.lineTo(bx, by + 17);
      knotPath.close();
      canvas.drawPath(knotPath, bPaint);
    }

    // 6. Draw Rich Detailed Treasure Chest
    final double chestW = 84.0;
    final double chestH = 54.0;
    final chestRect = Rect.fromCenter(center: Offset(chestX, chestY), width: chestW, height: chestH);

    // Drop Shadow under chest
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(chestX, chestY + (chestH / 2) + 2), width: chestW + 8, height: 14),
      shadowPaint,
    );

    // Main Wooden Chest Body
    final chestPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF92400E), Color(0xFF78350F), Color(0xFF451A03)],
      ).createShader(chestRect);
    canvas.drawRRect(RRect.fromRectAndRadius(chestRect, const Radius.circular(8)), chestPaint);

    // Wood Plank Lines
    final plankPaint = Paint()
      ..color = const Color(0xFF451A03).withOpacity(0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(chestRect.left + 4, chestRect.top + 18), Offset(chestRect.right - 4, chestRect.top + 18), plankPaint);
    canvas.drawLine(Offset(chestRect.left + 4, chestRect.top + 36), Offset(chestRect.right - 4, chestRect.top + 36), plankPaint);

    // Golden Iron Reinforcement Bands
    final goldBandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFDE047), Color(0xFFF59E0B), Color(0xFFD97706)],
      ).createShader(chestRect);

    // Left band, right band, middle trim
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(chestRect.left + 10, chestRect.top, 8, chestH), const Radius.circular(2)), goldBandPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(chestRect.right - 18, chestRect.top, 8, chestH), const Radius.circular(2)), goldBandPaint);
    canvas.drawRect(Rect.fromLTWH(chestRect.left, chestRect.top + (chestH * 0.38), chestW, 6), goldBandPaint);

    // Golden Keyhole Padlock in center
    final lockRect = Rect.fromCenter(center: Offset(chestX, chestRect.top + (chestH * 0.42)), width: 14, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(lockRect, const Radius.circular(3)), Paint()..color = const Color(0xFFFEF08A));
    canvas.drawCircle(Offset(chestX, lockRect.top + 6), 2.2, Paint()..color = const Color(0xFF78350F));
    canvas.drawRect(Rect.fromLTWH(chestX - 1.2, lockRect.top + 6, 2.4, 4), Paint()..color = const Color(0xFF78350F));

    // Outer Dark Bronze Border
    final borderPaint = Paint()
      ..color = const Color(0xFF291504)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(chestRect, const Radius.circular(8)), borderPaint);

    // 7. Victory Sparkles & Coins Burst when lifted to surface (balloonCount >= 3)
    if (balloonCount >= 3) {
      final coinPaint = Paint()..color = const Color(0xFFFACC15);
      final coinBorder = Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int c = 0; c < 5; c++) {
        final double cx = chestX + math.cos(c * 1.3) * 36.0;
        final double cy = chestY - 24.0 + math.sin(c * 1.3) * 16.0;
        canvas.drawCircle(Offset(cx, cy), 5.0, coinPaint);
        canvas.drawCircle(Offset(cx, cy), 5.0, coinBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreasureScenePainter oldDelegate) => true;
}


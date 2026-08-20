// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
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
import '../widgets/vector_asset_helper.dart';

class DensityExperimentScreen extends StatefulWidget {
  final Activity? activity;

  const DensityExperimentScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityExperimentScreen> createState() => _DensityExperimentScreenState();
}

class _DensityExperimentScreenState extends State<DensityExperimentScreen> {
  Student? _student;
  int _currentStep = 0;
  bool _isCompleted = false;

  final List<Map<String, dynamic>> _missions = [
    {
      'title': 'Mission 1: Wood vs. Gold Comparison',
      'instruction': 'Select the "Custom" or "Intro" tab in the PhET simulation. Drop the Wood block into the pool. Then drop the Gold block. Observe which one floats!',
      'dendyState': DendyState.thinking,
      'hint': 'Notice: Wood has a density of 0.40 kg/L (less than water = 1.00 kg/L), so it floats! Gold has a density of 19.30 kg/L, so it sinks instantly.',
      'actionText': 'I OBSERVED THIS!',
    },
    {
      'title': 'Mission 2: Changing Mass & Volume',
      'instruction': 'Choose the "Same Mass" or "Same Volume" mode. Slide the Mass and Volume sliders to change the block properties.',
      'dendyState': DendyState.idle,
      'hint': 'Key discovery: Increasing mass without changing volume makes the object denser. Increasing volume spreads the mass out, making it less dense!',
      'actionText': 'EXPERIMENTED & VERIFIED!',
    },
    {
      'title': 'Mission 3: Formulate The Buoyancy Rule',
      'instruction': 'Calculate: Density = Mass ÷ Volume. Try to make a block with Mass = 5 kg and Volume = 10 L. Will it float?',
      'dendyState': DendyState.success,
      'hint': '5 kg ÷ 10 L = 0.50 kg/L. Since 0.50 < 1.00 kg/L (water density), it floats! You discovered Archimedes principle of buoyancy!',
      'actionText': 'COMPLETE EXPERIMENT',
    },
  ];

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
  }

  String _getSimulationUrl() {
    try {
      final origin = html.window.location.origin;
      return '$origin/phet_density/index.html';
    } catch (_) {
      return '/phet_density/index.html';
    }
  }

  void _onNextStep() {
    SoundService.playClick();
    if (_currentStep < _missions.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _onExperimentCompleted();
    }
  }

  Future<void> _onExperimentCompleted() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Lesson 2 Progress
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les2',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Award XP (+60) and Coins (+15)
      final updated = _student!.copyWith(
        xp: _student!.xp + 60,
        gold: _student!.gold + 15,
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
        });
      }
    }

    SoundService.playLevelComplete();
    if (mounted) {
      _showCelebrationDialog();
    }
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
    final currentMission = _missions[_currentStep];

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isShort ? 10 : 16,
              vertical: isShort ? 6 : 10,
            ),
            child: Column(
              children: [
                // Top Header Bar
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 6 : 8),

                // Main Content Area: Simulation (Left) + Dendy Mission Dock (Right)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PhET Simulation Container
                      Expanded(
                        flex: 13,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox.expand(
                              child: HtmlElementView.fromTagName(
                                key: const ValueKey('phet_density_sim'),
                                tagName: 'iframe',
                                onElementCreated: (Object element) {
                                  final iframe = element as html.IFrameElement;
                                  iframe.src = _getSimulationUrl();
                                  iframe.style.border = 'none';
                                  iframe.style.width = '100%';
                                  iframe.style.height = '100%';
                                  iframe.style.display = 'block';
                                  iframe.setAttribute('allowfullscreen', 'true');
                                  iframe.setAttribute('allow', 'fullscreen; autoplay; clipboard-write');
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Dendy Interactive Mission Dock
                      Expanded(
                        flex: 7,
                        child: _buildDendyMissionDock(currentMission, isShort),
                      ),
                    ],
                  ),
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
        // Back Button + Subject & Title
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleReturn,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'SCIENCE • DENSITY & BUOYANCY',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  'LESSON 2: EXPERIMENT (PHET SIMULATION LAB)',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 9 : 10,
                    color: ColorSystem.purple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Metrics: XP, Coins
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_student != null) ...[
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
          ],
        ),
      ],
    );
  }

  Widget _buildMetricBadge(Widget icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DENDY MISSION DOCK
  // ==========================================
  Widget _buildDendyMissionDock(Map<String, dynamic> mission, bool isShort) {
    return Container(
      padding: EdgeInsets.all(isShort ? 10 : 14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Progress Indicators
          Row(
            children: List.generate(_missions.length, (index) {
              final isPassed = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < _missions.length - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isPassed ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: isShort ? 6 : 10),

          // Dendy Avatar + Title
          Row(
            children: [
              DendyMascot(
                size: isShort ? 36 : 46,
                state: mission['dendyState'] as DendyState,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP ${_currentStep + 1} OF ${_missions.length}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      mission['title'] as String,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 11 : 12,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isShort ? 6 : 10),

          // Instruction Bubble
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorSystem.lavender.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.purple.withOpacity(0.2)),
                    ),
                    child: Text(
                      mission['instruction'] as String,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: ColorSystem.plum,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Dendy Hint
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorSystem.cream,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.gold.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: ColorSystem.gold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            mission['hint'] as String,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: isShort ? 9.5 : 10.5,
                              color: ColorSystem.purple,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
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
          SizedBox(height: isShort ? 6 : 10),

          // Next Step / Complete Button
          CustomButton(
            text: mission['actionText'] as String,
            backgroundColor: _currentStep == _missions.length - 1 ? ColorSystem.green : ColorSystem.purple,
            textColor: Colors.white,
            height: isShort ? 34 : 40,
            onPressed: _onNextStep,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COMPLETION CELEBRATION MODAL
  // ==========================================
  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorSystem.plum, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.18),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VectorAssetHelper.xpStarIcon(size: 38, color: ColorSystem.gold),
                    const SizedBox(width: 6),
                    VectorAssetHelper.xpStarIcon(size: 48, color: ColorSystem.gold),
                    const SizedBox(width: 6),
                    VectorAssetHelper.xpStarIcon(size: 38, color: ColorSystem.gold),
                  ],
                ),
                const SizedBox(height: 10),

                const Text(
                  'EXPERIMENT COMPLETED!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),

                const Text(
                  'You discovered the fundamental law of density and buoyancy through the PhET Interactive Lab!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ColorSystem.purple,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Reward Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorSystem.lavender,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.purple.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VectorAssetHelper.xpStarIcon(size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            '+60 XP',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColorSystem.cream,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.gold.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VectorAssetHelper.questCoinIcon(size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            '+15 COINS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                CustomButton(
                  text: 'RETURN TO ROADMAP',
                  backgroundColor: ColorSystem.green,
                  textColor: Colors.white,
                  height: 40,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    _handleReturn();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

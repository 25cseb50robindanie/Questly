import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../services/localization_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/resource_counter.dart';
import '../widgets/vector_asset_helper.dart';

enum LabMaterial { wood, ice, plastic, steel, gold }

class MaterialInfo {
  final String nameKey;
  final double density; // kg/L
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;
  final IconData icon;

  const MaterialInfo({
    required this.nameKey,
    required this.density,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.icon,
  });
}

const Map<LabMaterial, MaterialInfo> kMaterialData = {
  LabMaterial.wood: MaterialInfo(
    nameKey: 'mat_wood',
    density: 0.40,
    primaryColor: Color(0xFFD97706),
    secondaryColor: Color(0xFFB45309),
    borderColor: Color(0xFF78350F),
    icon: Icons.forest_rounded,
  ),
  LabMaterial.ice: MaterialInfo(
    nameKey: 'mat_ice',
    density: 0.92,
    primaryColor: Color(0xFFBAE6FD),
    secondaryColor: Color(0xFF7DD3FC),
    borderColor: Color(0xFF0284C7),
    icon: Icons.ac_unit_rounded,
  ),
  LabMaterial.plastic: MaterialInfo(
    nameKey: 'mat_plastic',
    density: 0.85,
    primaryColor: Color(0xFFFB923C),
    secondaryColor: Color(0xFFF97316),
    borderColor: Color(0xFFC2410C),
    icon: Icons.category_rounded,
  ),
  LabMaterial.steel: MaterialInfo(
    nameKey: 'mat_steel',
    density: 7.80,
    primaryColor: Color(0xFF94A3B8),
    secondaryColor: Color(0xFF64748B),
    borderColor: Color(0xFF334155),
    icon: Icons.hardware_rounded,
  ),
  LabMaterial.gold: MaterialInfo(
    nameKey: 'mat_gold',
    density: 19.30,
    primaryColor: Color(0xFFFACC15),
    secondaryColor: Color(0xFFEAB308),
    borderColor: Color(0xFFCA8A04),
    icon: Icons.monetization_on_rounded,
  ),
};

enum LabMission { mission1Mass, mission2Volume, mission3Compare, discoveryComplete }

class DensityExperimentScreen extends StatefulWidget {
  final Activity? activity;

  const DensityExperimentScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityExperimentScreen> createState() => _DensityExperimentScreenState();
}

class _DensityExperimentScreenState extends State<DensityExperimentScreen>
    with TickerProviderStateMixin {
  Student? _student;
  bool _isCompleted = false;

  LabMission _currentMission = LabMission.mission1Mass;
  bool _showingQuestion = false;
  bool _showIntroBanner = true;
  bool _showDiscoveryCard = false;

  double _massA = 2.0;
  double _volumeA = 5.0;
  LabMaterial _materialA = LabMaterial.wood;

  double _massB = 5.0;
  double _volumeB = 2.5;
  LabMaterial _materialB = LabMaterial.steel;
  bool _isCompareMode = false;
  int _selectedObject = 0;

  bool _hasModifiedMass = false;
  bool _hasModifiedVolume = false;
  bool _hasComparedObjects = false;

  late AnimationController _waveController;
  late AnimationController _bobbingController;
  late AnimationController _transitionController;

  final List<_Bubble> _bubbles = [];
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ??
        Locator.authService.getCurrentStudent();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _bobbingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    for (int i = 0; i < 8; i++) {
      _bubbles.add(_Bubble(
        x: _rand.nextDouble(),
        y: 0.3 + _rand.nextDouble() * 0.6,
        size: 3.0 + _rand.nextDouble() * 5.0,
        speed: 0.002 + _rand.nextDouble() * 0.004,
      ));
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _showIntroBanner) {
        setState(() {
          _showIntroBanner = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _bobbingController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  void _triggerBubbles({int count = 12}) {
    for (int i = 0; i < count; i++) {
      _bubbles.add(_Bubble(
        x: 0.2 + _rand.nextDouble() * 0.6,
        y: 0.7 + _rand.nextDouble() * 0.25,
        size: 3.0 + _rand.nextDouble() * 6.0,
        speed: 0.004 + _rand.nextDouble() * 0.008,
      ));
    }
  }

  void _onMassChanged(double newMass) {
    setState(() {
      if (_selectedObject == 0) {
        _massA = double.parse(newMass.toStringAsFixed(1));
      } else {
        _massB = double.parse(newMass.toStringAsFixed(1));
      }
      _hasModifiedMass = true;
      _triggerBubbles(count: 3);

      if (_currentMission == LabMission.mission1Mass && _massA >= 4.0 && !_showingQuestion) {
        _showingQuestion = true;
      }
    });
  }

  void _onVolumeChanged(double newVolume) {
    setState(() {
      if (_selectedObject == 0) {
        _volumeA = double.parse(newVolume.toStringAsFixed(1));
      } else {
        _volumeB = double.parse(newVolume.toStringAsFixed(1));
      }
      _hasModifiedVolume = true;
      _triggerBubbles(count: 3);

      if (_currentMission == LabMission.mission2Volume && (_volumeA >= 8.0 || _volumeA <= 2.0) && !_showingQuestion) {
        _showingQuestion = true;
      }
    });
  }

  void _onMaterialSelected(LabMaterial mat) {
    SoundService.playClick();
    setState(() {
      final info = kMaterialData[mat]!;
      if (_selectedObject == 0) {
        _materialA = mat;
        _massA = double.parse((info.density * _volumeA).clamp(1.0, 10.0).toStringAsFixed(1));
      } else {
        _materialB = mat;
        _massB = double.parse((info.density * _volumeB).clamp(1.0, 10.0).toStringAsFixed(1));
      }
      _hasComparedObjects = true;
      _triggerBubbles(count: 6);

      if (_currentMission == LabMission.mission3Compare && !_showingQuestion) {
        _showingQuestion = true;
      }
    });
  }

  void _handleAnswerSelected(int index) {
    SoundService.playCorrect();
    setState(() {
      _showingQuestion = false;

      if (_currentMission == LabMission.mission1Mass) {
        _currentMission = LabMission.mission2Volume;
      } else if (_currentMission == LabMission.mission2Volume) {
        _currentMission = LabMission.mission3Compare;
        _isCompareMode = true;
      } else if (_currentMission == LabMission.mission3Compare) {
        _currentMission = LabMission.discoveryComplete;
        _showDiscoveryCard = true;
      }
    });
  }

  Future<void> _completeLesson() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();
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

      final updated = _student!.copyWith(
        xp: _student!.xp + 60,
        gold: _student!.gold + 15,
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (!mounted) return;

      await QuestCompletionDialog.show(
        context: context,
        title: l('lesson_2_measure_density'),
        xpReward: 60,
        goldReward: 15,
        earnedStars: 3,
        onContinue: () {
          Navigator.pop(context); // Return to overview / roadmap
        },
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final densityA = _volumeA > 0 ? _massA / _volumeA : 0.0;
    final densityB = _volumeB > 0 ? _massB / _volumeB : 0.0;
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Top App Bar: Navigation, Lesson 2 Indicator, XP & Coins
                  _buildHeader(),

                  // Main Laboratory Viewport
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left & Center: Native Fluid Water Tank Simulation
                          Expanded(
                            flex: 13,
                            child: _buildWaterTankCard(densityA, densityB),
                          ),
                          const SizedBox(width: 14),

                          // Right: Interactive Slider & Material Controls Deck
                          Expanded(
                            flex: 11,
                            child: _buildControlDeck(densityA, densityB),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Dendy Guidance Banner
                  _buildDendyGuideBanner(),
                ],
              ),

              // Smooth Welcome Transition Banner
              if (_showIntroBanner) _buildIntroTransition(),

              // Beautiful Discovery Moment Modal
              if (_showDiscoveryCard) _buildDiscoveryModal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: ColorSystem.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.science_rounded, color: ColorSystem.purple, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      l('lesson_2_title_progress'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right: XP and Gold counters
          Row(
            children: [
              ResourceCounter(
                iconWidget: VectorAssetHelper.questCoinIcon(size: 16),
                value: '${_student?.gold ?? 0}',
              ),
              const SizedBox(width: 10),
              ResourceCounter(
                iconWidget: VectorAssetHelper.xpStarIcon(size: 16),
                value: '${_student?.xp ?? 0} XP',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterTankCard(double densityA, double densityB) {
    // Water baseline volume = 100.0 L
    final subFracA = (densityA / 1.0).clamp(0.0, 1.0);
    final dispA = _volumeA * subFracA;
    final subFracB = (densityB / 1.0).clamp(0.0, 1.0);
    final dispB = _isCompareMode ? (_volumeB * subFracB) : 0.0;
    final totalDisplaced = dispA + dispB;
    final currentWaterVolume = 100.0 + totalDisplaced;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Custom Animated Water Tank Simulation
            AnimatedBuilder(
              animation: Listenable.merge([_waveController, _bobbingController]),
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _LivingWaterTankPainter(
                    wavePhase: _waveController.value * 2 * pi,
                    bobbingPhase: _bobbingController.value,
                    waterVolume: currentWaterVolume,
                    densityA: densityA,
                    volumeA: _volumeA,
                    materialA: _materialA,
                    densityB: densityB,
                    volumeB: _volumeB,
                    materialB: _materialB,
                    isCompareMode: _isCompareMode,
                    bubbles: _bubbles,
                  ),
                );
              },
            ),

            // Top Status Badge: Water Volume & Density Marker
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Color(0xFF0284C7), size: 15),
                    const SizedBox(width: 5),
                    Text(
                      '${currentWaterVolume.toStringAsFixed(1)} L (${l('water_density_standard')})',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active Object Selector in Compare Mode
            if (_isCompareMode)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      _buildObjectToggle(0, l('object_a'), _materialA),
                      const SizedBox(width: 4),
                      _buildObjectToggle(1, l('object_b'), _materialB),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectToggle(int index, String label, LabMaterial mat) {
    final isSelected = _selectedObject == index;
    final info = kMaterialData[mat]!;

    return GestureDetector(
      onTap: () {
        SoundService.playClick();
        setState(() {
          _selectedObject = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? info.primaryColor.withOpacity(0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? info.borderColor : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(info.icon, size: 13, color: info.borderColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlDeck(double densityA, double densityB) {
    final isObjectA = _selectedObject == 0;
    final currentMass = isObjectA ? _massA : _massB;
    final currentVolume = isObjectA ? _volumeA : _volumeB;
    final currentDensity = isObjectA ? densityA : densityB;
    final currentMat = isObjectA ? _materialA : _materialB;
    final matInfo = kMaterialData[currentMat]!;

    final isVolumeUnlocked = _currentMission != LabMission.mission1Mass;
    final isMaterialUnlocked = _currentMission == LabMission.mission3Compare || _currentMission == LabMission.discoveryComplete;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Object Header with Density Live Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: matInfo.primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: matInfo.borderColor, width: 1.5),
                    ),
                    child: Icon(matInfo.icon, size: 18, color: matInfo.borderColor),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCompareMode
                            ? (isObjectA ? l('object_a') : l('object_b'))
                            : l(matInfo.nameKey).toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                        ),
                      ),
                      Text(
                        l(matInfo.nameKey),
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          color: ColorSystem.plum.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Live Density Metric
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentDensity < 1.0
                      ? ColorSystem.green.withOpacity(0.15)
                      : ColorSystem.pink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: currentDensity < 1.0 ? ColorSystem.green : ColorSystem.pink,
                    width: 1.2,
                  ),
                ),
                child: Text(
                  '${currentDensity.toStringAsFixed(2)} kg/L (${currentDensity < 1.0 ? l('float').toUpperCase() : l('sink').toUpperCase()})',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: currentDensity < 1.0 ? ColorSystem.green : ColorSystem.pink,
                  ),
                ),
              ),
            ],
          ),

          const Divider(color: ColorSystem.cream, thickness: 1.5, height: 16),

          // 1. Mass Slider (Mission 1+)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l('mass_kg'),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum,
                    ),
                  ),
                  Text(
                    '${currentMass.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: ColorSystem.purple,
                  inactiveTrackColor: ColorSystem.purple.withOpacity(0.15),
                  thumbColor: ColorSystem.purple,
                  overlayColor: ColorSystem.purple.withOpacity(0.12),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: currentMass,
                  min: 1.0,
                  max: 10.0,
                  divisions: 18,
                  onChanged: _onMassChanged,
                ),
              ),
            ],
          ),

          // 2. Volume Slider (Mission 2+)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l('volume_l'),
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isVolumeUnlocked ? ColorSystem.plum : Colors.grey,
                    ),
                  ),
                  Text(
                    '${currentVolume.toStringAsFixed(1)} L',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isVolumeUnlocked ? ColorSystem.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: isVolumeUnlocked ? ColorSystem.blue : Colors.grey.shade300,
                  inactiveTrackColor: ColorSystem.blue.withOpacity(0.15),
                  thumbColor: isVolumeUnlocked ? ColorSystem.blue : Colors.grey,
                  overlayColor: ColorSystem.blue.withOpacity(0.12),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: currentVolume,
                  min: 1.0,
                  max: 10.0,
                  divisions: 18,
                  onChanged: isVolumeUnlocked ? _onVolumeChanged : null,
                ),
              ),
            ],
          ),

          // 3. Material Selector (Mission 3+)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l('materials').toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isMaterialUnlocked ? ColorSystem.plum.withOpacity(0.6) : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: LabMaterial.values.map((mat) {
                    final isSel = currentMat == mat;
                    final info = kMaterialData[mat]!;

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: isMaterialUnlocked ? () => _onMaterialSelected(mat) : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? info.primaryColor.withOpacity(0.3) : (isMaterialUnlocked ? Colors.grey.shade50 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSel ? info.borderColor : Colors.grey.shade300,
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                info.icon,
                                size: 12,
                                color: isMaterialUnlocked ? info.borderColor : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l(info.nameKey),
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMaterialUnlocked
                                      ? (isSel ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.6))
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDendyGuideBanner() {
    String message = l('lets_experiment');
    List<String> choices = [];

    switch (_currentMission) {
      case LabMission.mission1Mass:
        if (_showingQuestion) {
          message = l('what_changed');
          choices = [l('sank_deeper'), l('floated_higher'), l('nothing_changed')];
        } else {
          message = l('try_making_object_heavier');
        }
        break;
      case LabMission.mission2Volume:
        if (_showingQuestion) {
          message = l('what_do_you_notice');
          choices = [l('floated_higher'), l('sank_deeper'), l('nothing_changed')];
        } else {
          message = l('what_happens_change_size');
        }
        break;
      case LabMission.mission3Compare:
        if (_showingQuestion) {
          message = l('which_one_sinks_more');
          choices = [l('denser_heavier_object'), l('larger_lighter_object'), l('both_sink_equally')];
        } else {
          message = l('compare_two_objects');
        }
        break;
      case LabMission.discoveryComplete:
        message = l('can_you_spot_pattern');
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          DendyMascot(
            state: _showingQuestion ? DendyState.thinking : DendyState.idle,
            size: 48,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                    const SizedBox(width: 6),
                    DendySpeakButton(textToSpeak: message, size: 20),
                  ],
                ),
                if (_showingQuestion && choices.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: List.generate(choices.length, (idx) {
                      return GestureDetector(
                        onTap: () => _handleAnswerSelected(idx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: ColorSystem.purple,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: ColorSystem.plum.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            choices[idx],
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroTransition() {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: _showIntroBanner ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 600),
        child: Container(
          color: ColorSystem.cream.withOpacity(0.96),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DendyMascot(state: DendyState.success, size: 90),
                const SizedBox(height: 16),
                Text(
                  l('nice_prediction_become_scientists'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 180,
                  child: CustomButton(
                    text: l('lets_experiment').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    height: 40,
                    onPressed: () {
                      SoundService.playClick();
                      setState(() {
                        _showIntroBanner = false;
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

  Widget _buildDiscoveryModal() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DendyMascot(state: DendyState.success, size: 64),
                const SizedBox(height: 12),
                Text(
                  l('the_density_formula'),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Formula Highlight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorSystem.gold, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      l('density_equals_mass_divided_volume'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l('density_discovery_desc'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    color: ColorSystem.plum.withOpacity(0.8),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Floating / Sinking Summary Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorSystem.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l('less_dense_than_water_floats'),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: l('continue_to_lesson_3').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    height: 44,
                    onPressed: () {
                      SoundService.playClick();
                      setState(() {
                        _showDiscoveryCard = false;
                      });
                      _completeLesson();
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

class _Bubble {
  double x;
  double y;
  double size;
  double speed;

  _Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}

class _LivingWaterTankPainter extends CustomPainter {
  final double wavePhase;
  final double bobbingPhase;
  final double waterVolume; // e.g. 100 to 120 L
  final double densityA;
  final double volumeA;
  final LabMaterial materialA;
  final double densityB;
  final double volumeB;
  final LabMaterial materialB;
  final bool isCompareMode;
  final List<_Bubble> bubbles;

  _LivingWaterTankPainter({
    required this.wavePhase,
    required this.bobbingPhase,
    required this.waterVolume,
    required this.densityA,
    required this.volumeA,
    required this.materialA,
    required this.densityB,
    required this.volumeB,
    required this.materialB,
    required this.isCompareMode,
    required this.bubbles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double tankPadding = 16.0;
    final Rect tankRect = Rect.fromLTWH(
      tankPadding,
      tankPadding,
      size.width - (tankPadding * 2),
      size.height - (tankPadding * 2),
    );

    // 1. Draw Glass Tank Background & Measurement Ticks
    _drawTankStructure(canvas, tankRect);

    // 2. Calculate Water Level based on volume (baseline 100L = 55% height)
    final double volumeRatio = (waterVolume - 100.0) / 30.0; // 0.0 to 1.0
    final double waterSurfaceY = tankRect.bottom - (tankRect.height * (0.50 + (volumeRatio * 0.25)));

    // 3. Draw Water Surface Wave Mesh & Living Liquid Gradient
    _drawLivingWater(canvas, tankRect, waterSurfaceY);

    // 4. Draw Rising Ambient & Interaction Bubbles
    _drawBubbles(canvas, tankRect, waterSurfaceY);

    // 5. Draw Objects in Tank
    if (isCompareMode) {
      // Object A on left half
      final double centerAX = tankRect.left + (tankRect.width * 0.32);
      _drawPhysicalBlock(canvas, centerAX, waterSurfaceY, densityA, volumeA, materialA, 'A');

      // Object B on right half
      final double centerBX = tankRect.left + (tankRect.width * 0.68);
      _drawPhysicalBlock(canvas, centerBX, waterSurfaceY, densityB, volumeB, materialB, 'B');
    } else {
      // Single Object in center
      final double centerAX = tankRect.center.dx;
      _drawPhysicalBlock(canvas, centerAX, waterSurfaceY, densityA, volumeA, materialA, '');
    }

    // 6. Tank Glass Specular Highlights
    _drawGlassHighlights(canvas, tankRect);
  }

  void _drawTankStructure(Canvas canvas, Rect tankRect) {
    // Tank background wall
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(12)), bgPaint);

    // Graduated Measurement ticks on left glass border
    final tickPaint = Paint()
      ..color = ColorSystem.plum.withOpacity(0.2)
      ..strokeWidth = 1.5;

    for (int i = 0; i <= 6; i++) {
      final double y = tankRect.top + (tankRect.height * (0.2 + i * 0.11));
      canvas.drawLine(Offset(tankRect.left + 4, y), Offset(tankRect.left + 14, y), tickPaint);
    }
  }

  void _drawLivingWater(Canvas canvas, Rect tankRect, double surfaceY) {
    final path = Path();
    path.moveTo(tankRect.left, surfaceY);

    // Sinusoidal surface wave curve
    final int segments = 24;
    final double dx = tankRect.width / segments;

    for (int i = 0; i <= segments; i++) {
      final double x = tankRect.left + (i * dx);
      final double wave1 = sin(wavePhase + (i * 0.35)) * 3.5;
      final double wave2 = cos((wavePhase * 1.5) + (i * 0.2)) * 1.8;
      final double y = surfaceY + wave1 + wave2;
      path.lineTo(x, y);
    }

    path.lineTo(tankRect.right, tankRect.bottom);
    path.lineTo(tankRect.left, tankRect.bottom);
    path.close();

    // Deep luminous aquatic gradient
    final waterPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF38BDF8), // Tropical cyan
          Color(0xFF0284C7), // Bright ocean blue
          Color(0xFF0369A1), // Deep sapphire
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(tankRect);

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(12)));
    canvas.drawPath(path, waterPaint);

    // Surface wave gleam highlight
    final surfaceGleamPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawPath(path, surfaceGleamPaint);
    canvas.restore();
  }

  void _drawBubbles(Canvas canvas, Rect tankRect, double surfaceY) {
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (final b in bubbles) {
      // Update bubble upward float
      b.y -= b.speed;
      if (b.y < 0.1) b.y = 0.95;

      final double px = tankRect.left + (b.x * tankRect.width);
      final double py = tankRect.top + (b.y * tankRect.height);

      if (py > surfaceY) {
        canvas.drawCircle(Offset(px, py), b.size, bubblePaint);
      }
    }
  }

  void _drawPhysicalBlock(
    Canvas canvas,
    double centerX,
    double surfaceY,
    double density,
    double volume,
    LabMaterial material,
    String label,
  ) {
    final matInfo = kMaterialData[material]!;

    // Block dimensions scale smoothly with volume (1.0 L = 44px, 10.0 L = 88px)
    final double blockSize = 44.0 + (volume * 4.4);
    final double blockRadius = 8.0;

    // Equilibrium calculation:
    // Immersed fraction f = min(1.0, density / 1.0)
    final double submergedFrac = (density / 1.0).clamp(0.0, 1.0);

    // Target Y:
    // Floating: center aligns so that (submergedFrac * blockSize) is under surface
    // Sinking (density >= 1.0): sinks to bottom
    final double bobbing = sin(bobbingPhase * 2 * pi) * (density < 1.0 ? 3.5 : 0.5);

    double blockTopY;
    if (density < 1.0) {
      // Floats at equilibrium
      blockTopY = surfaceY - (blockSize * (1.0 - submergedFrac)) + bobbing;
    } else {
      // Sinks directly to floor of tank
      blockTopY = surfaceY + (blockSize * 0.8) + (density * 2.0);
    }

    final Rect blockRect = Rect.fromCenter(
      center: Offset(centerX, blockTopY + (blockSize / 2)),
      width: blockSize,
      height: blockSize,
    );

    // 1. Draw Drop Shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect.shift(const Offset(0, 3)), Radius.circular(blockRadius)),
      Paint()..color = Colors.black.withOpacity(0.18),
    );

    // 2. Draw Material Body Gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [matInfo.primaryColor, matInfo.secondaryColor],
      ).createShader(blockRect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, Radius.circular(blockRadius)),
      bodyPaint,
    );

    // 3. Draw Border
    final borderPaint = Paint()
      ..color = matInfo.borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(blockRect, Radius.circular(blockRadius)),
      borderPaint,
    );

    // 4. Draw Label & Mass Tag
    final textPainter = TextPainter(
      text: TextSpan(
        text: label.isNotEmpty ? label : '${density.toStringAsFixed(2)} kg/L',
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        blockRect.center.dx - (textPainter.width / 2),
        blockRect.center.dy - (textPainter.height / 2),
      ),
    );
  }

  void _drawGlassHighlights(Canvas canvas, Rect tankRect) {
    // Outer Tank Frame
    final framePaint = Paint()
      ..color = ColorSystem.plum
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(RRect.fromRectAndRadius(tankRect, const Radius.circular(12)), framePaint);

    // Specular glass shine corner line
    final shinePaint = Paint()
      ..color = Colors.white.withOpacity(0.35)
      ..strokeWidth = 2.0;

    canvas.drawLine(
      Offset(tankRect.left + 8, tankRect.top + 8),
      Offset(tankRect.left + 32, tankRect.top + 8),
      shinePaint,
    );
    canvas.drawLine(
      Offset(tankRect.left + 8, tankRect.top + 8),
      Offset(tankRect.left + 8, tankRect.top + 32),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LivingWaterTankPainter oldDelegate) => true;
}

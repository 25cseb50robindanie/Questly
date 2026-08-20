import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/activity.dart';
import '../models/lesson.dart';
import '../models/progress.dart';
import '../games/questly_game.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Activity? _activity;
  QuestlyGame? _game;
  
  // Local slider & preset state variables
  double _mass = 3.0;
  double _volume = 5.0;
  String _selectedPreset = 'wood'; // wood, aluminum, gold, custom
  Color _blockColor = ColorSystem.pink;

  bool _isDropped = false;
  bool _isSuccess = false;
  double _finalDensity = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_activity == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Activity) {
        _activity = args;
      } else if (args is Lesson && args.activities.isNotEmpty) {
        _activity = args.activities.first;
      } else if (args is String) {
        _activity = Locator.moduleRepository.getActivityById(args);
      }
      
      _activity ??= Activity(
        id: 'act_density_game',
        title: 'Density Simulation',
        instruction: 'Adjust mass and volume to achieve target buoyancy.',
        type: 'flameGame',
        targetDensity: 0.6,
        targetCondition: 'float',
        xpReward: 25,
        goldReward: 5,
      );

      _initializeGame();
    }
  }

  void _initializeGame() {
    _game = QuestlyGame(
      targetDensity: _activity!.targetDensity,
      targetCondition: _activity!.targetCondition,
      onGoalAchieved: (finalDensity) {
        setState(() {
          _isSuccess = true;
          _finalDensity = finalDensity;
        });
      },
    );
    _applyPreset(_selectedPreset);
  }

  void _applyPreset(String preset) {
    setState(() {
      _selectedPreset = preset;
      if (preset == 'wood') {
        _mass = 3.0;
        _volume = 5.0;
        _blockColor = const Color(0xFF8B5A2B); // Brown Wood
      } else if (preset == 'aluminum') {
        _mass = 2.7;
        _volume = 1.0;
        _blockColor = const Color(0xFFC0C0C0); // Silver Aluminum
      } else if (preset == 'gold') {
        _mass = 19.3;
        _volume = 1.0;
        _blockColor = ColorSystem.gold; // Yellow Gold
      } else {
        // Custom
        _blockColor = ColorSystem.pink;
      }
    });

    _game?.updateBlockProperties(_mass, _volume, _blockColor);
  }

  void _handleCustomSliderChange() {
    if (_selectedPreset != 'custom') {
      setState(() {
        _selectedPreset = 'custom';
        _blockColor = ColorSystem.pink;
      });
    }
    _game?.updateBlockProperties(_mass, _volume, _blockColor);
  }

  void _dropBlock() {
    setState(() {
      _isDropped = true;
    });
    _game?.dropBlock();
  }

  void _resetBlock() {
    setState(() {
      _isDropped = false;
      _isSuccess = false;
    });
    _game?.resetBlock();
  }

  Future<void> _claimRewards() async {
    final currentStudent = Locator.authService.getCurrentStudent();
    if (currentStudent == null || _activity == null) return;

    // 1. Log simulation progress details
    final progress = Progress(
      studentId: currentStudent.questlyId,
      lessonId: currentStudent.currentLessonId ?? _activity!.id,
      status: 'completed',
      score: _finalDensity,
      attempts: 1,
      lastPlayed: DateTime.now(),
      completedAt: DateTime.now(),
    );
    await Locator.authService.saveProgress(progress);

    // 2. Accumulate XP & Gold, evaluate level increases
    int newXp = currentStudent.xp + _activity!.xpReward;
    int newGold = currentStudent.gold + _activity!.goldReward;
    int level = currentStudent.level;
    
    int xpRequired = level * 200;
    while (newXp >= xpRequired) {
      newXp -= xpRequired;
      level++;
      xpRequired = level * 200;
    }

    final updatedProfile = currentStudent.copyWith(
      xp: newXp,
      gold: newGold,
      level: level,
    );

    // Write updated student model back
    await Locator.studentRepository.updateStudentProfile(updatedProfile);

    if (!mounted) return;
    
    // Close simulation view
    Navigator.pop(context);
  }

  double get _currentDensity => _mass / _volume;

  @override
  Widget build(BuildContext context) {
    if (_activity == null || _game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: SafeArea(
        child: Stack(
          children: [
            // Row Layout splitting game view and dashboard control panel
            Row(
              children: [
                // 1. Simulation Game Canvas Left Pane
                Expanded(
                  flex: 14,
                  child: ClipRect(
                    child: GameWidget(game: _game!),
                  ),
                ),
                // Split Border Line
                Container(width: 1.5, color: ColorSystem.plum.withOpacity(0.3)),
                // 2. Control Form Panel Right Pane
                Expanded(
                  flex: 10,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Header
                        Text(
                          'SIMULATION CONTROLS',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: ColorSystem.plum,
                                letterSpacing: 0.5,
                              ),
                        ),
                        const SizedBox(height: 12),
                        // Preset Material dropdown Selector
                        Row(
                          children: [
                            const Text('Material:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: ColorSystem.plum, width: 1),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPreset,
                                    isExpanded: true,
                                    onChanged: _isDropped
                                        ? null
                                        : (val) {
                                            if (val != null) _applyPreset(val);
                                          },
                                    items: const [
                                      DropdownMenuItem(value: 'wood', child: Text('Wood (Floats)')),
                                      DropdownMenuItem(value: 'aluminum', child: Text('Aluminum (Sinks)')),
                                      DropdownMenuItem(value: 'gold', child: Text('Gold (Sinks)')),
                                      DropdownMenuItem(value: 'custom', child: Text('Custom Material')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Custom mass slider (enabled only for custom presets)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Mass (m):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${_mass.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Slider(
                              value: _mass,
                              min: 0.5,
                              max: 10.0,
                              divisions: 95,
                              activeColor: ColorSystem.purple,
                              inactiveColor: ColorSystem.lavender,
                              onChanged: _isDropped
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _mass = val;
                                        _handleCustomSliderChange();
                                      });
                                    },
                            ),
                          ],
                        ),
                        // Custom volume slider
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Volume (V):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text('${_volume.toStringAsFixed(1)} L', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Slider(
                              value: _volume,
                              min: 0.5,
                              max: 10.0,
                              divisions: 95,
                              activeColor: ColorSystem.purple,
                              inactiveColor: ColorSystem.lavender,
                              onChanged: _isDropped
                                  ? null
                                  : (val) {
                                      setState(() {
                                        _volume = val;
                                        _handleCustomSliderChange();
                                      });
                                    },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Calculated density display box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: ColorSystem.lavender.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Calculated Density:', style: TextStyle(fontSize: 12)),
                              Text(
                                '${_currentDensity.toStringAsFixed(2)} kg/L',
                                style: const TextStyle(
                                  fontFamily: 'system-ui',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSystem.plum,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Primary Actions Buttons
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'RESET',
                                backgroundColor: ColorSystem.lavender,
                                textColor: ColorSystem.plum,
                                onPressed: _resetBlock,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomButton(
                                text: 'DROP',
                                backgroundColor: _isDropped ? ColorSystem.plum.withOpacity(0.2) : ColorSystem.purple,
                                textColor: _isDropped ? ColorSystem.plum.withOpacity(0.4) : Colors.white,
                                onPressed: _isDropped ? () {} : _dropBlock,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 3. Top HUD Layer (Exit/Goal display overlays on Flame view)
            Positioned(
              left: 16,
              top: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tactile Back Button
                  CustomButton(
                    text: 'EXIT LAB',
                    width: 100,
                    height: 38,
                    backgroundColor: ColorSystem.cream,
                    textColor: ColorSystem.plum,
                    icon: Icons.close,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  // Goal Requirement Badge
                  Container(
                    width: 320,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum, width: 1.5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _activity!.title.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'system-ui',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activity!.instruction,
                          style: TextStyle(
                            fontFamily: 'system-ui',
                            fontSize: 11,
                            color: ColorSystem.plum.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Modal Success Dialog overlay (shown when goal solved)
            if (_isSuccess)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 100),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: ColorSystem.green,
                            size: 64,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'QUEST COMPLETED!',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                  color: ColorSystem.green,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Excellent work! The material block reached the target buoyant state.\nRecorded Density: ${_finalDensity.toStringAsFixed(2)} kg/L.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                ),
                          ),
                          const SizedBox(height: 20),
                          // Rewards details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ColorSystem.gold.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ColorSystem.gold, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.stars, color: ColorSystem.gold, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+${_activity!.xpReward} XP',
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: ColorSystem.plum),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: ColorSystem.lavender.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ColorSystem.purple, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: ColorSystem.purple, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      '+${_activity!.goldReward} Gold',
                                      style: const TextStyle(fontWeight: FontWeight.w900, color: ColorSystem.plum),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'CLAIM REWARDS & RETURN',
                            backgroundColor: ColorSystem.purple,
                            textColor: Colors.white,
                            onPressed: _claimRewards,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

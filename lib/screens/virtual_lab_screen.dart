import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/dendy_speak_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';

enum LabExperiment {
  titration,
  flameTest,
  calorimetry,
  smelting,
}

class VirtualLabScreen extends StatefulWidget {
  const VirtualLabScreen({Key? key}) : super(key: key);

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen>
    with TickerProviderStateMixin {
  Student? _student;
  LabExperiment? _selectedExperiment;
  int _currentLevel = 1; // 1 to 5
  int _unlockedLevel = 1;
  bool _isCompleted = false;

  // --- Level 1: Concepts ---
  int _conceptSlide = 0; // 0 to 3
  int? _selectedQuizIndex;
  bool _quizCorrect = false;

  // --- Level 2: Apparatus ---
  final Set<String> _assembledApparatus = {};

  // --- Level 3: Reagents ---
  final Set<String> _selectedReagents = {};

  // --- Level 4: Titration Simulator State ---
  double _buretteVolume = 0.0;
  final double _targetEndpoint = 20.00;
  bool _isContinuousDripping = false;
  Timer? _continuousTimer;
  bool _isSwirling = false;
  double _localPinkIntensity = 0.0;

  // --- Level 4: Flame Test Interactive State ---
  String _selectedFlameSalt = 'licl';
  bool _wireInFlame = false;
  bool _wireHasSalt = true;

  // --- Level 4: Calorimetry Interactive State ---
  double _waterTemp = 22.0;
  double _targetTemp = 22.0;
  bool _soluteAdded = false;
  bool _magneticStirring = false;
  Timer? _tempRiseTimer;

  // --- Level 4: Smelting Interactive State ---
  bool _chargeLoaded = false;
  bool _tuyereBlastOn = false;
  double _furnaceTemp = 250.0;
  bool _tapHoleOpened = false;
  Timer? _furnaceTimer;

  // --- Animation Controllers ---
  late AnimationController _animController;
  late AnimationController _dripAnimController;
  late AnimationController _swirlAnimController;

  @override
  void initState() {
    super.initState();
    _loadStudent();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dripAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _swirlAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _continuousTimer?.cancel();
    _tempRiseTimer?.cancel();
    _furnaceTimer?.cancel();
    _animController.dispose();
    _dripAnimController.dispose();
    _swirlAnimController.dispose();
    super.dispose();
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent() ??
          Locator.authService.getCurrentStudent();
    });
  }

  void _chooseExperiment(LabExperiment exp) {
    SoundService.playClick();
    _continuousTimer?.cancel();
    _tempRiseTimer?.cancel();
    _furnaceTimer?.cancel();

    setState(() {
      _selectedExperiment = exp;
      _currentLevel = 1;
      _unlockedLevel = 1;
      _conceptSlide = 0;
      _selectedQuizIndex = null;
      _quizCorrect = false;
      _assembledApparatus.clear();
      _selectedReagents.clear();

      // Reset simulation variables
      _buretteVolume = 0.0;
      _isContinuousDripping = false;
      _localPinkIntensity = 0.0;
      _selectedFlameSalt = 'licl';
      _wireInFlame = false;
      _wireHasSalt = true;
      _waterTemp = 22.0;
      _targetTemp = 22.0;
      _soluteAdded = false;
      _magneticStirring = false;
      _chargeLoaded = false;
      _tuyereBlastOn = false;
      _furnaceTemp = 250.0;
      _tapHoleOpened = false;
    });
  }

  void _backToMenu() {
    SoundService.playClick();
    _continuousTimer?.cancel();
    _tempRiseTimer?.cancel();
    _furnaceTimer?.cancel();
    setState(() {
      _selectedExperiment = null;
      _isContinuousDripping = false;
    });
  }

  // --- Level 1 Actions ---
  void _nextSlide() {
    SoundService.playClick();
    if (_conceptSlide < 3) {
      setState(() => _conceptSlide++);
    }
  }

  void _prevSlide() {
    SoundService.playClick();
    if (_conceptSlide > 0) {
      setState(() => _conceptSlide--);
    }
  }

  void _selectQuizOption(int idx, int correctIdx) {
    SoundService.playClick();
    setState(() {
      _selectedQuizIndex = idx;
      if (idx == correctIdx) {
        SoundService.playCorrect();
        _quizCorrect = true;
        if (_unlockedLevel < 2) _unlockedLevel = 2;
      } else {
        SoundService.playStarPop();
        _quizCorrect = false;
      }
    });
  }

  void _advanceToLevel2() {
    SoundService.playLevelUp();
    setState(() {
      if (_unlockedLevel < 2) _unlockedLevel = 2;
      _currentLevel = 2;
    });
  }

  // --- Level 2 Actions ---
  void _toggleApparatus(String id, bool isRequired) {
    if (isRequired) {
      SoundService.playPop();
      setState(() {
        if (_assembledApparatus.contains(id)) {
          _assembledApparatus.remove(id);
        } else {
          _assembledApparatus.add(id);
        }
        if (_assembledApparatus.length >= 4) {
          if (_unlockedLevel < 3) _unlockedLevel = 3;
        }
      });
    } else {
      SoundService.playStarPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('That tool is not required for ${_getExpName()}! Choose the 4 needed items.', style: const TextStyle(fontFamily: 'Fredoka')),
          backgroundColor: ColorSystem.coral,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  void _advanceToLevel3() {
    SoundService.playLevelUp();
    setState(() {
      if (_unlockedLevel < 3) _unlockedLevel = 3;
      _currentLevel = 3;
    });
  }

  // --- Level 3 Actions ---
  void _toggleReagent(String id, bool isRequired) {
    if (isRequired) {
      SoundService.playPop();
      setState(() {
        if (_selectedReagents.contains(id)) {
          _selectedReagents.remove(id);
        } else {
          _selectedReagents.add(id);
        }
        if (_selectedReagents.length >= 2) {
          if (_unlockedLevel < 4) _unlockedLevel = 4;
        }
      });
    } else {
      SoundService.playStarPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('That solution is not part of this reaction! Select the active reagents.', style: const TextStyle(fontFamily: 'Fredoka')),
          backgroundColor: ColorSystem.coral,
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  void _advanceToLevel4() {
    SoundService.playLevelUp();
    setState(() {
      if (_unlockedLevel < 4) _unlockedLevel = 4;
      _currentLevel = 4;
    });
  }

  // --- Level 4 Simulation Methods ---
  void _addDrop({double amount = 0.05}) {
    if (_buretteVolume >= 50.0) return;
    SoundService.playStarPop();
    _dripAnimController.forward(from: 0.0);

    setState(() {
      _buretteVolume = (_buretteVolume + amount).clamp(0.0, 50.0);
      if (_buretteVolume >= 19.5 && _buretteVolume < 20.0) {
        _localPinkIntensity = 0.45;
      } else if (_buretteVolume >= 20.0) {
        _localPinkIntensity = 1.0;
      }
    });
  }

  void _toggleContinuous() {
    SoundService.playClick();
    setState(() => _isContinuousDripping = !_isContinuousDripping);

    if (_isContinuousDripping) {
      _continuousTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted || _buretteVolume >= 50.0) {
          timer.cancel();
          if (mounted) setState(() => _isContinuousDripping = false);
          return;
        }
        _addDrop(amount: 0.25);
      });
    } else {
      _continuousTimer?.cancel();
    }
  }

  void _swirlFlask() {
    SoundService.playStarPop();
    setState(() => _isSwirling = true);
    _swirlAnimController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isSwirling = false;
          if (_buretteVolume < 20.0) {
            _localPinkIntensity = 0.0;
          }
        });
      }
    });
  }

  // Flame test methods
  void _dipWireInSalt(String salt) {
    SoundService.playPop();
    setState(() {
      _selectedFlameSalt = salt;
      _wireHasSalt = true;
      _wireInFlame = true;
    });
  }

  void _toggleWireInFlame() {
    SoundService.playCorrect();
    setState(() => _wireInFlame = !_wireInFlame);
  }

  void _cleanWireLoop() {
    SoundService.playStarPop();
    setState(() {
      _wireHasSalt = false;
      _wireInFlame = false;
    });
  }

  // Calorimetry methods
  void _addCalorimeterSolute() {
    SoundService.playStarPop();
    setState(() {
      _soluteAdded = true;
      _targetTemp = 31.8;
    });

    _tempRiseTimer?.cancel();
    _tempRiseTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (!mounted || _waterTemp >= _targetTemp) {
        t.cancel();
        return;
      }
      setState(() {
        _waterTemp = (_waterTemp + 0.6).clamp(22.0, _targetTemp);
      });
    });
  }

  void _toggleStirring() {
    SoundService.playClick();
    setState(() => _magneticStirring = !_magneticStirring);
  }

  // Smelting methods
  void _loadBlastFurnaceCharge() {
    SoundService.playPop();
    setState(() => _chargeLoaded = true);
  }

  void _toggleTuyereBlast() {
    SoundService.playCorrect();
    setState(() => _tuyereBlastOn = !_tuyereBlastOn);

    if (_tuyereBlastOn) {
      _furnaceTimer?.cancel();
      _furnaceTimer = Timer.periodic(const Duration(milliseconds: 100), (t) {
        if (!mounted || _furnaceTemp >= 1520.0) {
          t.cancel();
          return;
        }
        setState(() {
          _furnaceTemp = (_furnaceTemp + 95.0).clamp(250.0, 1520.0);
        });
      });
    }
  }

  void _tapMoltenIron() {
    SoundService.playSuccess();
    setState(() => _tapHoleOpened = true);
  }

  void _verifyLevel4() {
    _continuousTimer?.cancel();
    setState(() => _isContinuousDripping = false);

    SoundService.playLevelUp();
    setState(() {
      if (_unlockedLevel < 5) _unlockedLevel = 5;
      _currentLevel = 5;
    });
  }

  // --- Level 5 Completion ---
  Future<void> _claimRewardAndFinish() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();
      final expKey = _selectedExperiment.toString().split('.').last;
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'lab_$expKey',
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
      if (mounted) setState(() => _student = updated);
    }

    SoundService.playLevelComplete();
    if (mounted) {
      await QuestCompletionDialog.show(
        context: context,
        title: 'LAB MASTERED!',
        message: 'You completed all 5 levels of ${_getExpName()} with 100% accuracy!',
        xpReward: 60,
        goldReward: 15,
        earnedStars: 3,
        onContinue: () {
          Navigator.pop(context);
          setState(() {
            _selectedExperiment = null;
            _isCompleted = false;
          });
        },
      );
    }
  }

  String _getExpName() {
    switch (_selectedExperiment) {
      case LabExperiment.flameTest:
        return 'Flame Emission Spectra';
      case LabExperiment.calorimetry:
        return 'Solution Calorimetry';
      case LabExperiment.smelting:
        return 'Blast Furnace Metallurgy';
      case LabExperiment.titration:
      default:
        return 'Acid–Base Titration';
    }
  }

  double _getCalculatedPH() {
    final molesAcid = 0.002;
    final molesBase = (_buretteVolume / 1000.0) * 0.1;
    final totalVol = (20.0 + _buretteVolume) / 1000.0;

    if (molesAcid > molesBase) {
      final excess = molesAcid - molesBase;
      return (-log(excess / totalVol) / ln10).clamp(1.0, 6.9);
    } else if ((molesAcid - molesBase).abs() < 0.00001) {
      return 7.0;
    } else {
      final excess = molesBase - molesAcid;
      return (14.0 - (-log(excess / totalVol) / ln10)).clamp(7.1, 13.5);
    }
  }

  Color _getFlaskColor() {
    final ph = _getCalculatedPH();
    if (_buretteVolume >= 20.0) {
      return ph > 9.0 ? const Color(0xDDDB2777) : const Color(0x99F472B6);
    } else if (_localPinkIntensity > 0) {
      return Color.lerp(const Color(0x44BAE6FD), const Color(0x99F472B6), _localPinkIntensity)!;
    } else {
      return const Color(0x44BAE6FD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: _selectedExperiment == null
                    ? _buildExperimentMenu()
                    : _buildActiveExperimentWorkflow(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. EXPERIMENT PICKER MENU
  // ==========================================
  Widget _buildExperimentMenu() {
    final modules = [
      {
        'id': LabExperiment.titration,
        'title': 'Acid–Base Titration',
        'subtitle': 'Quantitative neutralization & molarity (HCl + NaOH)',
        'color': ColorSystem.castlePurple,
        'icon': Icons.science_rounded,
        'tag': 'CHEMISTRY',
      },
      {
        'id': LabExperiment.flameTest,
        'title': 'Flame Emission Spectra',
        'subtitle': 'Excitation of metal salts (Li⁺, Na⁺, K⁺, Cu²⁺)',
        'color': const Color(0xFFD97706),
        'icon': Icons.local_fire_department_rounded,
        'tag': 'PHYSICS',
      },
      {
        'id': LabExperiment.calorimetry,
        'title': 'Solution Calorimetry',
        'subtitle': 'Measure enthalpy & heat capacity (q=mcΔT)',
        'color': const Color(0xFF0284C7),
        'icon': Icons.thermostat_rounded,
        'tag': 'THERMODYNAMICS',
      },
      {
        'id': LabExperiment.smelting,
        'title': 'Blast Furnace Metallurgy',
        'subtitle': 'Reduction of hematite to pig iron at 1500°C',
        'color': const Color(0xFFC2410C),
        'icon': Icons.fireplace_rounded,
        'tag': 'METALLURGY',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Text('VIRTUAL SCIENCE LABS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
              ],
            ),
            if (_student != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
                child: Row(
                  children: [
                    VectorAssetHelper.xpStarIcon(size: 13),
                    const SizedBox(width: 4),
                    Text('${_student!.xp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Dendy Teacher Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
          child: Row(
            children: [
              const DendyMascot(state: DendyState.idle, size: 36),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '"Select any experiment below to begin your hands-on 5-level interactive science lab!"',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25),
                ),
              ),
              const SizedBox(width: 8),
              const DendySpeakButton(textToSpeak: 'Select any experiment below to begin your hands-on 5-level interactive science lab!', size: 22),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 4 Clean Playable Cards
        Expanded(
          child: ListView.separated(
            itemCount: modules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final m = modules[idx];
              final col = m['color'] as Color;

              return InkWell(
                onTap: () => _chooseExperiment(m['id'] as LabExperiment),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: col.withOpacity(0.5), width: 1.6),
                    boxShadow: [
                      BoxShadow(color: ColorSystem.plum.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                        child: Icon(m['icon'] as IconData, size: 24, color: col),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(color: col.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text(m['tag'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, fontWeight: FontWeight.w900, color: col)),
                                ),
                                const SizedBox(width: 6),
                                const Text('5 LEVELS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(m['title'] as String, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                            Text(m['subtitle'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, color: ColorSystem.plum.withOpacity(0.65))),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14, color: col),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. ACTIVE 5-LEVEL EXPERIMENT WORKFLOW
  // ==========================================
  Widget _buildActiveExperimentWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeaderBar(),
        const SizedBox(height: 8),
        _buildLevelPills(),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 1.8),
              boxShadow: [
                BoxShadow(color: ColorSystem.plum.withOpacity(0.06), offset: const Offset(0, 3), blurRadius: 8),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildCurrentLevelView(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _backToMenu,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('VIRTUAL SCIENCE LAB', style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    Text('LEVEL $_currentLevel OF 5 • ${_getExpName().toUpperCase()}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w800, color: ColorSystem.purple)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_student != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
                child: Row(
                  children: [
                    VectorAssetHelper.xpStarIcon(size: 13),
                    const SizedBox(width: 4),
                    Text('${_student!.xp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
                child: Row(
                  children: [
                    VectorAssetHelper.questCoinIcon(size: 13),
                    const SizedBox(width: 4),
                    Text('${_student!.gold}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.gold)),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLevelPills() {
    return Row(
      children: List.generate(5, (index) {
        final levelNum = index + 1;
        final isPassed = _unlockedLevel > levelNum;
        final isActive = _currentLevel == levelNum;
        final isLocked = _unlockedLevel < levelNum;

        Color bg = Colors.white;
        Color border = ColorSystem.plum.withOpacity(0.15);
        Color textColor = ColorSystem.plum.withOpacity(0.5);

        if (isActive) {
          bg = ColorSystem.purple;
          border = ColorSystem.purple;
          textColor = Colors.white;
        } else if (isPassed) {
          bg = ColorSystem.green.withOpacity(0.15);
          border = ColorSystem.green;
          textColor = ColorSystem.green;
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
            child: InkWell(
              onTap: !isLocked ? () => setState(() => _currentLevel = levelNum) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 1.2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPassed) ...[
                      const Icon(Icons.check_rounded, size: 10, color: ColorSystem.green),
                      const SizedBox(width: 3),
                    ] else if (isLocked) ...[
                      Icon(Icons.lock_outline_rounded, size: 9, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                    ],
                    Text('Level $levelNum', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: textColor)),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFoxyTeacherBanner(String speechText, DendyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        border: Border(bottom: BorderSide(color: ColorSystem.plum.withOpacity(0.12), width: 1.2)),
      ),
      child: Row(
        children: [
          DendyMascot(state: state, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(speechText, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25)),
          ),
          const SizedBox(width: 8),
          DendySpeakButton(textToSpeak: speechText, size: 22),
        ],
      ),
    );
  }

  Widget _buildCurrentLevelView() {
    switch (_currentLevel) {
      case 1:
        return _buildLevel1View();
      case 2:
        return _buildLevel2View();
      case 3:
        return _buildLevel3View();
      case 4:
        return _buildLevel4InteractiveWorkbench();
      case 5:
      default:
        return _buildLevel5PerformanceAnalysis();
    }
  }

  // =========================================================================
  // LEVEL 1: 4 CONCEPTS SLIDES
  // =========================================================================
  Widget _buildLevel1View() {
    String teacherMessage;
    Widget slideContent;

    if (_selectedExperiment == LabExperiment.flameTest) {
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: When metal salt cations are heated, electrons absorb thermal energy and jump to excited states!"';
          slideContent = _buildConceptBox('E = h • c / λ (Photon Emission Spectra)', 'Valence electrons relax back down to ground state, releasing precise photon energies as visible emission wavelengths.');
          break;
        case 1:
          teacherMessage = '"Step 2/4: Lithium produces Crimson Red (670nm), while Copper emits Vivid Emerald Green (510nm)!"';
          slideContent = _buildTwoColSlide('LiCl (Lithium)', 'Crimson Red (670 nm)', 'CuSO₄ (Copper)', 'Emerald Green (510 nm)', const Color(0xFFEF4444), const Color(0xFF10B981));
          break;
        case 2:
          teacherMessage = '"Step 3/4: We always use the hot blue non-luminous flame zone with open air collar for clean viewing."';
          slideContent = _buildTwoColSlide('Open Air Collar', 'Hot Blue Flame (1400°C)\nClean test zone', 'Closed Collar', 'Yellow Safety Flame (800°C)\nSmoky, soot interference', Colors.blue, Colors.orange);
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! Which salt produces a persistent golden yellow flame?"';
          slideContent = _buildQuizSlide('CHECKPOINT: Which metal cation produces a persistent golden-yellow flame?', ['Sodium (NaCl) - 589 nm', 'Lithium (LiCl) - 670 nm', 'Copper (CuSO₄) - 510 nm'], 0);
          break;
      }
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: Calorimetry measures heat energy exchanged during chemical dissolution in an insulated vessel."';
          slideContent = _buildConceptBox('q = m • c • ΔT (Enthalpy Equation)', 'Where m is mass of water (100g), c is specific heat capacity (4.184 J/g°C), and ΔT is temperature change.');
          break;
        case 1:
          teacherMessage = '"Step 2/4: Exothermic processes release heat (+ΔT), while endothermic processes absorb heat (-ΔT)."';
          slideContent = _buildTwoColSlide('Exothermic (+q)', 'Heat released\nTemperature rises', 'Endothermic (-q)', 'Heat absorbed\nTemperature falls', Colors.red, Colors.blue);
          break;
        case 2:
          teacherMessage = '"Step 3/4: We use an insulated styrofoam cup calorimeter with precision digital thermometer."';
          slideContent = _buildTwoColSlide('Styrofoam Cup', 'Insulates against heat loss', 'Thermometer Probe', 'Digital precision ±0.1°C', Colors.grey, Colors.blueGrey);
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! What is the specific heat capacity of liquid water?"';
          slideContent = _buildQuizSlide('CHECKPOINT: What is the specific heat capacity (c) of pure water?', ['4.184 J/g°C', '1.000 J/g°C', '10.50 J/g°C'], 0);
          break;
      }
    } else if (_selectedExperiment == LabExperiment.smelting) {
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: Blast furnace smelting reduces hematite iron ore into elemental molten iron using carbon monoxide gas."';
          slideContent = _buildConceptBox('Fe₂O₃ + 3 CO ➔ 2 Fe (liquid) + 3 CO₂', 'Coke burns with hot air blast to form CO reducing gas. Iron ore is reduced to molten pig iron at the furnace hearth (1500°C).');
          break;
        case 1:
          teacherMessage = '"Step 2/4: Limestone (CaCO₃) acts as flux to react with sandy silica impurities and form molten slag."';
          slideContent = _buildTwoColSlide('Raw Charge', 'Hematite Ore + Coke Fuel', 'Flux Agent', 'Limestone ➔ Slag Builder', Colors.brown, Colors.amber);
          break;
        case 2:
          teacherMessage = '"Step 3/4: Hot blast air (1500°C) is pumped through tuyeres at the bottom of the tall blast furnace shaft."';
          slideContent = _buildTwoColSlide('Tuyere Nozzles', 'Injects 1500°C hot blast air', 'Tap Hole', 'Drains pure liquid iron', Colors.orange, Colors.deepOrange);
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! What is the primary chemical reducing agent in the furnace?"';
          slideContent = _buildQuizSlide('CHECKPOINT: What gas reduces hematite (Fe₂O₃) into metallic iron?', ['Carbon Monoxide (CO)', 'Pure Oxygen (O₂)', 'Nitrogen Gas (N₂)'], 0);
          break;
      }
    } else {
      // Titration default
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: In an acid-base titration, hydrochloric acid reacts with sodium hydroxide to form water and salt!"';
          slideContent = _buildConceptBox('HCl (aq) + NaOH (aq) ➔ NaCl (aq) + H₂O (l)', 'Titration determines unknown acid concentration by reacting it with measured volumes of a standard base until neutralization is reached.');
          break;
        case 1:
          teacherMessage = '"Step 2/4: We use standard 0.100 M NaOH titrant in the burette to find the concentration of our 20.0 mL HCl analyte acid."';
          slideContent = _buildTwoColSlide('1. Analyte Acid', 'Hydrochloric Acid (HCl)\n20.00 mL in Flask', '2. Standard Titrant', 'Sodium Hydroxide (NaOH)\n0.100 M in Burette', ColorSystem.coral, ColorSystem.purple);
          break;
        case 2:
          teacherMessage = '"Step 3/4: Phenolphthalein indicator stays clear in acid and turns pale pink the exact moment neutralization happens!"';
          slideContent = _buildTwoColSlide('Acidic pH (< 8.2)', 'COLORLESS / CLEAR\nIndicator stays clear in acid', 'Endpoint (pH 8.2)', 'FAINT PERSISTENT PINK\nExact equivalence point!', Colors.blueGrey, const Color(0xFFEC4899));
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! Select the correct option below to unlock and enter the apparatus lab!"';
          slideContent = _buildQuizSlide('CHECKPOINT: What is the color change of Phenolphthalein at titration endpoint?', ['Colorless in Acid ➔ Pale Persistent Pink at Endpoint', 'Turns Dark Blue in Acid ➔ Red at Endpoint', 'Remains completely clear regardless of pH'], 0);
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(teacherMessage, _quizCorrect ? DendyState.success : DendyState.idle),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: slideContent,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_conceptSlide > 0)
                CustomButton(text: '⮜ Previous', backgroundColor: ColorSystem.lavender, textColor: Colors.white, onPressed: _prevSlide)
              else
                const SizedBox(width: 90),
              Text('Lesson ${_conceptSlide + 1} of 4', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              if (_conceptSlide < 3)
                CustomButton(text: 'Next Concept ➜', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: _nextSlide)
              else
                CustomButton(
                  text: _quizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option',
                  backgroundColor: _quizCorrect ? ColorSystem.green : Colors.grey.shade400,
                  textColor: Colors.white,
                  onPressed: _quizCorrect ? _advanceToLevel2 : () {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConceptBox(String formula, String desc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: ColorSystem.castlePurple, borderRadius: BorderRadius.circular(12)),
          child: Text(formula, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3)),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: ColorSystem.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
          child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, color: ColorSystem.plum, height: 1.35)),
        ),
      ],
    );
  }

  Widget _buildTwoColSlide(String t1, String d1, String t2, String d2, Color c1, Color c2) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: c1.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t1, style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: c1)),
                const SizedBox(height: 6),
                Text(d1, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: c2.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t2, style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: c2)),
                const SizedBox(height: 6),
                Text(d2, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizSlide(String question, List<String> options, int correctIdx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(question, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
        const SizedBox(height: 10),
        ...List.generate(options.length, (idx) {
          final isSelected = _selectedQuizIndex == idx;
          final isRight = idx == correctIdx;
          Color bg = const Color(0xFFF8FAFC);
          Color border = ColorSystem.plum.withOpacity(0.15);

          if (isSelected) {
            bg = isRight ? ColorSystem.green.withOpacity(0.18) : ColorSystem.coral.withOpacity(0.18);
            border = isRight ? ColorSystem.green : ColorSystem.coral;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () => _selectQuizOption(idx, correctIdx),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border, width: 1.2)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: isSelected ? (isRight ? ColorSystem.green : ColorSystem.coral) : ColorSystem.lavender.withOpacity(0.2),
                      child: Text(String.fromCharCode(65 + idx), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : ColorSystem.plum)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(options[idx], style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.bold, color: ColorSystem.plum))),
                    if (isSelected && isRight) const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // =========================================================================
  // LEVEL 2: APPARATUS SELECTION
  // =========================================================================
  Widget _buildLevel2View() {
    List<Map<String, dynamic>> tools;

    if (_selectedExperiment == LabExperiment.flameTest) {
      tools = [
        {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Heating flame', 'req': true},
        {'id': 'loop', 'name': 'Platinum Wire Loop', 'desc': 'Sample carrier', 'req': true},
        {'id': 'watchglass', 'name': 'Watch Glass Dish', 'desc': 'Holds salt crystals', 'req': true},
        {'id': 'clamp', 'name': 'Retort Clamp', 'desc': 'Secures burner safely', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titration dispenser (Wrong)', 'req': false},
        {'id': 'calorimeter', 'name': 'Insulated Cup', 'desc': 'Calorimeter (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      tools = [
        {'id': 'calorimeter', 'name': 'Styrofoam Calorimeter', 'desc': 'Insulated reaction cup', 'req': true},
        {'id': 'thermometer', 'name': 'Precision Thermometer', 'desc': 'Measures ΔT temperature', 'req': true},
        {'id': 'stirrer', 'name': 'Magnetic Stir Bar', 'desc': 'Homogenizes liquid', 'req': true},
        {'id': 'beaker', 'name': '100 mL Glass Beaker', 'desc': 'Holds measured water', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titration tube (Wrong)', 'req': false},
        {'id': 'furnace', 'name': 'Blast Tuyere Rig', 'desc': 'Smelting tool (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      tools = [
        {'id': 'furnace', 'name': 'Blast Furnace Shaft', 'desc': 'Refractory smelting stack', 'req': true},
        {'id': 'tuyere', 'name': 'Hot Air Tuyere Blower', 'desc': '1500°C blast nozzle', 'req': true},
        {'id': 'hopper', 'name': 'Bell Charging Hopper', 'desc': 'Feeds raw hematite & coke', 'req': true},
        {'id': 'ladle', 'name': 'Cast Iron Tap Ladle', 'desc': 'Collects molten pig iron', 'req': true},
        {'id': 'pipette', 'name': '20 mL Pipette', 'desc': 'Liquid aliquot (Wrong)', 'req': false},
        {'id': 'watchglass', 'name': 'Watch Glass', 'desc': 'Flat dish (Wrong)', 'req': false},
      ];
    } else {
      // Titration default
      tools = [
        {'id': 'stand', 'name': 'Retort Stand & Clamp', 'desc': 'Secures burette vertically', 'req': true},
        {'id': 'burette', 'name': '50 mL Glass Burette', 'desc': 'Precision titrant dispenser', 'req': true},
        {'id': 'flask', 'name': '250 mL Conical Flask', 'desc': 'Erlenmeyer reaction vessel', 'req': true},
        {'id': 'pipette', 'name': '20 mL Volumetric Pipette', 'desc': 'Accurate acid aliquot', 'req': true},
        {'id': 'beaker', 'name': '100 mL Glass Beaker', 'desc': 'Stock solution holder (Extra)', 'req': false},
        {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Heating source (Wrong)', 'req': false},
      ];
    }

    final isDone = _assembledApparatus.length >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 2: Select the 4 required apparatus tools for ${_getExpName()}!"',
          isDone ? DendyState.success : DendyState.thinking,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: tools.length,
              itemBuilder: (ctx, idx) {
                final item = tools[idx];
                final isAdded = _assembledApparatus.contains(item['id']);

                return InkWell(
                  onTap: () => _toggleApparatus(item['id'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isAdded ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isAdded ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                        width: isAdded ? 1.6 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(isAdded ? Icons.check_circle_rounded : Icons.science_outlined, size: 22, color: isAdded ? ColorSystem.green : ColorSystem.castlePurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: isAdded ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            text: isDone ? 'START REAGENTS PREPARATION ➜' : 'Select all 4 required tools (${_assembledApparatus.length}/4)',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? _advanceToLevel3 : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 3: REAGENTS PREPARATION
  // =========================================================================
  Widget _buildLevel3View() {
    List<Map<String, dynamic>> reagents;

    if (_selectedExperiment == LabExperiment.flameTest) {
      reagents = [
        {'id': 'licl', 'name': 'Lithium Chloride (LiCl)', 'desc': 'Crimson Red Salt', 'req': true},
        {'id': 'hcl_rinse', 'name': 'Conc. HCl Acid', 'desc': 'Wire Cleaning Solvent', 'req': true},
        {'id': 'cacl2', 'name': 'Calcium Chloride', 'desc': 'Brick Red Salt', 'req': true},
        {'id': 'kcl', 'name': 'Potassium Chloride', 'desc': 'Lilac Violet Salt', 'req': true},
        {'id': 'sugar', 'name': 'Sucrose Sugar', 'desc': 'Organic sugar (Wrong)', 'req': false},
        {'id': 'oil', 'name': 'Cooking Oil', 'desc': 'Nonpolar liquid (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      reagents = [
        {'id': 'h2o_mass', 'name': '100.0 g Distilled Water', 'desc': 'Calorimeter Solvent', 'req': true},
        {'id': 'naoh_solid', 'name': 'Solid NaOH Pellets', 'desc': 'Exothermic Solute (+q)', 'req': true},
        {'id': 'nh4no3', 'name': 'Ammonium Nitrate', 'desc': 'Endothermic Salt (-q)', 'req': true},
        {'id': 'ethanol', 'name': 'Ethanol Fuel', 'desc': 'Organic Solvent (Wrong)', 'req': false},
        {'id': 'sand', 'name': 'Silica Sand', 'desc': 'Insoluble solid (Wrong)', 'req': false},
        {'id': 'oil', 'name': 'Mineral Oil', 'desc': 'Nonpolar Liquid (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      reagents = [
        {'id': 'hematite', 'name': 'Hematite Ore (Fe₂O₃)', 'desc': 'Iron Oxide Source', 'req': true},
        {'id': 'coke', 'name': 'Carbon Coke Fuel', 'desc': 'CO Gas Reducer', 'req': true},
        {'id': 'limestone', 'name': 'Limestone (CaCO₃)', 'desc': 'Slag Flux Builder', 'req': true},
        {'id': 'sand', 'name': 'Quartz Sand', 'desc': 'Silica Impurity (Distractor)', 'req': false},
        {'id': 'copper_ore', 'name': 'Chalcopyrite', 'desc': 'Copper ore (Wrong)', 'req': false},
        {'id': 'water', 'name': 'Liquid Water', 'desc': 'Quenching agent (Wrong)', 'req': false},
      ];
    } else {
      // Titration default
      reagents = [
        {'id': 'hcl', 'name': '0.100 M HCl Acid', 'desc': 'Analyte Solution in Flask', 'req': true},
        {'id': 'naoh', 'name': '0.100 M NaOH Standard', 'desc': 'Standard Titrant in Burette', 'req': true},
        {'id': 'phenolphthalein', 'name': 'Phenolphthalein', 'desc': 'pH 8.2-10.0 Indicator', 'req': true},
        {'id': 'ch3cooh', 'name': '0.100 M Acetic Acid', 'desc': 'Weak Acid (Distractor)', 'req': false},
        {'id': 'methyl_orange', 'name': 'Methyl Orange', 'desc': 'pH 3.1-4.4 Indicator (Distractor)', 'req': false},
        {'id': 'oil', 'name': 'Mineral Oil', 'desc': 'Nonpolar Liquid (Wrong)', 'req': false},
      ];
    }

    final isDone = _selectedReagents.length >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 3: Select at least 2 active chemical reagents required for ${_getExpName()}!"',
          isDone ? DendyState.success : DendyState.thinking,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: reagents.length,
              itemBuilder: (ctx, idx) {
                final item = reagents[idx];
                final isSelected = _selectedReagents.contains(item['id']);

                return InkWell(
                  onTap: () => _toggleReagent(item['id'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? ColorSystem.green : ColorSystem.purple.withOpacity(0.3),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.check_circle_rounded : Icons.opacity_rounded, size: 20, color: isSelected ? ColorSystem.green : ColorSystem.castlePurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: isSelected ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            text: isDone ? 'START VIRTUAL LAB SIMULATOR ➜' : 'Select at least 2 active chemicals (${_selectedReagents.length}/2)',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? _advanceToLevel4 : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 4: INTERACTIVE LAB SIMULATORS
  // =========================================================================
  Widget _buildLevel4InteractiveWorkbench() {
    if (_selectedExperiment == LabExperiment.flameTest) {
      return _buildLevel4FlameInteractive();
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      return _buildLevel4CalorimetryInteractive();
    } else if (_selectedExperiment == LabExperiment.smelting) {
      return _buildLevel4SmeltingInteractive();
    } else {
      return _buildLevel4TitrationInteractive();
    }
  }

  // 1. Titration Interactive View
  Widget _buildLevel4TitrationInteractive() {
    final ph = _getCalculatedPH();
    final liquidColor = _getFlaskColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 4: Turn the stopcock to add NaOH titrant. Swirl regularly. Stop right when a faint persistent pink endpoint appears!"',
          DendyState.thinking,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorSystem.plum.withOpacity(0.12))),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) => LayoutBuilder(
                            builder: (context, constraints) => CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: _MobileTitrationPainter(
                                buretteVolume: _buretteVolume,
                                maxVolume: 50.0,
                                liquidColor: liquidColor,
                                dripProgress: _dripAnimController.value,
                                isSwirling: _isSwirling,
                                swirlProgress: _swirlAnimController.value,
                                animTime: _animController.value,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(color: ColorSystem.plum.withOpacity(0.88), borderRadius: BorderRadius.circular(6)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('V: ${_buretteVolume.toStringAsFixed(2)} mL', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('pH: ${ph.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.gold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(text: '+0.05 mL Drop', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: () => _addDrop(amount: 0.05)),
                      CustomButton(text: '+1.00 mL Fast', backgroundColor: ColorSystem.purple, textColor: Colors.white, onPressed: () => _addDrop(amount: 1.00)),
                      CustomButton(text: '+5.00 mL Pour', backgroundColor: const Color(0xFF6366F1), textColor: Colors.white, onPressed: () => _addDrop(amount: 5.00)),
                      CustomButton(text: _isContinuousDripping ? '⏸ Pause' : '▶ Continuous', backgroundColor: _isContinuousDripping ? ColorSystem.coral : ColorSystem.lavender, textColor: Colors.white, onPressed: _toggleContinuous),
                      CustomButton(text: 'Swirl Flask', backgroundColor: const Color(0xFF0EA5E9), textColor: Colors.white, onPressed: _swirlFlask),
                      CustomButton(text: 'Verify Endpoint', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. Flame Test Interactive View
  Widget _buildLevel4FlameInteractive() {
    final Map<String, dynamic> salts = {
      'licl': {'name': 'LiCl (Lithium)', 'color': const Color(0xFFEF4444), 'lambda': '670 nm Crimson'},
      'nacl': {'name': 'NaCl (Sodium)', 'color': const Color(0xFFFBBF24), 'lambda': '589 nm Golden Yellow'},
      'kcl': {'name': 'KCl (Potassium)', 'color': const Color(0xFFA855F7), 'lambda': '766 nm Lilac Violet'},
      'cuso4': {'name': 'CuSO₄ (Copper)', 'color': const Color(0xFF10B981), 'lambda': '510 nm Emerald Green'},
    };
    final activeSaltInfo = salts[_selectedFlameSalt] ?? salts['licl']!;
    final Color flameColor = _wireInFlame && _wireHasSalt ? (activeSaltInfo['color'] as Color) : const Color(0xFF38BDF8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Dip the platinum wire into metal salts and hold it in the flame to see spectral emissions!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (ctx, _) => LayoutBuilder(
                            builder: (ctx, constraints) => CustomPaint(
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                              painter: _FlameCanvasPainter(
                                flameColor: flameColor,
                                flicker: _animController.value,
                                isWireInFlame: _wireInFlame,
                                wireHasSalt: _wireHasSalt,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              _wireInFlame && _wireHasSalt ? 'Wavelength: ${activeSaltInfo['lambda']}' : 'Status: Blue Flame (1400°C)',
                              style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: _wireInFlame && _wireHasSalt ? (activeSaltInfo['color'] as Color) : Colors.cyanAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(text: 'LiCl (Crimson)', backgroundColor: const Color(0xFFEF4444), textColor: Colors.white, onPressed: () => _dipWireInSalt('licl')),
                      CustomButton(text: 'NaCl (Yellow)', backgroundColor: const Color(0xFFF59E0B), textColor: Colors.white, onPressed: () => _dipWireInSalt('nacl')),
                      CustomButton(text: 'KCl (Lilac)', backgroundColor: const Color(0xFFA855F7), textColor: Colors.white, onPressed: () => _dipWireInSalt('kcl')),
                      CustomButton(text: 'CuSO₄ (Green)', backgroundColor: const Color(0xFF10B981), textColor: Colors.white, onPressed: () => _dipWireInSalt('cuso4')),
                      CustomButton(text: _wireInFlame ? 'Wire in Flame' : 'Hold Wire in Flame', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: _toggleWireInFlame),
                      CustomButton(text: 'Clean Wire in HCl', backgroundColor: ColorSystem.lavender, textColor: Colors.white, onPressed: _cleanWireLoop),
                      CustomButton(text: 'Complete Flame Lab', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Calorimetry Interactive View
  Widget _buildLevel4CalorimetryInteractive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Add the measured solute into the calorimeter, stir, and observe the temperature rise ΔT!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorSystem.plum.withOpacity(0.12))),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (ctx, _) => LayoutBuilder(
                        builder: (ctx, constraints) => CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _CalorimeterPainter(
                            temperature: _waterTemp,
                            isStirring: _magneticStirring,
                            hasSolute: _soluteAdded,
                            animProgress: _animController.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        text: _soluteAdded ? 'NaOH Pellets Added' : 'Drop NaOH Pellets',
                        backgroundColor: _soluteAdded ? ColorSystem.green : ColorSystem.coral,
                        textColor: Colors.white,
                        onPressed: _addCalorimeterSolute,
                      ),
                      CustomButton(
                        text: _magneticStirring ? 'Stirring Active' : 'Start Magnetic Stirrer',
                        backgroundColor: const Color(0xFF0EA5E9),
                        textColor: Colors.white,
                        onPressed: _toggleStirring,
                      ),
                      CustomButton(
                        text: 'Reset Water (22.0°C)',
                        backgroundColor: ColorSystem.lavender,
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            _soluteAdded = false;
                            _waterTemp = 22.0;
                            _targetTemp = 22.0;
                          });
                        },
                      ),
                      CustomButton(text: 'Complete Calorimetry', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. Smelting Interactive View
  Widget _buildLevel4SmeltingInteractive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Load the ore charge, activate the 1500°C blast, and tap the glowing molten pig iron!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (ctx, _) => LayoutBuilder(
                        builder: (ctx, constraints) => CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BlastFurnacePainter(
                            chargeLoaded: _chargeLoaded,
                            blastOn: _tuyereBlastOn,
                            furnaceTemp: _furnaceTemp,
                            isTapped: _tapHoleOpened,
                            animProgress: _animController.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomButton(
                        text: _chargeLoaded ? 'Charge Loaded' : 'Load Ore, Coke & Flux',
                        backgroundColor: ColorSystem.castlePurple,
                        textColor: Colors.white,
                        onPressed: _loadBlastFurnaceCharge,
                      ),
                      CustomButton(
                        text: _tuyereBlastOn ? '1500°C Blast Active' : 'Start 1500°C Hot Blast',
                        backgroundColor: const Color(0xFFF97316),
                        textColor: Colors.white,
                        onPressed: _toggleTuyereBlast,
                      ),
                      CustomButton(
                        text: _tapHoleOpened ? 'Molten Iron Tapped' : 'Drill Tap Hole & Pour',
                        backgroundColor: const Color(0xFFDC2626),
                        textColor: Colors.white,
                        onPressed: _tapMoltenIron,
                      ),
                      CustomButton(text: 'Finish Smelting Lab', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 5: COMPREHENSIVE FINAL PERFORMANCE REPORT
  // =========================================================================
  Widget _buildLevel5PerformanceAnalysis() {
    final diff = (_buretteVolume - _targetEndpoint).abs();
    final calculatedMolarity = _buretteVolume > 0 ? (0.1 * _buretteVolume / 20.0) : 0.0;
    final accuracy = (100.0 - (diff * 5.0)).clamp(70.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 5: Outstanding achievement! Review your laboratory performance report below and claim your trophy!"',
          DendyState.success,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('OVERALL PERFORMANCE ANALYSIS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                    Text('Accuracy: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAnalysisRow('Experiment Module', _getExpName(), Icons.science_rounded),
                        _buildAnalysisRow('Apparatus Accuracy', '4 / 4 Tools Correct', Icons.check_circle_rounded),
                        _buildAnalysisRow('Chemical Reagents', '100% Stoichiometric Match', Icons.opacity_rounded),
                        _buildAnalysisRow('Simulation Target', 'Equivalence Achieved', Icons.straighten_rounded),
                        _buildAnalysisRow('Neutralization Ratio', '1 : 1 Equivalence', Icons.stars_rounded),
                        _buildAnalysisRow('XP & Coin Rewards', '+60 XP  •  +15 Coins', Icons.military_tech_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            text: 'CLAIM 60 XP & COMPLETE MODULE',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            onPressed: _claimRewardAndFinish,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: ColorSystem.castlePurple),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.plum.withOpacity(0.65))),
          ],
        ),
        Text(value, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
      ],
    );
  }
}

// ==========================================
// HIGH FIDELITY CUSTOM PAINTERS (CRASH-PROOF)
// ==========================================

// 1. Titration Custom Painter
class _MobileTitrationPainter extends CustomPainter {
  final double buretteVolume;
  final double maxVolume;
  final Color liquidColor;
  final double dripProgress;
  final bool isSwirling;
  final double swirlProgress;
  final double animTime;

  _MobileTitrationPainter({
    required this.buretteVolume,
    required this.maxVolume,
    required this.liquidColor,
    required this.dripProgress,
    required this.isSwirling,
    required this.swirlProgress,
    required this.animTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 10 || size.height <= 10) return;

    final cx = size.width * 0.55;
    final standX = size.width * 0.20;

    // Retort Stand Base & Rod
    final standPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(standX, size.height * 0.94), width: 45, height: 7), const Radius.circular(2)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawLine(Offset(standX, size.height * 0.94), Offset(standX, size.height * 0.06), standPaint);
    canvas.drawLine(Offset(standX, size.height * 0.26), Offset(cx, size.height * 0.26), standPaint..strokeWidth = 2.5);

    // Burette Body
    final bTop = size.height * 0.08;
    final bBottom = size.height * 0.54;
    final bWidth = 11.0;
    final bRect = Rect.fromCenter(center: Offset(cx, (bTop + bBottom) / 2), width: bWidth, height: (bBottom - bTop).abs());

    final fraction = (1.0 - (buretteVolume / maxVolume)).clamp(0.0, 1.0);
    final liqTop = bTop + (bBottom - bTop) * (1.0 - fraction);
    canvas.drawRect(Rect.fromLTRB(cx - bWidth / 2 + 1, liqTop, cx + bWidth / 2 - 1, bBottom), Paint()..color = const Color(0x66BAE6FD));
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF475569)..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // Stopcock & Tip
    final valveY = bBottom + 6;
    canvas.drawCircle(Offset(cx, valveY), 3.5, Paint()..color = const Color(0xFFEF4444));
    canvas.drawLine(Offset(cx, valveY), Offset(cx, valveY + 10), Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5);

    if (dripProgress > 0.0 && dripProgress < 1.0) {
      final dropY = (valveY + 10) + (size.height * 0.76 - (valveY + 10)) * dripProgress;
      canvas.drawCircle(Offset(cx, dropY), 2.5, Paint()..color = const Color(0xFF38BDF8));
    }

    // Conical Flask
    final fTop = size.height * 0.66;
    final fBottom = size.height * 0.92;
    final fPath = Path()
      ..moveTo(cx - 7, fTop)
      ..lineTo(cx + 7, fTop)
      ..lineTo(cx + 7, fTop + 8)
      ..lineTo(cx + 26, fBottom)
      ..lineTo(cx - 26, fBottom)
      ..lineTo(cx - 7, fTop + 8)
      ..close();

    final liqY = fBottom - 18;
    final liqPath = Path()..moveTo(cx - 16, liqY);
    if (isSwirling) {
      final wave = sin(swirlProgress * pi * 4) * 2.5;
      liqPath.quadraticBezierTo(cx, liqY + wave, cx + 16, liqY);
    } else {
      liqPath.lineTo(cx + 16, liqY);
    }
    liqPath.lineTo(cx + 25, fBottom - 1);
    liqPath.lineTo(cx - 25, fBottom - 1);
    liqPath.close();

    canvas.drawPath(liqPath, Paint()..color = liquidColor);
    canvas.drawPath(fPath, Paint()..color = const Color(0xFF334155)..strokeWidth = 1.5..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _MobileTitrationPainter oldDelegate) => true;
}

// 2. Flame Test Custom Painter
class _FlameCanvasPainter extends CustomPainter {
  final Color flameColor;
  final double flicker;
  final bool isWireInFlame;
  final bool wireHasSalt;

  _FlameCanvasPainter({
    required this.flameColor,
    required this.flicker,
    required this.isWireInFlame,
    required this.wireHasSalt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 10 || size.height <= 10) return;

    final cx = size.width / 2;
    final cy = size.height * 0.65;

    // Bunsen Burner
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 30), width: 18, height: 40), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 50), width: 54, height: 8), Paint()..color = const Color(0xFF1E293B));

    // Flame Cones
    final flameH = 50 + sin(flicker * pi * 2) * 6;
    final outerFlame = Path()
      ..moveTo(cx - 12, cy + 10)
      ..quadraticBezierTo(cx - 14, cy - flameH * 0.5, cx, cy - flameH)
      ..quadraticBezierTo(cx + 14, cy - flameH * 0.5, cx + 12, cy + 10)
      ..close();
    canvas.drawPath(outerFlame, Paint()..color = flameColor.withOpacity(0.85));

    // Inner Cone
    final innerFlame = Path()
      ..moveTo(cx - 6, cy + 10)
      ..quadraticBezierTo(cx - 7, cy - flameH * 0.25, cx, cy - flameH * 0.5)
      ..quadraticBezierTo(cx + 7, cy - flameH * 0.25, cx + 6, cy + 10)
      ..close();
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFF38BDF8).withOpacity(0.9));

    // Platinum Wire
    final wireX = isWireInFlame ? cx : cx + 32;
    final wireY = isWireInFlame ? cy - 18 : cy + 15;
    final wirePaint = Paint()..color = Colors.white70..strokeWidth = 1.6;
    canvas.drawLine(Offset(size.width - 8, size.height * 0.3), Offset(wireX, wireY), wirePaint);
    canvas.drawCircle(Offset(wireX, wireY), 3.0, Paint()..color = wireHasSalt ? Colors.amberAccent : Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(covariant _FlameCanvasPainter oldDelegate) => true;
}

// 3. Calorimeter Custom Painter
class _CalorimeterPainter extends CustomPainter {
  final double temperature;
  final bool isStirring;
  final bool hasSolute;
  final double animProgress;

  _CalorimeterPainter({
    required this.temperature,
    required this.isStirring,
    required this.hasSolute,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 10 || size.height <= 10) return;

    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Outer Insulated Cup
    final cup = Rect.fromCenter(center: Offset(cx, cy), width: 70, height: 80);
    canvas.drawRRect(RRect.fromRectAndRadius(cup, const Radius.circular(8)), Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawRRect(RRect.fromRectAndRadius(cup, const Radius.circular(8)), Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Water
    final water = Rect.fromCenter(center: Offset(cx, cy + 8), width: 62, height: 56);
    canvas.drawRRect(RRect.fromRectAndRadius(water, const Radius.circular(6)), Paint()..color = const Color(0x6638BDF8));

    // Stir Bar
    if (isStirring) {
      final angle = animProgress * pi * 2;
      canvas.save();
      canvas.translate(cx, cy + 28);
      canvas.rotate(angle);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 18, height: 4), const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.restore();
    }

    // Thermometer Probe
    canvas.drawRect(Rect.fromLTWH(cx + 12, cy - 50, 4, 75), Paint()..color = const Color(0xFFEF4444));

    // Digital Readout Box
    final box = Rect.fromCenter(center: Offset(cx, cy - 35), width: 60, height: 18);
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = const Color(0xFF1E293B));
    final tp = TextPainter(
      text: TextSpan(text: '${temperature.toStringAsFixed(1)} °C', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 41));
  }

  @override
  bool shouldRepaint(covariant _CalorimeterPainter oldDelegate) => true;
}

// 4. Blast Furnace Custom Painter
class _BlastFurnacePainter extends CustomPainter {
  final bool chargeLoaded;
  final bool blastOn;
  final double furnaceTemp;
  final bool isTapped;
  final double animProgress;

  _BlastFurnacePainter({
    required this.chargeLoaded,
    required this.blastOn,
    required this.furnaceTemp,
    required this.isTapped,
    required this.animProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 10 || size.height <= 10) return;

    final cx = size.width / 2;

    // Blast Furnace Stack
    final path = Path()
      ..moveTo(cx - 15, size.height * 0.12)
      ..lineTo(cx + 15, size.height * 0.12)
      ..lineTo(cx + 28, size.height * 0.65)
      ..lineTo(cx + 20, size.height * 0.88)
      ..lineTo(cx - 20, size.height * 0.88)
      ..lineTo(cx - 28, size.height * 0.65)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF334155));
    canvas.drawPath(path, Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 2);

    // Charge Layers
    if (chargeLoaded) {
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, size.height * 0.32), width: 34, height: 16), Paint()..color = const Color(0xFF78350F));
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, size.height * 0.48), width: 44, height: 16), Paint()..color = const Color(0xFF1E293B));
    }

    // 1500°C Tuyere Hot Blast Zone
    if (blastOn) {
      final flameP = Paint()..color = Color.lerp(const Color(0xFFF97316), const Color(0xFFEF4444), animProgress)!;
      canvas.drawCircle(Offset(cx, size.height * 0.76), 14, flameP);
    }

    // Molten Iron Tapping Stream
    if (isTapped) {
      final tapPaint = Paint()..color = const Color(0xFFF97316)..strokeWidth = 3.5;
      canvas.drawLine(Offset(cx + 18, size.height * 0.84), Offset(size.width - 10, size.height * 0.92), tapPaint);
      canvas.drawCircle(Offset(size.width - 10, size.height * 0.92), 4, Paint()..color = Colors.amberAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _BlastFurnacePainter oldDelegate) => true;
}

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
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _dripAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _swirlAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
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
      if (_buretteVolume >= 19.4 && _buretteVolume < 20.0) {
        _localPinkIntensity = 0.55;
      } else if (_buretteVolume >= 20.0) {
        _localPinkIntensity = 1.0;
      }
    });
  }

  void _toggleContinuous() {
    SoundService.playClick();
    setState(() => _isContinuousDripping = !_isContinuousDripping);

    if (_isContinuousDripping) {
      _continuousTimer = Timer.periodic(const Duration(milliseconds: 110), (timer) {
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
          if (_buretteVolume < 19.8) {
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
        message: 'You completed all 5 levels of ${_getExpName()} with 100% precision!',
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
      return ph > 9.5 ? const Color(0xEEDB2777) : const Color(0xBBF472B6);
    } else if (_localPinkIntensity > 0) {
      return Color.lerp(const Color(0x33BAE6FD), const Color(0xBBF472B6), _localPinkIntensity)!;
    } else {
      return const Color(0x33BAE6FD);
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        'subtitle': 'Quantitative neutralization (HCl + NaOH)',
        'color': ColorSystem.castlePurple,
        'icon': Icons.science_rounded,
        'tag': 'CHEMISTRY',
      },
      {
        'id': LabExperiment.flameTest,
        'title': 'Flame Emission Spectra',
        'subtitle': 'Photon excitation (Li⁺, Na⁺, K⁺, Cu²⁺)',
        'color': const Color(0xFFD97706),
        'icon': Icons.local_fire_department_rounded,
        'tag': 'PHYSICS',
      },
      {
        'id': LabExperiment.calorimetry,
        'title': 'Solution Calorimetry',
        'subtitle': 'Enthalpy & heat capacity (q=mcΔT)',
        'color': const Color(0xFF0284C7),
        'icon': Icons.thermostat_rounded,
        'tag': 'THERMODYNAMICS',
      },
      {
        'id': LabExperiment.smelting,
        'title': 'Blast Furnace Metallurgy',
        'subtitle': 'Hematite reduction to iron at 1500°C',
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
                const SizedBox(width: 8),
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
        const SizedBox(height: 6),

        // Dendy Teacher Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
          child: Row(
            children: [
              const DendyMascot(state: DendyState.idle, size: 34),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '"Select any experiment below to begin your hands-on 5-level interactive science lab!"',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.2),
                ),
              ),
              const SizedBox(width: 6),
              const DendySpeakButton(textToSpeak: 'Select any experiment below to begin your hands-on 5-level interactive science lab!', size: 20),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 4 Clean Playable Cards (2x2 Grid)
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: modules.length,
            itemBuilder: (ctx, idx) {
              final m = modules[idx];
              final col = m['color'] as Color;

              return InkWell(
                onTap: () => _chooseExperiment(m['id'] as LabExperiment),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: col.withOpacity(0.5), width: 1.6),
                    boxShadow: [
                      BoxShadow(color: ColorSystem.plum.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: col.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                            child: Icon(m['icon'] as IconData, size: 20, color: col),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(color: ColorSystem.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                            child: const Text('5 LEVELS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['title'] as String, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                          Text(m['subtitle'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: ColorSystem.plum.withOpacity(0.65)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
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
        const SizedBox(height: 6),
        _buildLevelPills(),
        const SizedBox(height: 6),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ColorSystem.plum, width: 1.6),
              boxShadow: [
                BoxShadow(color: ColorSystem.plum.withOpacity(0.06), offset: const Offset(0, 3), blurRadius: 8),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
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
                icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _backToMenu,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('VIRTUAL SCIENCE LAB', style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    Text('LEVEL $_currentLevel OF 5 • ${_getExpName().toUpperCase()}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w800, color: ColorSystem.purple)),
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
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
                child: Row(
                  children: [
                    VectorAssetHelper.xpStarIcon(size: 12),
                    const SizedBox(width: 4),
                    Text('${_student!.xp} XP', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: ColorSystem.plum.withOpacity(0.15))),
                child: Row(
                  children: [
                    VectorAssetHelper.questCoinIcon(size: 12),
                    const SizedBox(width: 4),
                    Text('${_student!.gold}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.gold)),
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
            padding: EdgeInsets.only(right: index == 4 ? 0 : 5),
            child: InkWell(
              onTap: !isLocked ? () => setState(() => _currentLevel = levelNum) : null,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6), border: Border.all(color: border, width: 1.2)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isPassed) ...[
                      const Icon(Icons.check_rounded, size: 9, color: ColorSystem.green),
                      const SizedBox(width: 2),
                    ] else if (isLocked) ...[
                      Icon(Icons.lock_outline_rounded, size: 8, color: Colors.grey.shade400),
                      const SizedBox(width: 2),
                    ],
                    Text('Level $levelNum', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: textColor)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        border: Border(bottom: BorderSide(color: ColorSystem.plum.withOpacity(0.12), width: 1.2)),
      ),
      child: Row(
        children: [
          DendyMascot(state: state, size: 34),
          const SizedBox(width: 8),
          Expanded(
            child: Text(speechText, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.2)),
          ),
          const SizedBox(width: 6),
          DendySpeakButton(textToSpeak: speechText, size: 18),
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
  // LEVEL 1: 4 CONCEPTS SLIDES (COMPACT CARDS)
  // =========================================================================
  Widget _buildLevel1View() {
    String teacherMessage;
    Widget slideContent;

    if (_selectedExperiment == LabExperiment.flameTest) {
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: When metal salt cations are heated, valence electrons absorb energy and jump to excited states!"';
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: slideContent,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_conceptSlide > 0)
                SizedBox(
                  width: 100,
                  child: CustomButton(
                    width: 100,
                    height: 34,
                    text: '⮜ Previous',
                    backgroundColor: ColorSystem.lavender,
                    textColor: Colors.white,
                    onPressed: _prevSlide,
                  ),
                )
              else
                const SizedBox(width: 100),
              Text('Lesson ${_conceptSlide + 1} of 4', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              if (_conceptSlide < 3)
                SizedBox(
                  width: 130,
                  child: CustomButton(
                    width: 130,
                    height: 34,
                    text: 'Next Concept ➜',
                    backgroundColor: ColorSystem.castlePurple,
                    textColor: Colors.white,
                    onPressed: _nextSlide,
                  ),
                )
              else
                SizedBox(
                  width: 190,
                  child: CustomButton(
                    width: 190,
                    height: 34,
                    text: _quizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option',
                    backgroundColor: _quizCorrect ? ColorSystem.green : Colors.grey.shade400,
                    textColor: Colors.white,
                    onPressed: _quizCorrect ? _advanceToLevel2 : () {},
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConceptBox(String formula, String desc) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: ColorSystem.castlePurple, borderRadius: BorderRadius.circular(8)),
          child: Text(formula, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.2)),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ColorSystem.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
          child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, color: ColorSystem.plum, height: 1.3)),
        ),
      ],
    );
  }

  Widget _buildTwoColSlide(String t1, String d1, String t2, String d2, Color c1, Color c2) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: c1.withOpacity(0.4), width: 1.2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t1, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: c1)),
                const SizedBox(height: 3),
                Text(d1, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: c2.withOpacity(0.4), width: 1.2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t2, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: c2)),
                const SizedBox(height: 3),
                Text(d2, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.7))),
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
        Text(question, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
        const SizedBox(height: 6),
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
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () => _selectQuizOption(idx, correctIdx),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: border, width: 1.2)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundColor: isSelected ? (isRight ? ColorSystem.green : ColorSystem.coral) : ColorSystem.lavender.withOpacity(0.2),
                      child: Text(String.fromCharCode(65 + idx), style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : ColorSystem.plum)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(options[idx], style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: ColorSystem.plum))),
                    if (isSelected && isRight) const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 16),
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
  // LEVEL 2: APPARATUS SELECTION (COMPACT 2x3 GRID)
  // =========================================================================
  Widget _buildLevel2View() {
    List<Map<String, dynamic>> tools;

    if (_selectedExperiment == LabExperiment.flameTest) {
      tools = [
        {'id': 'burner', 'name': 'Bunsen Burner', 'desc': 'Heating flame', 'req': true},
        {'id': 'loop', 'name': 'Platinum Loop', 'desc': 'Sample carrier', 'req': true},
        {'id': 'watchglass', 'name': 'Watch Glass', 'desc': 'Holds crystals', 'req': true},
        {'id': 'clamp', 'name': 'Retort Clamp', 'desc': 'Secures burner', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titration tube (Wrong)', 'req': false},
        {'id': 'calorimeter', 'name': 'Insulated Cup', 'desc': 'Calorimeter (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      tools = [
        {'id': 'calorimeter', 'name': 'Styrofoam Cup', 'desc': 'Insulated cup', 'req': true},
        {'id': 'thermometer', 'name': 'Thermometer', 'desc': 'Measures ΔT', 'req': true},
        {'id': 'stirrer', 'name': 'Stir Bar', 'desc': 'Stirs liquid', 'req': true},
        {'id': 'beaker', 'name': '100 mL Beaker', 'desc': 'Water vessel', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titration tube (Wrong)', 'req': false},
        {'id': 'furnace', 'name': 'Tuyere Rig', 'desc': 'Smelting (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      tools = [
        {'id': 'furnace', 'name': 'Furnace Shaft', 'desc': 'Smelting stack', 'req': true},
        {'id': 'tuyere', 'name': 'Tuyere Blower', 'desc': '1500°C blast', 'req': true},
        {'id': 'hopper', 'name': 'Charging Hopper', 'desc': 'Feeds ore & coke', 'req': true},
        {'id': 'ladle', 'name': 'Tap Ladle', 'desc': 'Collects iron', 'req': true},
        {'id': 'pipette', 'name': '20 mL Pipette', 'desc': 'Aliquot (Wrong)', 'req': false},
        {'id': 'watchglass', 'name': 'Watch Glass', 'desc': 'Dish (Wrong)', 'req': false},
      ];
    } else {
      // Titration default
      tools = [
        {'id': 'stand', 'name': 'Retort Stand', 'desc': 'Secures burette', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titrant tube', 'req': true},
        {'id': 'flask', 'name': 'Conical Flask', 'desc': 'Reaction vessel', 'req': true},
        {'id': 'pipette', 'name': '20 mL Pipette', 'desc': 'Acid aliquot', 'req': true},
        {'id': 'beaker', 'name': '100 mL Beaker', 'desc': 'Stock holder (Extra)', 'req': false},
        {'id': 'burner', 'name': 'Bunsen Burner', 'desc': 'Flame (Wrong)', 'req': false},
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
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: tools.length,
              itemBuilder: (ctx, idx) {
                final item = tools[idx];
                final isAdded = _assembledApparatus.contains(item['id']);

                return InkWell(
                  onTap: () => _toggleApparatus(item['id'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdded ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdded ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                        width: isAdded ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(isAdded ? Icons.check_circle_rounded : Icons.science_outlined, size: 18, color: isAdded ? ColorSystem.green : ColorSystem.castlePurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: isAdded ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            height: 36,
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
  // LEVEL 3: REAGENTS PREPARATION (COMPACT 2x3 GRID)
  // =========================================================================
  Widget _buildLevel3View() {
    List<Map<String, dynamic>> reagents;

    if (_selectedExperiment == LabExperiment.flameTest) {
      reagents = [
        {'id': 'licl', 'name': 'LiCl (Lithium)', 'desc': 'Crimson Red Salt', 'req': true},
        {'id': 'hcl_rinse', 'name': 'Conc. HCl Acid', 'desc': 'Cleaning Solvent', 'req': true},
        {'id': 'cacl2', 'name': 'CaCl₂ Salt', 'desc': 'Brick Red Salt', 'req': true},
        {'id': 'kcl', 'name': 'KCl (Potassium)', 'desc': 'Lilac Violet Salt', 'req': true},
        {'id': 'sugar', 'name': 'Sucrose Sugar', 'desc': 'Sugar (Wrong)', 'req': false},
        {'id': 'oil', 'name': 'Cooking Oil', 'desc': 'Oil (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      reagents = [
        {'id': 'h2o_mass', 'name': '100.0 g Water', 'desc': 'Calorimeter Solvent', 'req': true},
        {'id': 'naoh_solid', 'name': 'Solid NaOH', 'desc': 'Exothermic (+q)', 'req': true},
        {'id': 'nh4no3', 'name': 'NH₄NO₃ Salt', 'desc': 'Endothermic (-q)', 'req': true},
        {'id': 'ethanol', 'name': 'Ethanol Fuel', 'desc': 'Solvent (Wrong)', 'req': false},
        {'id': 'sand', 'name': 'Silica Sand', 'desc': 'Sand (Wrong)', 'req': false},
        {'id': 'oil', 'name': 'Mineral Oil', 'desc': 'Oil (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      reagents = [
        {'id': 'hematite', 'name': 'Hematite (Fe₂O₃)', 'desc': 'Iron Ore Source', 'req': true},
        {'id': 'coke', 'name': 'Carbon Coke', 'desc': 'CO Gas Reducer', 'req': true},
        {'id': 'limestone', 'name': 'Limestone (CaCO₃)', 'desc': 'Slag Flux Builder', 'req': true},
        {'id': 'sand', 'name': 'Quartz Sand', 'desc': 'Silica (Impurity)', 'req': false},
        {'id': 'copper_ore', 'name': 'Chalcopyrite', 'desc': 'Copper (Wrong)', 'req': false},
        {'id': 'water', 'name': 'Liquid Water', 'desc': 'Water (Wrong)', 'req': false},
      ];
    } else {
      // Titration default
      reagents = [
        {'id': 'hcl', 'name': '0.100 M HCl Acid', 'desc': 'Analyte Solution', 'req': true},
        {'id': 'naoh', 'name': '0.100 M NaOH', 'desc': 'Standard Titrant', 'req': true},
        {'id': 'phenolphthalein', 'name': 'Phenolphthalein', 'desc': 'pH Indicator', 'req': true},
        {'id': 'ch3cooh', 'name': '0.100 M Acetic Acid', 'desc': 'Weak Acid (Wrong)', 'req': false},
        {'id': 'methyl_orange', 'name': 'Methyl Orange', 'desc': 'Indicator (Wrong)', 'req': false},
        {'id': 'oil', 'name': 'Mineral Oil', 'desc': 'Oil (Wrong)', 'req': false},
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
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: reagents.length,
              itemBuilder: (ctx, idx) {
                final item = reagents[idx];
                final isSelected = _selectedReagents.contains(item['id']);

                return InkWell(
                  onTap: () => _toggleReagent(item['id'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? ColorSystem.green : ColorSystem.purple.withOpacity(0.3),
                        width: isSelected ? 1.4 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(isSelected ? Icons.check_circle_rounded : Icons.opacity_rounded, size: 18, color: isSelected ? ColorSystem.green : ColorSystem.castlePurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: isSelected ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            height: 36,
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
  // LEVEL 4: INTERACTIVE LAB SIMULATORS (RESPONSIVE VIEWPORT-FITTING)
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

  // 1. Titration Interactive View (Rich Visuals + Compact Controls)
  Widget _buildLevel4TitrationInteractive() {
    final ph = _getCalculatedPH();
    final liquidColor = _getFlaskColor();

    String statusText;
    Color statusColor;
    if (_buretteVolume < 18.0) {
      statusText = 'Acidic Solution (pH < 7)';
      statusColor = const Color(0xFF38BDF8);
    } else if (_buretteVolume >= 18.0 && _buretteVolume < 19.9) {
      statusText = 'Near Equivalence (Swirl frequently)';
      statusColor = const Color(0xFFFBBF24);
    } else if (_buretteVolume >= 19.9 && _buretteVolume <= 20.3) {
      statusText = '🎯 EQUIVALENCE POINT (pH 8.2 • Faint Pink)';
      statusColor = ColorSystem.green;
    } else {
      statusText = 'Over-titrated (Excess NaOH)';
      statusColor = ColorSystem.coral;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 4: Turn stopcock to add NaOH titrant. Swirl regularly. Stop right when persistent faint pink appears!"',
          _buretteVolume >= 19.9 && _buretteVolume <= 20.3 ? DendyState.success : DendyState.thinking,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                // Simulation Canvas
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.12)),
                    ),
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
                        // HUD Overlay
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: ColorSystem.plum.withOpacity(0.88), borderRadius: BorderRadius.circular(5)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('V: ${_buretteVolume.toStringAsFixed(2)} mL', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white)),
                                Text('pH: ${ph.toStringAsFixed(2)}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: ColorSystem.gold)),
                              ],
                            ),
                          ),
                        ),
                        // Reaction Status Pill
                        Positioned(
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                            child: Text(statusText, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Compact Responsive Controls Grid (2 columns)
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildCompactButton('+0.05 mL', ColorSystem.castlePurple, () => _addDrop(amount: 0.05))),
                          const SizedBox(width: 4),
                          Expanded(child: _buildCompactButton('+1.00 mL', ColorSystem.purple, () => _addDrop(amount: 1.00))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCompactButton('+5.00 mL', const Color(0xFF6366F1), () => _addDrop(amount: 5.00))),
                          const SizedBox(width: 4),
                          Expanded(child: _buildCompactButton(_isContinuousDripping ? '⏸ Pause' : '▶ Auto', _isContinuousDripping ? ColorSystem.coral : ColorSystem.lavender, _toggleContinuous)),
                        ],
                      ),
                      _buildCompactButton('🌀 Swirl Flask', const Color(0xFF0EA5E9), _swirlFlask),
                      _buildCompactButton('🎯 Verify Endpoint', ColorSystem.green, _verifyLevel4),
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
      'licl': {'name': 'LiCl', 'color': const Color(0xFFEF4444), 'lambda': '670 nm Crimson'},
      'nacl': {'name': 'NaCl', 'color': const Color(0xFFFBBF24), 'lambda': '589 nm Yellow'},
      'kcl': {'name': 'KCl', 'color': const Color(0xFFA855F7), 'lambda': '766 nm Lilac'},
      'cuso4': {'name': 'CuSO₄', 'color': const Color(0xFF10B981), 'lambda': '510 nm Green'},
    };
    final activeSaltInfo = salts[_selectedFlameSalt] ?? salts['licl']!;
    final Color flameColor = _wireInFlame && _wireHasSalt ? (activeSaltInfo['color'] as Color) : const Color(0xFF38BDF8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Dip platinum wire into salts and hold it in the flame to observe emission spectra!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
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
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              _wireInFlame && _wireHasSalt ? 'Wavelength: ${activeSaltInfo['lambda']}' : 'Status: Blue Flame (1400°C)',
                              style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: _wireInFlame && _wireHasSalt ? (activeSaltInfo['color'] as Color) : Colors.cyanAccent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildCompactButton('LiCl', const Color(0xFFEF4444), () => _dipWireInSalt('licl'))),
                          const SizedBox(width: 4),
                          Expanded(child: _buildCompactButton('NaCl', const Color(0xFFF59E0B), () => _dipWireInSalt('nacl'))),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: _buildCompactButton('KCl', const Color(0xFFA855F7), () => _dipWireInSalt('kcl'))),
                          const SizedBox(width: 4),
                          Expanded(child: _buildCompactButton('CuSO₄', const Color(0xFF10B981), () => _dipWireInSalt('cuso4'))),
                        ],
                      ),
                      _buildCompactButton(_wireInFlame ? 'Wire in Flame' : '🔥 Hold in Flame', ColorSystem.castlePurple, _toggleWireInFlame),
                      _buildCompactButton('🧼 Clean Loop (HCl)', ColorSystem.lavender, _cleanWireLoop),
                      _buildCompactButton('🎯 Complete Flame Lab', ColorSystem.green, _verifyLevel4),
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
        _buildFoxyTeacherBanner('"Level 4: Add measured solute into calorimeter, stir, and observe temperature rise ΔT!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.12))),
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
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactButton(_soluteAdded ? 'NaOH Added' : 'Drop NaOH Pellets', _soluteAdded ? ColorSystem.green : ColorSystem.coral, _addCalorimeterSolute),
                      _buildCompactButton(_magneticStirring ? 'Stirring Active' : '▶ Start Stirrer', const Color(0xFF0EA5E9), _toggleStirring),
                      _buildCompactButton('Reset (22.0°C)', ColorSystem.lavender, () {
                        setState(() {
                          _soluteAdded = false;
                          _waterTemp = 22.0;
                          _targetTemp = 22.0;
                        });
                      }),
                      _buildCompactButton('🎯 Complete Calorimetry', ColorSystem.green, _verifyLevel4),
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
        _buildFoxyTeacherBanner('"Level 4: Load ore charge, activate 1500°C blast, and tap glowing molten iron!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
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
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCompactButton(_chargeLoaded ? 'Charge Loaded' : 'Load Ore & Coke', ColorSystem.castlePurple, _loadBlastFurnaceCharge),
                      _buildCompactButton(_tuyereBlastOn ? '1500°C Active' : '🔥 Start 1500°C Blast', const Color(0xFFF97316), _toggleTuyereBlast),
                      _buildCompactButton(_tapHoleOpened ? 'Iron Tapped' : '⛏️ Drill & Pour', const Color(0xFFDC2626), _tapMoltenIron),
                      _buildCompactButton('🎯 Finish Smelting Lab', ColorSystem.green, _verifyLevel4),
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

  Widget _buildCompactButton(String text, Color bg, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 32,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(color: bg.withOpacity(0.3), blurRadius: 2, offset: const Offset(0, 1.5)),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
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
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('OVERALL PERFORMANCE ANALYSIS', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                    Text('Accuracy: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            height: 36,
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
            Icon(icon, size: 12, color: ColorSystem.castlePurple),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: ColorSystem.plum.withOpacity(0.65))),
          ],
        ),
        Text(value, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
      ],
    );
  }
}

// ==========================================
// HIGH FIDELITY CUSTOM PAINTERS (RICH VISUALS)
// ==========================================

// 1. Titration Custom Painter (Graduations, Meniscus, Bubbles, Ripples, Swirl Vortex)
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

    final cx = size.width * 0.52;
    final standX = size.width * 0.18;

    // 1. Retort Stand Base & Rod
    final standPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(standX, size.height * 0.94), width: 44, height: 7), const Radius.circular(2)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawLine(Offset(standX, size.height * 0.94), Offset(standX, size.height * 0.05), standPaint);
    canvas.drawLine(Offset(standX, size.height * 0.24), Offset(cx, size.height * 0.24), standPaint..strokeWidth = 2.5);

    // 2. Burette Body with Graduations
    final bTop = size.height * 0.06;
    final bBottom = size.height * 0.52;
    final bWidth = 12.0;
    final bRect = Rect.fromCenter(center: Offset(cx, (bTop + bBottom) / 2), width: bWidth, height: (bBottom - bTop).abs());

    final fraction = (1.0 - (buretteVolume / maxVolume)).clamp(0.0, 1.0);
    final liqTop = bTop + (bBottom - bTop) * (1.0 - fraction);

    // Liquid in burette
    canvas.drawRect(Rect.fromLTRB(cx - bWidth / 2 + 1, liqTop, cx + bWidth / 2 - 1, bBottom), Paint()..color = const Color(0x77BAE6FD));

    // Meniscus curved surface
    final meniscusPath = Path()
      ..moveTo(cx - bWidth / 2 + 1, liqTop)
      ..quadraticBezierTo(cx, liqTop + 1.5, cx + bWidth / 2 - 1, liqTop)
      ..close();
    canvas.drawPath(meniscusPath, Paint()..color = const Color(0xCC38BDF8));

    // Glass outline
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF475569)..strokeWidth = 1.2..style = PaintingStyle.stroke);

    // Graduations (ticks on right side of burette)
    final tickPaint = Paint()..color = const Color(0xFF475569)..strokeWidth = 0.8;
    for (int i = 0; i <= 10; i++) {
      final y = bTop + (bBottom - bTop) * (i / 10.0);
      final isMajor = i % 2 == 0;
      canvas.drawLine(Offset(cx + bWidth / 2 - (isMajor ? 4 : 2), y), Offset(cx + bWidth / 2, y), tickPaint);
    }

    // 3. Stopcock & Tip
    final valveY = bBottom + 6;
    // Valve knob
    canvas.drawCircle(Offset(cx, valveY), 3.5, Paint()..color = const Color(0xFFEF4444));
    // Valve handle
    final handleAngle = (buretteVolume * 0.5) % (pi * 2);
    canvas.drawLine(
      Offset(cx - cos(handleAngle) * 4, valveY - sin(handleAngle) * 4),
      Offset(cx + cos(handleAngle) * 4, valveY + sin(handleAngle) * 4),
      Paint()..color = Colors.white..strokeWidth = 1.2,
    );
    // Tip
    canvas.drawLine(Offset(cx, valveY), Offset(cx, valveY + 9), Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5);

    // 4. Falling Droplet with Splash Physics
    final flaskTopY = size.height * 0.65;
    if (dripProgress > 0.0 && dripProgress < 1.0) {
      final dropY = (valveY + 9) + (flaskTopY + 16 - (valveY + 9)) * dripProgress;

      // Teardrop droplet shape
      final dropPath = Path()
        ..moveTo(cx, dropY - 2.5)
        ..quadraticBezierTo(cx + 2.0, dropY, cx, dropY + 2.5)
        ..quadraticBezierTo(cx - 2.0, dropY, cx, dropY - 2.5)
        ..close();
      canvas.drawPath(dropPath, Paint()..color = const Color(0xFF0284C7));
    }

    // 5. Conical Flask (Erlenmeyer)
    final fTop = flaskTopY;
    final fBottom = size.height * 0.92;
    final fPath = Path()
      ..moveTo(cx - 6, fTop)
      ..lineTo(cx + 6, fTop)
      ..lineTo(cx + 6, fTop + 7)
      ..lineTo(cx + 24, fBottom)
      ..lineTo(cx - 24, fBottom)
      ..lineTo(cx - 6, fTop + 7)
      ..close();

    final liqY = fBottom - 18;
    final liqPath = Path()..moveTo(cx - 15, liqY);

    if (isSwirling) {
      final wave1 = sin(swirlProgress * pi * 4) * 3.0;
      final wave2 = cos(swirlProgress * pi * 4) * 2.0;
      liqPath.cubicTo(cx - 6, liqY + wave1, cx + 6, liqY - wave2, cx + 15, liqY);
    } else {
      liqPath.lineTo(cx + 15, liqY);
    }
    liqPath.lineTo(cx + 23, fBottom - 1);
    liqPath.lineTo(cx - 23, fBottom - 1);
    liqPath.close();

    // Fill liquid
    canvas.drawPath(liqPath, Paint()..color = liquidColor);

    // Swirl Vortex Waves
    if (isSwirling) {
      final swirlWavePaint = Paint()..color = Colors.white.withOpacity(0.35)..style = PaintingStyle.stroke..strokeWidth = 1.0;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, liqY + 8), width: 22, height: 8), animTime * pi * 2, pi, false, swirlWavePaint);
    }

    // Chemical Reaction Bubbles / Effervescence
    final bubblePaint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.fill;
    for (int b = 0; b < 4; b++) {
      final bx = cx - 10 + (b * 6.5);
      final by = fBottom - 4 - ((animTime * 20 + b * 5) % 14);
      canvas.drawCircle(Offset(bx, by), 1.0, bubblePaint);
    }

    // Ripple wave when drop enters flask
    if (dripProgress > 0.75) {
      final ripProgress = (dripProgress - 0.75) / 0.25;
      final ripRadius = 2.0 + ripProgress * 8.0;
      final ripPaint = Paint()
        ..color = Colors.white.withOpacity((1.0 - ripProgress).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, liqY), width: ripRadius * 2, height: ripRadius * 0.7), ripPaint);
    }

    // Flask glass outline & specular highlights
    canvas.drawPath(fPath, Paint()..color = const Color(0xFF334155)..strokeWidth = 1.4..style = PaintingStyle.stroke);
    // Left glass specular highlight
    canvas.drawLine(Offset(cx - 5, fTop + 2), Offset(cx - 20, fBottom - 4), Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 1.0);
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
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 28), width: 16, height: 36), Paint()..color = const Color(0xFF64748B));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 46), width: 48, height: 7), Paint()..color = const Color(0xFF1E293B));

    // Flame Cones
    final flameH = 46 + sin(flicker * pi * 2) * 5;
    final outerFlame = Path()
      ..moveTo(cx - 10, cy + 10)
      ..quadraticBezierTo(cx - 12, cy - flameH * 0.5, cx, cy - flameH)
      ..quadraticBezierTo(cx + 12, cy - flameH * 0.5, cx + 10, cy + 10)
      ..close();
    canvas.drawPath(outerFlame, Paint()..color = flameColor.withOpacity(0.85));

    // Inner Cone
    final innerFlame = Path()
      ..moveTo(cx - 5, cy + 10)
      ..quadraticBezierTo(cx - 6, cy - flameH * 0.25, cx, cy - flameH * 0.5)
      ..quadraticBezierTo(cx + 6, cy - flameH * 0.25, cx + 5, cy + 10)
      ..close();
    canvas.drawPath(innerFlame, Paint()..color = const Color(0xFF38BDF8).withOpacity(0.9));

    // Platinum Wire
    final wireX = isWireInFlame ? cx : cx + 28;
    final wireY = isWireInFlame ? cy - 16 : cy + 12;
    final wirePaint = Paint()..color = Colors.white70..strokeWidth = 1.4;
    canvas.drawLine(Offset(size.width - 6, size.height * 0.3), Offset(wireX, wireY), wirePaint);
    canvas.drawCircle(Offset(wireX, wireY), 2.5, Paint()..color = wireHasSalt ? Colors.amberAccent : Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.2);
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
    final cup = Rect.fromCenter(center: Offset(cx, cy), width: 64, height: 74);
    canvas.drawRRect(RRect.fromRectAndRadius(cup, const Radius.circular(8)), Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawRRect(RRect.fromRectAndRadius(cup, const Radius.circular(8)), Paint()..color = const Color(0xFF94A3B8)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Water
    final water = Rect.fromCenter(center: Offset(cx, cy + 7), width: 56, height: 52);
    canvas.drawRRect(RRect.fromRectAndRadius(water, const Radius.circular(6)), Paint()..color = const Color(0x6638BDF8));

    // Stir Bar
    if (isStirring) {
      final angle = animProgress * pi * 2;
      canvas.save();
      canvas.translate(cx, cy + 24);
      canvas.rotate(angle);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 16, height: 3.5), const Radius.circular(2)), Paint()..color = Colors.white);
      canvas.restore();
    }

    // Thermometer Probe
    canvas.drawRect(Rect.fromLTWH(cx + 10, cy - 44, 3.5, 68), Paint()..color = const Color(0xFFEF4444));

    // Digital Readout Box
    final box = Rect.fromCenter(center: Offset(cx, cy - 32), width: 56, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(4)), Paint()..color = const Color(0xFF1E293B));
    final tp = TextPainter(
      text: TextSpan(text: '${temperature.toStringAsFixed(1)} °C', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - 38));
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
      ..moveTo(cx - 14, size.height * 0.12)
      ..lineTo(cx + 14, size.height * 0.12)
      ..lineTo(cx + 26, size.height * 0.65)
      ..lineTo(cx + 18, size.height * 0.88)
      ..lineTo(cx - 18, size.height * 0.88)
      ..lineTo(cx - 26, size.height * 0.65)
      ..close();

    canvas.drawPath(path, Paint()..color = const Color(0xFF334155));
    canvas.drawPath(path, Paint()..color = const Color(0xFF64748B)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    // Charge Layers
    if (chargeLoaded) {
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, size.height * 0.32), width: 30, height: 14), Paint()..color = const Color(0xFF78350F));
      canvas.drawRect(Rect.fromCenter(center: Offset(cx, size.height * 0.48), width: 40, height: 14), Paint()..color = const Color(0xFF1E293B));
    }

    // 1500°C Tuyere Hot Blast Zone
    if (blastOn) {
      final flameP = Paint()..color = Color.lerp(const Color(0xFFF97316), const Color(0xFFEF4444), animProgress)!;
      canvas.drawCircle(Offset(cx, size.height * 0.76), 12, flameP);
    }

    // Molten Iron Tapping Stream
    if (isTapped) {
      final tapPaint = Paint()..color = const Color(0xFFF97316)..strokeWidth = 3.0;
      canvas.drawLine(Offset(cx + 16, size.height * 0.84), Offset(size.width - 8, size.height * 0.92), tapPaint);
      canvas.drawCircle(Offset(size.width - 8, size.height * 0.92), 3.5, Paint()..color = Colors.amberAccent);
    }
  }

  @override
  bool shouldRepaint(covariant _BlastFurnacePainter oldDelegate) => true;
}

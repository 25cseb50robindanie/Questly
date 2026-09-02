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
  LabExperiment? _selectedExperiment; // null = Selection Menu
  int _currentLevel = 1; // 1 to 5
  int _unlockedLevel = 1;
  bool _isCompleted = false;

  // Level 1: Concept Slides
  int _conceptSlide = 0;
  int? _selectedQuizIndex;
  bool _quizCorrect = false;

  // Level 2: Apparatus
  final Set<String> _assembledApparatus = {};
  String? _wrongApparatusFeedback;

  // Level 3: Reagents
  String? _selectedReagent1;
  String? _selectedReagent2;
  bool _reagentStep1Done = false;
  bool _reagentStep2Done = false;
  String? _wrongReagentFeedback;

  // Level 4: Titration State
  double _buretteVolume = 0.0;
  final double _targetEndpoint = 20.00;
  bool _isContinuousDripping = false;
  Timer? _continuousTimer;
  bool _isSwirling = false;

  // Level 4: Flame Test State
  String _selectedFlameSalt = 'licl';
  bool _airCollarOpen = true;

  // Level 4: Calorimetry State
  double _waterTemp = 22.0;
  bool _soluteAdded = false;

  // Level 4: Smelting State
  bool _chargeLoaded = false;
  bool _blastOn = false;
  double _furnaceTemp = 250.0;

  // Animation Controllers
  late AnimationController _dripAnimController;
  late AnimationController _swirlAnimController;
  late AnimationController _flameAnimController;

  @override
  void initState() {
    super.initState();
    _loadStudent();

    _dripAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _swirlAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flameAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _continuousTimer?.cancel();
    _dripAnimController.dispose();
    _swirlAnimController.dispose();
    _flameAnimController.dispose();
    super.dispose();
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent() ??
          Locator.authService.getCurrentStudent();
    });
  }

  // Choose Experiment
  void _chooseExperiment(LabExperiment exp) {
    SoundService.playClick();
    setState(() {
      _selectedExperiment = exp;
      _currentLevel = 1;
      _unlockedLevel = 1;
      _conceptSlide = 0;
      _selectedQuizIndex = null;
      _quizCorrect = false;
      _assembledApparatus.clear();
      _wrongApparatusFeedback = null;
      _selectedReagent1 = null;
      _selectedReagent2 = null;
      _reagentStep1Done = false;
      _reagentStep2Done = false;
      _wrongReagentFeedback = null;
      _buretteVolume = 0.0;
      _isContinuousDripping = false;
      _selectedFlameSalt = 'licl';
      _airCollarOpen = true;
      _waterTemp = 22.0;
      _soluteAdded = false;
      _chargeLoaded = false;
      _blastOn = false;
      _furnaceTemp = 250.0;
    });
  }

  void _backToMenu() {
    SoundService.playClick();
    _continuousTimer?.cancel();
    setState(() {
      _selectedExperiment = null;
      _isContinuousDripping = false;
    });
  }

  // --- Hurrah Task Completed Modal ---
  void _showHurrahModal({
    required String title,
    required String message,
    required String nextButtonText,
    required VoidCallback onNext,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              const Text('🎉 HURRAH! TASK COMPLETED!', style: TextStyle(fontFamily: 'Fredoka', fontSize: 16, fontWeight: FontWeight.w900, color: ColorSystem.green, letterSpacing: 0.4)),
              const SizedBox(height: 4),
              Text(title, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 14, fontWeight: FontWeight.bold, color: ColorSystem.plum)),
              const SizedBox(height: 4),
              Text(message, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, color: ColorSystem.plum.withOpacity(0.7))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRewardBadge('+15 XP', ColorSystem.purple),
                  const SizedBox(width: 8),
                  _buildRewardBadge('+5 Coins', ColorSystem.gold),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: nextButtonText,
                  backgroundColor: ColorSystem.green,
                  textColor: Colors.white,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(text, style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: color == ColorSystem.gold ? const Color(0xFFD97706) : color)),
    );
  }

  // --- Level 1 Actions ---
  void _nextSlide() {
    SoundService.playClick();
    if (_conceptSlide < 3) setState(() => _conceptSlide++);
  }

  void _prevSlide() {
    SoundService.playClick();
    if (_conceptSlide > 0) setState(() => _conceptSlide--);
  }

  void _submitQuiz(int idx, int correctIdx) {
    SoundService.playClick();
    setState(() => _selectedQuizIndex = idx);

    if (idx == correctIdx) {
      SoundService.playCorrect();
      setState(() {
        _quizCorrect = true;
        if (_unlockedLevel < 2) _unlockedLevel = 2;
      });
      _showHurrahModal(
        title: 'Level 1: Theory Mastered!',
        message: 'You correctly answered the pre-lab checkpoint question.',
        nextButtonText: 'Enter Apparatus Setup ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 2);
        },
      );
    } else {
      SoundService.playStarPop();
      setState(() => _quizCorrect = false);
    }
  }

  // --- Level 2 Actions with Correct / Wrong Indication ---
  void _tapApparatus(String id, bool isRequiredForThisExp) {
    if (isRequiredForThisExp) {
      SoundService.playCorrect();
      setState(() {
        _wrongApparatusFeedback = null;
        if (_assembledApparatus.contains(id)) {
          _assembledApparatus.remove(id);
        } else {
          _assembledApparatus.add(id);
        }
      });

      final requiredCount = _getRequiredApparatus().length;
      if (_assembledApparatus.length == requiredCount) {
        SoundService.playLevelUp();
        if (_unlockedLevel < 3) _unlockedLevel = 3;
        _showHurrahModal(
          title: 'Level 2: Workbench Assembled!',
          message: 'All required apparatus items are accurately placed on the workbench.',
          nextButtonText: 'Start Chemical Reagents ➜',
          onNext: () {
            Navigator.pop(context);
            setState(() => _currentLevel = 3);
          },
        );
      }
    } else {
      // Wrong apparatus selected!
      SoundService.playStarPop();
      setState(() {
        _wrongApparatusFeedback = 'Incorrect tool! This item is not needed for ${_getExpName()}. Choose the required tools!';
      });
    }
  }

  // --- Level 3 Actions ---
  void _tapReagent(String id, String type, bool isCorrect) {
    if (isCorrect) {
      SoundService.playCorrect();
      setState(() {
        _wrongReagentFeedback = null;
        if (type == 'primary') {
          _selectedReagent1 = id;
          _reagentStep1Done = true;
        } else {
          _selectedReagent2 = id;
          _reagentStep2Done = true;
        }
      });

      if (_reagentStep1Done && _reagentStep2Done) {
        SoundService.playLevelUp();
        if (_unlockedLevel < 4) _unlockedLevel = 4;
        _showHurrahModal(
          title: 'Level 3: Solutions Ready!',
          message: 'Both required chemical reagents have been measured and prepared in the flask.',
          nextButtonText: 'Start Lab Simulator ➜',
          onNext: () {
            Navigator.pop(context);
            setState(() => _currentLevel = 4);
          },
        );
      }
    } else {
      SoundService.playStarPop();
      setState(() {
        _wrongReagentFeedback = 'Incorrect chemical! Check formula and select the active reagents for this reaction.';
      });
    }
  }

  // --- Level 4 Experiment Verification ---
  void _verifyLevel4() {
    _continuousTimer?.cancel();
    setState(() => _isContinuousDripping = false);

    bool success = false;
    String feedback = '';

    if (_selectedExperiment == LabExperiment.titration) {
      final diff = (_buretteVolume - _targetEndpoint).abs();
      if (diff <= 0.35) {
        success = true;
      } else if (_buretteVolume < _targetEndpoint) {
        feedback = 'Keep adding drops! Volume is ${_buretteVolume.toStringAsFixed(2)} mL (Target: 20.00 mL). Stop at faint pink!';
      } else {
        feedback = 'Over-titrated (${_buretteVolume.toStringAsFixed(2)} mL). Proceeding to stoichiometry report.';
        success = true;
      }
    } else if (_selectedExperiment == LabExperiment.flameTest) {
      success = true;
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      if (_soluteAdded) {
        success = true;
      } else {
        feedback = 'Add the exothermic solute into the calorimeter first!';
      }
    } else if (_selectedExperiment == LabExperiment.smelting) {
      if (_chargeLoaded && _blastOn) {
        success = true;
      } else {
        feedback = 'Load raw ore and activate hot blast tuyeres first!';
      }
    }

    if (success) {
      SoundService.playLevelUp();
      if (_unlockedLevel < 5) _unlockedLevel = 5;
      _showHurrahModal(
        title: 'Level 4: Experiment Succeeded!',
        message: 'You completed the physical laboratory simulation with high scientific accuracy!',
        nextButtonText: 'View Performance Analysis ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 5);
        },
      );
    } else {
      SoundService.playStarPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(feedback, style: const TextStyle(fontFamily: 'Fredoka')), backgroundColor: ColorSystem.coral),
      );
    }
  }

  // --- Level 5: Final Claim ---
  Future<void> _claimTrophy() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'lab_${_selectedExperiment.toString().split('.').last}',
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
        title: 'LAB MASTERED! 🏆',
        message: 'You scored 100% precision across all 5 levels in ${_getExpName()}!',
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

  Set<String> _getRequiredApparatus() {
    switch (_selectedExperiment) {
      case LabExperiment.flameTest:
        return {'burner', 'loop', 'watchglass', 'clamp'};
      case LabExperiment.calorimetry:
        return {'calorimeter', 'thermometer', 'stirrer', 'beaker'};
      case LabExperiment.smelting:
        return {'furnace', 'tuyere', 'hopper', 'ladle'};
      case LabExperiment.titration:
      default:
        return {'stand', 'burette', 'flask', 'pipette'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _selectedExperiment == null
                ? _buildExperimentMenu()
                : _buildActiveExperimentWorkflow(),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. ALL 4 PLAYABLE EXPERIMENT MODULES MENU
  // =========================================================================
  Widget _buildExperimentMenu() {
    final modules = [
      {
        'id': LabExperiment.titration,
        'title': 'Acid–Base Titration',
        'subtitle': 'Quantitative neutralization & molarity (HCl + NaOH)',
        'color': ColorSystem.castlePurple,
        'icon': Icons.science_rounded,
        'tag': 'CHEMISTRY • 5 LEVELS',
      },
      {
        'id': LabExperiment.flameTest,
        'title': 'Flame Emission Spectra',
        'subtitle': 'Excitation of metal salts (Li⁺, Na⁺, K⁺, Cu²⁺)',
        'color': const Color(0xFFD97706),
        'icon': Icons.local_fire_department_rounded,
        'tag': 'PHYSICS • 5 LEVELS',
      },
      {
        'id': LabExperiment.calorimetry,
        'title': 'Solution Calorimetry',
        'subtitle': 'Measure enthalpy change & heat capacity (q=mcΔT)',
        'color': const Color(0xFF0284C7),
        'icon': Icons.thermostat_rounded,
        'tag': 'THERMODYNAMICS • 5 LEVELS',
      },
      {
        'id': LabExperiment.smelting,
        'title': 'Blast Furnace Metallurgy',
        'subtitle': 'Reduction of hematite to pig iron at 1500°C',
        'color': const Color(0xFFC2410C),
        'icon': Icons.fireplace_rounded,
        'tag': 'METALLURGY • 5 LEVELS',
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
                  icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                const Text(
                  'VIRTUAL SCIENCE LABS',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 13, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                ),
              ],
            ),
            if (_student != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                ),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const DendyMascot(state: DendyState.idle, size: 36),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '"Choose any of the 4 science lab experiments below to begin your hands-on 5-level simulation!"',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25),
                ),
              ),
              const SizedBox(width: 6),
              const DendySpeakButton(textToSpeak: 'Choose any of the 4 science lab experiments below to begin your hands-on 5-level simulation!', size: 20),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Grid of 4 All-Playable Modules
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: modules.length,
            itemBuilder: (ctx, idx) {
              final m = modules[idx];
              return InkWell(
                onTap: () => _chooseExperiment(m['id'] as LabExperiment),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: (m['color'] as Color).withOpacity(0.6), width: 1.8),
                    boxShadow: [
                      BoxShadow(color: ColorSystem.plum.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 3)),
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
                            decoration: BoxDecoration(
                              color: (m['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(m['icon'] as IconData, size: 20, color: m['color'] as Color),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(color: ColorSystem.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                            child: const Text('READY', style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m['title'] as String, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                          const SizedBox(height: 2),
                          Text(m['subtitle'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, color: ColorSystem.plum.withOpacity(0.65), height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  // =========================================================================
  // 2. ACTIVE 5-LEVEL EXPERIMENT WORKFLOW
  // =========================================================================
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _backToMenu,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VIRTUAL SCIENCE LAB', style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                Text('LEVEL $_currentLevel OF 5 • ${_getExpName().toUpperCase()}', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w800, color: ColorSystem.purple)),
              ],
            ),
          ],
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
            padding: EdgeInsets.only(right: index == 4 ? 0 : 4),
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
                    Icon(Icons.lock_outline_rounded, size: 8.5, color: Colors.grey.shade400),
                    const SizedBox(width: 2),
                  ],
                  Text('Level $levelNum', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: textColor)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFoxyTeacherBanner(String speechText, DendyState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        border: Border(bottom: BorderSide(color: ColorSystem.plum.withOpacity(0.12), width: 1.2)),
      ),
      child: Row(
        children: [
          DendyMascot(state: state, size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Text(speechText, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25)),
          ),
          const SizedBox(width: 6),
          DendySpeakButton(textToSpeak: speechText, size: 20),
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
        return _buildLevel4View();
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
          teacherMessage = '"Step 1/4: When metal salt cations are heated, electrons jump to excited states and emit colored photons as they relax!"';
          slideContent = _buildConceptBox('E = h • c / λ (Photon Emission Spectra)', 'Thermal energy excites valence electrons in metal cations. As electrons drop back to ground state, they release energy as visible spectral wavelengths.');
          break;
        case 1:
          teacherMessage = '"Step 2/4: Lithium Chloride produces Crimson Red (670nm), while Copper Sulfate emits Vivid Emerald Green (510nm)!"';
          slideContent = _buildTwoColSlide('LiCl (Lithium)', 'Crimson Red (670 nm)', 'CuSO₄ (Copper)', 'Emerald Green (510 nm)', const Color(0xFFEF4444), const Color(0xFF10B981));
          break;
        case 2:
          teacherMessage = '"Step 3/4: We always use the hot, non-luminous blue flame zone with open air collar for clean emission viewing."';
          slideContent = _buildTwoColSlide('Open Air Collar', 'Hot Blue Flame (1400°C)\nClean test zone', 'Closed Collar', 'Yellow Safety Flame (800°C)\nSmoky, soot interference', Colors.blue, Colors.orange);
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! Which salt produces a golden yellow flame in the Bunsen burner?"';
          slideContent = _buildQuizSlide('CHECKPOINT: Which metal cation produces a persistent golden-yellow flame?', ['Sodium (NaCl) - 589 nm', 'Lithium (LiCl) - 670 nm', 'Copper (CuSO₄) - 510 nm'], 0);
          break;
      }
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      switch (_conceptSlide) {
        case 0:
          teacherMessage = '"Step 1/4: Calorimetry measures heat energy exchanged during chemical processes in an insulated reaction vessel."';
          slideContent = _buildConceptBox('q = m • c • ΔT (Enthalpy Equation)', 'Where m is mass of water (100g), c is specific heat capacity (4.184 J/g°C), and ΔT is temperature difference.');
          break;
        case 1:
          teacherMessage = '"Step 2/4: Exothermic reactions release thermal energy (+ΔT), while endothermic reactions absorb heat (-ΔT)."';
          slideContent = _buildTwoColSlide('Exothermic (+q)', 'Heat released to solution\nTemperature rises', 'Endothermic (-q)', 'Heat absorbed from water\nTemperature falls', Colors.red, Colors.blue);
          break;
        case 2:
          teacherMessage = '"Step 3/4: We use an insulated styrofoam cup calorimeter with lid and precision digital thermometer."';
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
          teacherMessage = '"Step 2/4: We use a standard 0.100 M NaOH titrant to find the concentration of our 20.0 mL HCl analyte acid."';
          slideContent = _buildTwoColSlide('1. Analyte Acid', 'Hydrochloric Acid (HCl)\n20.00 mL in Flask', '2. Standard Titrant', 'Sodium Hydroxide (NaOH)\n0.100 M in Burette', ColorSystem.coral, ColorSystem.purple);
          break;
        case 2:
          teacherMessage = '"Step 3/4: Phenolphthalein indicator stays clear in acid and turns pale pink the exact moment neutralization happens!"';
          slideContent = _buildTwoColSlide('Acidic pH (< 8.2)', 'COLORLESS / CLEAR\nIndicator stays clear in acid', 'Endpoint (pH 8.2)', 'FAINT PERSISTENT PINK\nExact equivalence point!', Colors.blueGrey, const Color(0xFFEC4899));
          break;
        case 3:
        default:
          teacherMessage = '"Step 4/4: Checkpoint quiz! Answer correctly to unlock and enter the lab apparatus workbench!"';
          slideContent = _buildQuizSlide('CHECKPOINT: What is the color change of Phenolphthalein at titration endpoint?', ['Colorless in Acid ➔ Pale Persistent Pink at Endpoint', 'Turns Dark Blue in Acid ➔ Red at Endpoint', 'Remains completely clear regardless of pH'], 0);
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(teacherMessage, _quizCorrect ? DendyState.success : DendyState.idle),
        Expanded(child: Padding(padding: const EdgeInsets.all(10), child: slideContent)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_conceptSlide > 0)
                CustomButton(text: '⮜ Previous', backgroundColor: ColorSystem.lavender, textColor: Colors.white, onPressed: _prevSlide)
              else
                const SizedBox(width: 80),
              Text('Lesson ${_conceptSlide + 1} of 4', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              if (_conceptSlide < 3)
                CustomButton(text: 'Next Concept ➜', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: _nextSlide)
              else
                CustomButton(
                  text: _quizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option',
                  backgroundColor: _quizCorrect ? ColorSystem.green : Colors.grey.shade400,
                  textColor: Colors.white,
                  onPressed: _quizCorrect ? () => setState(() => _currentLevel = 2) : () {},
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: ColorSystem.castlePurple, borderRadius: BorderRadius.circular(10)),
          child: Text(formula, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ColorSystem.cream, borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
          child: Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum, height: 1.3)),
        ),
      ],
    );
  }

  Widget _buildTwoColSlide(String t1, String d1, String t2, String d2, Color c1, Color c2) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: c1.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t1, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: c1)),
                const SizedBox(height: 4),
                Text(d1, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: c2.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t2, style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: c2)),
                const SizedBox(height: 4),
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
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (ctx, idx) {
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
                  onTap: () => _submitQuiz(idx, correctIdx),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            },
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 2: APPARATUS SELECTION (WITH CORRECT / WRONG FEEDBACK)
  // =========================================================================
  Widget _buildLevel2View() {
    List<Map<String, dynamic>> tools;

    if (_selectedExperiment == LabExperiment.flameTest) {
      tools = [
        {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Provides heating flame', 'req': true},
        {'id': 'loop', 'name': 'Platinum Wire Loop', 'desc': 'Inert sample carrier', 'req': true},
        {'id': 'watchglass', 'name': 'Watch Glass Dish', 'desc': 'Holds metal salt crystals', 'req': true},
        {'id': 'clamp', 'name': 'Retort Clamp Holder', 'desc': 'Secures burner safely', 'req': true},
        {'id': 'burette', 'name': '50 mL Glass Burette', 'desc': 'Volumetric dispenser (Wrong tool)', 'req': false},
        {'id': 'calorimeter', 'name': 'Insulated Cup', 'desc': 'Heat calorimeter (Wrong tool)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      tools = [
        {'id': 'calorimeter', 'name': 'Styrofoam Calorimeter', 'desc': 'Insulated reaction cup', 'req': true},
        {'id': 'thermometer', 'name': 'Precision Thermometer', 'desc': 'Measures ΔT temperature', 'req': true},
        {'id': 'stirrer', 'name': 'Magnetic Stir Bar', 'desc': 'Homogenizes liquid', 'req': true},
        {'id': 'beaker', 'name': '100 mL Glass Beaker', 'desc': 'Holds measured water', 'req': true},
        {'id': 'burette', 'name': '50 mL Burette', 'desc': 'Titration tube (Wrong tool)', 'req': false},
        {'id': 'furnace', 'name': 'Blast Tuyere Rig', 'desc': 'High temp smelting (Wrong tool)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      tools = [
        {'id': 'furnace', 'name': 'Blast Furnace Shaft', 'desc': 'Refractory smelting stack', 'req': true},
        {'id': 'tuyere', 'name': 'Hot Air Tuyere Blower', 'desc': '1500°C blast nozzle', 'req': true},
        {'id': 'hopper', 'name': 'Bell Charging Hopper', 'desc': 'Feeds raw hematite & coke', 'req': true},
        {'id': 'ladle', 'name': 'Cast Iron Tap Ladle', 'desc': 'Collects molten pig iron', 'req': true},
        {'id': 'pipette', 'name': '20 mL Pipette', 'desc': 'Liquid aliquot (Wrong tool)', 'req': false},
        {'id': 'watchglass', 'name': 'Watch Glass', 'desc': 'Flat dish (Wrong tool)', 'req': false},
      ];
    } else {
      // Titration default
      tools = [
        {'id': 'stand', 'name': 'Retort Stand & Clamp', 'desc': 'Secures burette vertically', 'req': true},
        {'id': 'burette', 'name': '50 mL Glass Burette', 'desc': 'Precision titrant dispenser', 'req': true},
        {'id': 'flask', 'name': '250 mL Conical Flask', 'desc': 'Erlenmeyer reaction vessel', 'req': true},
        {'id': 'pipette', 'name': '20 mL Volumetric Pipette', 'desc': 'Accurate acid aliquot', 'req': true},
        {'id': 'beaker', 'name': '100 mL Pyrex Beaker', 'desc': 'Stock solution holder (Extra)', 'req': false},
        {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Heating source (Wrong tool)', 'req': false},
      ];
    }

    final requiredCount = tools.where((t) => t['req'] == true).length;
    final isDone = _assembledApparatus.length == requiredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 2: Select the 4 correct apparatus items for ${_getExpName()}! Wrong tools will be highlighted in red."',
          isDone ? DendyState.success : DendyState.thinking,
        ),
        if (_wrongApparatusFeedback != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: ColorSystem.coral.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: ColorSystem.coral)),
            child: Text('❌ $_wrongApparatusFeedback', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: ColorSystem.coral)),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: tools.length,
              itemBuilder: (ctx, idx) {
                final item = tools[idx];
                final isAdded = _assembledApparatus.contains(item['id']);

                return InkWell(
                  onTap: () => _tapApparatus(item['id'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isAdded ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdded ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                        width: isAdded ? 1.6 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(isAdded ? Icons.check_circle_rounded : Icons.science_outlined, size: 20, color: isAdded ? ColorSystem.green : ColorSystem.castlePurple),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: isAdded ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 7, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
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
            text: isDone ? 'START REAGENTS PREPARATION ➜' : 'Select all 4 required tools (${_assembledApparatus.length}/$requiredCount)',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? () => setState(() => _currentLevel = 3) : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 3: CHEMICAL REAGENTS PREPARATION (WITH ERROR FEEDBACK)
  // =========================================================================
  Widget _buildLevel3View() {
    List<Map<String, dynamic>> reagents;

    if (_selectedExperiment == LabExperiment.flameTest) {
      reagents = [
        {'id': 'licl', 'name': 'Lithium Chloride (LiCl)', 'type': 'primary', 'desc': 'Crimson Red Salt', 'req': true},
        {'id': 'hcl_rinse', 'name': 'Conc. HCl Acid', 'type': 'secondary', 'desc': 'Wire Cleaning Solvent', 'req': true},
        {'id': 'cacl2', 'name': 'Calcium Chloride', 'type': 'primary', 'desc': 'Brick Red (Alternative)', 'req': false},
        {'id': 'sugar', 'name': 'Sucrose Sugar', 'type': 'secondary', 'desc': 'Organic compound (Wrong)', 'req': false},
        {'id': 'kcl', 'name': 'Potassium Chloride', 'type': 'primary', 'desc': 'Lilac Violet (Alternative)', 'req': false},
        {'id': 'h2o', 'name': 'Distilled Water', 'type': 'secondary', 'desc': 'Rinse Solvent', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      reagents = [
        {'id': 'h2o_mass', 'name': '100.0 g Distilled Water', 'type': 'primary', 'desc': 'Calorimeter Solvent', 'req': true},
        {'id': 'naoh_solid', 'name': 'Solid NaOH Pellets', 'type': 'secondary', 'desc': 'Exothermic Solute', 'req': true},
        {'id': 'nacl', 'name': 'Sodium Chloride', 'type': 'secondary', 'desc': 'Neutral Salt (Distractor)', 'req': false},
        {'id': 'ethanol', 'name': 'Ethanol Fuel', 'type': 'primary', 'desc': 'Organic Solvent (Wrong)', 'req': false},
        {'id': 'nh4no3', 'name': 'Ammonium Nitrate', 'type': 'secondary', 'desc': 'Endothermic Salt (Extra)', 'req': false},
        {'id': 'oil', 'name': 'Mineral Oil', 'type': 'primary', 'desc': 'Nonpolar Liquid (Wrong)', 'req': false},
      ];
    } else if (_selectedExperiment == LabExperiment.smelting) {
      reagents = [
        {'id': 'hematite', 'name': 'Hematite Ore (Fe₂O₃)', 'type': 'primary', 'desc': 'Iron Oxide Source', 'req': true},
        {'id': 'coke', 'name': 'Carbon Coke Fuel', 'type': 'secondary', 'desc': 'CO Gas Reducer', 'req': true},
        {'id': 'limestone', 'name': 'Limestone (CaCO₃)', 'type': 'secondary', 'desc': 'Slag Flux Builder', 'req': false},
        {'id': 'sand', 'name': 'Pure Quartz Sand', 'type': 'primary', 'desc': 'Silica (Impurity)', 'req': false},
        {'id': 'copper_ore', 'name': 'Chalcopyrite', 'type': 'primary', 'desc': 'Copper ore (Wrong)', 'req': false},
        {'id': 'charcoal', 'name': 'Wood Charcoal', 'type': 'secondary', 'desc': 'Biomass Fuel (Extra)', 'req': false},
      ];
    } else {
      // Titration default
      reagents = [
        {'id': 'hcl', 'name': '0.100 M HCl Acid', 'type': 'primary', 'desc': 'Analyte Solution', 'req': true},
        {'id': 'phenolphthalein', 'name': 'Phenolphthalein', 'type': 'secondary', 'desc': 'pH 8.2-10.0 Indicator', 'req': true},
        {'id': 'naoh', 'name': '0.100 M NaOH Standard', 'type': 'secondary', 'desc': 'Titrant in Burette', 'req': false},
        {'id': 'ch3cooh', 'name': '0.100 M CH₃COOH', 'type': 'primary', 'desc': 'Acetic Acid (Distractor)', 'req': false},
        {'id': 'methyl_orange', 'name': 'Methyl Orange', 'type': 'secondary', 'desc': 'pH 3.1-4.4 Indicator', 'req': false},
        {'id': 'h2o', 'name': 'Distilled H₂O', 'type': 'secondary', 'desc': 'Rinse Solvent', 'req': false},
      ];
    }

    final isDone = _reagentStep1Done && _reagentStep2Done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 3: Select and prepare the primary reactant and secondary chemical reagent for ${_getExpName()}!"',
          isDone ? DendyState.success : DendyState.thinking,
        ),
        if (_wrongReagentFeedback != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: ColorSystem.coral.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: ColorSystem.coral)),
            child: Text('❌ $_wrongReagentFeedback', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: ColorSystem.coral)),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: reagents.length,
              itemBuilder: (ctx, idx) {
                final item = reagents[idx];
                final isSelected = (_selectedReagent1 == item['id']) || (_selectedReagent2 == item['id']);

                return InkWell(
                  onTap: () => _tapReagent(item['id'] as String, item['type'] as String, item['req'] as bool),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? ColorSystem.green : ColorSystem.purple.withOpacity(0.3),
                        width: isSelected ? 1.6 : 1.0,
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
                              Text(item['name'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: isSelected ? ColorSystem.green : ColorSystem.plum), maxLines: 1),
                              Text(item['desc'] as String, style: TextStyle(fontFamily: 'Fredoka', fontSize: 7, color: ColorSystem.plum.withOpacity(0.6)), maxLines: 1),
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
            text: isDone ? 'START SIMULATOR ➜' : 'Select both required chemical solutions',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? () => setState(() => _currentLevel = 4) : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 4: INTERACTIVE LAB SIMULATORS FOR ALL 4 EXPERIMENTS
  // =========================================================================
  Widget _buildLevel4View() {
    if (_selectedExperiment == LabExperiment.flameTest) {
      return _buildLevel4FlameSimulator();
    } else if (_selectedExperiment == LabExperiment.calorimetry) {
      return _buildLevel4CalorimetrySimulator();
    } else if (_selectedExperiment == LabExperiment.smelting) {
      return _buildLevel4SmeltingSimulator();
    } else {
      return _buildLevel4TitrationSimulator();
    }
  }

  Widget _buildLevel4TitrationSimulator() {
    final ph = _getCalculatedPH();
    final liquidColor = _getFlaskColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Turn the stopcock to add drops of NaOH. Swirl regularly. Stop right when a faint persistent pink endpoint appears!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.12))),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _MobileTitrationPainter(
                            buretteVolume: _buretteVolume,
                            maxVolume: 50.0,
                            liquidColor: liquidColor,
                            dripProgress: _dripAnimController.value,
                            isSwirling: _isSwirling,
                            swirlProgress: _swirlAnimController.value,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(text: '+0.05 mL Drop 💧', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: () => _addDrop(amount: 0.05)),
                      CustomButton(text: '+0.50 mL Fast 🌊', backgroundColor: ColorSystem.purple, textColor: Colors.white, onPressed: () => _addDrop(amount: 0.50)),
                      CustomButton(text: _isContinuousDripping ? '⏸ Pause' : '▶ Continuous', backgroundColor: _isContinuousDripping ? ColorSystem.coral : ColorSystem.lavender, textColor: Colors.white, onPressed: _toggleContinuous),
                      CustomButton(text: '🌀 Swirl Flask', backgroundColor: const Color(0xFF0EA5E9), textColor: Colors.white, onPressed: _swirlFlask),
                      CustomButton(text: '🎯 Verify Endpoint', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
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

  Widget _buildLevel4FlameSimulator() {
    final Map<String, Color> flameColors = {
      'licl': const Color(0xFFEF4444),
      'nacl': const Color(0xFFFBBF24),
      'kcl': const Color(0xFFA855F7),
      'cuso4': const Color(0xFF10B981),
    };
    final activeColor = flameColors[_selectedFlameSalt] ?? const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Dip the platinum wire into different metal salts and observe the spectral flame emission wavelengths!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: Size.infinite,
                          painter: _FlameCanvasPainter(
                            flameColor: _airCollarOpen ? activeColor : const Color(0xFFF59E0B),
                            flicker: _flameAnimController.value,
                            isBlueBase: _airCollarOpen,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Text('Salt: ${_selectedFlameSalt.toUpperCase()} (1400°C)', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: Colors.white70)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(text: '🔴 LiCl (Crimson Red)', backgroundColor: const Color(0xFFEF4444), textColor: Colors.white, onPressed: () => setState(() => _selectedFlameSalt = 'licl')),
                      CustomButton(text: '🟡 NaCl (Golden Yellow)', backgroundColor: const Color(0xFFF59E0B), textColor: Colors.white, onPressed: () => setState(() => _selectedFlameSalt = 'nacl')),
                      CustomButton(text: '🟣 KCl (Lilac Violet)', backgroundColor: const Color(0xFFA855F7), textColor: Colors.white, onPressed: () => setState(() => _selectedFlameSalt = 'kcl')),
                      CustomButton(text: '🟢 CuSO₄ (Emerald Green)', backgroundColor: const Color(0xFF10B981), textColor: Colors.white, onPressed: () => setState(() => _selectedFlameSalt = 'cuso4')),
                      CustomButton(text: '🎯 Complete Flame Lab', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
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

  Widget _buildLevel4CalorimetrySimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Add the measured solute into the calorimeter, stir, and observe the temperature rise ΔT!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.12))),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.thermostat_rounded, size: 36, color: ColorSystem.coral),
                          Text('${_waterTemp.toStringAsFixed(1)} °C', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w900, color: ColorSystem.coral)),
                          const Text('Mass: 100.0 g • c = 4.184 J/g°C', style: TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: _soluteAdded ? '✓ Solute Added' : 'Add NaOH Pellets 🔥',
                        backgroundColor: ColorSystem.coral,
                        textColor: Colors.white,
                        onPressed: () {
                          SoundService.playStarPop();
                          setState(() {
                            _soluteAdded = true;
                            _waterTemp = 30.4;
                          });
                        },
                      ),
                      CustomButton(
                        text: 'Reset Water 22.0°C ❄️',
                        backgroundColor: ColorSystem.lavender,
                        textColor: Colors.white,
                        onPressed: () => setState(() {
                          _waterTemp = 22.0;
                          _soluteAdded = false;
                        }),
                      ),
                      CustomButton(text: '🎯 Complete Calorimetry', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
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

  Widget _buildLevel4SmeltingSimulator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 4: Load the hematite ore charge into the furnace, then activate the 1500°C hot blast tuyeres!"', DendyState.thinking),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fireplace_rounded, size: 36, color: _blastOn ? const Color(0xFFF97316) : Colors.grey),
                          Text('${_furnaceTemp.toStringAsFixed(0)} °C', style: TextStyle(fontFamily: 'Fredoka', fontSize: 20, fontWeight: FontWeight.w900, color: _blastOn ? const Color(0xFFF97316) : Colors.white70)),
                          Text(_blastOn ? 'Hot Blast Active (1500°C)' : 'Furnace Idle', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 8, color: Colors.white54)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: _chargeLoaded ? '✓ Charge Loaded' : 'Load Ore & Coke ⛰️',
                        backgroundColor: ColorSystem.castlePurple,
                        textColor: Colors.white,
                        onPressed: () => setState(() => _chargeLoaded = true),
                      ),
                      CustomButton(
                        text: _blastOn ? '🔥 1500°C Blast On' : 'Activate Tuyere Blast 🔥',
                        backgroundColor: const Color(0xFFF97316),
                        textColor: Colors.white,
                        onPressed: () => setState(() {
                          _blastOn = true;
                          _furnaceTemp = 1520.0;
                        }),
                      ),
                      CustomButton(text: '🎯 Tap Liquid Pig Iron', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyLevel4),
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
  // LEVEL 5: COMPREHENSIVE OVERALL PERFORMANCE ANALYSIS
  // =========================================================================
  Widget _buildLevel5PerformanceAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner('"Level 5: Outstanding achievement! Here is your complete laboratory performance analysis report!"', DendyState.success),
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
                    const Text('⭐⭐⭐ 100% Mastery', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
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
                        _buildAnalysisRow('First-Attempt Accuracy', '100.0% (Perfect)', Icons.check_circle_rounded),
                        _buildAnalysisRow('Apparatus Precision', '4 / 4 Tools Correct', Icons.architecture_rounded),
                        _buildAnalysisRow('Chemical Reagents', '100% Stoichiometric Match', Icons.opacity_rounded),
                        _buildAnalysisRow('Simulation Target', 'Equivalence Achieved', Icons.stars_rounded),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            text: 'CLAIM 60 XP & COMPLETE MODULE 🏆',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            onPressed: _claimTrophy,
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

// Painters for Titration and Flame
class _MobileTitrationPainter extends CustomPainter {
  final double buretteVolume;
  final double maxVolume;
  final Color liquidColor;
  final double dripProgress;
  final bool isSwirling;
  final double swirlProgress;

  _MobileTitrationPainter({
    required this.buretteVolume,
    required this.maxVolume,
    required this.liquidColor,
    required this.dripProgress,
    required this.isSwirling,
    required this.swirlProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.55;
    final standX = size.width * 0.22;

    final standPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(standX, size.height * 0.94), width: 45, height: 7), const Radius.circular(2)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawLine(Offset(standX, size.height * 0.94), Offset(standX, size.height * 0.06), standPaint);
    canvas.drawLine(Offset(standX, size.height * 0.26), Offset(cx, size.height * 0.26), standPaint..strokeWidth = 2.5);

    final bTop = size.height * 0.08;
    final bBottom = size.height * 0.54;
    final bWidth = 11.0;
    final bRect = Rect.fromCenter(center: Offset(cx, (bTop + bBottom) / 2), width: bWidth, height: bBottom - bTop);

    final fraction = (1.0 - (buretteVolume / maxVolume)).clamp(0.0, 1.0);
    final liqTop = bTop + (bBottom - bTop) * (1.0 - fraction);
    canvas.drawRect(Rect.fromLTRB(cx - bWidth / 2 + 1, liqTop, cx + bWidth / 2 - 1, bBottom), Paint()..color = const Color(0x66BAE6FD));
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF475569)..strokeWidth = 1.0..style = PaintingStyle.stroke);

    final valveY = bBottom + 6;
    canvas.drawCircle(Offset(cx, valveY), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawLine(Offset(cx, valveY), Offset(cx, valveY + 10), Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5);

    if (dripProgress > 0.0 && dripProgress < 1.0) {
      final dropY = (valveY + 10) + (size.height * 0.76 - (valveY + 10)) * dripProgress;
      canvas.drawCircle(Offset(cx, dropY), 2.5, Paint()..color = const Color(0xFF38BDF8));
    }

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

class _FlameCanvasPainter extends CustomPainter {
  final Color flameColor;
  final double flicker;
  final bool isBlueBase;

  _FlameCanvasPainter({required this.flameColor, required this.flicker, required this.isBlueBase});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.65;

    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 30), width: 16, height: 40), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 50), width: 50, height: 8), Paint()..color = const Color(0xFF334155));

    final flameH = 50 + (flicker * 8);
    final outerFlame = Path()
      ..moveTo(cx - 10, cy + 10)
      ..quadraticBezierTo(cx - 12, cy - flameH * 0.5, cx, cy - flameH)
      ..quadraticBezierTo(cx + 12, cy - flameH * 0.5, cx + 10, cy + 10)
      ..close();
    canvas.drawPath(outerFlame, Paint()..color = flameColor.withOpacity(0.85));

    final wire = Paint()..color = Colors.white70..strokeWidth = 1.5;
    canvas.drawLine(Offset(cx + 30, cy), Offset(cx, cy - 8), wire);
    canvas.drawCircle(Offset(cx, cy - 8), 2.5, Paint()..color = Colors.white..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant _FlameCanvasPainter oldDelegate) => true;
}

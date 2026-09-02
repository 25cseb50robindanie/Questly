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
  LabExperiment? _selectedExperiment; // null = Choose Experiment screen
  int _currentLevel = 1; // 1 to 5
  int _unlockedLevel = 1;
  bool _isCompleted = false;

  // --- Level 1: 4 Concept Slides ---
  int _conceptSlide = 0;
  int? _selectedQuizIndex;
  bool _quizCorrect = false;

  // --- Level 2: Apparatus Assembly (6 choices, 4 required) ---
  final Set<String> _assembledApparatus = {};

  // --- Level 3: Chemical Reagents (6 bottles, required: HCl + Phenolphthalein + NaOH) ---
  String? _selectedAcid;
  String? _selectedIndicator;
  bool _acidPipetted = false;
  bool _indicatorAdded = false;

  // --- Level 4: Interactive Titration Simulator ---
  double _buretteVolume = 0.0; // 0.00 to 50.00 mL
  final double _targetEndpoint = 20.00;
  bool _isContinuousDripping = false;
  Timer? _continuousTimer;
  bool _isSwirling = false;

  // --- Animation Controllers ---
  late AnimationController _dripAnimController;
  late AnimationController _swirlAnimController;

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
  }

  @override
  void dispose() {
    _continuousTimer?.cancel();
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
      _selectedAcid = null;
      _selectedIndicator = null;
      _acidPipetted = false;
      _indicatorAdded = false;
      _buretteVolume = 0.0;
      _isContinuousDripping = false;
    });
  }

  void _backToExperimentSelect() {
    SoundService.playClick();
    _continuousTimer?.cancel();
    setState(() {
      _selectedExperiment = null;
      _isContinuousDripping = false;
    });
  }

  // --- Level 1 Navigation ---
  void _nextConceptSlide() {
    SoundService.playClick();
    if (_conceptSlide < 3) {
      setState(() => _conceptSlide++);
    }
  }

  void _prevConceptSlide() {
    SoundService.playClick();
    if (_conceptSlide > 0) {
      setState(() => _conceptSlide--);
    }
  }

  void _submitQuiz(int index) {
    SoundService.playClick();
    setState(() => _selectedQuizIndex = index);

    if (index == 0) {
      SoundService.playCorrect();
      setState(() {
        _quizCorrect = true;
        if (_unlockedLevel < 2) _unlockedLevel = 2;
      });
    } else {
      SoundService.playStarPop();
      setState(() => _quizCorrect = false);
    }
  }

  void _finishLevel1() {
    SoundService.playLevelUp();
    setState(() {
      _currentLevel = 2;
      if (_unlockedLevel < 2) _unlockedLevel = 2;
    });
  }

  // --- Level 2: Apparatus Assembly ---
  void _toggleApparatus(String id) {
    SoundService.playStarPop();
    setState(() {
      if (_assembledApparatus.contains(id)) {
        _assembledApparatus.remove(id);
      } else {
        _assembledApparatus.add(id);
      }
    });

    final requiredItems = {'stand', 'burette', 'flask', 'pipette'};
    if (requiredItems.every((item) => _assembledApparatus.contains(item))) {
      SoundService.playCorrect();
      if (_unlockedLevel < 3) _unlockedLevel = 3;
    }
  }

  void _finishLevel2() {
    SoundService.playLevelUp();
    setState(() {
      _currentLevel = 3;
      if (_unlockedLevel < 3) _unlockedLevel = 3;
    });
  }

  // --- Level 3: Reagents Preparation ---
  void _selectAcid(String acidId) {
    SoundService.playStarPop();
    setState(() {
      _selectedAcid = acidId;
      if (acidId == 'hcl') {
        _acidPipetted = true;
      }
    });
    _checkLevel3Done();
  }

  void _selectIndicator(String indId) {
    SoundService.playStarPop();
    setState(() {
      _selectedIndicator = indId;
      if (indId == 'phenolphthalein') {
        _indicatorAdded = true;
      }
    });
    _checkLevel3Done();
  }

  void _checkLevel3Done() {
    if (_acidPipetted && _indicatorAdded) {
      SoundService.playCorrect();
      if (_unlockedLevel < 4) _unlockedLevel = 4;
    }
  }

  void _finishLevel3() {
    SoundService.playLevelUp();
    setState(() {
      _currentLevel = 4;
      if (_unlockedLevel < 4) _unlockedLevel = 4;
    });
  }

  // --- Level 4: Titration Simulator ---
  void _addDrop({double amount = 0.05}) {
    if (_buretteVolume >= 50.0) return;
    SoundService.playStarPop();
    _dripAnimController.forward(from: 0.0);

    setState(() {
      _buretteVolume = (_buretteVolume + amount).clamp(0.0, 50.0);
    });
  }

  void _toggleContinuous() {
    SoundService.playClick();
    setState(() => _isContinuousDripping = !_isContinuousDripping);

    if (_isContinuousDripping) {
      _continuousTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
        if (!mounted || _buretteVolume >= 50.0) {
          timer.cancel();
          if (mounted) setState(() => _isContinuousDripping = false);
          return;
        }
        _addDrop(amount: 0.15);
      });
    } else {
      _continuousTimer?.cancel();
    }
  }

  void _swirlFlask() {
    SoundService.playStarPop();
    setState(() => _isSwirling = true);
    _swirlAnimController.forward(from: 0.0).then((_) {
      if (mounted) setState(() => _isSwirling = false);
    });
  }

  void _verifyEndpoint() {
    _continuousTimer?.cancel();
    setState(() => _isContinuousDripping = false);

    final diff = (_buretteVolume - _targetEndpoint).abs();
    if (diff <= 0.35) {
      SoundService.playCorrect();
      if (_unlockedLevel < 5) _unlockedLevel = 5;
      setState(() => _currentLevel = 5);
    } else if (_buretteVolume < _targetEndpoint) {
      SoundService.playStarPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Keep going! Current volume is ${_buretteVolume.toStringAsFixed(2)} mL (Target: 20.00 mL). Add drops until faint pink persists!',
            style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
          ),
          backgroundColor: ColorSystem.castlePurple,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      SoundService.playStarPop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Over-titrated (${_buretteVolume.toStringAsFixed(2)} mL). Dark pink indicates excess base. Let\'s see calculations in the report!',
            style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold),
          ),
          backgroundColor: ColorSystem.coral,
          duration: const Duration(seconds: 3),
        ),
      );
      if (_unlockedLevel < 5) _unlockedLevel = 5;
      setState(() => _currentLevel = 5);
    }
  }

  double _getCalculatedPH() {
    final molesAcid = 0.002;
    final molesBase = (_buretteVolume / 1000.0) * 0.1;
    final totalVol = (20.0 + _buretteVolume) / 1000.0;

    if (molesAcid > molesBase) {
      final excess = molesAcid - molesBase;
      final conc = excess / totalVol;
      return (-log(conc) / ln10).clamp(1.0, 6.9);
    } else if ((molesAcid - molesBase).abs() < 0.00001) {
      return 7.0;
    } else {
      final excess = molesBase - molesAcid;
      final conc = excess / totalVol;
      return (14.0 - (-log(conc) / ln10)).clamp(7.1, 13.5);
    }
  }

  Color _getFlaskColor() {
    if (!_acidPipetted && _currentLevel < 4) return Colors.transparent;
    final ph = _getCalculatedPH();

    if (ph < 8.2) {
      return const Color(0x44BAE6FD);
    } else if (ph >= 8.2 && ph <= 9.0) {
      return const Color(0x99F472B6);
    } else {
      return const Color(0xDDDB2777);
    }
  }

  // --- Level 5: Claim Reward ---
  Future<void> _claimRewardAndFinish() async {
    if (_isCompleted) return;
    _isCompleted = true;

    final diff = (_buretteVolume - _targetEndpoint).abs();
    final stars = diff <= 0.4 ? 3 : (diff <= 1.2 ? 2 : 1);

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'lab_titration_1',
        status: 'completed',
        score: 1.0,
        stars: stars,
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
        title: 'TITRATION MASTERED! 🏆',
        message: 'You completed all 5 Virtual Lab levels with high precision and stoichiometric mastery!',
        xpReward: 60,
        goldReward: 15,
        earnedStars: stars,
        onContinue: () => Navigator.pop(context),
      );
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
                ? _buildExperimentSelectionScreen()
                : _buildActiveExperimentWorkflow(),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. CHOOSE EXPERIMENT SCREEN
  // ==========================================
  Widget _buildExperimentSelectionScreen() {
    final experiments = [
      {
        'id': LabExperiment.titration,
        'title': 'Acid–Base Titration',
        'subtitle': 'Quantitative neutralization & molarity analysis',
        'color': ColorSystem.castlePurple,
        'icon': Icons.science_rounded,
        'tag': 'CHEMISTRY • 5 LEVELS',
      },
      {
        'id': LabExperiment.flameTest,
        'title': 'Flame Emission Spectra',
        'subtitle': 'Excitation of metal salts in Bunsen flame',
        'color': const Color(0xFFD97706),
        'icon': Icons.local_fire_department_rounded,
        'tag': 'OPTICAL PHYSICS',
      },
      {
        'id': LabExperiment.calorimetry,
        'title': 'Solution Calorimetry',
        'subtitle': 'Measure enthalpy change & specific heat (q=mcΔT)',
        'color': const Color(0xFF0284C7),
        'icon': Icons.thermostat_rounded,
        'tag': 'THERMODYNAMICS',
      },
      {
        'id': LabExperiment.smelting,
        'title': 'Blast Furnace Metallurgy',
        'subtitle': 'Pyrometallurgical extraction of iron from hematite',
        'color': const Color(0xFFC2410C),
        'icon': Icons.fireplace_rounded,
        'tag': 'METALLURGY',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
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
        const SizedBox(height: 8),

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
                  '"Welcome to Questly Virtual Labs! Choose an experiment module to enter your hands-on 5-level lab simulation!"',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25),
                ),
              ),
              const SizedBox(width: 6),
              const DendySpeakButton(
                textToSpeak: 'Welcome to Questly Virtual Labs! Choose an experiment module to enter your hands-on 5-level lab simulation!',
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Experiments Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.35,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: experiments.length,
            itemBuilder: (ctx, idx) {
              final exp = experiments[idx];
              final isAvailable = exp['id'] == LabExperiment.titration;

              return InkWell(
                onTap: isAvailable ? () => _chooseExperiment(exp['id'] as LabExperiment) : () {
                  SoundService.playStarPop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting with Acid-Base Titration! Tap Titration card to enter.', style: TextStyle(fontFamily: 'Fredoka')),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (exp['color'] as Color).withOpacity(0.6),
                      width: 1.8,
                    ),
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
                              color: (exp['color'] as Color).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(exp['icon'] as IconData, size: 20, color: exp['color'] as Color),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAvailable ? ColorSystem.green.withOpacity(0.15) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isAvailable ? 'ACTIVE' : 'READY',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: isAvailable ? ColorSystem.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exp['title'] as String,
                            style: const TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exp['subtitle'] as String,
                            style: TextStyle(fontFamily: 'Fredoka', fontSize: 7.5, color: ColorSystem.plum.withOpacity(0.65), height: 1.2),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
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
  // 2. ACTIVE EXPERIMENT 5-LEVEL WORKFLOW
  // ==========================================
  Widget _buildActiveExperimentWorkflow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header
        _buildHeaderBar(),
        const SizedBox(height: 6),

        // Level Stepper (1 to 5)
        _buildLevelPills(),
        const SizedBox(height: 8),

        // Main Container for Active Level
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.06),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildCurrentLevelContent(),
            ),
          ),
        ),
      ],
    );
  }

  // Header Bar
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
              onPressed: _backToExperimentSelect,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'VIRTUAL CHEMISTRY LAB',
                  style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum),
                ),
                Text(
                  'LEVEL $_currentLevel OF 5 • ACID–BASE TITRATION',
                  style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w800, color: ColorSystem.purple),
                ),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                ),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                ),
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

  // Level Stepper Pills
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
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: border, width: 1.2),
              ),
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

  // Teacher Banner
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
            child: Text(
              speechText,
              style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.bold, color: ColorSystem.plum, height: 1.25),
            ),
          ),
          const SizedBox(width: 6),
          DendySpeakButton(textToSpeak: speechText, size: 20),
        ],
      ),
    );
  }

  // Level Content Router
  Widget _buildCurrentLevelContent() {
    switch (_currentLevel) {
      case 1:
        return _buildLevel1ConceptLearning();
      case 2:
        return _buildLevel2ApparatusAssembly();
      case 3:
        return _buildLevel3ReagentsPreparation();
      case 4:
        return _buildLevel4TitrationSimulator();
      case 5:
      default:
        return _buildLevel5ReportAndRewards();
    }
  }

  // ==========================================
  // LEVEL 1: CONCEPT LEARNING
  // ==========================================
  Widget _buildLevel1ConceptLearning() {
    String teacherMessage;
    Widget slideContent;

    switch (_conceptSlide) {
      case 0:
        teacherMessage = '"Step 1/4: In an acid-base titration, hydrochloric acid reacts with sodium hydroxide to form water and salt!"';
        slideContent = _buildSlide1Neutralization();
        break;
      case 1:
        teacherMessage = '"Step 2/4: We use a standard 0.100 M NaOH titrant to find the concentration of our 20.0 mL HCl analyte acid."';
        slideContent = _buildSlide2Solutions();
        break;
      case 2:
        teacherMessage = '"Step 3/4: Phenolphthalein indicator stays clear in acid and turns pale pink the exact moment neutralization happens!"';
        slideContent = _buildSlide3Indicator();
        break;
      case 3:
      default:
        teacherMessage = '"Step 4/4: Checkpoint quiz! Answer correctly to unlock and enter the lab apparatus workbench!"';
        slideContent = _buildSlide4Quiz();
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(teacherMessage, _quizCorrect ? DendyState.success : DendyState.idle),
        Expanded(child: Padding(padding: const EdgeInsets.all(10), child: slideContent)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_conceptSlide > 0)
                CustomButton(text: '⮜ Previous', backgroundColor: ColorSystem.lavender, textColor: Colors.white, onPressed: _prevConceptSlide)
              else
                const SizedBox(width: 80),
              Text('Lesson ${_conceptSlide + 1} of 4', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.purple)),
              if (_conceptSlide < 3)
                CustomButton(text: 'Next Concept ➜', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: _nextConceptSlide)
              else
                CustomButton(
                  text: _quizCorrect ? 'ENTER APPARATUS LAB ➜' : 'Select Correct Option',
                  backgroundColor: _quizCorrect ? ColorSystem.green : Colors.grey.shade400,
                  textColor: Colors.white,
                  onPressed: _quizCorrect ? _finishLevel1 : () {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlide1Neutralization() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: ColorSystem.castlePurple, borderRadius: BorderRadius.circular(10)),
          child: const Text('HCl (aq) + NaOH (aq) ➔ NaCl (aq) + H₂O (l)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.3)),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ColorSystem.cream, borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.plum.withOpacity(0.1))),
          child: const Text(
            'Titration is a fundamental laboratory method in analytical chemistry used to determine the unknown concentration of an acid by adding exact measured volumes of a standard base until neutralization is reached.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, color: ColorSystem.plum, height: 1.3),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide2Solutions() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.coral.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRealFlaskSVG(size: 32, isPink: false),
                const SizedBox(height: 4),
                const Text('1. Analyte Acid', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                Text('Hydrochloric Acid (HCl)\nVolume: 20.00 mL\nPlaced in Conical Flask', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: ColorSystem.purple.withOpacity(0.4), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRealBuretteSVG(size: 32),
                const SizedBox(height: 4),
                const Text('2. Standard Titrant', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                Text('Sodium Hydroxide (NaOH)\nConcentration: 0.100 M\nFilled into Burette', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: ColorSystem.plum.withOpacity(0.7))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide3Indicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.lightBlueAccent, width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRealFlaskSVG(size: 32, isPink: false),
                const SizedBox(height: 4),
                const Text('Acidic pH (< 8.2)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                const Text('COLORLESS / CLEAR\nIndicator stays completely clear in acid.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: Colors.blueGrey)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFEC4899), width: 1.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRealFlaskSVG(size: 32, isPink: true),
                const SizedBox(height: 4),
                const Text('Endpoint (pH 8.2)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                const Text('FAINT PERSISTENT PINK\nSignals exact stoichiometric equivalence point!', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, color: Color(0xFFBE185D))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide4Quiz() {
    final options = [
      'Colorless in Acid ➔ Pale Persistent Pink at Endpoint',
      'Turns Dark Blue in Acid ➔ Red at Endpoint',
      'Remains completely clear regardless of pH',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'CHECKPOINT QUESTION:\nWhat is the color change of Phenolphthalein at the titration endpoint?',
          style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (ctx, idx) {
              final isSelected = _selectedQuizIndex == idx;
              final isRight = idx == 0;
              Color bg = const Color(0xFFF8FAFC);
              Color border = ColorSystem.plum.withOpacity(0.15);

              if (isSelected) {
                bg = isRight ? ColorSystem.green.withOpacity(0.18) : ColorSystem.coral.withOpacity(0.18);
                border = isRight ? ColorSystem.green : ColorSystem.coral;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => _submitQuiz(idx),
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
  // LEVEL 2: APPARATUS WORKBENCH (6 REALISTIC GLASSWARE ITEMS)
  // =========================================================================
  Widget _buildLevel2ApparatusAssembly() {
    final apparatusList = [
      {'id': 'stand', 'name': 'Retort Stand & Clamp', 'desc': 'Clamps burette vertically', 'widget': _buildRealStandSVG(size: 24)},
      {'id': 'burette', 'name': '50 mL Glass Burette', 'desc': 'Precision stopcock dispenser', 'widget': _buildRealBuretteSVG(size: 24)},
      {'id': 'flask', 'name': '250 mL Conical Flask', 'desc': 'Erlenmeyer reaction vessel', 'widget': _buildRealFlaskSVG(size: 24, isPink: false)},
      {'id': 'pipette', 'name': '20 mL Volumetric Pipette', 'desc': 'Accurate aliquot transfer', 'widget': _buildRealPipetteSVG(size: 24)},
      {'id': 'beaker', 'name': '100 mL Pyrex Beaker', 'desc': 'Holding stock solutions', 'widget': _buildRealBeakerSVG(size: 24)},
      {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Heating source (Not needed for titration)', 'widget': _buildRealBurnerSVG(size: 24)},
    ];

    final requiredItems = {'stand', 'burette', 'flask', 'pipette'};
    final isDone = requiredItems.every((id) => _assembledApparatus.contains(id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 2: Select the 4 required glassware apparatus for titration from the 6 lab tools below!"',
          isDone ? DendyState.success : DendyState.thinking,
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
                    const Text('SELECT REQUIRED APPARATUS (4 OF 6)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    Text('${_assembledApparatus.length} Selected', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: isDone ? ColorSystem.green : ColorSystem.purple)),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.1,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: apparatusList.length,
                    itemBuilder: (ctx, idx) {
                      final item = apparatusList[idx];
                      final isAdded = _assembledApparatus.contains(item['id']);

                      return InkWell(
                        onTap: () => _toggleApparatus(item['id'] as String),
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
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isAdded ? ColorSystem.green.withOpacity(0.15) : ColorSystem.castlePurple.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: item['widget'] as Widget,
                              ),
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
                              Icon(
                                isAdded ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                                size: 14,
                                color: isAdded ? ColorSystem.green : Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
            text: isDone ? 'START REAGENTS PREPARATION ➜' : 'Select Retort Stand, Burette, Flask & Pipette',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? _finishLevel2 : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 3: REAGENTS PREPARATION (6 REALISTIC REAGENT BOTTLES)
  // =========================================================================
  Widget _buildLevel3ReagentsPreparation() {
    final reagentsList = [
      {'id': 'hcl', 'name': '0.100 M HCl Acid', 'type': 'acid', 'desc': 'Analyte Solution', 'color': ColorSystem.coral, 'req': true},
      {'id': 'phenolphthalein', 'name': 'Phenolphthalein', 'type': 'indicator', 'desc': 'pH 8.2-10.0 Indicator', 'color': const Color(0xFFEC4899), 'req': true},
      {'id': 'naoh', 'name': '0.100 M NaOH Standard', 'type': 'base', 'desc': 'Titrant in Burette', 'color': ColorSystem.purple, 'req': false},
      {'id': 'ch3cooh', 'name': '0.100 M CH₃COOH', 'type': 'acid', 'desc': 'Acetic Acid (Distractor)', 'color': const Color(0xFFD97706), 'req': false},
      {'id': 'methyl_orange', 'name': 'Methyl Orange', 'type': 'indicator', 'desc': 'pH 3.1-4.4 Indicator', 'color': const Color(0xFFF59E0B), 'req': false},
      {'id': 'h2o', 'name': 'Distilled H₂O', 'type': 'solvent', 'desc': 'Rinse Solvent', 'color': Colors.blue, 'req': false},
    ];

    final isDone = _acidPipetted && _indicatorAdded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 3: Select and pipette 20.0 mL of 0.1M HCl into the flask, then add 3 drops of Phenolphthalein!"',
          isDone ? DendyState.success : DendyState.thinking,
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
                    const Text('CHEMICAL REAGENTS SHELF (SELECT CORRECT PAIR)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                    Text(_acidPipetted && _indicatorAdded ? '✓ Ready' : 'Select Acid & Indicator', style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.w900, color: isDone ? ColorSystem.green : ColorSystem.coral)),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: reagentsList.length,
                    itemBuilder: (ctx, idx) {
                      final item = reagentsList[idx];
                      final isSelected = (_selectedAcid == item['id']) || (_selectedIndicator == item['id']);

                      return InkWell(
                        onTap: () {
                          if (item['type'] == 'acid') {
                            _selectAcid(item['id'] as String);
                          } else if (item['type'] == 'indicator') {
                            _selectIndicator(item['id'] as String);
                          } else {
                            SoundService.playStarPop();
                          }
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isSelected ? ColorSystem.green.withOpacity(0.12) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? ColorSystem.green : (item['color'] as Color).withOpacity(0.3),
                              width: isSelected ? 1.6 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildRealBottleSVG(color: item['color'] as Color, size: 22),
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
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, size: 14, color: ColorSystem.green),
                            ],
                          ),
                        ),
                      );
                    },
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
            text: isDone ? 'START TITRATION SIMULATOR ➜' : 'Select 0.1M HCl and Phenolphthalein',
            backgroundColor: isDone ? ColorSystem.green : Colors.grey.shade400,
            textColor: Colors.white,
            onPressed: isDone ? _finishLevel3 : () {},
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // LEVEL 4: INTERACTIVE TITRATION SIMULATOR
  // =========================================================================
  Widget _buildLevel4TitrationSimulator() {
    final ph = _getCalculatedPH();
    final liquidColor = _getFlaskColor();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 4: Turn the stopcock to add drops of NaOH. Swirl regularly. Stop right when a faint persistent pink endpoint appears!"',
          DendyState.thinking,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.12)),
                    ),
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
                            decoration: BoxDecoration(
                              color: ColorSystem.plum.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(5),
                            ),
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
                      CustomButton(text: '🎯 Verify Endpoint', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyEndpoint),
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
  // LEVEL 5: REPORT & REWARDS
  // =========================================================================
  Widget _buildLevel5ReportAndRewards() {
    final diff = (_buretteVolume - _targetEndpoint).abs();
    final calculatedMolarity = _buretteVolume > 0 ? (0.1 * _buretteVolume / 20.0) : 0.0;
    final accuracy = (100.0 - (diff * 5.0)).clamp(70.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 5: Excellent laboratory work! Review your stoichiometry analysis below and claim your 3-star trophy!"',
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
                    const Text('FINAL LAB REPORT', style: TextStyle(fontFamily: 'Fredoka', fontSize: 10.5, fontWeight: FontWeight.w900, color: ColorSystem.green)),
                    Text('Accuracy: ${accuracy.toStringAsFixed(1)}%', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.1)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildReportRow('Analyte Solution', '20.00 mL HCl (0.100 M)'),
                        _buildReportRow('Titrant Standard', '0.100 M NaOH'),
                        _buildReportRow('Endpoint Volume', '${_buretteVolume.toStringAsFixed(2)} mL'),
                        _buildReportRow('Calculated Molarity', '${calculatedMolarity.toStringAsFixed(4)} M'),
                        _buildReportRow('Equivalence Ratio', '1 : 1 Neutralization'),
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
            text: 'CLAIM 60 XP & FINISH LAB 🏆',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            onPressed: _claimRewardAndFinish,
          ),
        ),
      ],
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Fredoka', fontSize: 9, fontWeight: FontWeight.bold, color: ColorSystem.plum.withOpacity(0.65))),
        Text(value, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
      ],
    );
  }

  // ==========================================
  // REALISTIC LAB APPARATUS ICONS (CUSTOM PAINTERS)
  // ==========================================
  Widget _buildRealStandSVG({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StandIconPainter()),
    );
  }

  Widget _buildRealBuretteSVG({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BuretteIconPainter()),
    );
  }

  Widget _buildRealFlaskSVG({required double size, required bool isPink}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FlaskIconPainter(isPink: isPink)),
    );
  }

  Widget _buildRealPipetteSVG({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PipetteIconPainter()),
    );
  }

  Widget _buildRealBeakerSVG({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BeakerIconPainter()),
    );
  }

  Widget _buildRealBurnerSVG({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BurnerIconPainter()),
    );
  }

  Widget _buildRealBottleSVG({required Color color, required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BottleIconPainter(liquidColor: color)),
    );
  }
}

// Custom Glassware Painters
class _StandIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF334155)..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(2, size.height - 4, size.width - 4, 3), p);
    canvas.drawLine(Offset(size.width * 0.3, size.height - 4), Offset(size.width * 0.3, 2), p);
    canvas.drawLine(Offset(size.width * 0.3, size.height * 0.35), Offset(size.width * 0.8, size.height * 0.35), p..strokeWidth = 1.5);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BuretteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawRect(Rect.fromLTWH(cx - 3, 2, 6, size.height - 8), Paint()..color = const Color(0x66BAE6FD));
    canvas.drawRect(Rect.fromLTWH(cx - 3, 2, 6, size.height - 8), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawCircle(Offset(cx, size.height - 5), 2, Paint()..color = const Color(0xFFEF4444));
    canvas.drawLine(Offset(cx, size.height - 5), Offset(cx, size.height), Paint()..color = const Color(0xFF475569)..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlaskIconPainter extends CustomPainter {
  final bool isPink;
  _FlaskIconPainter({required this.isPink});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final path = Path()
      ..moveTo(cx - 3, 2)
      ..lineTo(cx + 3, 2)
      ..lineTo(cx + 3, 7)
      ..lineTo(size.width - 2, size.height - 2)
      ..lineTo(2, size.height - 2)
      ..lineTo(cx - 3, 7)
      ..close();
    canvas.drawPath(path, Paint()..color = isPink ? const Color(0x99F472B6) : const Color(0x44BAE6FD));
    canvas.drawPath(path, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PipetteIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, 4), width: 7, height: 6), Paint()..color = const Color(0xFFDC2626));
    canvas.drawRect(Rect.fromLTWH(cx - 1.5, 7, 3, size.height - 10), Paint()..color = const Color(0x66BAE6FD));
    canvas.drawRect(Rect.fromLTWH(cx - 1.5, 7, 3, size.height - 10), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 0.8);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BeakerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(3, 4, size.width - 6, size.height - 6);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = const Color(0x44BAE6FD));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 1.2);
    canvas.drawLine(Offset(size.width - 6, 8), Offset(size.width - 3, 8), Paint()..color = Colors.white..strokeWidth = 1);
    canvas.drawLine(Offset(size.width - 6, 12), Offset(size.width - 3, 12), Paint()..color = Colors.white..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BurnerIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    canvas.drawRect(Rect.fromLTWH(cx - 3, 8, 6, size.height - 12), Paint()..color = const Color(0xFF94A3B8));
    canvas.drawRect(Rect.fromLTWH(2, size.height - 4, size.width - 4, 3), Paint()..color = const Color(0xFF334155));
    final flame = Path()..moveTo(cx - 3, 8)..quadraticBezierTo(cx, 1, cx + 3, 8)..close();
    canvas.drawPath(flame, Paint()..color = const Color(0xFF38BDF8));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottleIconPainter extends CustomPainter {
  final Color liquidColor;
  _BottleIconPainter({required this.liquidColor});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Cap
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, 3), width: 6, height: 4), Paint()..color = const Color(0xFF1E293B));
    // Glass Body
    final body = Rect.fromLTWH(3, 5, size.width - 6, size.height - 6);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(3)), Paint()..color = liquidColor.withOpacity(0.85));
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(3)), Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    // Label
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, size.height * 0.55), width: size.width * 0.6, height: 6), Paint()..color = Colors.white);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Mobile Titration Canvas Painter
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

    // Retort Stand
    final standPaint = Paint()..color = const Color(0xFF334155)..strokeWidth = 3.5..strokeCap = StrokeCap.round;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(standX, size.height * 0.94), width: 45, height: 7), const Radius.circular(2)), Paint()..color = const Color(0xFF1E293B));
    canvas.drawLine(Offset(standX, size.height * 0.94), Offset(standX, size.height * 0.06), standPaint);
    canvas.drawLine(Offset(standX, size.height * 0.26), Offset(cx, size.height * 0.26), standPaint..strokeWidth = 2.5);

    // Burette
    final bTop = size.height * 0.08;
    final bBottom = size.height * 0.54;
    final bWidth = 11.0;
    final bRect = Rect.fromCenter(center: Offset(cx, (bTop + bBottom) / 2), width: bWidth, height: bBottom - bTop);

    final fraction = (1.0 - (buretteVolume / maxVolume)).clamp(0.0, 1.0);
    final liqTop = bTop + (bBottom - bTop) * (1.0 - fraction);
    canvas.drawRect(Rect.fromLTRB(cx - bWidth / 2 + 1, liqTop, cx + bWidth / 2 - 1, bBottom), Paint()..color = const Color(0x66BAE6FD));
    canvas.drawRect(bRect, Paint()..color = const Color(0xFF475569)..strokeWidth = 1.0..style = PaintingStyle.stroke);

    // Stopcock & Tip
    final valveY = bBottom + 6;
    canvas.drawCircle(Offset(cx, valveY), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawLine(Offset(cx, valveY), Offset(cx, valveY + 10), Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5);

    // Droplet
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

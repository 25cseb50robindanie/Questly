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

class VirtualLabScreen extends StatefulWidget {
  const VirtualLabScreen({Key? key}) : super(key: key);

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen>
    with TickerProviderStateMixin {
  Student? _student;
  int _currentLevel = 1; // Exactly 1 level on screen at a time (1 to 5)
  int _unlockedLevel = 1; // Strict progression: cannot skip ahead
  bool _isCompleted = false;

  // --- Animation Controllers ---
  late AnimationController _dripAnimController;
  late AnimationController _swirlAnimController;

  // --- Level 1 State: Learning & Pre-Lab Check ---
  int? _selectedQuizOption;
  bool _level1QuizSubmitted = false;

  // --- Level 2 State: Apparatus Workbench Assembly ---
  final Set<String> _assembledApparatus = {};
  final List<Map<String, dynamic>> _apparatusItems = [
    {'id': 'stand', 'name': 'Retort Stand', 'icon': Icons.tune_rounded, 'desc': 'Clamps burette vertically'},
    {'id': 'burette', 'name': '50 mL Burette', 'icon': Icons.format_color_fill_rounded, 'desc': 'Dispenses base dropwise'},
    {'id': 'flask', 'name': 'Conical Flask', 'icon': Icons.science_rounded, 'desc': 'Reaction vessel for swirling'},
    {'id': 'pipette', 'name': '20 mL Pipette', 'icon': Icons.colorize_rounded, 'desc': 'Measures exact acid volume'},
  ];

  // --- Level 3 State: Reagents Preparation ---
  bool _acidPipetted = false;
  bool _indicatorAdded = false;

  // --- Level 4 State: Interactive Titration Simulation ---
  double _buretteVolume = 0.0; // 0.00 to 50.00 mL
  final double _targetEndpoint = 20.00; // 20.00 mL of 0.1M NaOH
  bool _isContinuousDripping = false;
  Timer? _continuousDripTimer;
  bool _isSwirling = false;

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
    _continuousDripTimer?.cancel();
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

  // Strict Navigation: User can only view currently unlocked levels (no skipping)
  void _selectLevel(int level) {
    if (level < 1 || level > 5 || level > _unlockedLevel) return;
    SoundService.playClick();
    _continuousDripTimer?.cancel();
    setState(() {
      _currentLevel = level;
      _isContinuousDripping = false;
    });
  }

  // --- Level 1: Submit Learning Checkpoint ---
  void _submitLevel1Quiz(int index) {
    SoundService.playClick();
    setState(() {
      _selectedQuizOption = index;
      _level1QuizSubmitted = true;
    });

    if (index == 0) {
      // Correct!
      SoundService.playCorrect();
      if (_unlockedLevel < 2) _unlockedLevel = 2;
      _showLevelCompletionModal(
        levelNumber: 1,
        title: 'Level 1 Complete! ⭐',
        subtitle: 'You mastered the neutralization theory and indicator principles!',
        nextButtonLabel: 'Start Level 2: Apparatus Setup ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 2);
        },
      );
    } else {
      SoundService.playStarPop();
    }
  }

  // --- Level 2: Toggle Apparatus Item ---
  void _toggleApparatus(String id) {
    SoundService.playStarPop();
    setState(() {
      if (_assembledApparatus.contains(id)) {
        _assembledApparatus.remove(id);
      } else {
        _assembledApparatus.add(id);
      }
    });

    if (_assembledApparatus.length == 4) {
      SoundService.playCorrect();
      if (_unlockedLevel < 3) _unlockedLevel = 3;
      _showLevelCompletionModal(
        levelNumber: 2,
        title: 'Level 2 Complete! 🧪',
        subtitle: 'All 4 essential apparatus items are securely assembled on your lab table!',
        nextButtonLabel: 'Start Level 3: Chemical Reagents ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 3);
        },
      );
    }
  }

  // --- Level 3: Reagents Preparation ---
  void _pipetteAcid() {
    SoundService.playStarPop();
    setState(() => _acidPipetted = true);
    _checkLevel3Done();
  }

  void _addIndicator() {
    SoundService.playStarPop();
    setState(() => _indicatorAdded = true);
    _checkLevel3Done();
  }

  void _checkLevel3Done() {
    if (_acidPipetted && _indicatorAdded) {
      SoundService.playCorrect();
      if (_unlockedLevel < 4) _unlockedLevel = 4;
      _showLevelCompletionModal(
        levelNumber: 3,
        title: 'Level 3 Complete! 💧',
        subtitle: '20.0 mL of analyte acid and 3 drops of indicator are prepared in the flask!',
        nextButtonLabel: 'Start Level 4: Titration Simulator ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 4);
        },
      );
    }
  }

  // --- Level 4: Titration Experiment ---
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
    setState(() {
      _isContinuousDripping = !_isContinuousDripping;
    });

    if (_isContinuousDripping) {
      _continuousDripTimer = Timer.periodic(const Duration(milliseconds: 180), (timer) {
        if (!mounted || _buretteVolume >= 50.0) {
          timer.cancel();
          if (mounted) setState(() => _isContinuousDripping = false);
          return;
        }
        _addDrop(amount: 0.15);
      });
    } else {
      _continuousDripTimer?.cancel();
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
    _continuousDripTimer?.cancel();
    setState(() => _isContinuousDripping = false);

    final diff = (_buretteVolume - _targetEndpoint).abs();
    if (diff <= 0.35) {
      SoundService.playCorrect();
      if (_unlockedLevel < 5) _unlockedLevel = 5;
      _showLevelCompletionModal(
        levelNumber: 4,
        title: 'Level 4 Complete! 🎯',
        subtitle: 'Perfect equivalence point! Faint persistent pink endpoint detected at ${_buretteVolume.toStringAsFixed(2)} mL!',
        nextButtonLabel: 'Start Level 5: Stoichiometry Report ➜',
        onNext: () {
          Navigator.pop(context);
          setState(() => _currentLevel = 5);
        },
      );
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
            'Over-titrated (${_buretteVolume.toStringAsFixed(2)} mL). Dark pink indicates excess base. Let\'s analyze results in the final report!',
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
    final molesAcid = 0.002; // 20mL of 0.1M
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
      return const Color(0x44BAE6FD); // Clear / Light Water Blue
    } else if (ph >= 8.2 && ph <= 9.0) {
      return const Color(0x99F472B6); // Pale Persistent Pink
    } else {
      return const Color(0xDDDB2777); // Deep Magenta (Over-titrated)
    }
  }

  // --- Level 5: Final Reward Claim ---
  Future<void> _completeAllLevels() async {
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
        title: 'LAB COMPLETED! 🏆',
        message: 'You completed all 5 Virtual Lab levels with high precision and stoichiometric mastery!',
        xpReward: 60,
        goldReward: 15,
        earnedStars: stars,
        onContinue: () => Navigator.pop(context),
      );
    }
  }

  // --- Level Completion Modal Dialog ---
  void _showLevelCompletionModal({
    required int levelNumber,
    required String title,
    required String subtitle,
    required String nextButtonLabel,
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
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 44),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11.5,
                  color: ColorSystem.plum.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRewardPill('+15 XP', ColorSystem.purple),
                  const SizedBox(width: 8),
                  _buildRewardPill('+5 Coins', ColorSystem.gold),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: nextButtonLabel,
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

  Widget _buildRewardPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color == ColorSystem.gold ? const Color(0xFFD97706) : color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isShortScreen = constraints.maxHeight < 480;

              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isShortScreen ? 10 : 14,
                  vertical: isShortScreen ? 6 : 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top App Header
                    _buildTopHeader(isShortScreen),
                    SizedBox(height: isShortScreen ? 4 : 6),

                    // Level Stepper (1 to 5) with strict locks
                    _buildLevelStepper(),
                    SizedBox(height: isShortScreen ? 6 : 8),

                    // Dendy (Foxy) Teacher & Instruction Speech Box
                    _buildFoxyTeacherCard(isShortScreen),
                    SizedBox(height: isShortScreen ? 6 : 8),

                    // Active Single Level Content Card
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
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
                          borderRadius: BorderRadius.circular(12),
                          child: _buildCurrentLevelView(isShortScreen),
                        ),
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

  // ==========================================
  // 1. TOP APP HEADER
  // ==========================================
  Widget _buildTopHeader(bool isShortScreen) {
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
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VIRTUAL SCIENCE LAB',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShortScreen ? 11 : 12,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  'LEVEL $_currentLevel OF 5 • ACID-BASE TITRATION',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShortScreen ? 8.5 : 9.5,
                    fontWeight: FontWeight.w800,
                    color: ColorSystem.purple,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Live XP & Gold
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
                    Text(
                      '${_student!.xp} XP',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
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
                    Text(
                      '${_student!.gold}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.gold,
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

  // ==========================================
  // 2. LEVEL PROGRESSION STEPPER (STRICT LOCKS)
  // ==========================================
  Widget _buildLevelStepper() {
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
            child: InkWell(
              onTap: isLocked ? null : () => _selectLevel(levelNum),
              borderRadius: BorderRadius.circular(6),
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
                    Text(
                      'Level $levelNum',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ==========================================
  // 3. FOXY (DENDY) TEACHER & INSTRUCTION CARD
  // ==========================================
  Widget _buildFoxyTeacherCard(bool isShortScreen) {
    String teacherMessage;
    DendyState dendyState = DendyState.idle;

    switch (_currentLevel) {
      case 1:
        teacherMessage =
            '"Hi! I\'m Dendy, your lab tutor! Read the neutralization theory below, then answer the checkpoint question to begin!"';
        dendyState = DendyState.idle;
        break;
      case 2:
        teacherMessage =
            '"Now let\'s assemble our apparatus! Tap all 4 pieces of glassware to place them onto your workbench."';
        dendyState = DendyState.thinking;
        break;
      case 3:
        teacherMessage =
            '"Time for reagents! Pipette 20.0 mL of HCl acid into the flask, then add 3 drops of indicator!"';
        dendyState = DendyState.thinking;
        break;
      case 4:
        teacherMessage =
            '"Carefully add drops from the burette and swirl the flask. Stop right when you reach a faint persistent pink endpoint!"';
        dendyState = DendyState.thinking;
        break;
      case 5:
      default:
        teacherMessage =
            '"Outstanding chemistry mastery! Review your volumetric calculations and claim your 3-star trophy!"';
        dendyState = DendyState.success;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isShortScreen ? 8 : 10,
        vertical: isShortScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DendyMascot(
            state: dendyState,
            size: isShortScreen ? 30 : 36,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              teacherMessage,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isShortScreen ? 9 : 10,
                fontWeight: FontWeight.bold,
                color: ColorSystem.plum,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 6),
          DendySpeakButton(
            textToSpeak: teacherMessage,
            size: isShortScreen ? 18 : 20,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. LEVEL ROUTER (ONLY 1 LEVEL ON SCREEN)
  // ==========================================
  Widget _buildCurrentLevelView(bool isShortScreen) {
    switch (_currentLevel) {
      case 1:
        return _buildLevel1LearningView(isShortScreen);
      case 2:
        return _buildLevel2ApparatusView(isShortScreen);
      case 3:
        return _buildLevel3ReagentsView(isShortScreen);
      case 4:
        return _buildLevel4TitrationSimView(isShortScreen);
      case 5:
      default:
        return _buildLevel5ReportView(isShortScreen);
    }
  }

  // ------------------------------------------
  // LEVEL 1: LEARNING & PRE-LAB CHECKPOINT
  // ------------------------------------------
  Widget _buildLevel1LearningView(bool isShortScreen) {
    final List<String> quizOptions = [
      'Colorless (Acid) ➔ Pale Persistent Pink (Base)',
      'Dark Blue ➔ Bright Red at Neutral Point',
      'Remains completely clear forever',
    ];

    return Padding(
      padding: EdgeInsets.all(isShortScreen ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chemical Reaction Equation Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ColorSystem.castlePurple,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.science_rounded, color: ColorSystem.gold, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'HCl (aq) + NaOH (aq) ➔ NaCl (aq) + H₂O (l)',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Theory Guide Note
          Text(
            'Titration is a volumetric analysis method where a standard titrant (0.1M NaOH) is added dropwise to an unknown analyte (HCl) until exact neutralization occurs at the stoichiometric equivalence point.',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShortScreen ? 8.5 : 9.5,
              color: ColorSystem.plum.withOpacity(0.8),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            'CHECKPOINT: What is the color transition of Phenolphthalein indicator?',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShortScreen ? 9.5 : 10,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 6),

          // Options List
          Expanded(
            child: ListView.builder(
              itemCount: quizOptions.length,
              itemBuilder: (ctx, idx) {
                final isSelected = _selectedQuizOption == idx;
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
                    onTap: () => _submitLevel1Quiz(idx),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border, width: 1.2),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 8,
                            backgroundColor: isSelected
                                ? (isRight ? ColorSystem.green : ColorSystem.coral)
                                : ColorSystem.lavender.withOpacity(0.2),
                            child: Text(
                              String.fromCharCode(65 + idx),
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : ColorSystem.plum,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              quizOptions[idx],
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ),
                          if (isSelected && isRight)
                            const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 16),
                        ],
                      ),
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

  // ------------------------------------------
  // LEVEL 2: APPARATUS WORKBENCH ASSEMBLY
  // ------------------------------------------
  Widget _buildLevel2ApparatusView(bool isShortScreen) {
    return Padding(
      padding: EdgeInsets.all(isShortScreen ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TAP TO ASSEMBLE APPARATUS',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
              Text(
                '${_assembledApparatus.length} / 4 Placed',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: isShortScreen ? 2.1 : 1.8,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: _apparatusItems.length,
              itemBuilder: (ctx, idx) {
                final item = _apparatusItems[idx];
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
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: isAdded ? ColorSystem.green : ColorSystem.castlePurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: isAdded ? Colors.white : ColorSystem.castlePurple,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['name'] as String,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: isAdded ? ColorSystem.green : ColorSystem.plum,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['desc'] as String,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 7.5,
                                  color: ColorSystem.plum.withOpacity(0.6),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
    );
  }

  // ------------------------------------------
  // LEVEL 3: CHEMICAL REAGENTS PREPARATION
  // ------------------------------------------
  Widget _buildLevel3ReagentsView(bool isShortScreen) {
    return Padding(
      padding: EdgeInsets.all(isShortScreen ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'PREPARE FLASK REAGENTS',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: Row(
              children: [
                // Step A: Pipette Acid
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _acidPipetted ? ColorSystem.green.withOpacity(0.1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _acidPipetted ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.colorize_rounded, size: 28, color: ColorSystem.coral),
                        const SizedBox(height: 4),
                        const Text(
                          '0.100 M HCl Acid',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                        Text(
                          '20.00 mL Aliquot',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 8,
                            color: ColorSystem.plum.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          text: _acidPipetted ? '✓ Pipetted' : 'Pipette 20 mL',
                          backgroundColor: _acidPipetted ? ColorSystem.green : ColorSystem.castlePurple,
                          textColor: Colors.white,
                          onPressed: _pipetteAcid,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Step B: Indicator
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _indicatorAdded ? ColorSystem.green.withOpacity(0.1) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _indicatorAdded ? ColorSystem.green : ColorSystem.plum.withOpacity(0.15),
                        width: 1.4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.opacity_rounded, size: 28, color: Color(0xFFEC4899)),
                        const SizedBox(height: 4),
                        const Text(
                          'Phenolphthalein',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                        Text(
                          'pH 8.2 - 10.0 Indicator',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 8,
                            color: ColorSystem.plum.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          text: _indicatorAdded ? '✓ 3 Drops' : 'Add 3 Drops',
                          backgroundColor: _indicatorAdded ? ColorSystem.green : const Color(0xFFEC4899),
                          textColor: Colors.white,
                          onPressed: _addIndicator,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // LEVEL 4: INTERACTIVE DROPWISE TITRATION
  // ------------------------------------------
  Widget _buildLevel4TitrationSimView(bool isShortScreen) {
    final ph = _getCalculatedPH();
    final liquidColor = _getFlaskColor();

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          // Left: Visual Glass Workbench Canvas
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

                  // Digital HUD Readout
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
                          Text(
                            'V: ${_buretteVolume.toStringAsFixed(2)} mL',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'pH: ${ph.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Right: Tactile Mobile Controls
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  text: '+0.05 mL Drop 💧',
                  backgroundColor: ColorSystem.castlePurple,
                  textColor: Colors.white,
                  onPressed: () => _addDrop(amount: 0.05),
                ),
                CustomButton(
                  text: '+0.50 mL Fast 🌊',
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  onPressed: () => _addDrop(amount: 0.50),
                ),
                CustomButton(
                  text: _isContinuousDripping ? '⏸ Pause' : '▶ Continuous',
                  backgroundColor: _isContinuousDripping ? ColorSystem.coral : ColorSystem.lavender,
                  textColor: Colors.white,
                  onPressed: _toggleContinuous,
                ),
                CustomButton(
                  text: '🌀 Swirl Flask',
                  backgroundColor: const Color(0xFF0EA5E9),
                  textColor: Colors.white,
                  onPressed: _swirlFlask,
                ),
                CustomButton(
                  text: '🎯 Verify Endpoint',
                  backgroundColor: ColorSystem.green,
                  textColor: Colors.white,
                  onPressed: _verifyEndpoint,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // LEVEL 5: STOICHIOMETRY LAB REPORT
  // ------------------------------------------
  Widget _buildLevel5ReportView(bool isShortScreen) {
    final diff = (_buretteVolume - _targetEndpoint).abs();
    final calculatedMolarity = _buretteVolume > 0 ? (0.1 * _buretteVolume / 20.0) : 0.0;
    final accuracy = (100.0 - (diff * 5.0)).clamp(70.0, 100.0);

    return Padding(
      padding: EdgeInsets.all(isShortScreen ? 8 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FINAL LAB REPORT',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.green,
                ),
              ),
              Text(
                'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Expanded(
            child: ListView(
              children: [
                _buildReportItem('Analyte Solution', '20.00 mL HCl (0.100 M)'),
                _buildReportItem('Titrant Standard', '0.100 M NaOH'),
                _buildReportItem('Endpoint Titer Volume', '${_buretteVolume.toStringAsFixed(2)} mL'),
                _buildReportItem('Calculated Molarity', '${calculatedMolarity.toStringAsFixed(4)} M'),
                _buildReportItem('Stoichiometric Ratio', '1 : 1 Equivalence'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          CustomButton(
            text: 'CLAIM 60 XP & FINISH LAB 🏆',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            onPressed: _completeAllLevels,
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withOpacity(0.65),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MOBILE PAINTER: HIGH FIDELITY TITRATION BENCH
// ==========================================
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
    final standPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(standX, size.height * 0.94), width: 45, height: 7),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawLine(Offset(standX, size.height * 0.94), Offset(standX, size.height * 0.06), standPaint);
    canvas.drawLine(Offset(standX, size.height * 0.26), Offset(cx, size.height * 0.26), standPaint..strokeWidth = 2.5);

    // Burette
    final bTop = size.height * 0.08;
    final bBottom = size.height * 0.54;
    final bWidth = 11.0;
    final bRect = Rect.fromCenter(
      center: Offset(cx, (bTop + bBottom) / 2),
      width: bWidth,
      height: bBottom - bTop,
    );

    // Titrant liquid
    final fraction = (1.0 - (buretteVolume / maxVolume)).clamp(0.0, 1.0);
    final liqTop = bTop + (bBottom - bTop) * (1.0 - fraction);
    canvas.drawRect(
      Rect.fromLTRB(cx - bWidth / 2 + 1, liqTop, cx + bWidth / 2 - 1, bBottom),
      Paint()..color = const Color(0x66BAE6FD),
    );

    // Burette glass outline
    canvas.drawRect(
      bRect,
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // Stopcock & Tip
    final valveY = bBottom + 6;
    canvas.drawCircle(Offset(cx, valveY), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawLine(Offset(cx, valveY), Offset(cx, valveY + 10), Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5);

    // Droplet Animation
    if (dripProgress > 0.0 && dripProgress < 1.0) {
      final dropY = (valveY + 10) + (size.height * 0.76 - (valveY + 10)) * dripProgress;
      canvas.drawCircle(Offset(cx, dropY), 2.5, Paint()..color = const Color(0xFF38BDF8));
    }

    // Conical Flask
    final fTop = size.height * 0.66;
    final fBottom = size.height * 0.92;
    final fPath = Path();
    fPath.moveTo(cx - 7, fTop);
    fPath.lineTo(cx + 7, fTop);
    fPath.lineTo(cx + 7, fTop + 8);
    fPath.lineTo(cx + 26, fBottom);
    fPath.lineTo(cx - 26, fBottom);
    fPath.lineTo(cx - 7, fTop + 8);
    fPath.close();

    // Liquid in flask
    final liqY = fBottom - 18;
    final liqPath = Path();
    liqPath.moveTo(cx - 16, liqY);
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
    canvas.drawPath(
      fPath,
      Paint()
        ..color = const Color(0xFF334155)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _MobileTitrationPainter oldDelegate) => true;
}

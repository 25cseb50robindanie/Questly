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

  void _selectQuizOption(int idx) {
    SoundService.playClick();
    setState(() {
      _selectedQuizIndex = idx;
      if (idx == 0) {
        // Correct answer
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
        const SnackBar(
          content: Text('That tool is not required for acid-base titration! Select the 4 glassware items.'),
          backgroundColor: ColorSystem.coral,
          duration: Duration(milliseconds: 1500),
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
        const SnackBar(
          content: Text('That solution is not part of this reaction! Select the active titration solutions.'),
          backgroundColor: ColorSystem.coral,
          duration: Duration(milliseconds: 1500),
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

  void _verifyEndpoint() {
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
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'lab_titration',
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
        title: 'TITRATION MASTERED!',
        message: 'You completed all 5 levels of the Virtual Chemistry Lab with 100% accuracy!',
        xpReward: 60,
        goldReward: 15,
        earnedStars: 3,
        onContinue: () {
          Navigator.pop(context);
        },
      );
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
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
            ),
          ),
        ),
      ),
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
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('VIRTUAL SCIENCE LAB', style: TextStyle(fontFamily: 'Fredoka', fontSize: 12, fontWeight: FontWeight.w900, color: ColorSystem.plum)),
                Text('LEVEL $_currentLevel OF 5 • ACID–BASE TITRATION', style: const TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, fontWeight: FontWeight.w800, color: ColorSystem.purple)),
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
                      Icon(Icons.lock_outline_rounded, size: 8.5, color: Colors.grey.shade400),
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

    switch (_conceptSlide) {
      case 0:
        teacherMessage = '"Step 1/4: In an acid-base titration, hydrochloric acid reacts with sodium hydroxide to form water and salt!"';
        slideContent = _buildConceptBox(
          'HCl (aq) + NaOH (aq) ➔ NaCl (aq) + H₂O (l)',
          'Titration determines unknown acid concentration by reacting it with measured volumes of a standard base until neutralization is reached.',
        );
        break;
      case 1:
        teacherMessage = '"Step 2/4: We use standard 0.100 M NaOH titrant in the burette to find the concentration of our 20.0 mL HCl analyte acid."';
        slideContent = _buildTwoColSlide(
          '1. Analyte Acid',
          'Hydrochloric Acid (HCl)\n20.00 mL in Flask',
          '2. Standard Titrant',
          'Sodium Hydroxide (NaOH)\n0.100 M in Burette',
          ColorSystem.coral,
          ColorSystem.purple,
        );
        break;
      case 2:
        teacherMessage = '"Step 3/4: Phenolphthalein indicator stays clear in acid and turns pale pink the exact moment neutralization happens!"';
        slideContent = _buildTwoColSlide(
          'Acidic pH (< 8.2)',
          'COLORLESS / CLEAR\nIndicator stays clear in acid',
          'Endpoint (pH 8.2)',
          'FAINT PERSISTENT PINK\nExact equivalence point!',
          Colors.blueGrey,
          const Color(0xFFEC4899),
        );
        break;
      case 3:
      default:
        teacherMessage = '"Step 4/4: Checkpoint quiz! Select the correct option below to unlock and enter the apparatus lab!"';
        slideContent = _buildQuizSlide(
          'CHECKPOINT: What is the color change of Phenolphthalein at titration endpoint?',
          [
            'Colorless in Acid ➔ Pale Persistent Pink at Endpoint',
            'Turns Dark Blue in Acid ➔ Red at Endpoint',
            'Remains completely clear regardless of pH',
          ],
          0,
        );
        break;
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
                  onTap: () => _selectQuizOption(idx),
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
  // LEVEL 2: APPARATUS SELECTION (4 REQUIRED GLASSWARE PIECES)
  // =========================================================================
  Widget _buildLevel2View() {
    final tools = [
      {'id': 'stand', 'name': 'Retort Stand & Clamp', 'desc': 'Secures burette vertically', 'req': true},
      {'id': 'burette', 'name': '50 mL Glass Burette', 'desc': 'Precision titrant dispenser', 'req': true},
      {'id': 'flask', 'name': '250 mL Conical Flask', 'desc': 'Erlenmeyer reaction vessel', 'req': true},
      {'id': 'pipette', 'name': '20 mL Volumetric Pipette', 'desc': 'Accurate acid aliquot', 'req': true},
      {'id': 'beaker', 'name': '100 mL Glass Beaker', 'desc': 'Stock solution holder (Extra)', 'req': false},
      {'id': 'burner', 'name': 'Bunsen Burner Rig', 'desc': 'Heating source (Wrong tool)', 'req': false},
    ];

    final isDone = _assembledApparatus.length >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 2: Select the 4 required apparatus tools (Stand, Burette, Flask, Pipette) to set up the titration workbench!"',
          isDone ? DendyState.success : DendyState.thinking,
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
                  onTap: () => _toggleApparatus(item['id'] as String, item['req'] as bool),
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
    final reagents = [
      {'id': 'hcl', 'name': '0.100 M HCl Acid', 'desc': 'Analyte Solution in Flask', 'req': true},
      {'id': 'naoh', 'name': '0.100 M NaOH Standard', 'desc': 'Standard Titrant in Burette', 'req': true},
      {'id': 'phenolphthalein', 'name': 'Phenolphthalein', 'desc': 'pH 8.2-10.0 Indicator', 'req': true},
      {'id': 'ch3cooh', 'name': '0.100 M Acetic Acid', 'desc': 'Weak Acid (Distractor)', 'req': false},
      {'id': 'methyl_orange', 'name': 'Methyl Orange', 'desc': 'pH 3.1-4.4 Indicator (Distractor)', 'req': false},
      {'id': 'oil', 'name': 'Mineral Oil', 'desc': 'Nonpolar Liquid (Wrong)', 'req': false},
    ];

    final isDone = _selectedReagents.length >= 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFoxyTeacherBanner(
          '"Level 3: Select at least 2 active chemical reagents required for titration (HCl, NaOH, or Phenolphthalein)!"',
          isDone ? DendyState.success : DendyState.thinking,
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
                final isSelected = _selectedReagents.contains(item['id']);

                return InkWell(
                  onTap: () => _toggleReagent(item['id'] as String, item['req'] as bool),
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
  // LEVEL 4: INTERACTIVE TITRATION SIMULATOR
  // =========================================================================
  Widget _buildLevel4InteractiveWorkbench() {
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
                        AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) => CustomPaint(
                            size: Size.infinite,
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
                      CustomButton(text: '+0.05 mL Drop', backgroundColor: ColorSystem.castlePurple, textColor: Colors.white, onPressed: () => _addDrop(amount: 0.05)),
                      CustomButton(text: '+1.00 mL Fast', backgroundColor: ColorSystem.purple, textColor: Colors.white, onPressed: () => _addDrop(amount: 1.00)),
                      CustomButton(text: '+5.00 mL Pour', backgroundColor: const Color(0xFF6366F1), textColor: Colors.white, onPressed: () => _addDrop(amount: 5.00)),
                      CustomButton(text: _isContinuousDripping ? '⏸ Pause' : '▶ Continuous', backgroundColor: _isContinuousDripping ? ColorSystem.coral : ColorSystem.lavender, textColor: Colors.white, onPressed: _toggleContinuous),
                      CustomButton(text: 'Swirl Flask', backgroundColor: const Color(0xFF0EA5E9), textColor: Colors.white, onPressed: _swirlFlask),
                      CustomButton(text: 'Verify Endpoint', backgroundColor: ColorSystem.green, textColor: Colors.white, onPressed: _verifyEndpoint),
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
          '"Level 5: Outstanding achievement! Review your stoichiometry analysis below and claim your 3-star trophy!"',
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
                        _buildAnalysisRow('Analyte Acid Solution', '20.00 mL HCl (0.100 M)', Icons.science_rounded),
                        _buildAnalysisRow('Titrant Base Standard', '0.100 M NaOH (Burette)', Icons.opacity_rounded),
                        _buildAnalysisRow('Measured Endpoint Volume', '${_buretteVolume.toStringAsFixed(2)} mL', Icons.straighten_rounded),
                        _buildAnalysisRow('Calculated Acid Molarity', '${calculatedMolarity.toStringAsFixed(4)} M', Icons.check_circle_rounded),
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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), border: Border(top: BorderSide(color: ColorSystem.plum.withOpacity(0.1)))),
          child: CustomButton(
            text: 'CLAIM 60 XP & FINISH LAB',
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
// HIGH FIDELITY TITRATION PAINTER
// ==========================================
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
    final bRect = Rect.fromCenter(center: Offset(cx, (bTop + bBottom) / 2), width: bWidth, height: bBottom - bTop);

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

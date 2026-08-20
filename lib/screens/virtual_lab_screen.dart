// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/progress.dart';
import '../models/student.dart';
import '../services/sound_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/questly_background.dart';
import '../widgets/vector_asset_helper.dart';

class VirtualLabScreen extends StatefulWidget {
  const VirtualLabScreen({Key? key}) : super(key: key);

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen> {
  Student? _student;
  int _currentStage = 1;
  bool _isCompleted = false;
  StreamSubscription<html.MessageEvent>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadStudent();
    _listenToLabEvents();
  }

  void _loadStudent() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
    });
  }

  void _listenToLabEvents() {
    try {
      _messageSubscription = html.window.onMessage.listen((event) {
        final data = event.data;
        if (data is Map && data['type'] == 'QUESTLY_LAB_EVENT') {
          final eventType = data['event'];
          if (eventType == 'stage_complete') {
            final stage = data['stage'] as int? ?? 1;
            SoundService.playStarPop();
            if (mounted) {
              setState(() {
                _currentStage = (stage + 1).clamp(1, 5);
              });
            }
          } else if (eventType == 'lab_complete') {
            _onLabCompleted();
          } else if (eventType == 'navigate_back') {
            _handleReturnToRoadmap();
          }
        }
      });
    } catch (_) {}
  }

  void _handleReturnToRoadmap() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _onLabCompleted() async {
    if (_isCompleted) return;
    _isCompleted = true;

    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save 3-Star Progress Record
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'lab_titration_1',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Award XP (+60) and Quest Coins (+15)
      final updated = _student!.copyWith(
        xp: _student!.xp + 60,
        gold: _student!.gold + 15,
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
          _currentStage = 5;
        });
      }
    }

    SoundService.playLevelComplete();
    if (mounted) {
      _showCompletionDialog();
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  String _getSimulationUrl() {
    try {
      final origin = html.window.location.origin;
      return '$origin/virtual_lab/index.html';
    } catch (_) {
      return '/virtual_lab/index.html';
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
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isShort ? 12 : 18,
              vertical: isShort ? 8 : 10,
            ),
            child: Column(
              children: [
                // Top Header Bar with 5-Stage Tracker & XP/Coins
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 6 : 8),

                // Main Area: Embedded Chemistry Lab (Left) + Dendy Guide Card (Right)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Virtual Lab HTML5 Canvas Frame
                      Expanded(
                        child: Container(
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: SizedBox.expand(
                              child: HtmlElementView.fromTagName(
                                key: const ValueKey('virtual_chemistry_lab'),
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
                      SizedBox(width: isShort ? 8 : 12),

                      // Dendy Companion Guidance Panel
                      SizedBox(
                        width: isShort ? 250 : 280,
                        child: _buildGuidancePanel(isShort),
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
  // 1. TOP HEADER BAR
  // ==========================================
  Widget _buildHeaderBar(bool isShort) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button + Title
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 20),
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
                  'VIRTUAL LABS',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: isShort ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                Text(
                  'ACID–BASE TITRATION',
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

        const SizedBox(width: 8),

        // 5-Stage Tracker Badges
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStageBadge('1. Apparatus', 1),
            const SizedBox(width: 4),
            _buildStageBadge('2. Solutions', 2),
            const SizedBox(width: 4),
            _buildStageBadge('3. Pipette', 3),
            const SizedBox(width: 4),
            _buildStageBadge('4. Titration', 4),
            const SizedBox(width: 4),
            _buildStageBadge('5. Results', 5),
          ],
        ),

        const SizedBox(width: 8),

        // XP & Coins Counters
        if (_student != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
          ),
      ],
    );
  }

  Widget _buildStageBadge(String label, int stageNumber) {
    final isCompleted = _currentStage > stageNumber;
    final isActive = _currentStage == stageNumber;

    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.2);
    Color textColor = ColorSystem.plum.withOpacity(0.6);

    if (isActive) {
      bg = ColorSystem.purple;
      border = ColorSystem.purple;
      textColor = Colors.white;
    } else if (isCompleted) {
      bg = ColorSystem.green.withOpacity(0.18);
      border = ColorSystem.green;
      textColor = ColorSystem.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted) ...[
            const Icon(Icons.check_rounded, size: 10, color: ColorSystem.green),
            const SizedBox(width: 2),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
        ],
      ),
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
  // 2. DENDY GUIDANCE PANEL
  // ==========================================
  Widget _buildGuidancePanel(bool isShort) {
    String message;
    DendyState dendyState = DendyState.idle;

    switch (_currentStage) {
      case 1:
        message = '"Select the 4 required apparatus cards on the lab table: Conical Flask, Pipette, Burette, and Beaker!"';
        dendyState = DendyState.idle;
        break;
      case 2:
        message = '"Great! Now prepare your solutions and choose the right acid, base, and phenolphthalein indicator!"';
        dendyState = DendyState.thinking;
        break;
      case 3:
        message = '"Measure the solution carefully using the pipette and transfer it into the conical flask."';
        dendyState = DendyState.thinking;
        break;
      case 4:
        message = '"Add drops from the burette stopcock slowly until the solution reaches the exact pink endpoint!"';
        dendyState = DendyState.thinking;
        break;
      case 5:
      default:
        message = '"Outstanding chemistry work! You completed the titration experiment with 100% accuracy!"';
        dendyState = DendyState.success;
        break;
    }

    return Container(
      padding: EdgeInsets.all(isShort ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 1.8),
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
          // Dendy speech row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DendyMascot(state: dendyState, size: isShort ? 32 : 38),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isShort ? 9 : 10,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Experiment Checklist
          Text(
            'TITRATION OBJECTIVES',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 9.5 : 10.5,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ColorSystem.lavender.withOpacity(0.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildChecklistRow('1. Apparatus Selection', _currentStage > 1),
                  _buildChecklistRow('2. Solutions Preparation', _currentStage > 2),
                  _buildChecklistRow('3. Pipette & Flask Setup', _currentStage > 3),
                  _buildChecklistRow('4. Dropwise Titration', _currentStage > 4),
                  _buildChecklistRow('5. Endpoint Detection', _currentStage >= 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String label, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 13,
            color: isDone ? ColorSystem.green : ColorSystem.plum.withOpacity(0.35),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                color: isDone ? ColorSystem.green : ColorSystem.plum,
                decoration: isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. COMPLETION CELEBRATION MODAL
  // ==========================================
  void _showCompletionDialog() {
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
                // 3 Gold Stars
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
                  'LAB COMPLETED!',
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
                  'You successfully mastered the Acid-Base Titration experiment in the Virtual Chemistry Lab!',
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
                    Navigator.of(context, rootNavigator: true).pop(); // Close dialog
                    _handleReturnToRoadmap(); // Return to roadmap / home
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

import 'dart:async';
import '../services/speech_recognition_helper.dart';
import '../services/whisper_voice_service.dart';
import '../services/localization_service.dart';
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
import '../widgets/quest_completion_dialog.dart';
import '../widgets/vector_asset_helper.dart';

class DensityTeachBackScreen extends StatefulWidget {
  final Activity? activity;

  const DensityTeachBackScreen({Key? key, this.activity}) : super(key: key);

  @override
  State<DensityTeachBackScreen> createState() => _DensityTeachBackScreenState();
}

enum _TeachBackStage {
  input,
  reviewed,
  mastery,
}

class _DensityTeachBackScreenState extends State<DensityTeachBackScreen> {
  Student? _student;
  _TeachBackStage _stage = _TeachBackStage.input;

  // Speech Recognition state
  dynamic _speechRecognition;
  bool _isListening = false;
  bool _isSpeechAvailable = true;
  String _transcribedText = '';
  bool _isManualTyping = false;

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _student = Locator.studentRepository.getCurrentStudent() ?? Locator.authService.getCurrentStudent();
    _initWebSpeechRecognition();
  }

  void _initWebSpeechRecognition() {
    if (!SpeechRecognitionHelper.isSupported) {
      _isSpeechAvailable = false;
      _isManualTyping = true;
      return;
    }
  }

  @override
  void dispose() {
    try {
      if (_speechRecognition != null && _isListening) {
        _speechRecognition.stop();
      }
    } catch (_) {}
    _textController.dispose();
    super.dispose();
  }

  void _handleReturn() {
    SoundService.playClick();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/roadmap');
    }
  }

  void _toggleListening() {
    SoundService.playClick();
    if (!SpeechRecognitionHelper.isSupported) {
      setState(() {
        _isManualTyping = true;
      });
      return;
    }

    if (_isListening) {
      try {
        _speechRecognition?.stop();
      } catch (_) {}
      setState(() {
        _isListening = false;
      });
    } else {
      try {
        _speechRecognition = SpeechRecognitionHelper.create();
        if (_speechRecognition != null) {
          _speechRecognition.start(
            langCode: 'en-US',
            continuous: true,
            interimResults: true,
            onStart: () {
              if (mounted) setState(() => _isListening = true);
            },
            onResult: (transcript) {
              if (mounted && transcript.trim().isNotEmpty) {
                setState(() {
                  _transcribedText = transcript.trim();
                  _textController.text = _transcribedText;
                });
              }
            },
            onError: () {
              if (mounted) {
                setState(() {
                  _isListening = false;
                  if (_transcribedText.isEmpty) {
                    _isManualTyping = true;
                  }
                });
              }
            },
            onEnd: () {
              if (mounted) {
                setState(() => _isListening = false);
              }
            },
          );
        }
      } catch (_) {
        setState(() {
          _isListening = false;
          _isManualTyping = true;
        });
      }
    }
  }

  TeachBackEvaluation? _evaluation;
  bool _isEvaluating = false;

  Future<void> _submitExplanation() async {
    final text = _isManualTyping ? _textController.text.trim() : _transcribedText.trim();
    if (text.isEmpty) return;

    if (_isListening) {
      try {
        _speechRecognition?.stop();
      } catch (_) {}
      _isListening = false;
    }

    setState(() {
      _isEvaluating = true;
    });

    final eval = await Locator.whisperVoiceService.evaluateTeachBack(
      moduleId: 'mod_density',
      transcript: text,
      language: LocalizationService.currentLanguage,
      topicTitle: 'Density & Buoyancy',
    );

    if (mounted) {
      setState(() {
        _evaluation = eval;
        _isEvaluating = false;
        _stage = _TeachBackStage.mastery;
      });
      SoundService.playSuccess();
    }
  }

  Future<void> _completeLevel1Mastery() async {
    if (_student != null) {
      final sId = _student!.questlyId.toLowerCase();

      // 1. Save Lesson 5 Progress Record
      await Locator.progressRepository.saveProgress(Progress(
        studentId: sId,
        lessonId: 'density_les5',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      // 2. Mark storage keys for Lesson 5 and Level 1 mastery
      await Locator.storageService.setBool('lesson_comp_${sId}_density_les5', true);
      await Locator.storageService.setBool('node_comp_${sId}_density_node1', true);
      await Locator.storageService.setBool('level_unlocked_${sId}_density_lvl2', true);
      await Locator.storageService.setBool('lesson_unlocked_${sId}_density_les6', true);

      // 3. Award Level 1 Mastery rewards (+100 XP, +20 Coins)
      final updated = _student!.copyWith(
        xp: _student!.xp + 100,
        gold: _student!.gold + 20,
        currentModuleId: 'mod_density',
        currentLessonId: 'density_les6',
      );
      await Locator.studentRepository.updateStudentProfile(updated);

      if (mounted) {
        setState(() {
          _student = updated;
        });
      }
    }

    if (mounted) {
      QuestCompletionDialog.show(
        context: context,
        xpReward: 100,
        goldReward: 20,
        earnedStars: 3,
        title: 'LEVEL 1 MASTERED!',
        message: 'You completed the entire Discover Density learning journey! Level 2 is now unlocked on the Roadmap.',
        onContinue: () {
          _handleReturn();
        },
      );
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
              horizontal: isShort ? 12 : 20,
              vertical: isShort ? 8 : 12,
            ),
            child: Column(
              children: [
                // Top Header Bar
                _buildHeaderBar(isShort),
                SizedBox(height: isShort ? 8 : 12),

                // Main Stage View
                Expanded(
                  child: _stage == _TeachBackStage.mastery
                      ? _buildMasteryCelebrationView(isShort)
                      : _buildTeachBackInputView(isShort),
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
        // Back Button & Badge
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleReturn,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ColorSystem.purple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'LESSON 5: TEACH-BACK',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Teach It Back',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: isShort ? 12 : 14,
                fontWeight: FontWeight.w900,
                color: ColorSystem.plum,
              ),
            ),
          ],
        ),

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

  Widget _buildMetricBadge(Widget icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TEACH-BACK INPUT VIEW
  // ==========================================
  Widget _buildTeachBackInputView(bool isShort) {
    final hasContent = _isManualTyping
        ? _textController.text.trim().isNotEmpty
        : _transcribedText.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Prompt Cards & Guiding Questions
        Expanded(
          flex: 11,
          child: Column(
            children: [
              // Guiding Prompts Box
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorSystem.lavender,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'EXPLAIN IN YOUR OWN WORDS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        const Text(
                          'Why do some objects float while others sink?',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Imagine explaining density to a friend who has never learned science before. Try to touch on these concepts:',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            color: ColorSystem.plum.withOpacity(0.75),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Bullet prompts
                        _buildPromptItem('What is density? (Mass packed inside volume)'),
                        const SizedBox(height: 6),
                        _buildPromptItem('How do mass and volume affect whether an object floats?'),
                        const SizedBox(height: 6),
                        _buildPromptItem('How does an object\'s density compare to water (1.00 kg/L)?'),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isShort ? 6 : 10),

              // Dendy Mascot Speech Dock
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ColorSystem.plum, width: 1.5),
                ),
                child: DendyMascot(
                  size: isShort ? 44 : 50,
                  state: _isListening ? DendyState.thinking : DendyState.idle,
                  message: _isListening
                      ? 'I am listening closely! Explain density in your own words...'
                      : 'Press Speak to talk or type your explanation on the right!',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Right Column: Voice Recorder & Transcript Editor
        Expanded(
          flex: 13,
          child: Container(
            padding: EdgeInsets.all(isShort ? 12 : 16),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Switcher: Voice vs Type
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isManualTyping ? 'YOUR WRITTEN EXPLANATION' : 'YOUR VOICE EXPLANATION',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(
                        _isManualTyping ? Icons.mic_rounded : Icons.keyboard_rounded,
                        size: 14,
                        color: ColorSystem.purple,
                      ),
                      label: Text(
                        _isManualTyping ? 'SWITCH TO VOICE' : 'TYPE INSTEAD',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isManualTyping = !_isManualTyping;
                          if (_isListening) {
                            try {
                              _speechRecognition?.stop();
                            } catch (_) {}
                            _isListening = false;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Main Input Body
                Expanded(
                  child: _isManualTyping
                      ? _buildManualTypeView()
                      : _buildVoiceRecorderView(isShort),
                ),
                const SizedBox(height: 10),

                // Action Buttons
                CustomButton(
                  text: _isEvaluating ? 'EVALUATING WITH WHISPER AI...' : 'SUBMIT EXPLANATION',
                  backgroundColor: hasContent && !_isEvaluating ? ColorSystem.green : Colors.grey.shade400,
                  textColor: Colors.white,
                  height: isShort ? 36 : 42,
                  onPressed: hasContent && !_isEvaluating ? _submitExplanation : () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: ColorSystem.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5, right: 8),
            decoration: const BoxDecoration(
              color: ColorSystem.purple,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: ColorSystem.plum,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecorderView(bool isShort) {
    return Column(
      children: [
        // Mic Button
        Center(
          child: GestureDetector(
            onTap: _toggleListening,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isShort ? 64 : 76,
              height: isShort ? 64 : 76,
              decoration: BoxDecoration(
                color: _isListening ? const Color(0xFFFF4D4D) : ColorSystem.purple,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? const Color(0xFFFF4D4D) : ColorSystem.purple).withOpacity(0.35),
                    offset: const Offset(0, 4),
                    blurRadius: _isListening ? 14 : 8,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: isShort ? 32 : 38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _isListening ? 'LISTENING... TAP TO FINISH' : 'TAP TO SPEAK YOUR ANSWER',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: _isListening ? const Color(0xFFFF4D4D) : ColorSystem.purple,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Live Transcript Box
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorSystem.plum.withOpacity(0.18), width: 1.2),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'YOU SAID:',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _transcribedText.isNotEmpty
                        ? _transcribedText
                        : 'Your speech transcript will appear here as you speak...',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11.5,
                      fontWeight: _transcribedText.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
                      color: _transcribedText.isNotEmpty ? ColorSystem.plum : Colors.grey.shade500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualTypeView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1.2),
      ),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 12,
          color: ColorSystem.plum,
          height: 1.35,
        ),
        decoration: InputDecoration(
          hintText: 'Type your explanation of density and floating here...',
          hintStyle: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11.5,
            color: Colors.grey.shade400,
          ),
          contentPadding: const EdgeInsets.all(10),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  // ==========================================
  // LEVEL 1 MASTERY CELEBRATION VIEW
  // ==========================================
  Widget _buildMasteryCelebrationView(bool isShort) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Container(
          padding: EdgeInsets.all(isShort ? 16 : 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorSystem.plum, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 8),
                blurRadius: 18,
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorSystem.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorSystem.gold, width: 1.2),
                      ),
                      child: const Text(
                        'LEVEL 1 COMPLETE',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_evaluation != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorSystem.green.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: ColorSystem.green, width: 1.2),
                        ),
                        child: Text(
                          'SCORE: ${_evaluation!.masteryScore}%',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.green,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  _evaluation?.feedbackTitle ?? 'DENSITY MASTERED',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _evaluation?.feedbackBody ?? 'Great job explaining density in your own words! You completed all 5 steps of Level 1.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11.5,
                    color: ColorSystem.plum.withOpacity(0.75),
                  ),
                ),
                const SizedBox(height: 12),

                // 5 Completed Stars Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorSystem.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ColorSystem.gold.withOpacity(0.6), width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMasteryStarBadge('CURIOSITY'),
                      _buildMasteryStarBadge('EXPERIMENT'),
                      _buildMasteryStarBadge('APPLY'),
                      _buildMasteryStarBadge('CHALLENGE'),
                      _buildMasteryStarBadge('TEACH-BACK'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Dendy Companion Praise
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
                  ),
                  child: DendyMascot(
                    size: isShort ? 40 : 46,
                    state: _evaluation?.dendyMood == 'thinking' ? DendyState.thinking : DendyState.success,
                    message: _evaluation?.feedbackBody ?? 'You understand density deeply! Level 2: Float or Sink is now unlocked on your Roadmap.',
                  ),
                ),
                const SizedBox(height: 14),

                // Final Action Button
                CustomButton(
                  text: 'CLAIM REWARDS & UNLOCK LEVEL 2',
                  backgroundColor: ColorSystem.green,
                  textColor: Colors.white,
                  height: 42,
                  onPressed: _completeLevel1Mastery,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasteryStarBadge(String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VectorAssetHelper.xpStarIcon(size: 24, isFilled: true),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }
}

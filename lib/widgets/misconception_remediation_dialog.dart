import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/misconception_engine.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'fraction_visual_models.dart';
import 'dendy_mascot.dart';

class MisconceptionRemediationDialog extends StatefulWidget {
  final MisconceptionDiagnosis diagnosis;
  final VoidCallback onResolved;

  const MisconceptionRemediationDialog({
    Key? key,
    required this.diagnosis,
    required this.onResolved,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required MisconceptionDiagnosis diagnosis,
    required VoidCallback onResolved,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MisconceptionRemediationDialog(
        diagnosis: diagnosis,
        onResolved: onResolved,
      ),
    );
  }

  @override
  State<MisconceptionRemediationDialog> createState() => _MisconceptionRemediationDialogState();
}

class _MisconceptionRemediationDialogState extends State<MisconceptionRemediationDialog> {
  int? _selectedRetryIndex;
  bool _isAnswered = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShortScreen = size.height < 450;
    final diag = widget.diagnosis;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 540,
            maxHeight: size.height * 0.94,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isShortScreen ? 16 : 22,
              vertical: isShortScreen ? 12 : 18,
            ),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.gold, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.25),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header with Lightbulb & Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: ColorSystem.gold.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb_rounded, color: ColorSystem.gold, size: 24),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AHA! LET\'S CLEAR THIS UP',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: isShortScreen ? 9.5 : 11,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.purple,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              diag.title.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: isShortScreen ? 13 : 15,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const DendyMascot(size: 38, mood: DendyMood.explaining),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Side-by-Side Comparison: What you thought vs The Rule
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Common trap explanation
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.help_outline_rounded, color: ColorSystem.pink, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                diag.studentThinking,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 11.5,
                                  color: ColorSystem.plum.withOpacity(0.85),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(color: ColorSystem.plum.withOpacity(0.1), height: 1),
                        const SizedBox(height: 8),
                        // Golden Rule
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.stars_rounded, color: ColorSystem.gold, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                diag.correctConcept,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.plum,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. Visual Demonstration
                  _buildVisualExplanation(diag),
                  const SizedBox(height: 12),

                  // 4. Scaffolded Quick Recovery Question
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorSystem.lavender.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorSystem.purple.withOpacity(0.3), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎯 QUICK CHECK – TEST YOUR UNDERSTANDING',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          diag.retryProblem.question,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.plum,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Options
                        ...List.generate(diag.retryProblem.options.length, (index) {
                          final option = diag.retryProblem.options[index];
                          final isSelected = _selectedRetryIndex == index;
                          final isCorrectOption = index == diag.retryProblem.correctIndex;

                          Color optBg = Colors.white;
                          Color optBorder = ColorSystem.plum.withOpacity(0.2);

                          if (_isAnswered) {
                            if (isCorrectOption) {
                              optBg = ColorSystem.green.withOpacity(0.15);
                              optBorder = ColorSystem.green;
                            } else if (isSelected && !isCorrectOption) {
                              optBg = ColorSystem.pink.withOpacity(0.15);
                              optBorder = ColorSystem.pink;
                            }
                          } else if (isSelected) {
                            optBg = ColorSystem.purple.withOpacity(0.12);
                            optBorder = ColorSystem.purple;
                          }

                          return GestureDetector(
                            onTap: () {
                              SoundService.playClick();
                              setState(() {
                                _selectedRetryIndex = index;
                                _isAnswered = true;
                                _isCorrect = (index == diag.retryProblem.correctIndex);
                              });
                              if (_isCorrect) {
                                SoundService.playSuccess();
                              } else {
                                SoundService.playSwitch();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: optBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: optBorder, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isAnswered && isCorrectOption
                                        ? Icons.check_circle_rounded
                                        : (_isAnswered && isSelected
                                            ? Icons.cancel_rounded
                                            : (isSelected
                                                ? Icons.radio_button_checked_rounded
                                                : Icons.radio_button_unchecked_rounded)),
                                    color: _isAnswered && isCorrectOption
                                        ? ColorSystem.green
                                        : (_isAnswered && isSelected ? ColorSystem.pink : ColorSystem.plum),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 11.5,
                                        fontWeight: isSelected || (_isAnswered && isCorrectOption)
                                            ? FontWeight.w900
                                            : FontWeight.normal,
                                        color: ColorSystem.plum,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Feedback message after answer
                        if (_isAnswered) ...[
                          const SizedBox(height: 6),
                          Text(
                            _isCorrect ? diag.retryProblem.feedback : diag.scaffoldedHint,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isCorrect ? ColorSystem.green : ColorSystem.pink,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Continue Button
                  CustomButton(
                    text: _isCorrect ? 'CONTINUE LEARNING ✓' : 'I UNDERSTAND THE RULE',
                    backgroundColor: _isCorrect ? ColorSystem.green : ColorSystem.purple,
                    textColor: Colors.white,
                    height: 42,
                    onPressed: () {
                      SoundService.playClick();
                      Navigator.pop(context);
                      widget.onResolved();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualExplanation(MisconceptionDiagnosis diag) {
    if (diag.visualType == 'pizza_comparison') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              PizzaVisualWidget(totalSlices: 4, selectedSlices: 1, size: 80, label: '1/4 (Bigger Slice)'),
              SizedBox(width: 8),
              Icon(Icons.compare_arrows_rounded, color: ColorSystem.purple, size: 24),
              SizedBox(width: 8),
              PizzaVisualWidget(totalSlices: 8, selectedSlices: 1, size: 80, label: '1/8 (Smaller Slice)'),
            ],
          ),
        ),
      );
    } else if (diag.visualType == 'fraction_strip') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
        ),
        child: const FractionStripsVisualWidget(
          denominators: [2, 4, 8],
          activeDenominator: 4,
          activeNumerator: 2,
        ),
      );
    } else if (diag.visualType == 'ratio_beaker') {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            FruitRatioVisualWidget(countA: 3, countB: 5, labelA: 'Apples', labelB: 'Bananas'),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}

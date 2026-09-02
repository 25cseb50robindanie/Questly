import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/sound_service.dart';

class FlashcardData {
  final String id;
  final String category;
  final String question;
  final String answer;
  final String rule;
  final Widget? frontWidget;
  final Widget? backWidget;

  const FlashcardData({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.rule,
    this.frontWidget,
    this.backWidget,
  });
}

class FlashcardWidget extends StatefulWidget {
  final FlashcardData card;
  final VoidCallback onMastered;
  final VoidCallback onReviewAgain;

  const FlashcardWidget({
    Key? key,
    required this.card,
    required this.onMastered,
    required this.onReviewAgain,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.id != widget.card.id) {
      _controller.reset();
      _isFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    SoundService.playClick();
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value * math.pi;
              final isUnder = angle > math.pi / 2;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // perspective
                  ..rotateY(angle),
                alignment: Alignment.center,
                child: isUnder
                    ? Transform(
                        transform: Matrix4.identity()..rotateY(math.pi),
                        alignment: Alignment.center,
                        child: _buildBack(),
                      )
                    : _buildFront(),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Action Rating Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSystem.cream,
                foregroundColor: ColorSystem.plum,
                elevation: 0,
                side: const BorderSide(color: ColorSystem.plum, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('STILL LEARNING', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () {
                SoundService.playClick();
                widget.onReviewAgain();
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorSystem.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: const Text('GOT IT! (+10 XP)', style: TextStyle(fontFamily: 'Fredoka', fontSize: 11, fontWeight: FontWeight.w900)),
              onPressed: () {
                SoundService.playSuccess();
                widget.onMastered();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFront() {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorSystem.plum, width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.12),
            offset: const Offset(0, 6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorSystem.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.card.category.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                  ),
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.touch_app_rounded, color: ColorSystem.purple, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'TAP TO FLIP',
                    style: TextStyle(fontFamily: 'Fredoka', fontSize: 8.5, fontWeight: FontWeight.bold, color: ColorSystem.purple),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: widget.card.frontWidget ??
                  Text(
                    widget.card.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                      height: 1.35,
                    ),
                  ),
            ),
          ),
          const Text(
            'Think of your answer, then tap to check!',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: 320,
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorSystem.purple, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.purple.withOpacity(0.18),
            offset: const Offset(0, 6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorSystem.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'EXPLANATION & RULE',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.green,
                  ),
                ),
              ),
              const Icon(Icons.flip_to_front_rounded, color: ColorSystem.purple, size: 16),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.card.answer,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.card.rule,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum.withOpacity(0.85),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'How did you do?',
            style: TextStyle(fontFamily: 'Fredoka', fontSize: 9.5, color: ColorSystem.plum.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

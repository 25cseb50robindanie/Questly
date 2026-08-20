import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../services/sound_service.dart';

class DendySpeakButton extends StatefulWidget {
  final String textToSpeak;
  final double size;
  final Color? color;
  final Color? activeColor;
  final Color? backgroundColor;

  const DendySpeakButton({
    Key? key,
    required this.textToSpeak,
    this.size = 28,
    this.color,
    this.activeColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _DendySpeakButtonState createState() => _DendySpeakButtonState();
}

class _DendySpeakButtonState extends State<DendySpeakButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.readAloudService,
      builder: (context, _) {
        final isPlaying = Locator.readAloudService.isSpeakingThis(widget.textToSpeak);
        final defaultColor = widget.color ?? ColorSystem.purple;
        final playingColor = widget.activeColor ?? ColorSystem.gold;
        final bgColor = widget.backgroundColor ?? (isPlaying ? ColorSystem.purple : ColorSystem.lavender.withOpacity(0.4));

        return Tooltip(
          message: isPlaying ? 'Stop Reading' : 'Read Aloud with Dendy',
          child: GestureDetector(
            onTap: () {
              SoundService.playClick();
              if (isPlaying) {
                Locator.readAloudService.stop();
              } else {
                final student = Locator.studentRepository.getCurrentStudent();
                final lang = student?.language ?? 'en';
                Locator.readAloudService.speak(
                  widget.textToSpeak,
                  languageCode: lang,
                );
              }
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isPlaying ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPlaying ? ColorSystem.gold : ColorSystem.plum.withOpacity(0.2),
                        width: isPlaying ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        if (isPlaying)
                          BoxShadow(
                            color: ColorSystem.gold.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        isPlaying ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                        color: isPlaying ? playingColor : defaultColor,
                        size: widget.size * 0.58,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

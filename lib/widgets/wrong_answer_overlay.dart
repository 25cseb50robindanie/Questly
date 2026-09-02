import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/sound_service.dart';
import 'dendy_mascot.dart';

void showIncorrectFeedback({
  required BuildContext context,
  required String explanation,
  required VoidCallback onTryAgain,
}) {
  SoundService.playDrop();
  
  final size = MediaQuery.of(context).size;
  final isShort = size.height < 450;

  showModalBottomSheet(
    context: context,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF2F2), // Light red/pink alert background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.redAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.plum.withOpacity(0.12),
                offset: const Offset(0, 4),
                blurRadius: 10,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mascot
              const DendyMascot(
                size: 52,
                state: DendyState.confused,
              ),
              const SizedBox(width: 14),
              // Explanation Text & Button
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LET'S THINK ABOUT THIS... 🌟",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 10 : 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent.shade700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      explanation,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 11 : 12.5,
                        fontWeight: FontWeight.w600,
                        color: ColorSystem.plum,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onTryAgain();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 2,
                ),
                child: const Text(
                  'TRY AGAIN',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

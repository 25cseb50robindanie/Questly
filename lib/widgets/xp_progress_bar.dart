import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/localization_service.dart';

class XpProgressBar extends StatelessWidget {
  final int currentXp;
  final int level;
  final double width;
  final double height;

  const XpProgressBar({
    Key? key,
    required this.currentXp,
    required this.level,
    this.width = 150.0,
    this.height = 11.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nextLevelXp = level * 200;
    final progressFraction = (currentXp / nextLevelXp).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: width,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l('xp_progress_title'),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum.withOpacity(0.65),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$currentXp / $nextLevelXp XP',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: ColorSystem.plum, width: 1.5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressFraction,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorSystem.gold,
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

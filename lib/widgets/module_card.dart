import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';

class ModuleCard extends StatelessWidget {
  final String subject;
  final String title;
  final double progressFraction; // 0.0 to 1.0
  final VoidCallback onTap;

  const ModuleCard({
    Key? key,
    required this.subject,
    required this.title,
    required this.progressFraction,
    required this.onTap,
  }) : super(key: key);

  Color _getSubjectColor() {
    switch (subject.toUpperCase()) {
      case 'SCIENCE':
        return const Color(0xFFE2D8F3); // Soft Questly Lavender
      case 'MATHEMATICS':
        return const Color(0xFFD6E4FF); // Soft Questly Blue
      case 'PHYSICS':
        return const Color(0xFFFFF0D6); // Soft Questly Gold
      case 'CHEMISTRY':
      case 'VIRTUAL LAB':
        return const Color(0xFFD1F2E6); // Soft Mint Green
      default:
        return const Color(0xFFE8E0F2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int percent = (progressFraction * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorSystem.plum, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: ColorSystem.plum.withOpacity(0.04),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Subject pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getSubjectColor(),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
              ),
              child: Text(
                subject.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: ColorSystem.plum,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorSystem.plum,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: ColorSystem.cream,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progressFraction,
                        child: Container(
                          decoration: BoxDecoration(
                            color: progressFraction >= 1.0
                                ? ColorSystem.green
                                : ColorSystem.purple,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

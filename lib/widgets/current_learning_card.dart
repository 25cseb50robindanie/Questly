import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../models/module.dart';
import '../models/lesson.dart';
import '../services/localization_service.dart';
import 'dendy_mascot.dart';
import 'custom_button.dart';

class CurrentLearningCard extends StatelessWidget {
  final Module? module;
  final Lesson? lesson;
  final int completedCount;
  final int totalCount;
  final VoidCallback onContinuePressed;
  final VoidCallback onExplorePressed;

  const CurrentLearningCard({
    Key? key,
    this.module,
    this.lesson,
    required this.completedCount,
    required this.totalCount,
    required this.onContinuePressed,
    required this.onExplorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no module is currently active
    if (module == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorSystem.plum, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l('start_first_quest').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s find something new to explore!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorSystem.plum.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: l('explore_modules').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    onPressed: onExplorePressed,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const DendyMascot(
              state: DendyState.idle,
              size: 76,
            ),
          ],
        ),
      );
    }

    final double progress = totalCount > 0 ? (completedCount / totalCount).clamp(0.0, 1.0) : 0.0;
    final int progressPercent = (progress * 100).toInt();

    // Dendy speech text
    String mascotMessage = "Ready for your next quest?";
    if (progressPercent >= 100) {
      mascotMessage = "Excellent! You completed all the physical science lab quests!";
    } else if (progressPercent >= 50) {
      mascotMessage = "You are almost done with this lesson!";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          // Left side: Quest status & information
          Expanded(
            flex: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l('your_quest'),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  module!.title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson != null
                      ? 'Level ${lesson!.order} • ${l('lesson_progress', args: {
                          'current': '${completedCount + 1}',
                          'total': '$totalCount'
                        })}'
                      : l('quest_complete'),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 10),
                // Custom Progress Bar & Percent Indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: ColorSystem.cream,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: ColorSystem.plum, width: 1.2),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorSystem.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 200,
                  child: CustomButton(
                    text: l('continue_quest').toUpperCase(),
                    backgroundColor: ColorSystem.purple,
                    textColor: Colors.white,
                    onPressed: onContinuePressed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Right side: floating Dendy fox
          Expanded(
            flex: 8,
            child: Center(
              child: DendyMascot(
                state: progressPercent >= 100 ? DendyState.success : DendyState.idle,
                size: 78,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

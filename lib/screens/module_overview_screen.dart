import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../models/module.dart';
import '../models/student.dart';
import '../core/locator.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../services/localization_service.dart';

class ModuleOverviewScreen extends StatelessWidget {
  const ModuleOverviewScreen({Key? key}) : super(key: key);

  Color _getSubjectColor(String subject) {
    switch (subject.toUpperCase()) {
      case 'SCIENCE':
        return const Color(0xFFE2D8F3); // Soft Questly Lavender
      case 'MATHEMATICS':
        return const Color(0xFFD6E4FF); // Soft Questly Blue
      case 'PHYSICS':
        return const Color(0xFFFFF0D6); // Soft Questly Gold
      default:
        return const Color(0xFFE8E0F2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Module module = ModalRoute.of(context)!.settings.arguments as Module;
    final Student? student = Locator.studentRepository.getCurrentStudent();

    if (student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Evaluate lessons count
    int lessonsCount = 0;
    for (var lvl in module.levels) {
      lessonsCount += lvl.lessons.length;
    }

    final progressList = Locator.progressRepository.getProgressList(student.questlyId);
    int completedCount = 0;
    for (var lvl in module.levels) {
      for (var les in lvl.lessons) {
        if (progressList.any((p) => p.lessonId == les.id && p.status == 'completed')) {
          completedCount++;
        }
      }
    }

    final double progress = lessonsCount > 0 ? completedCount / lessonsCount : 0.0;
    final isStarted = completedCount > 0;
    final isCompleted = completedCount == lessonsCount;

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row (Back navigation + title)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getSubjectColor(module.subject),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
                      ),
                      child: Text(
                        module.subject.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Main Details Card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Column: Details
                        Expanded(
                          flex: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    module.title,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: ColorSystem.plum,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    module.description,
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      color: ColorSystem.plum.withOpacity(0.85),
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                              // Specs row
                              Row(
                                children: [
                                  _buildSpecItem(Icons.playlist_add_check_rounded, '$completedCount / $lessonsCount Lessons'),
                                  const SizedBox(width: 24),
                                  _buildSpecItem(Icons.schedule_rounded, '${module.levels.length * 15} Mins Est.'),
                                  const SizedBox(width: 24),
                                  _buildSpecItem(Icons.layers_outlined, '${module.levels.length} Levels'),
                                ],
                              ),
                              // Learning objectives outline
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OBJECTIVES:',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSystem.plum.withOpacity(0.6),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '• Gain experimental understanding of physics basics.\n• Complete simulation problems in physical science laboratory setups.\n• Collect academic badges and rewards upon milestone achievements.',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 11,
                                      color: ColorSystem.plum.withOpacity(0.7),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: Progress radial & action button
                        Expanded(
                          flex: 8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Progress percent circle
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ColorSystem.plum, width: 3),
                                  color: ColorSystem.cream,
                                ),
                                child: Center(
                                  child: Text(
                                    '${(progress * 100).toInt()}%',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: ColorSystem.plum,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Main CTA
                              CustomButton(
                                text: isCompleted
                                    ? 'COMPLETED'
                                    : (isStarted ? l('continue_module') : l('start_module')),
                                backgroundColor: isCompleted ? ColorSystem.green : ColorSystem.purple,
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/roadmap',
                                    arguments: module,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildSpecItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ColorSystem.purple, size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
      ],
    );
  }
}

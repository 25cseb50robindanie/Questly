import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/module.dart';
import '../models/student.dart';
import '../widgets/module_card.dart';
import '../services/localization_service.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({Key? key}) : super(key: key);

  // Group modules by subject
  Map<String, List<Module>> _getGroupedModules() {
    final modules = Locator.moduleRepository.getModules();
    final grouped = <String, List<Module>>{};
    for (var m in modules) {
      final category = m.subject.toUpperCase();
      grouped.putIfAbsent(category, () => []).add(m);
    }
    return grouped;
  }

  double _getModuleProgress(String studentId, Module module) {
    final progressList = Locator.progressRepository.getProgressList(studentId);
    int total = 0;
    int completed = 0;
    for (var lvl in module.levels) {
      for (var les in lvl.lessons) {
        total++;
        if (progressList.any((p) => p.lessonId == les.id && p.status == 'completed')) {
          completed++;
        }
      }
    }
    return total > 0 ? completed / total : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.studentRepository,
      builder: (context, _) {
        final Student? student = Locator.studentRepository.getCurrentStudent();
        if (student == null) return const SizedBox();

        final grouped = _getGroupedModules();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l('my_modules').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    ...grouped.keys.map((subject) {
                      final modules = grouped[subject]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header Line
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  l(subject),
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: ColorSystem.plum,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Divider(
                                    color: ColorSystem.plum.withOpacity(0.15),
                                    thickness: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Modules list in this category
                          SizedBox(
                            height: 112,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: modules.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                final module = modules[index];
                                return ModuleCard(
                                  subject: module.subject,
                                  title: module.title,
                                  progressFraction: _getModuleProgress(student.questlyId, module),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/module_overview',
                                      arguments: module,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),

                    // Virtual Labs section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Text(
                                '🧪 VIRTUAL LABS (SIMULATIONS)',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Divider(
                                  color: ColorSystem.purple.withOpacity(0.2),
                                  thickness: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 112,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ModuleCard(
                                subject: 'Chemistry',
                                title: 'Acid–Base Titration (Virtual Lab)',
                                progressFraction: Locator.progressionService.isLessonCompleted(student.questlyId, 'lab_titration_1') ? 1.0 : 0.0,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/virtual_lab',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

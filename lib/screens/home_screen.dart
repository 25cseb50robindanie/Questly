import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../models/module.dart';
import '../models/lesson.dart';
import '../models/activity.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/questly_header.dart';
import '../widgets/questly_navigation.dart';
import '../widgets/current_learning_card.dart';
import '../widgets/revision_card.dart';
import '../widgets/module_card.dart';
import '../widgets/leaderboard_preview.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

// View Imports
import 'modules_screen.dart';
import 'leaderboard_screen.dart';
import 'collection_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Student? _student;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent();
    });
  }

  Future<void> _logout() async {
    await Locator.authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  // Active Quest Finder
  Module? _getActiveModule() {
    if (_student == null || _student!.currentModuleId == null) return null;
    return Locator.moduleRepository.getModuleById(_student!.currentModuleId!);
  }

  Lesson? _getActiveLesson() {
    if (_student == null || _student!.currentLessonId == null) return null;
    return Locator.moduleRepository.getLessonById(_student!.currentLessonId!);
  }

  int _getCompletedLessonsCount(Module? module) {
    if (_student == null || module == null) return 0;
    final progressList = Locator.progressRepository.getProgressList(_student!.questlyId);
    int completed = 0;
    for (var lvl in module.levels) {
      for (var les in lvl.lessons) {
        final isDone = progressList.any((p) => p.lessonId == les.id && p.status == 'completed');
        if (isDone) completed++;
      }
    }
    return completed;
  }

  int _getTotalLessonsCount(Module? module) {
    if (module == null) return 0;
    int total = 0;
    for (var lvl in module.levels) {
      total += lvl.lessons.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.studentRepository,
      builder: (context, _) {
        final currentStudent = Locator.studentRepository.getCurrentStudent();
        if (currentStudent == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        _student = currentStudent;

        return Scaffold(
          backgroundColor: ColorSystem.cream,
          body: QuestlyBackground(
            child: Column(
              children: [
                // 1. Persistent Top Header
                QuestlyHeader(
                  student: currentStudent,
                  onSettingsPressed: () async {
                    await Navigator.pushNamed(context, '/settings');
                    _loadState();
                  },
                  onNotificationsPressed: () async {
                    await Navigator.pushNamed(context, '/notifications');
                    _loadState();
                  },
                  onProfilePressed: () {
                    setState(() {
                      _currentTabIndex = 3; // Switch to Profile tab
                    });
                  },
                ),

                // 2. Body: Left Navigation Sidebar + Right Content Views
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      QuestlyNavigation(
                        currentIndex: _currentTabIndex,
                        onTabSelected: _onTabSelected,
                      ),
                      Expanded(
                        child: IndexedStack(
                          index: _currentTabIndex,
                          children: [
                            // Index 0: Home Dashboard View
                            _HomeDashboardView(
                              student: currentStudent,
                              activeModule: _getActiveModule(),
                              activeLesson: _getActiveLesson(),
                              completedLessons: _getCompletedLessonsCount(_getActiveModule()),
                              totalLessons: _getTotalLessonsCount(_getActiveModule()),
                              onTabSelected: _onTabSelected,
                              onStateRefresh: _loadState,
                            ),
                            // Index 1: Modules library listing
                            const ModulesScreen(),
                            // Index 2: Leaderboard rankings
                            const LeaderboardScreen(isTab: true),
                            // Index 3: Collection rewards & shop
                            const CollectionScreen(),
                            // Index 4: Profile stats
                            const ProfileScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Inner Private Dashboard content View
class _HomeDashboardView extends StatelessWidget {
  final Student student;
  final Module? activeModule;
  final Lesson? activeLesson;
  final int completedLessons;
  final int totalLessons;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onStateRefresh;

  const _HomeDashboardView({
    Key? key,
    required this.student,
    this.activeModule,
    this.activeLesson,
    required this.completedLessons,
    required this.totalLessons,
    required this.onTabSelected,
    required this.onStateRefresh,
  }) : super(key: key);

  // Leaderboard mock data
  List<LeaderboardEntry> _getLeaderboardEntries() {
    return [
      LeaderboardEntry(name: 'Ananya', xp: 1240),
      LeaderboardEntry(name: 'Rahul', xp: 1180),
      LeaderboardEntry(name: student.displayName, xp: student.xp, isMe: true),
      LeaderboardEntry(name: 'Meena', xp: 990),
      LeaderboardEntry(name: 'Arjun', xp: 920),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
  }

  // Find percentage for module card
  double _getModuleProgress(Module module) {
    final progressList = Locator.progressRepository.getProgressList(student.questlyId);
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
    final List<Module> allModules = Locator.moduleRepository.getModules();
    final leaderboardEntries = _getLeaderboardEntries();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Panel: Continue learning card & Revision card
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Left: Continue Learning
              Expanded(
                flex: 12,
                child: SizedBox(
                  height: 195,
                  child: CurrentLearningCard(
                    module: activeModule,
                    lesson: activeLesson,
                    completedCount: completedLessons,
                    totalCount: totalLessons,
                    onContinuePressed: () async {
                      if (activeLesson != null && activeLesson!.activities.isNotEmpty) {
                        // Route to Activity Renderer
                        await Navigator.pushNamed(
                          context,
                          '/activity_renderer',
                          arguments: activeLesson!.activities.first,
                        );
                        onStateRefresh(); // Reload student progress
                      }
                    },
                    onExplorePressed: () {
                      onTabSelected(1); // explore modules tab
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Main Right: Revision Card
              Expanded(
                flex: 8,
                child: SizedBox(
                  height: 195,
                  child: RevisionCard(
                    topicName: 'Density Basics',
                    conceptsCount: 3,
                    onStartRevision: () {
                      Navigator.pushNamed(
                        context,
                        '/activity_renderer',
                        arguments: Activity(
                          id: 'act_density_revision',
                          title: 'Revision: Density Basics',
                          instruction: 'Revision challenge: Solve matching formulas and displacement scenarios to reinforce buoyancy. Density = Mass / Volume.',
                          type: 'flashcard',
                          targetDensity: 0.0,
                          targetCondition: '',
                          xpReward: 15,
                          goldReward: 2,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Bottom Section: My Modules (Full Width)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l('my_modules').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onTabSelected(1), // Switch to Modules View
                    child: Text(
                      l('view_all_modules').toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: allModules.length + 2,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    if (index < allModules.length) {
                      final module = allModules[index];
                      return ModuleCard(
                        subject: module.subject,
                        title: module.title,
                        progressFraction: _getModuleProgress(module),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/module_overview',
                            arguments: module,
                          );
                        },
                      );
                    }
                    if (index == allModules.length) {
                      // Virtual Lab Card
                      final isDone = Locator.progressionService.isLessonCompleted(student.questlyId, 'lab_titration_1');
                      return ModuleCard(
                        subject: 'Chemistry',
                        title: 'Acid–Base Titration (Virtual Lab)',
                        progressFraction: isDone ? 1.0 : 0.0,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/virtual_lab',
                          );
                        },
                      );
                    }
                    // Fractions Module Card
                    final isDone = Locator.progressionService.isLessonCompleted(student.questlyId, 'math_fractions_1');
                    return ModuleCard(
                      subject: 'Mathematics',
                      title: 'Fractions & Ratios (Canyon Crossings)',
                      progressFraction: isDone ? 1.0 : 0.0,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/fraction_module',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

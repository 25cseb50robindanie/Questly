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

import '../widgets/vector_asset_helper.dart';
import '../widgets/daily_reward_overlay.dart';
import '../widgets/mission_panel.dart';
import '../widgets/dendy_chat_panel.dart';
import '../widgets/dendy_mascot.dart';

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
  bool _isAskDendyOpen = false;

  @override
  void initState() {
    super.initState();
    _loadState();

    // Check & trigger Daily Login Reward overlay if available today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = Locator.studentRepository.getCurrentStudent();
      if (s != null && mounted) {
        DailyRewardOverlay.showIfNeeded(context, s);
      }
    });
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
    if (_student == null) return null;
    if (_student!.currentModuleId != null) {
      final mod = Locator.moduleRepository.getModuleById(_student!.currentModuleId!);
      if (mod != null) return mod;
    }
    final modules = Locator.moduleRepository.getModules();
    return modules.isNotEmpty ? modules.first : null;
  }

  Lesson? _getActiveLesson() {
    if (_student == null) return null;
    if (_student!.currentLessonId != null) {
      final les = Locator.moduleRepository.getLessonById(_student!.currentLessonId!);
      if (les != null) return les;
    }
    final mod = _getActiveModule();
    if (mod != null) {
      final progressList = Locator.progressRepository.getProgressList(_student!.questlyId);
      for (var lvl in mod.levels) {
        for (var les in lvl.lessons) {
          final isDone = progressList.any((p) => p.lessonId == les.id && p.status == 'completed');
          if (!isDone) return les;
        }
      }
      if (mod.levels.isNotEmpty && mod.levels.first.lessons.isNotEmpty) {
        return mod.levels.first.lessons.first;
      }
    }
    return null;
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
          floatingActionButton: _isAskDendyOpen
              ? null
              : FloatingActionButton.extended(
                  backgroundColor: ColorSystem.purple,
                  elevation: 6,
                  icon: const DendyMascot(size: 26, mood: DendyMood.happy, enableChatShortcut: false),
                  label: const Text(
                    'ASK DENDY',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    SoundService.playClick();
                    setState(() {
                      _isAskDendyOpen = true;
                    });
                  },
                ),
          body: QuestlyBackground(
            child: Stack(
              children: [
                Column(
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
                          _currentTabIndex = 4; // Switch to Profile tab
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

                // 3. Ask Dendy Sliding Right Side Panel
                if (_isAskDendyOpen) ...[
                  // Dimmed backdrop detector
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isAskDendyOpen = false;
                        });
                      },
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                      ),
                    ),
                  ),
                  // Sliding Drawer
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: DendyChatPanel(
                      onClose: () {
                        setState(() {
                          _isAskDendyOpen = false;
                        });
                      },
                    ),
                  ),
                ],
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
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main Left: Continue Learning
                Expanded(
                  flex: 12,
                  child: CurrentLearningCard(
                    module: activeModule,
                    lesson: activeLesson,
                    completedCount: completedLessons,
                    totalCount: totalLessons,
                    onContinuePressed: () async {
                      try {
                        Lesson? targetLesson = activeLesson;
                        Module? targetModule = activeModule;

                        if (targetLesson == null && targetModule != null) {
                          for (var lvl in targetModule.levels) {
                            for (var les in lvl.lessons) {
                              targetLesson = les;
                              break;
                            }
                            if (targetLesson != null) break;
                          }
                        }

                        if (targetLesson == null) {
                          final mod = Locator.moduleRepository.getModuleById('mod_density');
                          if (mod != null && mod.levels.isNotEmpty && mod.levels.first.lessons.isNotEmpty) {
                            targetModule = mod;
                            targetLesson = mod.levels.first.lessons.first;
                          }
                        }

                        if (targetLesson != null) {
                          final currentStudent = Locator.studentRepository.getCurrentStudent();
                          if (currentStudent != null) {
                            final updated = currentStudent.copyWith(
                              currentModuleId: targetModule?.id ?? 'mod_density',
                              currentLessonId: targetLesson.id,
                            );
                            await Locator.studentRepository.updateStudentProfile(updated);
                          }

                          if (!context.mounted) return;

                          if (targetLesson.id == 'density_les1' || targetLesson.activityType == 'discovery_curiosity') {
                            await Navigator.pushNamed(context, '/curiosity_discovery');
                          } else if (targetLesson.id == 'density_les2' || targetLesson.activityType == 'experiment') {
                            await Navigator.pushNamed(context, '/density_experiment');
                          } else if (targetLesson.id == 'density_les3' || targetLesson.activityType == 'apply') {
                            await Navigator.pushNamed(context, '/density_apply');
                          } else if (targetLesson.id == 'density_les4' || targetLesson.activityType == 'challenge') {
                            await Navigator.pushNamed(context, '/density_detective');
                          } else if (targetLesson.id == 'density_les5' || targetLesson.activityType == 'teach_dendy') {
                            await Navigator.pushNamed(context, '/density_teach_back');
                          } else if (targetModule?.id == 'mod_chemistry' || targetLesson.id.contains('titration')) {
                            await Navigator.pushNamed(context, '/virtual_lab');
                          } else if (targetModule?.id == 'mod_fractions' || targetLesson.id.contains('fraction')) {
                            await Navigator.pushNamed(context, '/fraction_module');
                          } else if (targetLesson.activities.isNotEmpty) {
                            await Navigator.pushNamed(
                              context,
                              '/activity_renderer',
                              arguments: targetLesson.activities.first,
                            );
                          } else {
                            await Navigator.pushNamed(context, '/roadmap');
                          }
                          onStateRefresh();
                        } else {
                          await Navigator.pushNamed(context, '/roadmap');
                          onStateRefresh();
                        }
                      } catch (e) {
                        if (context.mounted) {
                          await Navigator.pushNamed(context, '/curiosity_discovery');
                          onStateRefresh();
                        }
                      }
                    },
                    onExplorePressed: () {
                      onTabSelected(1); // explore modules tab
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Main Right: Revision Card
                Expanded(
                  flex: 8,
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
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Daily & Weekly Missions System Panel
          MissionPanel(student: student),

          const SizedBox(height: 16),

          // 3. Badges & Achievements Section (Live reflection of Level Ups & Badges)
          ListenableBuilder(
            listenable: Locator.collectionRepository,
            builder: (context, _) {
              final studentId = student.questlyId.toLowerCase();
              final unlockedBadges = Locator.collectionRepository.getUnlockedBadges(studentId);
              final allBadges = Locator.collectionRepository.getAvailableBadges();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          VectorAssetHelper.badgeIcon('Explorer', size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'EARNED BADGES (${unlockedBadges.length}/${allBadges.length})',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => onTabSelected(3), // Switch to Collection & Badges tab
                        child: Row(
                          children: [
                            Text(
                              l('collection').toUpperCase(),
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.purple,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 14, color: ColorSystem.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 72,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: allBadges.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final badge = allBadges[index];
                        final isUnlocked = unlockedBadges.contains(badge);

                        return GestureDetector(
                          onTap: () => onTabSelected(3),
                          child: Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isUnlocked ? ColorSystem.gold : ColorSystem.plum.withOpacity(0.15),
                                width: isUnlocked ? 1.5 : 1.0,
                              ),
                              boxShadow: [
                                if (isUnlocked)
                                  BoxShadow(
                                    color: ColorSystem.gold.withOpacity(0.15),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                              ],
                            ),
                            child: Row(
                              children: [
                                VectorAssetHelper.badgeIcon(badge, size: 28, isUnlocked: isUnlocked),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        badge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.4),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isUnlocked ? 'UNLOCKED' : 'LOCKED',
                                        style: TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w900,
                                          color: isUnlocked ? ColorSystem.green : Colors.grey.shade500,
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
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // 3. Bottom Section: My Modules (Full Width)
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
                  itemCount: allModules.length + 1,
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
                    // Virtual Lab Card (Acid–Base Titration)
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

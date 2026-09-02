import '../models/roadmap_node.dart';
import '../models/roadmap_enums.dart';
import '../models/progress.dart';
import '../core/locator.dart';
import 'adaptive_learning_engine.dart';

class ProgressionService {
  final AdaptiveLearningEngine _adaptiveEngine = AdaptiveLearningEngine();

  // Checks if a specific lesson is completed by the student
  bool isLessonCompleted(String studentId, String lessonId) {
    final progressList = Locator.progressRepository.getProgressList(studentId);
    final isDone = progressList.any((p) => p.lessonId == lessonId && p.status == 'completed');
    if (isDone) return true;

    // Check fallback direct storage key
    final key = 'lesson_comp_${studentId}_$lessonId';
    return Locator.storageService.getBool(key) ?? false;
  }

  String _topicFromLessonId(String lessonId) {
    if (lessonId.startsWith('fractions_')) return 'fractions';
    if (lessonId.startsWith('ratios_')) return 'ratios';
    if (lessonId.startsWith('proportions_')) return 'proportions';
    if (lessonId.startsWith('percentages_')) return 'percentages';
    if (lessonId.startsWith('applications_')) return 'applications';
    return 'fractions';
  }

  // Checks if a specific lesson is unlocked for the student
  bool isLessonUnlocked(String studentId, String lessonId) {
    // Lesson 1 of Quest 1 or Density is always unlocked
    if (lessonId == 'density_les1' || lessonId == 'fractions_les1') return true;

    // Quest 2: Ratios Lesson 1 requires Quest 1 completion AND Claim Reward milestone (fractions_node2)
    if (lessonId == 'ratios_les1') {
      final isFractionsDone = isLessonCompleted(studentId, 'fractions_les5') ||
          (Locator.storageService.getBool('node_comp_${studentId}_fractions_node1') ?? false);
      final isRewardClaimed = (Locator.storageService.getBool('node_comp_${studentId}_fractions_node2') ?? false) ||
          (Locator.storageService.getBool('reward_claimed_${studentId}_rew_fractions_q1_xp') ?? false);
      return isFractionsDone && isRewardClaimed;
    }

    // Quest 3: Proportions Lesson 1 requires Quest 2 completion
    if (lessonId == 'proportions_les1') {
      return isLessonCompleted(studentId, 'ratios_les5') ||
          (Locator.storageService.getBool('node_comp_${studentId}_fractions_node3') ?? false);
    }

    // Quest 4: Percentages Lesson 1 requires Quest 3 completion AND Second Claim Reward milestone (fractions_node5)
    if (lessonId == 'percentages_les1') {
      final isProportionsDone = isLessonCompleted(studentId, 'proportions_les5') ||
          (Locator.storageService.getBool('node_comp_${studentId}_fractions_node4') ?? false);
      final isReward2Claimed = (Locator.storageService.getBool('node_comp_${studentId}_fractions_node5') ?? false) ||
          (Locator.storageService.getBool('reward_claimed_${studentId}_rew_fractions_q2_xp') ?? false);
      return isProportionsDone && isReward2Claimed;
    }

    // Quest 5: Applications Lesson 1 requires Quest 4 completion
    if (lessonId == 'applications_les1') {
      return isLessonCompleted(studentId, 'percentages_les5') ||
          (Locator.storageService.getBool('node_comp_${studentId}_fractions_node6') ?? false);
    }

    // Density Module Lessons
    if (lessonId == 'density_les2') return isLessonCompleted(studentId, 'density_les1');
    if (lessonId == 'density_les3') return isLessonCompleted(studentId, 'density_les2');
    if (lessonId == 'density_les4') return isLessonCompleted(studentId, 'density_les3');
    if (lessonId == 'density_les5') return isLessonCompleted(studentId, 'density_les4');

    // Generic 5-Lesson Quest Unlocking Rules
    if (lessonId.endsWith('_les2')) {
      // Lesson 2 requires Lesson 1 of same quest
      final prefix = lessonId.replaceAll('_les2', '');
      return isLessonCompleted(studentId, '${prefix}_les1');
    }

    if (lessonId.endsWith('_les3')) {
      // Lesson 3 (Guided Practice) requires Lesson 2 of same quest
      final prefix = lessonId.replaceAll('_les3', '');
      return isLessonCompleted(studentId, '${prefix}_les2');
    }

    if (lessonId.endsWith('_les4')) {
      // Lesson 4 (Challenge) requires Lesson 3 completion AND Adaptive Mastery
      final prefix = lessonId.replaceAll('_les4', '');
      final isLes3Done = isLessonCompleted(studentId, '${prefix}_les3');
      if (!isLes3Done) return false;

      final topic = _topicFromLessonId(lessonId);
      // Challenge should NEVER unlock until mastery is achieved!
      return _adaptiveEngine.isMasteryAchieved(studentId, topic);
    }

    if (lessonId.endsWith('_les5')) {
      // Lesson 5 (Teach Dendy) requires Lesson 4 Challenge completion
      final prefix = lessonId.replaceAll('_les5', '');
      return isLessonCompleted(studentId, '${prefix}_les4');
    }

    return false;
  }

  // Checks if a specific RoadmapNode is completed by the student
  bool isNodeCompleted(String studentId, RoadmapNode node) {
    if (node.levelId != null) {
      final List<String> lessons;
      if (node.levelId == 'density_lvl1') {
        lessons = ['density_les1', 'density_les2', 'density_les3', 'density_les4', 'density_les5'];
      } else if (node.levelId == 'fractions_lvl1') {
        lessons = ['fractions_les1', 'fractions_les2', 'fractions_les3', 'fractions_les4', 'fractions_les5'];
      } else if (node.levelId == 'ratios_lvl1' || node.levelId == 'fractions_lvl2') {
        lessons = ['ratios_les1', 'ratios_les2', 'ratios_les3', 'ratios_les4', 'ratios_les5'];
      } else if (node.levelId == 'proportions_lvl1') {
        lessons = ['proportions_les1', 'proportions_les2', 'proportions_les3', 'proportions_les4', 'proportions_les5'];
      } else if (node.levelId == 'percentages_lvl1') {
        lessons = ['percentages_les1', 'percentages_les2', 'percentages_les3', 'percentages_les4', 'percentages_les5'];
      } else if (node.levelId == 'applications_lvl1') {
        lessons = ['applications_les1', 'applications_les2', 'applications_les3', 'applications_les4', 'applications_les5'];
      } else {
        lessons = [];
      }

      if (lessons.isNotEmpty) {
        return lessons.every((lid) => isLessonCompleted(studentId, lid));
      }
    }

    final progressList = Locator.progressRepository.getProgressList(studentId);

    // If node is level/lesson type, check lesson progress
    if (node.levelId != null || node.lessonId != null) {
      final targetId = node.lessonId ?? node.levelId!;
      final isDone = progressList.any((p) => p.lessonId == targetId && p.status == 'completed');
      if (isDone) return true;
    }

    // Local storage completion flag
    final key = 'node_comp_${studentId}_${node.id}';
    final explicitlyDone = Locator.storageService.getBool(key) ?? false;
    if (explicitlyDone) return true;

    // For dedicated reward / mystery / mastery nodes, check if all associated rewards have been claimed
    if (node.type == RoadmapNodeType.reward ||
        node.type == RoadmapNodeType.mystery ||
        node.type == RoadmapNodeType.milestone ||
        node.type == RoadmapNodeType.mastery) {
      if (node.rewardIds.isEmpty) return true;
      return node.rewardIds.every((rid) {
        final claimKey = 'reward_claimed_${studentId}_$rid';
        return Locator.storageService.getBool(claimKey) ?? false;
      });
    }

    return false;
  }

  // Checks if a specific RoadmapNode is unlocked for the student
  bool isNodeUnlocked(String studentId, RoadmapNode node, List<RoadmapNode> allNodes) {
    // If no prerequisites, it's unlocked by default (e.g. Node 1)
    if (node.prerequisiteNodeIds.isEmpty) return true;

    // Must have all prerequisite nodes completed
    return node.prerequisiteNodeIds.every((prereqId) {
      final prereqNode = allNodes.firstWhere(
        (n) => n.id == prereqId,
        orElse: () => node,
      );
      return isNodeCompleted(studentId, prereqNode);
    });
  }

  // Helper to mark a node completed in storage
  Future<void> markNodeCompleted(String studentId, String nodeId, {int stars = 3}) async {
    final key = 'node_comp_${studentId}_$nodeId';
    await Locator.storageService.setBool(key, true);

    final starsKey = 'node_stars_${studentId}_$nodeId';
    await Locator.storageService.setInt(starsKey, stars);
  }

  // Gets the number of stars earned for a specific node (0-3)
  int getNodeStars(String studentId, RoadmapNode node) {
    if (node.levelId != null &&
        (node.levelId == 'density_lvl1' ||
            node.levelId == 'fractions_lvl1' ||
            node.levelId == 'ratios_lvl1' ||
            node.levelId == 'proportions_lvl1' ||
            node.levelId == 'percentages_lvl1' ||
            node.levelId == 'applications_lvl1')) {
      final List<String> lessons;
      if (node.levelId == 'density_lvl1') {
        lessons = ['density_les1', 'density_les2', 'density_les3', 'density_les4', 'density_les5'];
      } else if (node.levelId == 'fractions_lvl1') {
        lessons = ['fractions_les1', 'fractions_les2', 'fractions_les3', 'fractions_les4', 'fractions_les5'];
      } else if (node.levelId == 'ratios_lvl1' || node.levelId == 'fractions_lvl2') {
        lessons = ['ratios_les1', 'ratios_les2', 'ratios_les3', 'ratios_les4', 'ratios_les5'];
      } else if (node.levelId == 'proportions_lvl1') {
        lessons = ['proportions_les1', 'proportions_les2', 'proportions_les3', 'proportions_les4', 'proportions_les5'];
      } else if (node.levelId == 'percentages_lvl1') {
        lessons = ['percentages_les1', 'percentages_les2', 'percentages_les3', 'percentages_les4', 'percentages_les5'];
      } else {
        lessons = ['applications_les1', 'applications_les2', 'applications_les3', 'applications_les4', 'applications_les5'];
      }

      int totalEarnedStars = 0;
      int completedLessonsCount = 0;

      for (var lid in lessons) {
        final key = 'lesson_stars_${studentId}_$lid';
        final savedStars = Locator.storageService.getInt(key);
        if (savedStars != null && savedStars > 0) {
          totalEarnedStars += savedStars;
          completedLessonsCount++;
        } else if (isLessonCompleted(studentId, lid)) {
          totalEarnedStars += 3;
          completedLessonsCount++;
        }
      }

      if (completedLessonsCount == 0) return 0;
      return (totalEarnedStars / lessons.length).round().clamp(1, 3);
    }

    final key = 'node_stars_${studentId}_${node.id}';
    final saved = Locator.storageService.getInt(key);
    if (saved != null) return saved;

    if (isNodeCompleted(studentId, node)) return 3;
    return 0;
  }

  // Returns the status (locked, available, current, completed, claimable) for a given node
  RoadmapNodeStatus getNodeStatus(String studentId, RoadmapNode node, List<RoadmapNode> allNodes) {
    final isDone = isNodeCompleted(studentId, node);
    if (isDone) {
      return RoadmapNodeStatus.completed;
    }

    final isUnlocked = isNodeUnlocked(studentId, node, allNodes);
    if (!isUnlocked) {
      return RoadmapNodeStatus.locked;
    }

    // If unlocked and it is a reward, milestone, mystery, or mastery node
    if (node.type == RoadmapNodeType.reward ||
        node.type == RoadmapNodeType.mystery ||
        node.type == RoadmapNodeType.milestone ||
        node.type == RoadmapNodeType.mastery) {
      return RoadmapNodeStatus.claimable;
    }

    final currentId = getCurrentNodeId(studentId, allNodes);
    if (currentId == node.id) {
      return RoadmapNodeStatus.current;
    }

    return RoadmapNodeStatus.available;
  }

  // Returns the ID of the current active/uncompleted node on the roadmap
  String? getCurrentNodeId(String studentId, List<RoadmapNode> allNodes) {
    for (var node in allNodes) {
      final isDone = isNodeCompleted(studentId, node);
      if (!isDone) {
        final isUnlocked = isNodeUnlocked(studentId, node, allNodes);
        if (isUnlocked) {
          return node.id;
        }
      }
    }
    return allNodes.isNotEmpty ? allNodes.first.id : null;
  }
}

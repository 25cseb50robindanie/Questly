import '../models/roadmap_node.dart';
import '../models/roadmap_enums.dart';
import '../models/progress.dart';
import '../core/locator.dart';


class ProgressionService {
  // Checks if a specific lesson is completed by the student
  bool isLessonCompleted(String studentId, String lessonId) {
    final progressList = Locator.progressRepository.getProgressList(studentId);
    final isDone = progressList.any((p) => p.lessonId == lessonId && p.status == 'completed');
    if (isDone) return true;

    // Check fallback direct storage key
    final key = 'lesson_comp_${studentId}_$lessonId';
    return Locator.storageService.getBool(key) ?? false;
  }

  // Checks if a specific lesson is unlocked for the student
  bool isLessonUnlocked(String studentId, String lessonId) {
    // Lesson 1 is always unlocked
    if (lessonId == 'density_les1') return true;

    // Lesson 2 requires Lesson 1 to be completed
    if (lessonId == 'density_les2') {
      return isLessonCompleted(studentId, 'density_les1');
    }
    // Lesson 3 requires Lesson 2
    if (lessonId == 'density_les3') {
      return isLessonCompleted(studentId, 'density_les2');
    }
    // Lesson 4 requires Lesson 3
    if (lessonId == 'density_les4') {
      return isLessonCompleted(studentId, 'density_les3');
    }
    // Lesson 5 requires Lesson 4
    if (lessonId == 'density_les5') {
      return isLessonCompleted(studentId, 'density_les4');
    }

    return false;
  }

  // Checks if a specific RoadmapNode is completed by the student
  bool isNodeCompleted(String studentId, RoadmapNode node) {
    // If node is level type with multiple lessons (e.g. Level 1 Discover Density)
    if (node.levelId != null && node.levelId == 'density_lvl1') {
      // Level 1 requires all 5 lessons to be completed before the whole level node is marked completed!
      final lessons = ['density_les1', 'density_les2', 'density_les3', 'density_les4', 'density_les5'];
      return lessons.every((lid) => isLessonCompleted(studentId, lid));
    }

    final progressList = Locator.progressRepository.getProgressList(studentId);

    // If node is level/lesson type, check lesson progress
    if (node.levelId != null || node.lessonId != null) {
      final targetId = node.lessonId ?? node.levelId!;
      final isDone = progressList.any((p) => p.lessonId == targetId && p.status == 'completed');
      if (isDone) return true;
    }

    // For side quests / bonus challenges, check completion flags saved in local storage
    if (node.type == RoadmapNodeType.sideQuest || node.type == RoadmapNodeType.bonus) {
      final key = 'node_comp_${studentId}_${node.id}';
      return Locator.storageService.getBool(key) ?? false;
    }

    // For dedicated reward / mystery / mastery nodes, check if all associated rewards have been claimed
    if (node.type == RoadmapNodeType.reward ||
        node.type == RoadmapNodeType.mystery ||
        node.type == RoadmapNodeType.milestone ||
        node.type == RoadmapNodeType.mastery) {
      if (node.rewardIds.isEmpty) return true;
      final key = 'node_comp_${studentId}_${node.id}';
      final explicitlyDone = Locator.storageService.getBool(key) ?? false;
      if (explicitlyDone) return true;

      // Otherwise check if all reward definitions are marked claimed
      return node.rewardIds.every((rid) {
        final claimKey = 'reward_claimed_${studentId}_$rid';
        return Locator.storageService.getBool(claimKey) ?? false;
      });
    }

    return false;
  }

  // Evaluates a node's locks and prerequisite chains
  bool isNodeLocked(String studentId, RoadmapNode node, List<RoadmapNode> allNodes) {
    if (node.prerequisiteNodeIds.isEmpty) return false;

    // A node is locked if ANY of its prerequisite nodes are NOT completed
    return node.prerequisiteNodeIds.any((prereqId) {
      final prereqNode = allNodes.firstWhere((n) => n.id == prereqId, orElse: () => node);
      if (prereqNode.id == node.id) return false;
      return !isNodeCompleted(studentId, prereqNode);
    });
  }

  // Identifies the CURRENT recommended main-path educational node
  String? getCurrentNodeId(String studentId, List<RoadmapNode> allNodes) {
    // 1. Filter out optional nodes and non-educational nodes (rewards, mysteries)
    final mainEducationalNodes = allNodes.where((n) {
      final isEdu = n.type == RoadmapNodeType.level || n.type == RoadmapNodeType.lesson;
      return !n.isOptional && isEdu;
    }).toList();

    // Sort by order
    mainEducationalNodes.sort((a, b) => a.order.compareTo(b.order));

    // 2. Find the first incomplete educational node
    for (var node in mainEducationalNodes) {
      if (!isNodeCompleted(studentId, node)) {
        return node.id;
      }
    }

    // 3. Fallback: if all main education completed, the final mastery node becomes current
    final masteryNode = allNodes.firstWhere(
      (n) => n.type == RoadmapNodeType.mastery,
      orElse: () => allNodes.last,
    );
    return masteryNode.id;
  }

  // Dynamic status evaluator combining all states
  RoadmapNodeStatus getNodeStatus(String studentId, RoadmapNode node, List<RoadmapNode> allNodes) {
    final completed = isNodeCompleted(studentId, node);
    if (completed) {
      return RoadmapNodeStatus.completed;
    }

    final locked = isNodeLocked(studentId, node, allNodes);
    if (locked) {
      return RoadmapNodeStatus.locked;
    }

    // Check if it is the current recommended main-path node
    final currentId = getCurrentNodeId(studentId, allNodes);
    if (currentId == node.id) {
      return RoadmapNodeStatus.current;
    }

    // Check if it has claimable rewards (unclaimed rewards whose prerequisites are met)
    if (node.type == RoadmapNodeType.reward ||
        node.type == RoadmapNodeType.mystery ||
        node.type == RoadmapNodeType.milestone ||
        node.type == RoadmapNodeType.mastery) {
      // Unlocked, not yet completed/claimed: this means it is claimable!
      return RoadmapNodeStatus.claimable;
    }

    return RoadmapNodeStatus.available;
  }

  // Force mark a node as completed (for optional side quests/chests)
  Future<void> markNodeCompleted(String studentId, String nodeId, {int stars = 3}) async {
    final key = 'node_comp_${studentId}_$nodeId';
    await Locator.storageService.setBool(key, true);
    final starKey = 'node_stars_${studentId}_$nodeId';
    await Locator.storageService.setInt(starKey, stars);
  }

  // Returns earned stars (0, 1, 2, or 3) for a roadmap node
  int getNodeStars(String studentId, RoadmapNode node) {
    if (node.levelId == 'density_lvl1') {
      if (isLessonCompleted(studentId, 'density_les5')) return 3;
      if (isLessonCompleted(studentId, 'density_les3')) return 2;
      if (isLessonCompleted(studentId, 'density_les1')) return 1;
      return 0;
    }

    if (!isNodeCompleted(studentId, node)) return 0;

    // Check lesson progress record
    if (node.levelId != null || node.lessonId != null) {
      final targetId = node.lessonId ?? node.levelId!;
      final progressList = Locator.progressRepository.getProgressList(studentId);
      final p = progressList.firstWhere(
        (pr) => pr.lessonId == targetId && pr.status == 'completed',
        orElse: () => Progress(studentId: studentId, lessonId: targetId, lastPlayed: DateTime.now()),
      );
      if (p.stars > 0) return p.stars;
      if (p.score >= 1.0) return 3;
      if (p.score >= 0.7) return 2;
      return 1;
    }

    // Check saved node star key
    final starKey = 'node_stars_${studentId}_${node.id}';
    final savedStars = Locator.storageService.getInt(starKey);
    if (savedStars != null && savedStars > 0) return savedStars;

    // Default for completed nodes
    return 3;
  }
}


import '../models/roadmap_enums.dart';
import '../models/roadmap_node.dart';
import '../core/locator.dart';

class PendingReward {
  final String id;
  final String title;
  final String subtitle;
  final List<String> rewardIds;
  final String type; // 'daily', 'roadmap', 'mastery'
  final String? nodeId;

  PendingReward({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rewardIds,
    required this.type,
    this.nodeId,
  });
}

class PendingRewardService {
  // Check if student has pending rewards
  bool hasPendingRewards(String studentId) {
    return getPendingRewards(studentId).isNotEmpty;
  }

  // Retrieve all pending rewards in priority queue:
  // 1. Mastery
  // 2. Milestones
  // 3. Level Completions
  // 4. Daily Login
  // 5. Side Quests
  List<PendingReward> getPendingRewards(String studentId) {
    final List<PendingReward> list = [];
    final student = Locator.studentRepository.getCurrentStudent();
    if (student == null) return [];

    // A. Check Daily Login Reward (if not claimed)
    final dailyKey = 'daily_claimed_${studentId}';
    final dailyClaimed = Locator.storageService.getBool(dailyKey) ?? false;
    if (!dailyClaimed) {
      list.add(PendingReward(
        id: 'daily_reward_pending',
        title: '🎉 DAILY REWARD',
        subtitle: "Welcome back! Complete today's learning to lock in your streak bonus.",
        // Daily login rewards chest contents: +200 XP, +100 Coins, Water Drop fragment
        rewardIds: ['rew_density_n5_xp', 'rew_density_n5_coins', 'rew_density_n5_coll'],
        type: 'daily',
      ));
    }

    // B. Check Roadmap Node Rewards
    final moduleId = student.currentModuleId ?? 'mod_density';
    final nodes = Locator.roadmapRepository.getRoadmap(moduleId);

    for (var node in nodes) {
      final status = Locator.progressionService.getNodeStatus(studentId, node, nodes);
      if (status == RoadmapNodeStatus.claimable) {
        list.add(PendingReward(
          id: 'roadmap_node_pending_${node.id}',
          title: node.type == RoadmapNodeType.mastery
              ? '🏆 EXPEDITION CONQUERED!'
              : (node.type == RoadmapNodeType.milestone ? '🏆 MILESTONE UNLOCKED' : '🎉 QUEST COMPLETE!'),
          subtitle: node.title,
          rewardIds: node.rewardIds,
          type: node.type == RoadmapNodeType.mastery ? 'mastery' : 'roadmap',
          nodeId: node.id,
        ));
      }
    }

    // Sort by priority: mastery first, then milestone, then roadmap, then daily
    list.sort((a, b) {
      int priorityA = _getTypePriority(a);
      int priorityB = _getTypePriority(b);
      return priorityA.compareTo(priorityB);
    });

    return list;
  }

  int _getTypePriority(PendingReward r) {
    if (r.type == 'mastery') return 1;
    if (r.id.contains('milestone')) return 2;
    if (r.type == 'roadmap') return 3;
    if (r.type == 'daily') return 4;
    return 5;
  }

  PendingReward? getNextPendingReward(String studentId) {
    final list = getPendingRewards(studentId);
    return list.isNotEmpty ? list.first : null;
  }

  // Claim process dispatcher
  Future<void> markRewardClaimed(String studentId, PendingReward reward) async {
    // 1. Grant the actual items via RewardService
    for (var rid in reward.rewardIds) {
      await Locator.rewardService.claimReward(studentId, rid);
    }

    // 2. Mark the parent source as claimed
    if (reward.type == 'daily') {
      final key = 'daily_claimed_${studentId}';
      await Locator.storageService.setBool(key, true);
    } else if (reward.nodeId != null) {
      await Locator.progressionService.markNodeCompleted(studentId, reward.nodeId!);
    }
  }
}

import '../models/reward_definition.dart';
import '../models/roadmap_enums.dart';
import '../core/locator.dart';

class RewardService {
  // Checks if a student has claimed a specific reward ID
  bool hasClaimedReward(String studentId, String rewardId) {
    final key = 'reward_claimed_${studentId}_$rewardId';
    return Locator.storageService.getBool(key) ?? false;
  }

  // Set claimed flag in local storage
  Future<void> _setClaimed(String studentId, String rewardId) async {
    final key = 'reward_claimed_${studentId}_$rewardId';
    await Locator.storageService.setBool(key, true);
  }

  // Grant XP to a student profile with level up checks
  Future<int> grantXp(String studentId, int amount) async {
    final student = Locator.studentRepository.getCurrentStudent();
    if (student == null) return 0;

    int newXp = student.xp + amount;
    int level = student.level;
    int xpRequired = level * 200;
    bool leveledUp = false;

    while (newXp >= xpRequired) {
      newXp -= xpRequired;
      level++;
      xpRequired = level * 200;
      leveledUp = true;
    }

    final updated = student.copyWith(
      xp: newXp,
      level: level,
    );
    await Locator.studentRepository.updateStudentProfile(updated);

    // Save level-up flag if triggered
    if (leveledUp) {
      final luKey = 'level_up_pending_${studentId}';
      await Locator.storageService.setBool(luKey, true);
    }

    return level;
  }

  // Grant Coins to a student profile
  Future<void> grantCoins(String studentId, int amount) async {
    final student = Locator.studentRepository.getCurrentStudent();
    if (student == null) return;

    final updated = student.copyWith(
      gold: student.gold + amount,
    );
    await Locator.studentRepository.updateStudentProfile(updated);
  }

  // Claim process dispatcher
  Future<bool> claimReward(String studentId, String rewardId) async {
    if (hasClaimedReward(studentId, rewardId)) {
      return false; // Already claimed
    }

    // Retrieve RewardDefinition from repository
    final reward = Locator.roadmapRepository.getRewardById(rewardId);
    if (reward == null) return false;

    // Dispatch grant actions
    switch (reward.type) {
      case RewardType.xp:
        await grantXp(studentId, reward.amount);
        break;
      case RewardType.coins:
        await grantCoins(studentId, reward.amount);
        break;
      case RewardType.collectible:
        // Unlock collectible based on reward name mappings
        String collId = 'coll_star';
        if (reward.name.toLowerCase().contains('water')) {
          collId = 'coll_water';
        } else if (reward.name.toLowerCase().contains('crystal')) {
          collId = 'coll_crystal';
        }
        await Locator.collectionRepository.unlockCollectible(studentId, collId);
        break;
      case RewardType.badge:
        // Unlock badge matching name
        await Locator.collectionRepository.unlockBadge(studentId, reward.name);
        break;
      case RewardType.cosmetic:
        // Unlock custom profile frame or theme skin
        await Locator.collectionRepository.purchaseReward(studentId, 'reward_hat');
        break;
      case RewardType.chest:
        // Deterministic chest grants: Master Chest payload: +100 Coins, +1 Badge, +1 Cosmetic!
        await grantCoins(studentId, 100);
        await Locator.collectionRepository.unlockBadge(studentId, 'Density Explorer');
        await Locator.collectionRepository.purchaseReward(studentId, 'reward_chest');
        break;
    }

    // Mark as claimed
    await _setClaimed(studentId, rewardId);
    return true;
  }
}

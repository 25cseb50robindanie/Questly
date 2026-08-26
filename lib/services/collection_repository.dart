import 'package:flutter/foundation.dart';
import '../models/collectible.dart';
import '../models/reward.dart';
import 'storage_service.dart';

class CollectionRepository extends ChangeNotifier {
  final StorageService _storage;

  CollectionRepository(this._storage);

  // Available badges (earned by progress/levels)
  List<String> getAvailableBadges() {
    return ['Explorer', 'Scientist', 'Float Master', 'Density Master', 'Fractions Explorer'];
  }

  // Check which badges are unlocked for student
  List<String> getUnlockedBadges(String studentId) {
    final raw = _storage.getUnlockedBadgesRaw(studentId);
    return List<String>.from(raw);
  }

  Future<void> unlockBadge(String studentId, String badgeId) async {
    final list = getUnlockedBadges(studentId);
    if (!list.contains(badgeId)) {
      list.add(badgeId);
      await _storage.saveUnlockedBadgesRaw(studentId, list);
      notifyListeners();
    }
  }

  // Available collectibles
  List<Collectible> getCollectibles(String studentId) {
    final unlockedIds = _storage.getUnlockedCollectiblesRaw(studentId);
    return [
      Collectible(
        id: 'coll_star',
        name: 'Star Fragment',
        iconName: 'star',
        description: 'A glowing remnant of a stellar discovery.',
        cost: 10,
        isUnlocked: unlockedIds.contains('coll_star'),
      ),
      Collectible(
        id: 'coll_token',
        name: 'Science Token',
        iconName: 'science',
        description: 'Earned by mastering simulated physical concepts.',
        cost: 15,
        isUnlocked: unlockedIds.contains('coll_token'),
      ),
      Collectible(
        id: 'coll_map',
        name: 'Map Piece',
        iconName: 'map',
        description: 'Reveals locked regions of the Quest roadmap.',
        cost: 25,
        isUnlocked: unlockedIds.contains('coll_map'),
      ),
      Collectible(
        id: 'coll_badge',
        name: 'Explorer Badge',
        iconName: 'badge',
        description: 'Proof of starting your first academic adventure.',
        cost: 5,
        isUnlocked: unlockedIds.contains('coll_badge'),
      ),
      Collectible(
        id: 'coll_water',
        name: 'Water Drop',
        iconName: 'water',
        description: 'A pure drop of water earned during density experiments.',
        cost: 15,
        isUnlocked: unlockedIds.contains('coll_water'),
      ),
      Collectible(
        id: 'coll_crystal',
        name: 'Density Crystal',
        iconName: 'crystal',
        description: 'A high-density crystal commemorating experiment milestones.',
        cost: 30,
        isUnlocked: unlockedIds.contains('coll_crystal'),
      ),
    ];
  }

  Future<void> unlockCollectible(String studentId, String collectibleId) async {
    final unlocked = _storage.getUnlockedCollectiblesRaw(studentId);
    if (!unlocked.contains(collectibleId)) {
      unlocked.add(collectibleId);
      await _storage.saveUnlockedCollectiblesRaw(studentId, unlocked);
      notifyListeners();
    }
  }

  // Shop Rewards
  List<Reward> getShopRewards(String studentId) {
    final purchasedIds = _storage.getPurchasedRewardsRaw(studentId);
    return [
      Reward(
        id: 'reward_hat',
        name: 'Dendy Potion Hat',
        cost: 20,
        assetPath: 'reward_hat',
        isPurchased: purchasedIds.contains('reward_hat'),
      ),
      Reward(
        id: 'reward_frame',
        name: 'New Profile Frame',
        cost: 30,
        assetPath: 'reward_frame',
        isPurchased: purchasedIds.contains('reward_frame'),
      ),
      Reward(
        id: 'reward_bg',
        name: 'Quest Background',
        cost: 50,
        assetPath: 'reward_bg',
        isPurchased: purchasedIds.contains('reward_bg'),
      ),
      Reward(
        id: 'reward_chest',
        name: 'Mystery Reward Chest',
        cost: 40,
        assetPath: 'reward_chest',
        isPurchased: purchasedIds.contains('reward_chest'),
      ),
    ];
  }

  Future<bool> purchaseReward(String studentId, String rewardId) async {
    final purchased = _storage.getPurchasedRewardsRaw(studentId);
    if (!purchased.contains(rewardId)) {
      purchased.add(rewardId);
      await _storage.savePurchasedRewardsRaw(studentId, purchased);
      notifyListeners();
      return true;
    }
    return false;
  }
}


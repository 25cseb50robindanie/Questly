import 'package:flutter/foundation.dart';
import '../core/locator.dart';
import '../models/student.dart';
import 'sound_service.dart';
import 'storage_service.dart';

class DailyRewardItem {
  final int day;
  final int coins;
  final int xp;
  final String title;
  final String? badgeToUnlock;
  final bool isMystery;

  const DailyRewardItem({
    required this.day,
    required this.coins,
    this.xp = 0,
    required this.title,
    this.badgeToUnlock,
    this.isMystery = false,
  });
}

class DailyRewardService extends ChangeNotifier {
  final StorageService _storage;

  DailyRewardService(this._storage);

  static const List<DailyRewardItem> streakRewards = [
    DailyRewardItem(day: 1, coins: 20, xp: 10, title: '20 Quest Coins'),
    DailyRewardItem(day: 2, coins: 30, xp: 15, title: '30 Quest Coins'),
    DailyRewardItem(day: 3, coins: 40, xp: 20, title: '40 Quest Coins'),
    DailyRewardItem(day: 4, coins: 50, xp: 25, title: '50 Quest Coins'),
    DailyRewardItem(day: 5, coins: 75, xp: 35, title: '75 Quest Coins'),
    DailyRewardItem(day: 6, coins: 100, xp: 50, title: '100 Quest Coins'),
    DailyRewardItem(
      day: 7,
      coins: 150,
      xp: 60,
      title: 'Legendary Mystery Chest!',
      badgeToUnlock: 'Float Master',
      isMystery: true,
    ),
  ];

  String _getTodayDateStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getYesterdayDateStr() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return "${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}";
  }

  /// Checks if daily reward is available today
  bool isRewardAvailableToday(String studentId) {
    final sId = studentId.toLowerCase();
    final lastClaim = _storage.getString('questly_daily_last_claim_$sId');
    final today = _getTodayDateStr();

    if (lastClaim == today) {
      return false; // Already claimed today
    }
    return true;
  }

  /// Gets current streak day (1 to 7)
  int getCurrentStreakDay(String studentId) {
    final sId = studentId.toLowerCase();
    final lastClaim = _storage.getString('questly_daily_last_claim_$sId');
    final lastStreak = _storage.getInt('questly_daily_streak_$sId') ?? 0;
    final today = _getTodayDateStr();
    final yesterday = _getYesterdayDateStr();

    if (lastClaim == today) {
      return (lastStreak >= 1 && lastStreak <= 7) ? lastStreak : 1;
    } else if (lastClaim == yesterday) {
      // Continuing streak
      final nextStreak = lastStreak + 1;
      return nextStreak > 7 ? 1 : nextStreak;
    } else {
      // Streak broken or first day
      return 1;
    }
  }

  DailyRewardItem getRewardForDay(int day) {
    final index = (day - 1).clamp(0, streakRewards.length - 1);
    return streakRewards[index];
  }

  /// Claims today's daily reward
  Future<DailyRewardItem?> claimTodayReward(String studentId) async {
    final sId = studentId.toLowerCase();
    if (!isRewardAvailableToday(sId)) return null;

    final streakDay = getCurrentStreakDay(sId);
    final reward = getRewardForDay(streakDay);
    final student = Locator.studentRepository.getCurrentStudent();

    if (student != null) {
      // 1. Update Student Profile
      final updatedStudent = student.copyWith(
        gold: student.gold + reward.coins,
        xp: student.xp + reward.xp,
      );
      await Locator.studentRepository.updateStudentProfile(updatedStudent);

      // 2. Unlock badge if Day 7
      if (reward.badgeToUnlock != null) {
        await Locator.collectionRepository.unlockBadge(sId, reward.badgeToUnlock!);
        await Locator.collectionRepository.unlockCollectible(sId, 'coll_crystal');
      }

      // 3. Update missions
      await Locator.missionService.onXpEarned(sId, reward.xp);

      // 4. Save persistence
      final today = _getTodayDateStr();
      await _storage.setString('questly_daily_last_claim_$sId', today);
      await _storage.setInt('questly_daily_streak_$sId', streakDay);

      notifyListeners();
      return reward;
    }

    return null;
  }
}

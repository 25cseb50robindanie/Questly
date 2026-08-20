import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/locator.dart';
import '../models/mission.dart';
import '../models/student.dart';
import 'sound_service.dart';
import 'storage_service.dart';

class MissionService extends ChangeNotifier {
  final StorageService _storage;

  MissionService(this._storage);

  String _getTodayDateStr() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _getCurrentWeekStr() {
    final now = DateTime.now();
    // Monday as start of week
    final daysSinceMonday = now.weekday - 1;
    final monday = now.subtract(Duration(days: daysSinceMonday));
    return "${monday.year}-W${((monday.difference(DateTime(monday.year, 1, 1)).inDays) / 7).ceil()}";
  }

  List<Mission> getDailyMissions(String studentId) {
    final dateStr = _getTodayDateStr();
    final key = 'questly_missions_daily_${studentId.toLowerCase()}_$dateStr';
    final rawJson = _storage.getString(key);

    if (rawJson != null) {
      try {
        final List list = jsonDecode(rawJson);
        return list.map((e) => Mission.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    // Default 3 Daily Missions for today
    final defaultMissions = [
      Mission(
        id: 'daily_lessons_2',
        title: 'Complete 2 Lessons',
        description: 'Engage with and finish any 2 science or math lessons today.',
        type: MissionType.daily,
        target: 2,
        current: 0,
        coinReward: 30,
        xpReward: 20,
        iconType: 'lesson',
      ),
      Mission(
        id: 'daily_xp_100',
        title: 'Earn 100 XP',
        description: 'Solve quests and pass challenges to gain 100 XP.',
        type: MissionType.daily,
        target: 100,
        current: 0,
        coinReward: 25,
        xpReward: 15,
        iconType: 'xp',
      ),
      Mission(
        id: 'daily_experiment_1',
        title: 'Finish 1 Simulation Lab',
        description: 'Complete a simulation experiment (e.g. Density or Virtual Lab).',
        type: MissionType.daily,
        target: 1,
        current: 0,
        coinReward: 40,
        xpReward: 25,
        iconType: 'experiment',
      ),
    ];

    _saveDailyMissions(studentId, defaultMissions);
    return defaultMissions;
  }

  List<Mission> getWeeklyMissions(String studentId) {
    final weekStr = _getCurrentWeekStr();
    final key = 'questly_missions_weekly_${studentId.toLowerCase()}_$weekStr';
    final rawJson = _storage.getString(key);

    if (rawJson != null) {
      try {
        final List list = jsonDecode(rawJson);
        return list.map((e) => Mission.fromJson(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    // Default 2 Weekly Missions
    final defaultMissions = [
      Mission(
        id: 'weekly_module_1',
        title: 'Master 1 Full Module',
        description: 'Complete all lessons and detective challenges in any module.',
        type: MissionType.weekly,
        target: 1,
        current: 0,
        coinReward: 150,
        xpReward: 80,
        iconType: 'module',
      ),
      Mission(
        id: 'weekly_xp_500',
        title: 'Earn 500 Weekly XP',
        description: 'Reach 500 XP across all activities and teach-backs this week.',
        type: MissionType.weekly,
        target: 500,
        current: 0,
        coinReward: 100,
        xpReward: 50,
        iconType: 'xp',
      ),
    ];

    _saveWeeklyMissions(studentId, defaultMissions);
    return defaultMissions;
  }

  Future<void> _saveDailyMissions(String studentId, List<Mission> list) async {
    final dateStr = _getTodayDateStr();
    final key = 'questly_missions_daily_${studentId.toLowerCase()}_$dateStr';
    final jsonStr = jsonEncode(list.map((m) => m.toJson()).toList());
    await _storage.setString(key, jsonStr);
  }

  Future<void> _saveWeeklyMissions(String studentId, List<Mission> list) async {
    final weekStr = _getCurrentWeekStr();
    final key = 'questly_missions_weekly_${studentId.toLowerCase()}_$weekStr';
    final jsonStr = jsonEncode(list.map((m) => m.toJson()).toList());
    await _storage.setString(key, jsonStr);
  }

  /// Triggered whenever student finishes a lesson
  Future<void> onLessonCompleted(String studentId, {bool isExperiment = false}) async {
    final sId = studentId.toLowerCase();

    // 1. Update Daily Missions
    final daily = getDailyMissions(sId);
    bool dailyUpdated = false;
    for (int i = 0; i < daily.length; i++) {
      final m = daily[i];
      if (m.id == 'daily_lessons_2' && m.current < m.target) {
        daily[i] = m.copyWith(current: m.current + 1);
        dailyUpdated = true;
      } else if (isExperiment && m.id == 'daily_experiment_1' && m.current < m.target) {
        daily[i] = m.copyWith(current: m.current + 1);
        dailyUpdated = true;
      }
    }
    if (dailyUpdated) {
      await _saveDailyMissions(sId, daily);
    }

    notifyListeners();
  }

  /// Triggered whenever student gains XP
  Future<void> onXpEarned(String studentId, int amount) async {
    if (amount <= 0) return;
    final sId = studentId.toLowerCase();

    // 1. Daily XP mission
    final daily = getDailyMissions(sId);
    bool dailyUpdated = false;
    for (int i = 0; i < daily.length; i++) {
      final m = daily[i];
      if (m.id == 'daily_xp_100' && m.current < m.target) {
        daily[i] = m.copyWith(current: (m.current + amount).clamp(0, m.target));
        dailyUpdated = true;
      }
    }
    if (dailyUpdated) {
      await _saveDailyMissions(sId, daily);
    }

    // 2. Weekly XP mission
    final weekly = getWeeklyMissions(sId);
    bool weeklyUpdated = false;
    for (int i = 0; i < weekly.length; i++) {
      final m = weekly[i];
      if (m.id == 'weekly_xp_500' && m.current < m.target) {
        weekly[i] = m.copyWith(current: (m.current + amount).clamp(0, m.target));
        weeklyUpdated = true;
      }
    }
    if (weeklyUpdated) {
      await _saveWeeklyMissions(sId, weekly);
    }

    notifyListeners();
  }

  /// Triggered whenever a complete module is finished
  Future<void> onModuleCompleted(String studentId) async {
    final sId = studentId.toLowerCase();
    final weekly = getWeeklyMissions(sId);
    bool weeklyUpdated = false;
    for (int i = 0; i < weekly.length; i++) {
      final m = weekly[i];
      if (m.id == 'weekly_module_1' && m.current < m.target) {
        weekly[i] = m.copyWith(current: m.current + 1);
        weeklyUpdated = true;
      }
    }
    if (weeklyUpdated) {
      await _saveWeeklyMissions(sId, weekly);
      notifyListeners();
    }
  }

  /// Claim a completed mission reward
  Future<bool> claimMission(String studentId, String missionId, MissionType type) async {
    final sId = studentId.toLowerCase();
    final student = Locator.studentRepository.getCurrentStudent();
    if (student == null) return false;

    if (type == MissionType.daily) {
      final daily = getDailyMissions(sId);
      final index = daily.indexWhere((m) => m.id == missionId);
      if (index != -1 && daily[index].isCompleted && !daily[index].isClaimed) {
        final mission = daily[index];
        daily[index] = mission.copyWith(isClaimed: true);
        await _saveDailyMissions(sId, daily);

        // Grant reward
        final updatedStudent = student.copyWith(
          gold: student.gold + mission.coinReward,
          xp: student.xp + mission.xpReward,
        );
        await Locator.studentRepository.updateStudentProfile(updatedStudent);
        SoundService.playLevelComplete();
        notifyListeners();
        return true;
      }
    } else {
      final weekly = getWeeklyMissions(sId);
      final index = weekly.indexWhere((m) => m.id == missionId);
      if (index != -1 && weekly[index].isCompleted && !weekly[index].isClaimed) {
        final mission = weekly[index];
        weekly[index] = mission.copyWith(isClaimed: true);
        await _saveWeeklyMissions(sId, weekly);

        // Grant reward
        final updatedStudent = student.copyWith(
          gold: student.gold + mission.coinReward,
          xp: student.xp + mission.xpReward,
        );
        await Locator.studentRepository.updateStudentProfile(updatedStudent);
        SoundService.playLevelComplete();
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}

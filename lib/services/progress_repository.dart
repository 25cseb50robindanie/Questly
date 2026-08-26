import '../models/progress.dart';
import '../core/locator.dart';
import 'storage_service.dart';

class ProgressRepository {
  final StorageService _storage;

  ProgressRepository(this._storage);

  Future<void> saveProgress(Progress progress) async {
    await _storage.saveProgress(
      progress.studentId,
      progress.lessonId,
      progress.toJson(),
    );
  }

  List<Progress> getProgressList(String studentId) {
    final rawList = _storage.getProgressForStudent(studentId);
    final list = rawList.map((p) => Progress.fromJson(p)).toList();

    // Check if the old standalone module was completed
    final oldRecord = list.firstWhere(
      (p) => p.lessonId == 'math_fractions_1' && p.status == 'completed',
      orElse: () => Progress(studentId: studentId, lessonId: 'none', lastPlayed: DateTime.now()),
    );

    if (oldRecord.lessonId != 'none') {
      // Standalone completed: Migrate progress to the 5 new lessons
      final newLessonIds = ['fractions_les1', 'fractions_les2', 'fractions_les3', 'fractions_les4', 'fractions_les5'];
      bool migratedAny = false;
      for (final lid in newLessonIds) {
        if (!list.any((p) => p.lessonId == lid && p.status == 'completed')) {
          final newProgress = Progress(
            studentId: studentId.toLowerCase(),
            lessonId: lid,
            status: 'completed',
            score: 1.0,
            stars: 3,
            attempts: 1,
            lastPlayed: oldRecord.lastPlayed ?? DateTime.now(),
            completedAt: oldRecord.completedAt ?? DateTime.now(),
          );
          list.add(newProgress);
          saveProgress(newProgress);
          migratedAny = true;
        }
      }

      if (migratedAny) {
        final normalizedId = studentId.toLowerCase();
        
        // Unlock fractions badge
        try {
          Locator.collectionRepository.unlockBadge(studentId, 'Fractions Explorer');
        } catch (_) {
          final badgeList = _storage.getUnlockedBadgesRaw(studentId);
          if (!badgeList.contains('Fractions Explorer')) {
            badgeList.add('Fractions Explorer');
            _storage.saveUnlockedBadgesRaw(studentId, badgeList);
          }
        }

        // Mark all roadmap nodes as completed
        final nodeIds = [
          'fractions_node1', 'fractions_node2', 'fractions_node3',
          'fractions_node4', 'fractions_node5', 'fractions_node6',
          'fractions_node7'
        ];
        for (final nid in nodeIds) {
          _storage.setBool('node_comp_${normalizedId}_$nid', true);
        }

        // Mark all rewards as claimed
        final rewardIds = [
          'rew_fractions_n1', 'rew_fractions_n2', 'rew_fractions_n3_xp', 'rew_fractions_n3_coins',
          'rew_fractions_n5_xp', 'rew_fractions_n5_coins',
          'rew_fractions_n6_xp', 'rew_fractions_n7_xp', 'rew_fractions_n7_coins',
          'rew_fractions_mastery_badge', 'rew_fractions_mastery_coins', 'rew_fractions_mastery_chest'
        ];
        for (final rid in rewardIds) {
          _storage.setBool('reward_claimed_${normalizedId}_$rid', true);
        }
      }
    }

    return list;
  }

  Progress? getProgressForLesson(String studentId, String lessonId) {
    final list = getProgressList(studentId);
    for (var p in list) {
      if (p.lessonId == lessonId) return p;
    }
    return null;
  }
}

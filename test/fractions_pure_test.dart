import 'package:flutter_test/flutter_test.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/models/progress.dart';
import 'package:questly/services/module_repository.dart';
import 'package:questly/services/roadmap_repository.dart';
import 'package:questly/services/progression_service.dart';
import 'package:questly/services/progress_repository.dart';
import 'package:questly/services/collection_repository.dart';
import 'package:questly/services/storage_service.dart';

// Mock storage service that doesn't depend on actual SharedPreferences
class FakeStorageService implements StorageService {
  final Map<String, dynamic> _data = {};

  FakeStorageService();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }

  @override
  Map<String, dynamic>? getCurrentStudent() => null;

  @override
  List<Map<String, dynamic>> getProgressForStudent(String studentId) {
    final list = <Map<String, dynamic>>[];
    final prefix = '${studentId.toLowerCase()}_';
    _data.forEach((key, value) {
      if (key.startsWith(prefix) && value is Map<String, dynamic>) {
        list.add(value);
      }
    });
    return list;
  }

  @override
  Future<void> saveProgress(String studentId, String activityId, Map<String, dynamic> progressJson) async {
    final key = '${studentId.toLowerCase()}_$activityId';
    _data[key] = progressJson;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
  }

  @override
  List<String> getUnlockedBadgesRaw(String studentId) {
    final raw = _data['questly_badges_${studentId.toLowerCase()}'];
    if (raw is List<String>) return raw;
    return [];
  }

  @override
  Future<void> saveUnlockedBadgesRaw(String studentId, List<String> badges) async {
    _data['questly_badges_${studentId.toLowerCase()}'] = badges;
  }
}

class FakeCollectionRepository implements CollectionRepository {
  final FakeStorageService _storage;

  FakeCollectionRepository(this._storage);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }

  @override
  Future<void> unlockBadge(String studentId, String badgeId) async {
    final badgeList = _storage.getUnlockedBadgesRaw(studentId);
    if (!badgeList.contains(badgeId)) {
      badgeList.add(badgeId);
      await _storage.saveUnlockedBadgesRaw(studentId, badgeList);
    }
  }
}

void main() {
  group('Fractions Module Pure Unit Tests', () {
    late FakeStorageService fakeStorage;
    late ProgressRepository progressRepo;
    late FakeCollectionRepository fakeCollection;
    late ModuleRepository moduleRepo;
    late RoadmapRepository roadmapRepo;
    late ProgressionService progressionService;

    setUp(() {
      fakeStorage = FakeStorageService();
      progressRepo = ProgressRepository(fakeStorage);
      fakeCollection = FakeCollectionRepository(fakeStorage);

      Locator.storageService = fakeStorage;
      Locator.progressRepository = progressRepo;
      Locator.collectionRepository = fakeCollection;

      moduleRepo = ModuleRepository();
      roadmapRepo = RoadmapRepository();
      progressionService = ProgressionService();
    });

    test('1. Module definitions and 5 quests', () {
      final mod = moduleRepo.getModuleById('mod_fractions');
      expect(mod, isNotNull);
      expect(mod!.title, equals('Fractions & Ratios'));
      expect(mod.levels.length, equals(5));

      for (var lvl in mod.levels) {
        expect(lvl.lessons.length, equals(5));
      }
    });

    test('2. Roadmap Nodes and Grand Master sequence', () {
      final nodes = roadmapRepo.getRoadmap('mod_fractions');
      expect(nodes.length, equals(8));
      expect(nodes[1].id, equals('fractions_node2'));
      expect(nodes[4].id, equals('fractions_node5'));
    });

    test('3. Progression service lock and unlock rules', () {
      expect(progressionService.isLessonUnlocked('stu123', 'fractions_les1'), isTrue);
      expect(progressionService.isLessonUnlocked('stu123', 'fractions_les2'), isFalse);
    });

    test('4. Existing progress migration to 5 lessons', () async {
      await progressRepo.saveProgress(Progress(
        studentId: 'stu123',
        lessonId: 'math_fractions_1',
        status: 'completed',
        score: 1.0,
        stars: 3,
        attempts: 1,
        lastPlayed: DateTime.now(),
        completedAt: DateTime.now(),
      ));

      final progressList = progressRepo.getProgressList('stu123');
      for (int i = 1; i <= 5; i++) {
        final isDone = progressList.any((p) => p.lessonId == 'fractions_les$i' && p.status == 'completed');
        expect(isDone, isTrue);
      }
    });
  });
}

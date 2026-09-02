import 'dart:convert';
import 'package:questly/core/locator.dart';
import 'package:questly/models/module.dart';
import 'package:questly/models/progress.dart';
import 'package:questly/models/student.dart';
import 'package:questly/models/roadmap_node.dart';
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
    // Fallback for unused interface methods
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
  List<String> getUnlockedBadgesRaw(String studentId) {
    final list = _data['unlocked_badges_${studentId.toLowerCase()}'];
    return list != null ? List<String>.from(list) : [];
  }

  @override
  Future<void> saveUnlockedBadgesRaw(String studentId, List<String> badgeIds) async {
    _data['unlocked_badges_${studentId.toLowerCase()}'] = badgeIds;
  }

  @override
  bool? getBool(String key) {
    return _data[key] as bool?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
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

void main() async {
  print("--- STARTING FRACTIONS MODULE PURE UNIT TESTS ---");

  // Create mock storage and services
  final fakeStorage = FakeStorageService();
  final progressRepo = ProgressRepository(fakeStorage);
  final fakeCollection = FakeCollectionRepository(fakeStorage);

  // Inject mock services to locator for tests
  Locator.storageService = fakeStorage;
  Locator.progressRepository = progressRepo;
  Locator.collectionRepository = fakeCollection;

  // 1. Test Module definitions
  final moduleRepo = ModuleRepository();
  final mod = moduleRepo.getModuleById('mod_fractions');
  if (mod == null) {
    throw Exception("FAIL: Fractions module 'mod_fractions' not found!");
  }
  print("✓ PASS: Module exists");

  if (mod.title != 'Fractions & Ratios') {
    throw Exception("FAIL: Expected Fractions title to be 'Fractions & Ratios' but got: ${mod.title}");
  }
  print("✓ PASS: Module title is correctly unified");

  if (mod.levels.length != 2 || mod.levels[0].lessons.length != 5 || mod.levels[1].lessons.length != 5) {
    throw Exception("FAIL: Expected 2 levels with 5 lessons each, got ${mod.levels.length} levels");
  }
  print("✓ PASS: Level 1 (Fractions) and Level 2 (Ratios) both have exactly 5 sequential lessons");

  final l1Lessons = mod.levels[0].lessons;
  final expectedL1Types = [
    'fraction_concept',
    'fraction_visual',
    'fraction_practice',
    'fraction_challenge',
    'fraction_teach_dendy'
  ];
  for (int i = 0; i < expectedL1Types.length; i++) {
    if (l1Lessons[i].activityType != expectedL1Types[i]) {
      throw Exception("FAIL: Expected L1 lesson ${i + 1} activityType to be '${expectedL1Types[i]}' but got '${l1Lessons[i].activityType}'");
    }
  }

  final l2Lessons = mod.levels[1].lessons;
  final expectedL2Types = [
    'ratio_concept',
    'ratio_visual',
    'ratio_practice',
    'ratio_challenge',
    'ratio_teach_dendy'
  ];
  for (int i = 0; i < expectedL2Types.length; i++) {
    if (l2Lessons[i].activityType != expectedL2Types[i]) {
      throw Exception("FAIL: Expected L2 lesson ${i + 1} activityType to be '${expectedL2Types[i]}' but got '${l2Lessons[i].activityType}'");
    }
  }
  print("✓ PASS: Lesson activity types for Fractions & Ratios are correctly ordered");

  // 2. Test Roadmap Nodes
  final roadmapRepo = RoadmapRepository();
  final nodes = roadmapRepo.getRoadmap('mod_fractions');
  if (nodes.length != 7) {
    throw Exception("FAIL: Expected 7 roadmap nodes for fractions, got ${nodes.length}");
  }
  print("✓ PASS: Fractions roadmap has exactly 7 nodes");

  final masteryNode = nodes.firstWhere((n) => n.id == 'fractions_node7');
  if (!masteryNode.rewardIds.contains('rew_fractions_mastery_badge')) {
    throw Exception("FAIL: Mastery node does not award Fractions Explorer badge!");
  }
  print("✓ PASS: Mastery node awards correct badge reward definition");

  // 3. Test progression service lock & unlock rules
  final progressionService = ProgressionService();
  
  // Initially, fractions_les1 should be unlocked, others locked
  if (!progressionService.isLessonUnlocked('stu123', 'fractions_les1')) {
    throw Exception("FAIL: Lesson 1 should be unlocked by default");
  }
  if (progressionService.isLessonUnlocked('stu123', 'fractions_les2')) {
    throw Exception("FAIL: Lesson 2 should be locked initially");
  }
  print("✓ PASS: Unlocked rules apply correctly to fractions lesson 1 & 2");

  // 4. Test Student Progress Migration
  // Save old standalone progress
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

  // Fetching the progress list should trigger the migration
  final progressList = progressRepo.getProgressList('stu123');
  
  // Verify that all 5 lessons are now completed
  for (int i = 1; i <= 5; i++) {
    final isDone = progressList.any((p) => p.lessonId == 'fractions_les$i' && p.status == 'completed');
    if (!isDone) {
      throw Exception("FAIL: Progress migration failed to mark fractions_les$i as completed");
    }
  }
  print("✓ PASS: Existing progress correctly migrated to all 5 new lessons");

  // Verify that badge is unlocked in storage
  final badges = fakeStorage.getUnlockedBadgesRaw('stu123');
  if (!badges.contains('Fractions Explorer')) {
    throw Exception("FAIL: Progress migration failed to unlock 'Fractions Explorer' badge");
  }
  print("✓ PASS: Progress migration correctly unlocked the badge");

  // Verify that roadmap nodes and rewards are claimed
  if (!fakeStorage.getBool('node_comp_stu123_fractions_node1')! ||
      !fakeStorage.getBool('node_comp_stu123_fractions_node7')!) {
    throw Exception("FAIL: Progress migration failed to mark roadmap nodes completed");
  }
  if (!fakeStorage.getBool('reward_claimed_stu123_rew_fractions_mastery_badge')!) {
    throw Exception("FAIL: Progress migration failed to mark rewards claimed");
  }
  print("✓ PASS: Progress migration correctly claimed nodes and rewards");

  print("--- ALL FRACTIONS MODULE UNIT TESTS PASSED SUCCESSFULLY! ---");
}

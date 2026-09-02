import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/models/activity.dart';
import 'package:questly/screens/fraction_concept_screen.dart';
import 'package:questly/screens/fraction_visual_screen.dart';
import 'package:questly/services/adaptive_learning_engine.dart';
import 'package:questly/services/misconception_engine.dart';
import 'package:questly/services/module_repository.dart';
import 'package:questly/services/roadmap_repository.dart';
import 'package:questly/services/progression_service.dart';
import 'package:questly/services/storage_service.dart';
import 'package:questly/services/student_repository.dart';
import 'package:questly/services/auth_service.dart';
import 'package:questly/services/progress_repository.dart';
import 'package:questly/services/collection_repository.dart';
import 'package:questly/services/notification_repository.dart';
import 'package:questly/services/read_aloud_service.dart';

class _FakeStorage extends Fake implements StorageService {
  final Map<String, dynamic> _data = {};

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<void> setBool(String key, bool value) async {
    _data[key] = value;
  }

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<void> setInt(String key, int value) async {
    _data[key] = value;
  }

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _data[key] = value;
  }

  final List<Map<String, dynamic>> _progressList = [];

  @override
  List<Map<String, dynamic>> getProgressForStudent(String studentId) => _progressList;

  @override
  Future<void> saveProgress(String studentId, String lessonId, Map<String, dynamic> data) async {
    _progressList.removeWhere((p) => p['lessonId'] == lessonId);
    _progressList.add(data);
  }

  @override
  List<String> getUnlockedBadgesRaw(String studentId) => [];

  @override
  Map<String, dynamic>? getCurrentStudent() => null;
}

void main() {
  late _FakeStorage storage;
  late AdaptiveLearningEngine adaptiveEngine;
  late MisconceptionEngine misconceptionEngine;
  late ProgressionService progressionService;
  late ModuleRepository moduleRepo;
  late RoadmapRepository roadmapRepo;

  setUp(() {
    storage = _FakeStorage();
    Locator.storageService = storage;
    Locator.studentRepository = StudentRepository(storage);
    Locator.progressRepository = ProgressRepository(storage);
    Locator.collectionRepository = CollectionRepository(storage);
    Locator.notificationRepository = NotificationRepository(storage);
    Locator.authService = MockAuthService(
      storage,
      Locator.studentRepository,
      Locator.progressRepository,
      Locator.collectionRepository,
      Locator.notificationRepository,
    );
    Locator.readAloudService = ReadAloudService();
    Locator.progressionService = ProgressionService();

    adaptiveEngine = AdaptiveLearningEngine();
    misconceptionEngine = MisconceptionEngine();
    progressionService = Locator.progressionService;
    moduleRepo = ModuleRepository();
    roadmapRepo = RoadmapRepository();
  });

  group('1. Module & Roadmap 5-Quest Structure', () {
    test('ModuleRepository defines all 5 Quests under mod_fractions with 5 lessons each', () {
      final mod = moduleRepo.getModuleById('mod_fractions');
      expect(mod, isNotNull);
      expect(mod!.levels.length, 5);

      final expectedLevels = [
        'fractions_lvl1',
        'ratios_lvl1',
        'proportions_lvl1',
        'percentages_lvl1',
        'applications_lvl1',
      ];

      for (int i = 0; i < expectedLevels.length; i++) {
        final lvl = mod.levels[i];
        expect(lvl.id, expectedLevels[i]);
        expect(lvl.lessons.length, 5);
        expect(lvl.lessons[0].title, 'Concept Learning');
        expect(lvl.lessons[1].title, 'Visual Understanding');
        expect(lvl.lessons[2].title, 'Guided Practice');
        expect(lvl.lessons[3].title, 'Challenge');
        expect(lvl.lessons[4].title, 'Teach Dendy');
      }
    });

    test('RoadmapRepository defines 5 Quests, Two Claim Reward Milestones, plus Grand Master Chest', () {
      final roadmap = roadmapRepo.getRoadmap('mod_fractions');
      expect(roadmap.length, 8);
      expect(roadmap[0].id, 'fractions_node1');
      expect(roadmap[1].id, 'fractions_node2');
      expect(roadmap[2].id, 'fractions_node3');
      expect(roadmap[3].id, 'fractions_node4');
      expect(roadmap[4].id, 'fractions_node5');
      expect(roadmap[5].id, 'fractions_node6');
      expect(roadmap[6].id, 'fractions_node7');
      expect(roadmap[7].id, 'fractions_node8');
    });
  });

  group('2. Adaptive Learning Engine & Strict Mastery Gates', () {
    test('Mastery is NOT achieved when criteria are unmet', () {
      const studentId = 'stu_test1';
      const topic = 'fractions';
      adaptiveEngine.resetSession(studentId, topic);

      // Initial state
      expect(adaptiveEngine.isMasteryAchieved(studentId, topic), isFalse);

      // Answer 2 correct
      adaptiveEngine.recordAnswer(
        studentId: studentId,
        topic: topic,
        isCorrect: true,
        problemDifficulty: DifficultyLevel.beginner,
      );
      adaptiveEngine.recordAnswer(
        studentId: studentId,
        topic: topic,
        isCorrect: true,
        problemDifficulty: DifficultyLevel.beginner,
      );
      expect(adaptiveEngine.isMasteryAchieved(studentId, topic), isFalse);

      // Trigger a misconception
      adaptiveEngine.recordAnswer(
        studentId: studentId,
        topic: topic,
        isCorrect: false,
        problemDifficulty: DifficultyLevel.intermediate,
        triggeredMisconception: 'larger_denominator_fallacy',
      );
      final session = adaptiveEngine.getSession(studentId, topic);
      expect(session.activeMisconceptions.contains('larger_denominator_fallacy'), isTrue);
      expect(adaptiveEngine.isMasteryAchieved(studentId, topic), isFalse);
    });

    test('Mastery IS achieved when accuracy >= 80%, mastery >= 80%, streak >= 5, and 0 misconceptions', () {
      const studentId = 'stu_master';
      const topic = 'proportions';
      adaptiveEngine.resetSession(studentId, topic);

      // Answer 6 consecutive correct answers on intermediate/advanced
      for (int i = 0; i < 6; i++) {
        adaptiveEngine.recordAnswer(
          studentId: studentId,
          topic: topic,
          isCorrect: true,
          problemDifficulty: DifficultyLevel.advanced,
        );
      }

      final state = adaptiveEngine.getSession(studentId, topic);
      expect(state.totalAnswered >= 5, isTrue);
      expect(state.accuracy, 1.0);
      expect(state.masteryScore >= 0.80, isTrue);
      expect(state.streak >= 5, isTrue);
      expect(state.activeMisconceptions.isEmpty, isTrue);
      expect(adaptiveEngine.isMasteryAchieved(studentId, topic), isTrue);
    });
  });

  group('3. Progression Service Gate Rules', () {
    test('Lesson 4 (Challenge) remains locked until Guided Practice achieves mastery', () {
      const studentId = 'stu_prog_test';
      adaptiveEngine.resetSession(studentId, 'fractions');

      // Lesson 1 is unlocked
      expect(progressionService.isLessonUnlocked(studentId, 'fractions_les1'), isTrue);

      // Mark Lesson 1 & 2 complete
      storage.setBool('lesson_comp_${studentId}_fractions_les1', true);
      expect(progressionService.isLessonUnlocked(studentId, 'fractions_les2'), isTrue);

      storage.setBool('lesson_comp_${studentId}_fractions_les2', true);
      expect(progressionService.isLessonUnlocked(studentId, 'fractions_les3'), isTrue);

      // Mark Lesson 3 complete in storage, BUT without adaptive mastery
      storage.setBool('lesson_comp_${studentId}_fractions_les3', true);
      expect(progressionService.isLessonUnlocked(studentId, 'fractions_les4'), isFalse,
          reason: 'Challenge MUST remain locked until adaptive mastery is satisfied!');

      // Now achieve mastery in the engine
      for (int i = 0; i < 6; i++) {
        adaptiveEngine.recordAnswer(
          studentId: studentId,
          topic: 'fractions',
          isCorrect: true,
          problemDifficulty: DifficultyLevel.advanced,
        );
      }

      // Now Lesson 4 (Challenge) unlocks!
      expect(progressionService.isLessonUnlocked(studentId, 'fractions_les4'), isTrue);
    });

    test('Quest 2 unlocks after Quest 1 completion and Claim Reward milestone', () {
      const studentId = 'stu_q2_test';
      expect(progressionService.isLessonUnlocked(studentId, 'ratios_les1'), isFalse);

      storage.setBool('lesson_comp_${studentId}_fractions_les5', true);
      // Still locked until reward milestone is claimed
      expect(progressionService.isLessonUnlocked(studentId, 'ratios_les1'), isFalse);

      storage.setBool('node_comp_${studentId}_fractions_node2', true);
      expect(progressionService.isLessonUnlocked(studentId, 'ratios_les1'), isTrue);
    });
  });

  group('4. Misconception Diagnostics Across 5 Topics', () {
    test('Diagnoses rules for all 5 Quests correctly', () {
      final diagFrac = misconceptionEngine.diagnose(topic: 'fractions', selectedOption: '1/8', correctOption: '1/4');
      expect(diagFrac?.id, 'larger_denominator_fallacy');

      final diagRatio = misconceptionEngine.diagnose(topic: 'ratios', selectedOption: '5:3', correctOption: '3:5');
      expect(diagRatio?.id, 'ratio_order_inversion');

      final diagProp = misconceptionEngine.diagnose(topic: 'proportions', selectedOption: '4:5', correctOption: '4:6');
      expect(diagProp?.id, 'additive_scaling_fallacy');

      final diagPerc = misconceptionEngine.diagnose(topic: 'percentages', selectedOption: '3%', correctOption: '60%');
      expect(diagPerc?.id, 'base_100_misinterpretation');

      final diagApp = misconceptionEngine.diagnose(topic: 'applications', selectedOption: '8 gold', correctOption: '24 gold');
      expect(diagApp?.id, 'multi_step_order_confusion');
    });
  });

  group('5. Widget Rendering for 5 Quests', () {
    testWidgets('FractionConceptScreen renders Proportions Quest 3 cleanly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));

      final act = Activity(
        id: 'act_proportion_concept',
        title: 'Concept Learning: Proportions',
        instruction: 'Scale factors and cross multiplication.',
        type: 'proportion_concept',
        targetDensity: 0.0,
        targetCondition: '',
        xpReward: 40,
        goldReward: 5,
      );

      await tester.pumpWidget(MaterialApp(home: FractionConceptScreen(activity: act)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('PROPORTIONS • QUEST 3'), findsOneWidget);
      expect(find.text('The Royal Scale Blueprint'), findsOneWidget);
    });

    testWidgets('FractionVisualScreen renders Percentages Quest 4 cleanly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 600));

      final act = Activity(
        id: 'act_percentage_visual',
        title: 'Visual Understanding: Percentages',
        instruction: 'Explore 100-grids and discounts.',
        type: 'percentage_visual',
        targetDensity: 0.0,
        targetCondition: '',
        xpReward: 60,
        goldReward: 10,
      );

      await tester.pumpWidget(MaterialApp(home: FractionVisualScreen(activity: act)));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('PERCENTAGES • QUEST 4'), findsOneWidget);
      expect(find.text('🔟 100-Grid'), findsOneWidget);
    });
  });
}

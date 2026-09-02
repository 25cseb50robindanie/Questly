import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/screens/fraction_concept_screen.dart';
import 'package:questly/screens/fraction_visual_screen.dart';
import 'package:questly/screens/fraction_practice_screen.dart';
import 'package:questly/screens/fraction_challenge_screen.dart';
import 'package:questly/screens/fraction_teach_dendy_screen.dart';
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
  setUp(() {
    final storage = _FakeStorage();
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
  });

  testWidgets('1. FractionConceptScreen renders with zero layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(const MaterialApp(home: FractionConceptScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('The Great Canyon Feast'), findsOneWidget);
    expect(find.text('NEXT PART →'), findsOneWidget);
  });

  testWidgets('2. FractionVisualScreen renders and interacts with zero layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(const MaterialApp(home: FractionVisualScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LESSON 2: VISUAL UNDERSTANDING'), findsOneWidget);
    expect(find.text('PROCEED TO PRACTICE →'), findsOneWidget);

    // Switch to chocolate tab
    await tester.tap(find.text('🍫 Chocolate'));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('3. FractionPracticeScreen renders and answers questions with zero layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(const MaterialApp(home: FractionPracticeScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LESSON 3: GUIDED PRACTICE'), findsOneWidget);
    expect(find.text('CHECK ANSWER'), findsOneWidget);

    // Select option 3/4
    await tester.tap(find.text('3/4'));
    await tester.pump(const Duration(milliseconds: 100));

    // Tap Check Answer
    await tester.tap(find.text('CHECK ANSWER'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NEXT QUESTION →'), findsOneWidget);
  });

  testWidgets('4. FractionChallengeScreen renders all challenge modes with zero layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(const MaterialApp(home: FractionChallengeScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LESSON 4: CHALLENGE ARENA'), findsOneWidget);

    // Switch to Flashcards mode
    await tester.tap(find.text('🗂️ Flashcards'));
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to Speed Quiz mode
    await tester.tap(find.text('⚡ Speed Quiz'));
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to Memory Match mode
    await tester.tap(find.text('🧠 Memory Match'));
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('5. FractionTeachDendyScreen renders with zero layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    await tester.pumpWidget(const MaterialApp(home: FractionTeachDendyScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('LESSON 5: TEACH DENDY'), findsOneWidget);
    expect(find.text('HOW WILL YOU TEACH DENDY?'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/screens/fraction_concept_screen.dart';
import 'package:questly/models/activity.dart';
import 'package:questly/core/locator.dart';
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
  });

  testWidgets('FractionConceptScreen renders without blank screen or layout errors', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));

    await tester.pumpWidget(
      const MaterialApp(
        home: FractionConceptScreen(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Header
    expect(find.text('FRACTIONS • QUEST 1'), findsOneWidget);
    expect(find.text('LESSON 1: CONCEPT LEARNING'), findsOneWidget);

    // Verify Slide 1 Content
    expect(find.text('The Great Canyon Feast'), findsOneWidget);
    expect(find.text('PART 1 OF 4'), findsOneWidget);
    expect(find.text('NEXT PART →'), findsOneWidget);

    // Tap Next to navigate through slides
    await tester.tap(find.text('NEXT PART →'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Numerator & Denominator'), findsOneWidget);
    expect(find.text('PART 2 OF 4'), findsOneWidget);
    expect(find.text('PREVIOUS'), findsOneWidget);

    // Tap Next again
    await tester.tap(find.text('NEXT PART →'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('The Golden Secret of Denominators'), findsOneWidget);
    expect(find.text('PART 3 OF 4'), findsOneWidget);

    // Tap Next to last slide
    await tester.tap(find.text('NEXT PART →'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Fractions in the Real World'), findsOneWidget);
    expect(find.text('PART 4 OF 4'), findsOneWidget);
    expect(find.text('FINISH LESSON ✓'), findsOneWidget);
  });

  testWidgets('FractionConceptScreen renders Ratios mode when activity argument is provided', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));

    final ratioActivity = Activity(
      id: 'act_ratio_concept',
      title: 'Concept Learning: Ratios',
      instruction: 'Discover ratio relationships.',
      type: 'ratio_concept',
      targetDensity: 0.0,
      targetCondition: '',
      xpReward: 40,
      goldReward: 5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: FractionConceptScreen(activity: ratioActivity),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Ratios Header
    expect(find.text('RATIOS • QUEST 2'), findsOneWidget);
    expect(find.text('The Alchemist\'s Recipe'), findsOneWidget);
  });
}

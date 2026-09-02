import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/widgets/quest_progress_modal.dart';

void main() {
  const lessons = [
    QuestLessonData(
      id: 'fractions_les1',
      title: '1. Concept Learning',
      status: QuestLessonStatus.completed,
    ),
    QuestLessonData(
      id: 'fractions_les2',
      title: '2. Visual Understanding',
      status: QuestLessonStatus.completed,
    ),
    QuestLessonData(
      id: 'fractions_les3',
      title: '3. Guided Practice',
      status: QuestLessonStatus.completed,
    ),
    QuestLessonData(
      id: 'fractions_les4',
      title: '4. Challenge',
      status: QuestLessonStatus.current,
    ),
    QuestLessonData(
      id: 'fractions_les5',
      title: '5. Teach Dendy',
      status: QuestLessonStatus.locked,
    ),
  ];

  testWidgets('QuestProgressModal renders 5 lessons and taps START QUEST', (WidgetTester tester) async {
    bool startQuestPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestProgressModal(
            questBadge: 'QUEST 1',
            questTitle: 'CANYON CROSSINGS',
            objective: 'Master fraction basics and build the canyon bridge.',
            lessons: lessons,
            xpReward: 80,
            coinReward: 15,
            onStartQuest: () {
              startQuestPressed = true;
            },
            onStartLesson: (lesson) {},
          ),
        ),
      ),
    );

    // 1. Verify Quest Badge and Title
    expect(find.text('QUEST 1'), findsOneWidget);
    expect(find.text('CANYON CROSSINGS'), findsOneWidget);

    // 2. Verify Objective
    expect(find.text('Master fraction basics and build the canyon bridge.'), findsOneWidget);

    // 3. Verify all 5 lesson names are rendered
    expect(find.text('1. Concept Learning'), findsOneWidget);
    expect(find.text('2. Visual Understanding'), findsOneWidget);
    expect(find.text('3. Guided Practice'), findsOneWidget);
    expect(find.text('4. Challenge'), findsOneWidget);
    expect(find.text('5. Teach Dendy'), findsOneWidget);

    // 4. Verify Status Badges
    expect(find.text('COMPLETED'), findsNWidgets(3));
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('LOCKED'), findsOneWidget);

    // 5. Verify START QUEST button exists and tap it
    expect(find.text('START QUEST'), findsOneWidget);
    await tester.tap(find.text('START QUEST'));
    await tester.pump();
    expect(startQuestPressed, isTrue);
  });

  testWidgets('QuestProgressModal taps playable lesson', (WidgetTester tester) async {
    QuestLessonData? tappedLesson;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuestProgressModal(
            questBadge: 'QUEST 1',
            questTitle: 'CANYON CROSSINGS',
            objective: 'Master fraction basics and build the canyon bridge.',
            lessons: lessons,
            xpReward: 80,
            coinReward: 15,
            onStartQuest: () {},
            onStartLesson: (lesson) {
              tappedLesson = lesson;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    expect(tappedLesson?.id, equals('fractions_les4'));
  });
}

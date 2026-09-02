import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/widgets/fraction_visual_models.dart';
import 'package:questly/widgets/flashcard_widget.dart';
import 'package:questly/widgets/misconception_remediation_dialog.dart';
import 'package:questly/services/misconception_engine.dart';

void main() {
  testWidgets('PizzaVisualWidget renders pizza custom painter and label', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PizzaVisualWidget(
            totalSlices: 4,
            selectedSlices: 3,
            label: '3/4 Slices',
          ),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('3/4 Slices'), findsOneWidget);
  });

  testWidgets('ChocolateBarVisualWidget renders interactive grid segments', (WidgetTester tester) async {
    int selected = 2;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ChocolateBarVisualWidget(
              totalRows: 2,
              totalCols: 4,
              selectedPieces: selected,
              interactive: true,
              onSelectionChanged: (newSel) {
                setState(() {
                  selected = newSel;
                });
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
  });

  testWidgets('FractionStripsVisualWidget renders multiple fractional strip rows', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FractionStripsVisualWidget(
            denominators: [2, 4, 8],
            activeDenominator: 4,
            activeNumerator: 2,
          ),
        ),
      ),
    );

    expect(find.text('1/2'), findsWidgets);
    expect(find.text('1/4'), findsWidgets);
    expect(find.text('1/8'), findsWidgets);
  });

  testWidgets('RatioBeakerVisualWidget and FruitRatioVisualWidget render correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              RatioBeakerVisualWidget(partA: 2, partB: 3, labelA: 'Juice', labelB: 'Water'),
              FruitRatioVisualWidget(countA: 3, countB: 5, labelA: 'Apples', labelB: 'Bananas'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Juice (2)'), findsOneWidget);
    expect(find.text('Water (3)'), findsOneWidget);
    expect(find.text('Ratio Juice : Water = 2 : 3'), findsOneWidget);
    expect(find.text('3 Apples'), findsOneWidget);
    expect(find.text('5 Bananas'), findsOneWidget);
  });

  testWidgets('FlashcardWidget displays question, flips to answer, and triggers callbacks', (WidgetTester tester) async {
    bool mastered = false;

    const card = FlashcardData(
      id: 'test_card',
      category: 'Concept',
      question: 'What is a Numerator?',
      answer: 'Top Number',
      rule: 'Parts we have',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FlashcardWidget(
            card: card,
            onMastered: () {
              mastered = true;
            },
            onReviewAgain: () {},
          ),
        ),
      ),
    );

    expect(find.text('What is a Numerator?'), findsOneWidget);
    expect(find.text('TAP TO FLIP'), findsOneWidget);

    // Tap to flip
    await tester.tap(find.text('TAP TO FLIP'));
    await tester.pumpAndSettle();

    expect(find.text('Top Number'), findsOneWidget);
    expect(find.text('Parts we have'), findsOneWidget);

    // Tap Mastered button
    await tester.tap(find.text('GOT IT! (+10 XP)'));
    await tester.pump();
    expect(mastered, isTrue);
  });

  testWidgets('MisconceptionRemediationDialog renders diagnosis and interactive retry', (WidgetTester tester) async {
    final engine = MisconceptionEngine();
    final diag = engine.diagnose(
      explicitTrigger: 'larger_denominator_fallacy',
      topic: 'fractions',
      selectedOption: '1/8 is bigger',
      correctOption: '1/4 is bigger',
    )!;

    bool resolved = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MisconceptionRemediationDialog(
            diagnosis: diag,
            onResolved: () {
              resolved = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('AHA! LET\'S CLEAR THIS UP'), findsOneWidget);
    expect(find.text(diag.title.toUpperCase()), findsOneWidget);
    expect(find.text('🎯 QUICK CHECK – TEST YOUR UNDERSTANDING'), findsOneWidget);

    // Choose correct retry option
    await tester.tap(find.text('1/2 is bigger'));
    await tester.pump();

    // Tap continue
    await tester.tap(find.text('CONTINUE LEARNING ✓'));
    await tester.pump();
    expect(resolved, isTrue);
  });
}

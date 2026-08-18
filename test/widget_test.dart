// This is a basic Flutter widget test for Questly.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questly/main.dart';

void main() {
  testWidgets('App splash loading smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuestlyApp());

    // Verify that the splash screen initializes and shows a progress indicator.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

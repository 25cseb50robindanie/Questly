import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:questly/main.dart';
import 'package:questly/core/locator.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Locator.resetForTest();
    await Locator.setup();
  });

  testWidgets('App splash loading smoke test', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 768));
    await tester.pumpWidget(const QuestlyApp());
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(QuestlyApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:questly/services/curriculum_retriever.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dendy Deterministic Retrieval Tests', () {
    late CurriculumRetriever retriever;

    setUp(() async {
      retriever = CurriculumRetriever();
      await retriever.initialize();
    });

    test('1. What is density?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is density?');
      expect(res.text.toLowerCase(), contains('mass'));
      expect(res.text.toLowerCase(), contains('volume'));
      expect(res.suggestedChips, isNotEmpty);
    });

    test('2. What is the density of oil?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the density of oil?');
      expect(res.text, contains('0.80'));
      expect(res.text.toLowerCase(), contains('float'));
    });

    test('3. Why do ships float?', () async {
      final res = await retriever.retrieveAnswer(query: 'Why do ships float?');
      expect(res.text.toLowerCase(), contains('steel'));
      expect(res.text.toLowerCase(), contains('hollow'));
      expect(res.suggestedChips, contains('What about submarines?'));
    });

    test('4. Explain simply (style shifting)', () async {
      final res = await retriever.retrieveAnswer(
        query: 'Explain simply',
        lastActiveConceptId: 'density',
      );
      expect(res.text.toLowerCase(), contains('boxes'));
    });

    test('5. Compare water and oil', () async {
      final res = await retriever.retrieveAnswer(query: 'Compare water and oil');
      expect(res.text.toLowerCase(), contains('water is denser than oil'));
      expect(res.text, contains('1.00'));
      expect(res.text, contains('0.80'));
    });

    test('6. Quiz me', () async {
      final res = await retriever.retrieveAnswer(query: 'Quiz me');
      expect(res.text, contains('🧠 **Dendy Pop Quiz!**'));
      expect(res.suggestedChips, isNotEmpty);
    });

    test('7. Misconception: Heavy objects always sink', () async {
      final res = await retriever.retrieveAnswer(query: 'Heavy objects always sink.');
      expect(res.isMisconception, isTrue);
      expect(res.text, contains('Misconception Alert'));
      expect(res.text.toLowerCase(), contains('cruise ship'));
    });

    test('8. Alias matching: Why is oil lighter than water?', () async {
      final res = await retriever.retrieveAnswer(query: 'Why is oil lighter than water?');
      expect(res.text.toLowerCase(), contains('less dense than water'));
    });

    test('9. What is the formula?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the formula?');
      expect(res.text, contains('Density = Mass ÷ Volume'));
    });

    test('10. Is mass the same as weight?', () async {
      final res = await retriever.retrieveAnswer(query: 'Is mass the same as weight?');
      expect(res.text.toLowerCase(), contains('gravity'));
    });
  });
}

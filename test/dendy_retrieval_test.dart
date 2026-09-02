import 'package:flutter_test/flutter_test.dart';
import 'package:questly/services/curriculum_retriever.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dendy Deterministic Retrieval Tests (Density, Fractions & Ratios, Intents)', () {
    late CurriculumRetriever retriever;

    setUp(() async {
      retriever = CurriculumRetriever();
      await retriever.initialize();
    });

    void assertNoEmojisOrAsterisks(String text) {
      expect(text, isNot(contains('**')), reason: 'Response should not contain ** asterisks');
      expect(text, isNot(contains('__')), reason: 'Response should not contain __ underscores');
      final emojiRegExp = RegExp(r'[\u{1F300}-\u{1F9FF}\u{1FA00}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true);
      expect(emojiRegExp.hasMatch(text), isFalse, reason: 'Response should not contain emojis: $text');
    }

    // --- Science / Density Tests ---
    test('1. What is density?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is density?');
      expect(res.text.toLowerCase(), contains('mass'));
      expect(res.text.toLowerCase(), contains('volume'));
      expect(res.suggestedChips, isNotEmpty);
      assertNoEmojisOrAsterisks(res.text);
    });

    test('2. What is the density of oil?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the density of oil?');
      expect(res.text, contains('0.80'));
      expect(res.text.toLowerCase(), contains('float'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('3. Why do ships float?', () async {
      final res = await retriever.retrieveAnswer(query: 'Why do ships float?');
      expect(res.text.toLowerCase(), contains('steel'));
      expect(res.text.toLowerCase(), contains('hollow'));
      expect(res.suggestedChips, contains('What about submarines?'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('4. Density: Explain simply (style shifting)', () async {
      final res = await retriever.retrieveAnswer(
        query: 'Explain simply',
        lastActiveConceptId: 'density',
      );
      expect(res.text.toLowerCase(), contains('boxes'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('5. Compare water and oil', () async {
      final res = await retriever.retrieveAnswer(query: 'Compare water and oil');
      expect(res.text.toLowerCase(), contains('water is denser than oil'));
      expect(res.text, contains('1.00'));
      expect(res.text, contains('0.80'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('6. Density Misconception: Heavy objects always sink', () async {
      final res = await retriever.retrieveAnswer(query: 'Heavy objects always sink.');
      expect(res.isMisconception, isTrue);
      expect(res.text, contains('Misconception Alert'));
      expect(res.text.toLowerCase(), contains('cruise ship'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('7. Formula for density', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the formula for density?');
      expect(res.text, contains('Density = Mass ÷ Volume'));
      assertNoEmojisOrAsterisks(res.text);
    });

    // --- Math / Fractions & Ratios Tests ---
    test('8. What is a fraction?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is a fraction?');
      expect(res.text.toLowerCase(), contains('part of a whole'));
      expect(res.suggestedChips, isNotEmpty);
      assertNoEmojisOrAsterisks(res.text);
    });

    test('9. What is the numerator?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the numerator?');
      expect(res.text.toLowerCase(), contains('above the fraction line'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('10. What is the denominator?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is the denominator?');
      expect(res.text.toLowerCase(), contains('below the fraction line'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('11. Fractions: Explain simply (style shifting)', () async {
      final res = await retriever.retrieveAnswer(
        query: 'Explain simply',
        lastActiveConceptId: 'fraction',
      );
      expect(res.text.toLowerCase(), contains('pizza'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('12. Simplify 12/16', () async {
      final res = await retriever.retrieveAnswer(query: 'Simplify 12/16');
      expect(res.text, contains('3/4'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('13. How do I add fractions?', () async {
      final res = await retriever.retrieveAnswer(query: 'How do I add fractions?');
      expect(res.text, contains('5/6'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('14. How do I divide fractions?', () async {
      final res = await retriever.retrieveAnswer(query: 'How do I divide fractions?');
      expect(res.text.toLowerCase(), contains('keep'));
      expect(res.text.toLowerCase(), contains('change'));
      expect(res.text.toLowerCase(), contains('flip'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('15. Which is bigger 1/2 or 1/3?', () async {
      final res = await retriever.retrieveAnswer(query: 'Which is bigger 1/2 or 1/3?');
      expect(res.text, contains('1/2 is greater than 1/3'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('16. What is a ratio?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is a ratio?');
      expect(res.text.toLowerCase(), contains('compares two quantities'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('17. Simplify 12:18', () async {
      final res = await retriever.retrieveAnswer(query: 'Simplify 12:18');
      expect(res.text, contains('2:3'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('18. Convert 7/3', () async {
      final res = await retriever.retrieveAnswer(query: 'Convert 7/3');
      expect(res.text, contains('2 1/3'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('19. Convert 0.5 to fraction', () async {
      final res = await retriever.retrieveAnswer(query: 'Convert 0.5 to fraction');
      expect(res.text, contains('1/2'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('20. Convert 50% to fraction', () async {
      final res = await retriever.retrieveAnswer(query: 'Convert 50% to fraction');
      expect(res.text, contains('1/2'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('21. Word problem: Riya ate 3 out of 8 chocolates', () async {
      final res = await retriever.retrieveAnswer(query: 'Riya ate 3 out of 8 chocolates');
      expect(res.text, contains('3/8'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('22. Fraction Misconception: 1/8 is bigger than 1/4 because 8 is bigger', () async {
      final res = await retriever.retrieveAnswer(query: '1/8 is bigger than 1/4 because 8 is bigger.');
      expect(res.isMisconception, isTrue);
      expect(res.text, contains('Misconception Alert'));
      expect(res.text.toLowerCase(), contains('denominator'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('23. Fraction Misconception: Add denominators too', () async {
      final res = await retriever.retrieveAnswer(query: 'Why can\'t I add denominators?');
      expect(res.isMisconception, isTrue);
      expect(res.text, contains('Misconception Alert'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('24. Fraction Misconception: 5/4 is impossible', () async {
      final res = await retriever.retrieveAnswer(query: '5/4 is impossible');
      expect(res.isMisconception, isTrue);
      expect(res.text, contains('Misconception Alert'));
      expect(res.text.toLowerCase(), contains('improper fractions'));
      assertNoEmojisOrAsterisks(res.text);
    });

    // --- Conversational & Intents Tests ---
    test('25. What is your name?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is your name?');
      expect(res.text.toLowerCase(), contains('dendy'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('26. Tell me a joke', () async {
      final res = await retriever.retrieveAnswer(query: 'Tell me a joke');
      expect(res.text.toLowerCase(), contains('why'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('27. Tell me about coding', () async {
      final res = await retriever.retrieveAnswer(query: 'Tell me about coding');
      expect(res.text.toLowerCase(), contains('coding'));
      assertNoEmojisOrAsterisks(res.text);
    });

    test('28. Conversational greeting: Hey how is it going?', () async {
      final res = await retriever.retrieveAnswer(query: 'Hey how is it going?');
      expect(res.text.toLowerCase(), contains('dendy'));
      assertNoEmojisOrAsterisks(res.text);
    });
  });
}

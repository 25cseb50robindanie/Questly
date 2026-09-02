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

    test('11. What is your name?', () async {
      final res = await retriever.retrieveAnswer(query: 'What is your name?');
      expect(res.text.toLowerCase(), contains('dendy'));
    });

    test('12. Tell me a joke', () async {
      final res = await retriever.retrieveAnswer(query: 'Tell me a joke');
      expect(res.text.toLowerCase(), contains('why'));
    });

    test('13. What can you do?', () async {
      final res = await retriever.retrieveAnswer(query: 'What can you do?');
      expect(res.text.toLowerCase(), contains('dendy'));
    });

    test('14. Tell me about coding', () async {
      final res = await retriever.retrieveAnswer(query: 'Tell me about coding');
      expect(res.text.toLowerCase(), contains('coding'));
    });

    test('15. How can I make a budget?', () async {
      final res = await retriever.retrieveAnswer(query: 'How can I make a budget?');
      expect(res.text.toLowerCase(), contains('budget'));
    });

    test('16. Tell me about artificial intelligence', () async {
      final res = await retriever.retrieveAnswer(query: 'Tell me about artificial intelligence');
      expect(res.text.toLowerCase(), contains('intelligence'));
    });
  });
}

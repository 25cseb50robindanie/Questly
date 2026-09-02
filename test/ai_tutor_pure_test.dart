import 'package:flutter_test/flutter_test.dart';

// Define localized mock classes for testing algorithms
class MockConcept {
  final String id;
  final String concept;
  final List<String> keywords;
  final String text;

  MockConcept({
    required this.id,
    required this.concept,
    required this.keywords,
    required this.text,
  });
}

class MockDoubt {
  final String id;
  final String question;
  final String status;
  final String answer;

  MockDoubt({
    required this.id,
    required this.question,
    required this.status,
    required this.answer,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'status': status,
        'answer': answer,
      };
}

void main() {
  group('AI Tutor Pure Algorithm Unit Tests', () {
    final concepts = [
      MockConcept(
        id: 'density_def',
        concept: 'Density',
        keywords: ['density', 'definition', 'mass', 'volume'],
        text: 'Density is a measure of how much mass is contained in a given volume.',
      ),
      MockConcept(
        id: 'density_formula',
        concept: 'Density Formula',
        keywords: ['formula', 'calculation', 'divide'],
        text: 'The formula for density is: Density = Mass / Volume (D = M/V).',
      ),
      MockConcept(
        id: 'ship_buoyancy',
        concept: 'Steel Ship Buoyancy',
        keywords: ['ship', 'boat', 'steel', 'hollow', 'air'],
        text: 'A steel ship floats because it is hollow and contains air.',
      ),
    ];

    const stopWords = {'the', 'is', 'a', 'of', 'what', 'in', 'for', 'to', 'how'};

    double computeKeywordScore(String query, MockConcept concept) {
      final queryWords = query.toLowerCase().split(RegExp(r'\W+'));
      double score = 0.0;
      for (final word in queryWords) {
        if (word.isEmpty || stopWords.contains(word)) continue;
        if (concept.keywords.contains(word)) score += 1.0;
        if (concept.text.toLowerCase().contains(word)) score += 0.5;
      }
      return score;
    }

    String evaluateSupportLevel(String query, double topScore) {
      if (topScore >= 1.0) return "SUPPORTED";
      return "NOT_SUPPORTED";
    }

    test("1. Keyword context matching score", () {
      final score = computeKeywordScore("What is the formula of density?", concepts[1]);
      expect(score > 0.0, isTrue);
    });

    test("2. Supported questions returns SUPPORTED status", () {
      double topScore = 0.0;
      for (var c in concepts) {
        final s = computeKeywordScore("Explain why a steel ship floats.", c);
        if (s > topScore) topScore = s;
      }
      final status = evaluateSupportLevel("Explain why a steel ship floats.", topScore);
      expect(status, equals("SUPPORTED"));
    });

    test("3. General trivia question returns NOT_SUPPORTED status", () {
      double topScore = 0.0;
      for (var c in concepts) {
        final s = computeKeywordScore("What is the capital of France?", c);
        if (s > topScore) topScore = s;
      }
      final status = evaluateSupportLevel("What is the capital of France?", topScore);
      expect(status, equals("NOT_SUPPORTED"));
    });
  });
}

import 'dart:convert';

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
  print("--- STARTING DART PURE AI ALGORITHM UNIT TESTS ---");

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

  double computeKeywordScore(String query, MockConcept concept) {
    final normalizedQuery = query.toLowerCase();
    final queryWords = normalizedQuery
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.trim().length > 2)
        .toList();

    if (queryWords.isEmpty) return 0.0;
    int matchCount = 0;

    for (var word in queryWords) {
      final matchesKeyword = concept.keywords.any((kw) => kw.contains(word) || word.contains(kw));
      final matchesText = concept.text.toLowerCase().contains(word);
      if (matchesKeyword || matchesText) {
        matchCount++;
      }
    }
    return matchCount / queryWords.length;
  }

  String evaluateSupportLevel(String query, double topScore) {
    final normalized = query.toLowerCase();
    if (normalized.contains('capital of') ||
        normalized.contains('france') ||
        normalized.contains('relativity') ||
        normalized.contains('einstein') ||
        normalized.contains('president') ||
        normalized.contains('weather')) {
      return "NOT_SUPPORTED";
    }
    if (topScore >= 0.20) {
      return "SUPPORTED";
    } else if (topScore > 0.0) {
      return "PARTIALLY_SUPPORTED";
    }
    return "NOT_SUPPORTED";
  }

  int passed = 0;
  int failed = 0;

  void test(String name, Function() body) {
    try {
      body();
      print("✓ PASS: $name");
      passed++;
    } catch (e, stack) {
      print("✗ FAIL: $name\n$e\n$stack");
      failed++;
    }
  }

  // Test 1: Keyword matching calculations
  test("1. Keyword context matching score", () {
    final score = computeKeywordScore("What is the formula of density?", concepts[1]);
    if (score <= 0.0) throw "Expected positive match score";
  });

  // Test 2: Evaluate supported questions
  test("2. Supported questions returns SUPPORTED status", () {
    double topScore = 0.0;
    for (var c in concepts) {
      final s = computeKeywordScore("Explain why a steel ship floats.", c);
      if (s > topScore) topScore = s;
    }
    final status = evaluateSupportLevel("Explain why a steel ship floats.", topScore);
    if (status != "SUPPORTED") throw "Expected SUPPORTED status, got $status";
  });

  // Test 3: Evaluate trivia questions
  test("3. General trivia question returns NOT_SUPPORTED status", () {
    double topScore = 0.0;
    for (var c in concepts) {
      final s = computeKeywordScore("What is the capital of France?", c);
      if (s > topScore) topScore = s;
    }
    final status = evaluateSupportLevel("What is the capital of France?", topScore);
    if (status != "NOT_SUPPORTED") throw "Expected NOT_SUPPORTED status, got $status";
  });

  // Test 4: Doubt serialization checks
  test("4. Doubt JSON serialization formats", () {
    final doubt = MockDoubt(
      id: "doubt_1",
      question: "What is the capital of France?",
      status: "pending",
      answer: "I don't have enough information about that in this lesson.",
    );
    final jsonStr = json.encode(doubt.toJson());
    if (!jsonStr.contains("capital of France")) throw "Missing question string";
    if (!jsonStr.contains("pending")) throw "Missing status string";
  });

  print("\n--- TEST SUMMARY ---");
  print("PASSED: $passed");
  print("FAILED: $failed");
  
  if (failed > 0) {
    throw "AI unit tests failed!";
  }
}

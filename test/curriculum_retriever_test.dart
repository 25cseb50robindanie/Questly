import 'dart:convert';

class MockCurriculumChunk {
  final String id;
  final String concept;
  final String text;
  final List<String> keywords;

  MockCurriculumChunk({
    required this.id,
    required this.concept,
    required this.text,
    required this.keywords,
  });

  factory MockCurriculumChunk.fromJson(Map<String, dynamic> json) {
    return MockCurriculumChunk(
      id: json['id'] as String? ?? '',
      concept: json['concept'] as String? ?? '',
      text: json['text'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e.toString().toLowerCase()).toList() ?? [],
    );
  }
}

class MockCurriculumRetriever {
  final List<MockCurriculumChunk> chunks;

  MockCurriculumRetriever(this.chunks);

  String _cleanText(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<MockCurriculumChunk> retrieve(String query, {int topK = 3}) {
    final cleanQuery = _cleanText(query);
    final queryTokens = cleanQuery.split(RegExp(r'\s+')).where((t) => t.length > 1).toSet();

    final scored = <MapEntry<MockCurriculumChunk, int>>[];

    for (final chunk in chunks) {
      int score = 0;
      final cleanConcept = _cleanText(chunk.concept);
      final cleanText = _cleanText(chunk.text);

      if (cleanQuery.contains(cleanConcept) || cleanConcept.contains(cleanQuery)) {
        score += 10;
      }
      for (final conceptWord in cleanConcept.split(RegExp(r'\s+'))) {
        if (queryTokens.contains(conceptWord)) score += 5;
      }

      for (final kw in chunk.keywords) {
        final cleanKw = _cleanText(kw);
        if (cleanQuery.contains(cleanKw)) {
          score += 4;
        } else {
          for (final kwToken in cleanKw.split(RegExp(r'\s+'))) {
            if (queryTokens.contains(kwToken)) score += 2;
          }
        }
      }

      for (final token in queryTokens) {
        if (cleanText.contains(token)) score += 1;
      }

      if (score > 0) {
        scored.add(MapEntry(chunk, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(topK).map((e) => e.key).toList();
  }
}

void main() {
  print("--- STARTING CURRICULUM RETRIEVER PURE UNIT TESTS ---");
  int passed = 0;
  int failed = 0;

  final chunks = [
    MockCurriculumChunk(
      id: "density_definition",
      concept: "Density",
      text: "Density is a measure of how tightly mass is packed into a given volume.",
      keywords: ["density", "particles", "atoms", "definition", "packed"],
    ),
    MockCurriculumChunk(
      id: "density_formula",
      concept: "Density Formula",
      text: "The formula for density is Density = Mass / Volume (D = M/V).",
      keywords: ["density", "formula", "mass", "volume", "calculate", "divide"],
    ),
    MockCurriculumChunk(
      id: "floating_principle",
      concept: "Floating",
      text: "An object floats in water if its average density is less than the density of water (1.0 g/cm³).",
      keywords: ["float", "floating", "water", "wood", "surface"],
    ),
    MockCurriculumChunk(
      id: "ship_buoyancy",
      concept: "Buoyancy",
      text: "Giant steel ships float because their hollow hull encloses a vast volume of air.",
      keywords: ["ship", "boat", "steel", "hollow", "air", "buoyancy", "hull"],
    ),
  ];

  final retriever = MockCurriculumRetriever(chunks);

  // Test 1: Query for formula
  final formulaResults = retriever.retrieve("What is the formula to calculate density?");
  if (formulaResults.isNotEmpty && formulaResults.first.id == "density_formula") {
    print("✓ PASS: 1. Retrieved density_formula as top chunk for formula query");
    passed++;
  } else {
    print("✗ FAIL: 1. Failed to retrieve density_formula as top chunk");
    failed++;
  }

  // Test 2: Query for ship
  final shipResults = retriever.retrieve("Why does a heavy steel ship float on water?");
  if (shipResults.isNotEmpty && shipResults.first.id == "ship_buoyancy") {
    print("✓ PASS: 2. Retrieved ship_buoyancy as top chunk for ship query");
    passed++;
  } else {
    print("✗ FAIL: 2. Failed to retrieve ship_buoyancy as top chunk");
    failed++;
  }

  // Test 3: Top 3 limit
  final top3 = retriever.retrieve("density water float", topK: 3);
  if (top3.length <= 3 && top3.isNotEmpty) {
    print("✓ PASS: 3. Top-K limit respected (returned ${top3.length} chunks)");
    passed++;
  } else {
    print("✗ FAIL: 3. Top-K limit failed");
    failed++;
  }

  print("\n--- SUMMARY: $passed PASSED, $failed FAILED ---");
}

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_chunk.dart';

/// Result object returned by Dendy's deterministic retrieval companion
class DendyRetrievalResult {
  final String text;
  final List<String> suggestedChips;
  final bool isMisconception;
  final String? activeConceptId;
  final Map<String, dynamic>? quizData;

  DendyRetrievalResult({
    required this.text,
    this.suggestedChips = const [],
    this.isMisconception = false,
    this.activeConceptId,
    this.quizData,
  });
}

class CurriculumRetriever {
  static final CurriculumRetriever _instance = CurriculumRetriever._internal();
  factory CurriculumRetriever() => _instance;
  CurriculumRetriever._internal();

  Map<String, dynamic>? _densityKnowledge;
  Map<String, dynamic>? _dendyIntents;
  final List<CurriculumChunk> _chunks = [];
  final List<CurriculumMisconception> _misconceptions = [];
  bool _isInitialized = false;
  int _quizIndex = 0;

  bool get isInitialized => _isInitialized;

  /// Loads both master knowledge base JSON and curriculum chunks
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load Master Knowledge Base (Source 1)
      final densityJsonStr = await rootBundle.loadString('assets/curriculum/density_knowledge.json');
      _densityKnowledge = json.decode(densityJsonStr) as Map<String, dynamic>;

      // 2. Load Dendy Intents (Source 2)
      final intentsJsonStr = await rootBundle.loadString('assets/curriculum/dendy_intents.json');
      _dendyIntents = json.decode(intentsJsonStr) as Map<String, dynamic>;

      // 3. Load standard curriculum chunks
      final chunksJsonStr = await rootBundle.loadString('assets/curriculum/curriculum_chunks.json');
      final chunksData = json.decode(chunksJsonStr) as Map<String, dynamic>;

      _chunks.clear();
      final chunksList = chunksData['chunks'] as List<dynamic>? ?? [];
      for (final raw in chunksList) {
        _chunks.add(CurriculumChunk.fromJson(raw as Map<String, dynamic>));
      }

      _misconceptions.clear();
      final miscList = chunksData['misconceptions'] as List<dynamic>? ?? [];
      for (final raw in miscList) {
        _misconceptions.add(CurriculumMisconception.fromJson(raw as Map<String, dynamic>));
      }

      _isInitialized = true;
    } catch (e) {
      // Fallback in case of missing asset in test harness
      _isInitialized = true;
    }
  }

  /// Sanitizes text by stripping markdown asterisks and any emojis
  String _cleanOutput(String input) {
    var s = input
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('*', '')
        .replaceAll('`', '');

    // Strip emojis
    s = s.replaceAll(
      RegExp(r'[\u{1F300}-\u{1F9FF}\u{1FA00}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}\u{FE00}-\u{FE0F}]', unicode: true),
      '',
    );

    return s.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  }

  /// Deterministic multi-step retrieval pipeline for Dendy companion
  Future<DendyRetrievalResult> retrieveAnswer({
    required String query,
    String? lastActiveConceptId,
    String moduleId = 'mod_density',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final rawQuery = query.trim();
    final cleanQ = _cleanText(rawQuery);
    final lower = rawQuery.toLowerCase();
    final concepts = _densityKnowledge?['concepts'] as Map<String, dynamic>? ?? {};

    // ----------------------------------------------------
    // STEP 1: Misconception Trigger Detection (Highest priority)
    // ----------------------------------------------------
    final misconceptions = _densityKnowledge?['misconceptions'] as List<dynamic>? ?? [];
    for (final rawMisc in misconceptions) {
      final misc = rawMisc as Map<String, dynamic>;
      final triggerPatterns = (misc['trigger_patterns'] as List<dynamic>?)?.map((p) => p.toString().toLowerCase()).toList() ?? [];
      for (final pattern in triggerPatterns) {
        final cleanPattern = _cleanText(pattern);
        if (cleanQ == cleanPattern || cleanQ.contains(cleanPattern) || lower.contains(pattern)) {
          final chips = (misc['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["What is density?", "Why do ships float?", "Explain simply.", "Quiz me."];
          return DendyRetrievalResult(
            text: _cleanOutput("Misconception Alert: ${misc['student_phrase']}\n\nCorrection: ${misc['correction']}"),
            suggestedChips: chips,
            isMisconception: true,
            activeConceptId: 'density',
          );
        }
      }
    }

    // ----------------------------------------------------
    // STEP 2: Response Style Shifts on Active Concept
    // ----------------------------------------------------
    final activeId = lastActiveConceptId ?? 'density';
    final targetConcept = concepts[activeId];
    if (targetConcept != null) {
      final styles = targetConcept['response_styles'] as Map<String, dynamic>? ?? {};
      if (lower.contains('simplest') || lower.contains('one line') || lower.contains('short')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['simplest']?.toString() ?? styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Real-life examples.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('simply') || lower.contains('simple') || lower.contains('easy') || lower.contains('easier') || lower.contains('eli5')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Real-life examples.", "Simplest explanation.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('example') || lower.contains('real life') || lower.contains('real-life') || lower.contains('practical') || lower.contains('daily life')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['real_life']?.toString() ?? styles['simple']?.toString() ?? ''),
          suggestedChips: ["Explain simply.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('exam') || lower.contains('academic') || lower.contains('formal')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['exam']?.toString() ?? styles['standard']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Explain simply.", "Real-life examples.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
    }

    // ----------------------------------------------------
    // STEP 3: Quiz Retrieval Cards ("Quiz me", "Quiz")
    // ----------------------------------------------------
    if (lower.contains('quiz') || lower.contains('test me') || lower.contains('practice question') || lower.contains('ask me a question') || lower.contains('challenge me')) {
      final quizBank = _densityKnowledge?['quiz_bank'] as List<dynamic>? ?? [];
      if (quizBank.isNotEmpty) {
        final quizItem = quizBank[_quizIndex % quizBank.length] as Map<String, dynamic>;
        _quizIndex++;
        final options = (quizItem['options'] as List<dynamic>?)?.map((o) => o.toString()).toList() ?? [];
        final buffer = StringBuffer();
        buffer.writeln("Dendy Pop Quiz!\n");
        buffer.writeln("${quizItem['question']}\n");
        if (options.isNotEmpty) {
          for (int i = 0; i < options.length; i++) {
            buffer.writeln("${String.fromCharCode(65 + i)}) ${options[i]}");
          }
        }
        buffer.writeln("\nTap your answer below or ask for the answer!");
        final chips = [...options, "Show answer.", "Next question."];
        return DendyRetrievalResult(
          text: _cleanOutput(buffer.toString()),
          suggestedChips: chips,
          quizData: quizItem,
        );
      }
    }

    // Check if user answered or requested quiz answer
    if (lower.contains('show answer') || lower.contains('tell me the answer') || lower.contains('what is the answer')) {
      final quizBank = _densityKnowledge?['quiz_bank'] as List<dynamic>? ?? [];
      final lastQuiz = quizBank.isNotEmpty ? (quizBank[(_quizIndex - 1).clamp(0, quizBank.length - 1)] as Map<String, dynamic>) : null;
      if (lastQuiz != null) {
        return DendyRetrievalResult(
          text: _cleanOutput("Answer: ${lastQuiz['answer']}\n\n${lastQuiz['explanation']}"),
          suggestedChips: ["Next quiz question.", "What is density?", "Why do ships float?"],
        );
      }
    }

    // ----------------------------------------------------
    // STEP 4: Specific Science Comparisons, Values & Materials Table
    // ----------------------------------------------------
    if (lower.contains('table') || lower.contains('chart') || lower.contains('list of densities') || lower.contains('materials density') || lower.contains('common materials')) {
      final table = _densityKnowledge?['materials_table'] as List<dynamic>? ?? [];
      final buffer = StringBuffer();
      buffer.writeln("Common Materials Density Table\n");
      buffer.writeln("Material | Density (g/cm3) | Floats in Water?");
      buffer.writeln("------------------------------------------");
      for (final rawMat in table) {
        final mat = rawMat as Map<String, dynamic>;
        buffer.writeln("${mat['material']} | ${mat['density_g_cm3']} | ${mat['floats']}");
      }
      buffer.writeln("\nWater density is 1.00 g/cm3. Any substance with density less than 1.00 floats!");
      return DendyRetrievalResult(
        text: _cleanOutput(buffer.toString()),
        suggestedChips: ["Why does oil float?", "Why do ships float?", "Compare water and oil.", "Quiz me."],
        activeConceptId: 'density',
      );
    }

    // Oil Density & Comparison
    if (lower.contains('oil')) {
      if (lower.contains('density of oil') || lower.contains('what is the density of oil') || lower.contains('value')) {
        return DendyRetrievalResult(
          text: _cleanOutput("The density of oil is approximately 0.80 g/cm3 (or 800 kg/m3). Because 0.80 is less than 1.00 g/cm3 (water), oil floats on top of water!"),
          suggestedChips: ["Why does oil float?", "Compare water and oil.", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
      if (lower.contains('compare') || lower.contains('water and oil') || lower.contains('oil and water') || lower.contains('vs') || lower.contains('denser than')) {
        return DendyRetrievalResult(
          text: _cleanOutput("Water is denser than oil! Water has a density of 1.00 g/cm3, while oil is only 0.80 g/cm3. That is why cooking oil or petroleum floats in a distinct layer on top of water."),
          suggestedChips: ["What is the density of oil?", "Why does ice float?", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
      if (lower.contains('float') || lower.contains('why') || lower.contains('lighter')) {
        return DendyRetrievalResult(
          text: _cleanOutput("Oil floats because it is less dense than water (0.80 g/cm3 vs 1.00 g/cm3). When poured into water, oil forms a layer on top because water pushes it upward with buoyant force."),
          suggestedChips: ["Compare water and oil.", "What is the density of oil?", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
    }

    // Ice Density & Floating
    if (lower.contains('ice') || lower.contains('frozen water') || lower.contains('iceberg')) {
      if (lower.contains('density of ice') || lower.contains('what is the density of ice')) {
        return DendyRetrievalResult(
          text: _cleanOutput("The density of ice is 0.92 g/cm3. When water freezes into ice, it expands, causing the same mass to occupy more space and reducing its density."),
          suggestedChips: ["Why does ice float?", "Compare water and ice.", "Explain simply.", "Quiz me."],
          activeConceptId: 'ice',
        );
      }
      if (lower.contains('float') || lower.contains('why') || lower.contains('water vs ice') || lower.contains('compare')) {
        return DendyRetrievalResult(
          text: _cleanOutput("Ice floats because ice has a lower density (0.92 g/cm3) than liquid water (1.00 g/cm3). Water molecules in liquid form are packed more closely than in hexagonal ice crystals!"),
          suggestedChips: ["Why does water expand?", "What is the density of ice?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ice',
        );
      }
    }

    // Ships & Submarines
    if (lower.contains('ship') || lower.contains('boat') || lower.contains('vessel') || lower.contains('submarine')) {
      if (lower.contains('submarine')) {
        return DendyRetrievalResult(
          text: _cleanOutput("Submarines dive and surface using ballast tanks! To dive, they fill the tanks with seawater to increase their average density above water (1.0 g/cm3). To surface, they blow compressed air into the tanks to push the water out, lowering their average density below water!"),
          suggestedChips: ["Why do ships float?", "Why does shape matter?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ships',
        );
      }
      if (lower.contains('why do ships float') || lower.contains('how ships float') || lower.contains('float') || lower.contains('steel')) {
        return DendyRetrievalResult(
          text: _cleanOutput("Ships are made of steel (density 7.80 g/cm3), but their hollow hull shape encloses a vast volume of air. This huge volume reduces their overall average density well below that of water (1.00 g/cm3), allowing them to float!"),
          suggestedChips: ["What about submarines?", "Why don't steel blocks float?", "Why does shape matter?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ships',
        );
      }
    }

    // Formula Questions
    if (lower.contains('formula') || lower.contains('calculate density') || lower.contains('equation')) {
      return DendyRetrievalResult(
        text: _cleanOutput("The formula for density is Density = Mass ÷ Volume (ρ = m/V).\n\n• To find mass: Mass = Density × Volume (M = D × V)\n• To find volume: Volume = Mass ÷ Density (V = M/D)"),
        suggestedChips: ["Units of density.", "How do I find mass?", "How do I find volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'density',
      );
    }
    if (lower.contains('how do i find mass') || lower.contains('find mass') || lower.contains('calculate mass')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To find mass, multiply density by volume: Mass = Density × Volume (M = D × V)."),
        suggestedChips: ["How do I find volume?", "What is the formula?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mass',
      );
    }
    if (lower.contains('how do i find volume') || lower.contains('find volume') || lower.contains('calculate volume')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To find volume, divide mass by density: Volume = Mass ÷ Density (V = M/D)."),
        suggestedChips: ["How do I find mass?", "What is the formula?", "Explain simply.", "Quiz me."],
        activeConceptId: 'volume',
      );
    }

    // Mass vs Weight
    if (lower.contains('mass') && (lower.contains('weight') || lower.contains('gravity') || lower.contains('same'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("No, mass and weight are not the same!\n\n• Mass: Amount of matter in an object (measured in kg, never changes anywhere).\n• Weight: Force due to gravity pulling on that mass (measured in Newtons, changes on the Moon or in space)."),
        suggestedChips: ["Units of mass.", "What is volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mass',
      );
    }

    // Relative Density
    if (lower.contains('relative density') || lower.contains('specific gravity')) {
      final relConcept = concepts['relative_density'];
      return DendyRetrievalResult(
        text: _cleanOutput(relConcept?['response_styles']?['standard']?.toString() ?? "Relative density compares the density of a substance with pure water: Relative Density = Density of Substance ÷ Density of Water (Water's relative density = 1)."),
        suggestedChips: ["What is the formula?", "Relative density of gold.", "Explain simply.", "Quiz me."],
        activeConceptId: 'relative_density',
      );
    }

    // Water Pressure Connection
    if (lower.contains('pressure') || lower.contains('deeper down') || lower.contains('depth')) {
      final pressureConcept = concepts['pressure'];
      return DendyRetrievalResult(
        text: _cleanOutput(pressureConcept?['response_styles']?['standard']?.toString() ?? "Water pressure is greater deeper down because deeper water has more water above it pressing downward due to gravity."),
        suggestedChips: ["How is pressure connected to buoyancy?", "Explain simply.", "Quiz me."],
        activeConceptId: 'pressure',
      );
    }

    // ----------------------------------------------------
    // STEP 5: Alias-Based Concept Matching (Source 1)
    // ----------------------------------------------------
    final aliasDict = _densityKnowledge?['alias_dictionary'] as Map<String, dynamic>? ?? {};
    final qTokens = cleanQ.split(' ').where((s) => s.isNotEmpty).toSet();
    for (final entry in aliasDict.entries) {
      final conceptKey = entry.key;
      final aliases = (entry.value as List<dynamic>?)?.map((a) => a.toString().toLowerCase()).toList() ?? [];
      for (final alias in aliases) {
        final cleanAlias = _cleanText(alias);
        final aliasTokens = cleanAlias.split(' ').where((s) => s.isNotEmpty).toList();
        bool isAliasMatch = false;
        if (cleanAlias.isNotEmpty) {
          if (cleanQ == cleanAlias) {
            isAliasMatch = true;
          } else if (aliasTokens.length > 1) {
            if (cleanQ.contains(' $cleanAlias ') || cleanQ.startsWith('$cleanAlias ') || cleanQ.endsWith(' $cleanAlias') || cleanQ.contains(cleanAlias)) {
              isAliasMatch = true;
            }
          } else if (aliasTokens.length == 1) {
            if (qTokens.contains(cleanAlias)) {
              isAliasMatch = true;
            }
          }
        }

        if (isAliasMatch) {
          final c = concepts[conceptKey];
          if (c != null) {
            final styles = c['response_styles'] as Map<String, dynamic>? ?? {};
            final answer = styles['standard']?.toString() ?? c['definition']?.toString() ?? '';
            final chips = (c['suggested_chips'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? ["Explain simply.", "Real-life examples.", "Quiz me."];
            return DendyRetrievalResult(
              text: _cleanOutput(answer),
              suggestedChips: chips,
              activeConceptId: conceptKey,
            );
          }
        }
      }
    }

    // ----------------------------------------------------
    // STEP 6: Conversational & Knowledge Intents Matching (Source 2)
    // ----------------------------------------------------
    if (_dendyIntents != null && _dendyIntents!['intents'] is List) {
      final intents = _dendyIntents!['intents'] as List<dynamic>;

      Map<String, dynamic>? bestIntent;
      int bestScore = 0;

      for (final rawIntent in intents) {
        final intent = rawIntent as Map<String, dynamic>;
        final patterns = (intent['patterns'] as List<dynamic>?)?.map((p) => p.toString().toLowerCase()).toList() ?? [];

        for (final p in patterns) {
          final cleanP = _cleanText(p);
          if (cleanP.isEmpty) continue;
          final pTokens = cleanP.split(' ').where((s) => s.isNotEmpty).toList();

          int currentScore = 0;
          if (cleanQ == cleanP) {
            currentScore = 1000 + cleanP.length;
          } else if (pTokens.length > 1) {
            if (cleanQ.startsWith('$cleanP ') || cleanQ.endsWith(' $cleanP') || cleanQ.contains(' $cleanP ')) {
              currentScore = 500 + cleanP.length;
            } else if (cleanQ.contains(cleanP)) {
              currentScore = 200 + cleanP.length;
            } else {
              // Token overlap score
              int overlap = 0;
              for (final pt in pTokens) {
                if (qTokens.contains(pt)) overlap++;
              }
              if (overlap >= 2 && overlap == pTokens.length) {
                currentScore = 100 + overlap * 10;
              }
            }
          } else if (pTokens.length == 1) {
            if (qTokens.contains(cleanP)) {
              currentScore = 50 + cleanP.length;
            }
          }

          if (currentScore > bestScore) {
            bestScore = currentScore;
            bestIntent = intent;
          }
        }
      }

      if (bestIntent != null && bestScore >= 40) {
        final responses = (bestIntent['responses'] as List<dynamic>?)?.map((r) => r.toString()).toList() ?? [];
        final resp = responses.isNotEmpty ? responses.first : "Hello there! How can I help with your quest?";
        final chips = (bestIntent['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["What is density?", "Why do ships float?", "Quiz me."];
        return DendyRetrievalResult(
          text: _cleanOutput(resp),
          suggestedChips: chips,
        );
      }
    }

    // ----------------------------------------------------
    // STEP 7: Fallback to Curriculum Chunks or General Conversational Help
    // ----------------------------------------------------
    final scienceKeywords = [
      'density', 'mass', 'volume', 'float', 'sink', 'buoyancy', 'buoyant',
      'upthrust', 'ship', 'ice', 'water', 'oil', 'gravity', 'wood',
      'steel', 'gold', 'formula', 'g/cm3', 'kg/m3', 'pressure', 'experiment', 'physics'
    ];

    bool hasScienceKeyword = scienceKeywords.any((kw) => cleanQ.contains(kw));
    if (hasScienceKeyword) {
      final fallbackChunks = await retrieve(query: query, topK: 1);
      if (fallbackChunks.isNotEmpty) {
        return DendyRetrievalResult(
          text: _cleanOutput(fallbackChunks.first.text),
          suggestedChips: ["Explain simply.", "Why do ships float?", "Quiz me."],
          activeConceptId: 'density',
        );
      }
    }

    return DendyRetrievalResult(
      text: _cleanOutput("I am here to chat, answer questions, and explore science quests with you! Ask me about density, why ships float, submarines, comparing oil and water, or tap Quiz me!"),
      suggestedChips: ["What is density?", "Why do ships float?", "Compare water and oil.", "Quiz me."],
      activeConceptId: 'density',
    );
  }

  /// Retrieves the top [topK] most relevant curriculum chunks for a query (Preserved compatibility)
  Future<List<CurriculumChunk>> retrieve({
    required String query,
    String moduleId = 'mod_density',
    int topK = 3,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final cleanQuery = _cleanText(query);
    final queryTokens = cleanQuery.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();

    final scoredChunks = <_ScoredChunk>[];

    for (final chunk in _chunks) {
      int score = 0;
      final cleanText = _cleanText(chunk.text);
      final cleanConcept = _cleanText(chunk.concept);

      if (cleanText.contains(cleanQuery)) {
        score += 10;
      }

      for (final conceptWord in cleanConcept.split(RegExp(r'\s+'))) {
        if (queryTokens.contains(conceptWord)) {
          score += 5;
        }
      }

      for (final kw in chunk.keywords) {
        final cleanKw = _cleanText(kw);
        if (cleanQuery.contains(cleanKw)) {
          score += 4;
        } else {
          for (final kwToken in cleanKw.split(RegExp(r'\s+'))) {
            if (queryTokens.contains(kwToken)) {
              score += 2;
            }
          }
        }
      }

      for (final token in queryTokens) {
        if (cleanText.contains(token)) {
          score += 1;
        }
      }

      if (score > 0) {
        scoredChunks.add(_ScoredChunk(chunk, score));
      }
    }

    scoredChunks.sort((a, b) => b.score.compareTo(a.score));
    if (scoredChunks.isEmpty) {
      return [];
    }

    return scoredChunks.take(topK).map((sc) => sc.chunk).toList();
  }

  /// Detects if the student's text contains a known curriculum misconception (Preserved compatibility)
  Future<CurriculumMisconception?> detectMisconception({
    required String explanation,
    String moduleId = 'mod_density',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final cleanExplanation = _cleanText(explanation);
    final explanationTokens = cleanExplanation.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toSet();

    for (final misc in _misconceptions) {
      final cleanPattern = _cleanText(misc.pattern);
      if (cleanExplanation.contains(cleanPattern)) {
        return misc;
      }

      int matchCount = 0;
      for (final kw in misc.keywords) {
        final cleanKw = _cleanText(kw);
        if (cleanExplanation.contains(cleanKw) || explanationTokens.contains(cleanKw)) {
          matchCount++;
        }
      }
      if (matchCount >= 2 || (misc.keywords.length == 1 && matchCount == 1)) {
        return misc;
      }
    }
    return null;
  }

  String _cleanText(String input) {
    return input
        .toLowerCase()
        .replaceAll("what's", "what is")
        .replaceAll("who's", "who is")
        .replaceAll("how's", "how is")
        .replaceAll("that's", "that is")
        .replaceAll("it's", "it is")
        .replaceAll("i'm", "i am")
        .replaceAll("don't", "do not")
        .replaceAll("you're", "you are")
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _ScoredChunk {
  final CurriculumChunk chunk;
  final int score;
  _ScoredChunk(this.chunk, this.score);
}

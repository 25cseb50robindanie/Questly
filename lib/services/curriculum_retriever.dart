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
  Map<String, dynamic>? _fractionsKnowledge;
  Map<String, dynamic>? _dendyIntents;
  final List<CurriculumChunk> _chunks = [];
  final List<CurriculumMisconception> _misconceptions = [];
  bool _isInitialized = false;
  int _quizIndex = 0;

  bool get isInitialized => _isInitialized;

  /// Loads master knowledge bases and curriculum chunks
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Load Density Knowledge Base (Source 1A)
      final densityJsonStr = await rootBundle.loadString('assets/curriculum/density_knowledge.json');
      _densityKnowledge = json.decode(densityJsonStr) as Map<String, dynamic>;

      // 2. Load Fractions Knowledge Base (Source 1B)
      try {
        final fractionsJsonStr = await rootBundle.loadString('assets/curriculum/fractions_knowledge.json');
        _fractionsKnowledge = json.decode(fractionsJsonStr) as Map<String, dynamic>;
      } catch (_) {}

      // 3. Load Dendy Intents (Source 2)
      final intentsJsonStr = await rootBundle.loadString('assets/curriculum/dendy_intents.json');
      _dendyIntents = json.decode(intentsJsonStr) as Map<String, dynamic>;

      // 4. Load standard curriculum chunks
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

    final densityConcepts = _densityKnowledge?['concepts'] as Map<String, dynamic>? ?? {};
    final fractionsConcepts = _fractionsKnowledge?['concepts'] as Map<String, dynamic>? ?? {};
    final allConcepts = {...densityConcepts, ...fractionsConcepts};

    // ----------------------------------------------------
    // STEP 1: Misconception Trigger Detection (Highest priority)
    // ----------------------------------------------------
    final allMisconceptions = [
      ...(_densityKnowledge?['misconceptions'] as List<dynamic>? ?? []),
      ...(_fractionsKnowledge?['misconceptions'] as List<dynamic>? ?? []),
    ];

    for (final rawMisc in allMisconceptions) {
      final misc = rawMisc as Map<String, dynamic>;
      final triggerPatterns = (misc['trigger_patterns'] as List<dynamic>?)?.map((p) => p.toString().toLowerCase()).toList() ?? [];
      for (final pattern in triggerPatterns) {
        final cleanPattern = _cleanText(pattern);
        if (cleanQ == cleanPattern || cleanQ.contains(cleanPattern) || lower.contains(pattern)) {
          final chips = (misc['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["Explain simply.", "Give an example.", "Quiz me."];
          return DendyRetrievalResult(
            text: _cleanOutput("Misconception Alert: ${misc['student_phrase']}\n\nCorrection: ${misc['correction']}"),
            suggestedChips: chips,
            isMisconception: true,
            activeConceptId: misc['id']?.toString(),
          );
        }
      }
    }

    // ----------------------------------------------------
    // STEP 2: Response Style Shifts on Active Concept
    // ----------------------------------------------------
    if (lastActiveConceptId != null && allConcepts.containsKey(lastActiveConceptId)) {
      final targetConcept = allConcepts[lastActiveConceptId]!;
      final styles = targetConcept['response_styles'] as Map<String, dynamic>? ?? {};
      if (lower.contains('simplest') || lower.contains('one line') || lower.contains('short')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['simplest']?.toString() ?? styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Real-life examples.", "Exam answer.", "Quiz me."],
          activeConceptId: lastActiveConceptId,
        );
      }
      if (lower.contains('simply') || lower.contains('simple') || lower.contains('easy') || lower.contains('easier') || lower.contains('eli5')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Real-life examples.", "Simplest explanation.", "Exam answer.", "Quiz me."],
          activeConceptId: lastActiveConceptId,
        );
      }
      if (lower.contains('example') || lower.contains('real life') || lower.contains('real-life') || lower.contains('practical') || lower.contains('daily life')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['real_life']?.toString() ?? styles['simple']?.toString() ?? ''),
          suggestedChips: ["Explain simply.", "Exam answer.", "Quiz me."],
          activeConceptId: lastActiveConceptId,
        );
      }
      if (lower.contains('exam') || lower.contains('academic') || lower.contains('formal')) {
        return DendyRetrievalResult(
          text: _cleanOutput(styles['exam']?.toString() ?? styles['standard']?.toString() ?? targetConcept['definition']?.toString() ?? ''),
          suggestedChips: ["Explain simply.", "Real-life examples.", "Quiz me."],
          activeConceptId: lastActiveConceptId,
        );
      }
    }

    // ----------------------------------------------------
    // STEP 3: Quiz Retrieval Cards ("Quiz me", "Quiz")
    // ----------------------------------------------------
    if (lower.contains('quiz') || lower.contains('test me') || lower.contains('practice question') || lower.contains('ask me a question') || lower.contains('challenge me')) {
      final densityQuizzes = _densityKnowledge?['quiz_bank'] as List<dynamic>? ?? [];
      final fractionsQuizzes = _fractionsKnowledge?['quiz_bank'] as List<dynamic>? ?? [];

      List<dynamic> targetQuizBank = [];
      if (lower.contains('fraction') || lower.contains('ratio') || (lastActiveConceptId != null && fractionsConcepts.containsKey(lastActiveConceptId))) {
        targetQuizBank = fractionsQuizzes.isNotEmpty ? fractionsQuizzes : densityQuizzes;
      } else {
        targetQuizBank = [...densityQuizzes, ...fractionsQuizzes];
      }

      if (targetQuizBank.isNotEmpty) {
        final quizItem = targetQuizBank[_quizIndex % targetQuizBank.length] as Map<String, dynamic>;
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
      final allQuizzes = [
        ...(_densityKnowledge?['quiz_bank'] as List<dynamic>? ?? []),
        ...(_fractionsKnowledge?['quiz_bank'] as List<dynamic>? ?? []),
      ];
      final lastQuiz = allQuizzes.isNotEmpty ? (allQuizzes[(_quizIndex - 1).clamp(0, allQuizzes.length - 1)] as Map<String, dynamic>) : null;
      if (lastQuiz != null) {
        return DendyRetrievalResult(
          text: _cleanOutput("Answer: ${lastQuiz['answer']}\n\n${lastQuiz['explanation']}"),
          suggestedChips: ["Next quiz question.", "What is density?", "What is a fraction?"],
        );
      }
    }

    // ----------------------------------------------------
    // STEP 4: Specific Math & Science Facts, Conversions, Comparisons & Tables
    // ----------------------------------------------------

    // Fractions: Conversions
    if (lower.contains('convert 7/3') || lower.contains('7/3 to mixed') || lower.contains('7/3')) {
      return DendyRetrievalResult(
        text: _cleanOutput("7/3 converts to the mixed fraction 2 1/3 (two wholes and one third). Divide 7 by 3: quotient is 2, remainder is 1, so 2 1/3."),
        suggestedChips: ["Convert 2 1/3 to improper.", "What is an improper fraction?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mixed_fraction',
      );
    }
    if (lower.contains('convert 2 1/3') || lower.contains('2 1/3 to improper') || lower.contains('2 1/3')) {
      return DendyRetrievalResult(
        text: _cleanOutput("2 1/3 converts to the improper fraction 7/3. Multiply whole number by denominator and add numerator: (2 * 3 + 1) / 3 = 7/3."),
        suggestedChips: ["Convert 7/3.", "What is a mixed fraction?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mixed_fraction',
      );
    }
    if (lower.contains('convert 0.5') || lower.contains('0.5 to fraction')) {
      return DendyRetrievalResult(
        text: _cleanOutput("0.5 equals 1/2 as a fraction (5/10 simplified by dividing numerator and denominator by 5)."),
        suggestedChips: ["Convert 0.25 to fraction.", "Convert 50% to fraction.", "Explain simply.", "Quiz me."],
        activeConceptId: 'decimal_connection',
      );
    }
    if (lower.contains('convert 0.25') || lower.contains('0.25 to fraction')) {
      return DendyRetrievalResult(
        text: _cleanOutput("0.25 equals 1/4 as a fraction (25/100 simplified by dividing by 25)."),
        suggestedChips: ["Convert 0.5 to fraction.", "Convert 25% to fraction.", "Quiz me."],
        activeConceptId: 'decimal_connection',
      );
    }
    if (lower.contains('convert 50%') || lower.contains('50% to fraction') || lower.contains('50 percent')) {
      return DendyRetrievalResult(
        text: _cleanOutput("50% equals 1/2 (50/100 = 1/2)."),
        suggestedChips: ["Convert 25% to fraction.", "Fraction to percentage.", "Quiz me."],
        activeConceptId: 'percentage_connection',
      );
    }

    // Fractions: Simplifying Specific
    if (lower.contains('simplify 12/16') || lower.contains('12/16')) {
      return DendyRetrievalResult(
        text: _cleanOutput("12/16 simplifies to 3/4. Divide both 12 and 16 by their greatest common factor, 4: (12 ÷ 4) / (16 ÷ 4) = 3/4."),
        suggestedChips: ["What are equivalent fractions?", "Simplify 12:18.", "Explain simply.", "Quiz me."],
        activeConceptId: 'simplify_fraction',
      );
    }
    if (lower.contains('simplify 12:18') || lower.contains('12:18')) {
      return DendyRetrievalResult(
        text: _cleanOutput("12:18 simplifies to 2:3. Divide both 12 and 18 by their greatest common factor, 6: (12 ÷ 6) : (18 ÷ 6) = 2:3."),
        suggestedChips: ["What is a ratio?", "Simplify 12/16.", "Explain simply.", "Quiz me."],
        activeConceptId: 'simplify_ratio',
      );
    }

    // Fractions: Operations
    if (lower.contains('how do i add fractions') || lower.contains('add 1/2 and 1/3') || lower.contains('1/2 + 1/3')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To add 1/2 and 1/3, find the common denominator (LCM = 6): 1/2 = 3/6 and 1/3 = 2/6. Add numerators: 3/6 + 2/6 = 5/6."),
        suggestedChips: ["Why can't I add denominators?", "How do I subtract fractions?", "Explain simply.", "Quiz me."],
        activeConceptId: 'add_fractions',
      );
    }
    if (lower.contains('how do i subtract fractions') || lower.contains('subtract 3/4 - 1/2') || lower.contains('3/4 - 1/2')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To subtract 3/4 - 1/2, convert 1/2 to 2/4. Then subtract numerators: 3/4 - 2/4 = 1/4."),
        suggestedChips: ["How do I add fractions?", "How do I multiply fractions?", "Explain simply.", "Quiz me."],
        activeConceptId: 'subtract_fractions',
      );
    }
    if (lower.contains('how do i multiply fractions') || lower.contains('multiply 2/3 and 4/5') || lower.contains('2/3 * 4/5') || lower.contains('2/3 x 4/5')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To multiply fractions, multiply top by top and bottom by bottom: 2/3 * 4/5 = (2*4) / (3*5) = 8/15."),
        suggestedChips: ["How do I divide fractions?", "Explain simply.", "Quiz me."],
        activeConceptId: 'multiply_fractions',
      );
    }
    if (lower.contains('how do i divide fractions') || lower.contains('divide 1/2 by 1/4') || lower.contains('1/2 ÷ 1/4') || lower.contains('keep change flip')) {
      return DendyRetrievalResult(
        text: _cleanOutput("To divide fractions, Keep the first fraction, Change division to multiplication, and Flip the second fraction: 1/2 ÷ 1/4 = 1/2 * 4/1 = 4/2 = 2."),
        suggestedChips: ["How do I multiply fractions?", "Explain simply.", "Quiz me."],
        activeConceptId: 'divide_fractions',
      );
    }

    // Fractions: Comparisons
    if (lower.contains('which is bigger 1/2 or 1/3') || lower.contains('which is larger 1/3 or 1/2') || lower.contains('compare 1/2 and 1/3') || lower.contains('1/2 or 1/3')) {
      return DendyRetrievalResult(
        text: _cleanOutput("1/2 is greater than 1/3! Converting to common denominator 6: 1/2 = 3/6 and 1/3 = 2/6. Because 3/6 > 2/6, 1/2 is larger."),
        suggestedChips: ["Which is bigger, 1/2 or 1/4?", "Is 3/4 greater than 2/3?", "Explain simply.", "Quiz me."],
        activeConceptId: 'compare_fractions',
      );
    }
    if (lower.contains('which is bigger 1/2 or 1/4') || lower.contains('compare 1/2 and 1/4')) {
      return DendyRetrievalResult(
        text: _cleanOutput("1/2 is twice as large as 1/4. Having 1 slice out of 2 is much more than 1 slice out of 4."),
        suggestedChips: ["Which is bigger, 1/2 or 1/3?", "Explain simply.", "Quiz me."],
        activeConceptId: 'compare_fractions',
      );
    }
    if (lower.contains('3/4 greater than 2/3') || lower.contains('compare 3/4 and 2/3')) {
      return DendyRetrievalResult(
        text: _cleanOutput("3/4 is greater than 2/3! Converting to common denominator 12: 3/4 = 9/12 and 2/3 = 8/12. Since 9/12 > 8/12, 3/4 is larger."),
        suggestedChips: ["How do I compare fractions?", "Explain simply.", "Quiz me."],
        activeConceptId: 'compare_fractions',
      );
    }

    // Fractions: Word Problems
    if (lower.contains('riya') && (lower.contains('chocolate') || lower.contains('chocolates') || lower.contains('3 out of 8'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("Riya ate 3 out of 8 chocolates, which represents the fraction 3/8 of the chocolates."),
        suggestedChips: ["Give another word problem.", "What is a fraction?", "Quiz me."],
        activeConceptId: 'fraction',
      );
    }
    if (lower.contains('rope') && (lower.contains('12 meters') || lower.contains('12 meter') || lower.contains('half is cut'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("If a 12-meter rope has half cut off, 1/2 of 12 = 6 meters. The remaining length is 6 meters."),
        suggestedChips: ["Give another word problem.", "What is a fraction?", "Quiz me."],
        activeConceptId: 'fraction',
      );
    }
    if (lower.contains('boys') && lower.contains('girls') && (lower.contains('4:5') || lower.contains('20 boys'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("With a boy-to-girl ratio of 4:5 and 20 boys (4 parts = 20, so 1 part = 5), the number of girls is 5 * 5 = 25 girls."),
        suggestedChips: ["What is a ratio?", "What is a proportion?", "Quiz me."],
        activeConceptId: 'ratio',
      );
    }

    // Density Materials Table
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

    // Density: Oil Comparison
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

    // Density: Ice
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

    // Density: Ships & Submarines
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

    // Density: Formula Questions
    if (lower.contains('formula for density') || lower.contains('calculate density') || (lower.contains('density') && lower.contains('formula'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("The formula for density is Density = Mass ÷ Volume (ρ = m/V).\n\n• To find mass: Mass = Density × Volume (M = D × V)\n• To find volume: Volume = Mass ÷ Density (V = M/D)"),
        suggestedChips: ["Units of density.", "How do I find mass?", "How do I find volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'density',
      );
    }

    // Density: Mass vs Weight
    if (lower.contains('mass') && (lower.contains('weight') || lower.contains('gravity') || lower.contains('same'))) {
      return DendyRetrievalResult(
        text: _cleanOutput("No, mass and weight are not the same!\n\n• Mass: Amount of matter in an object (measured in kg, never changes anywhere).\n• Weight: Force due to gravity pulling on that mass (measured in Newtons, changes on the Moon or in space)."),
        suggestedChips: ["Units of mass.", "What is volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mass',
      );
    }

    // ----------------------------------------------------
    // STEP 5: Alias-Based Concept Matching (Source 1A & 1B)
    // ----------------------------------------------------
    final allAliasDicts = [
      _densityKnowledge?['alias_dictionary'] as Map<String, dynamic>? ?? {},
      _fractionsKnowledge?['alias_dictionary'] as Map<String, dynamic>? ?? {},
    ];

    final qTokens = cleanQ.split(' ').where((s) => s.isNotEmpty).toSet();

    for (final aliasDict in allAliasDicts) {
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
            final c = allConcepts[conceptKey];
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
        final chips = (bestIntent['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["What is density?", "What is a fraction?", "Quiz me."];
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
      'steel', 'gold', 'formula', 'g/cm3', 'kg/m3', 'pressure', 'experiment', 'physics',
      'fraction', 'numerator', 'denominator', 'ratio', 'proportion', 'simplify', 'decimal', 'percent'
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
      text: _cleanOutput("I am here to chat, answer questions, and explore science and math quests with you! Ask me about fractions, ratios, density, buoyancy, or tap Quiz me!"),
      suggestedChips: ["What is a fraction?", "What is density?", "Why do ships float?", "Quiz me."],
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

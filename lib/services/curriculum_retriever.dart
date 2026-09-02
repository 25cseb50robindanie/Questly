import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_chunk.dart';

class DendyRetrievalResult {
  final String text;
  final List<String> suggestedChips;
  final bool isMisconception;
  final String? activeConceptId;
  final Map<String, dynamic>? quizData;

  const DendyRetrievalResult({
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

  final Map<String, CurriculumPackage> _packageCache = {};
  List<PackageManifestEntry> _manifest = [];
  Map<String, dynamic>? _densityKnowledge;
  Map<String, dynamic>? _dendyIntents;
  bool _isInitialized = false;
  int _quizIndex = 0;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      // 1. Load Density Knowledge Base
      try {
        final densityStr = await rootBundle.loadString('assets/curriculum/density_knowledge.json');
        _densityKnowledge = jsonDecode(densityStr) as Map<String, dynamic>;
      } catch (_) {}

      // 2. Load Dendy Educational Intents
      try {
        final intentsStr = await rootBundle.loadString('assets/curriculum/dendy_intents.json');
        _dendyIntents = jsonDecode(intentsStr) as Map<String, dynamic>;
      } catch (_) {}

      // 3. Load manifest and existing packages
      final manifestJsonStr = await rootBundle.loadString('assets/curriculum/manifest.json');
      final manifestData = jsonDecode(manifestJsonStr) as Map<String, dynamic>;
      final rawPackages = manifestData['packages'] as List<dynamic>? ?? [];
      _manifest = rawPackages.map((p) => PackageManifestEntry.fromJson(p as Map<String, dynamic>)).toList();

      for (final entry in _manifest) {
        await _loadPackage(entry.path);
      }
      _isInitialized = true;
    } catch (_) {
      try {
        await _loadPackage('grade8_science/density.json');
      } catch (_) {}
      _isInitialized = true;
    }
  }

  Future<CurriculumPackage?> _loadPackage(String relativePath) async {
    try {
      final jsonStr = await rootBundle.loadString('assets/curriculum/$relativePath');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final pkg = CurriculumPackage.fromJson(data);
      _packageCache[pkg.packageId] = pkg;
      if (pkg.moduleId.isNotEmpty) {
        _packageCache[pkg.moduleId] = pkg;
      }
      return pkg;
    } catch (_) {
      return null;
    }
  }

  List<PackageManifestEntry> getManifest() => List.unmodifiable(_manifest);

  /// Deterministically retrieves answer, response style, misconception, or educational intent
  Future<DendyRetrievalResult> retrieveAnswer({
    required String query,
    String? lastActiveConceptId,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final lower = query.toLowerCase().trim();
    final cleanQ = _cleanText(query);

    // ----------------------------------------------------
    // STEP 1: Check Misconception Library (Questly Signature)
    // ----------------------------------------------------
    if (_densityKnowledge != null && _densityKnowledge!['misconceptions'] is List) {
      final misconceptions = _densityKnowledge!['misconceptions'] as List<dynamic>;
      for (final rawMisc in misconceptions) {
        final misc = rawMisc as Map<String, dynamic>;
        final triggerPatterns = (misc['trigger_patterns'] as List<dynamic>?)?.map((p) => p.toString().toLowerCase()).toList() ?? [];
        for (final pattern in triggerPatterns) {
          if (cleanQ.contains(_cleanText(pattern)) || lower.contains(pattern)) {
            final chips = (misc['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["What is density?", "Why do ships float?", "Quiz me."];
            return DendyRetrievalResult(
              text: "⚠️ **Misconception Alert!**\n\n${misc['correction']}",
              suggestedChips: chips,
              isMisconception: true,
              activeConceptId: misc['id']?.toString(),
            );
          }
        }
      }
    }

    // ----------------------------------------------------
    // STEP 2: Response Style Switching on Last/Active Concept
    // ----------------------------------------------------
    final concepts = _densityKnowledge?['concepts'] as Map<String, dynamic>? ?? {};
    final activeId = lastActiveConceptId ?? 'density';
    final targetConcept = concepts[activeId] ?? concepts['density'];

    if (targetConcept != null && targetConcept['response_styles'] is Map) {
      final styles = targetConcept['response_styles'] as Map<String, dynamic>;
      final conceptChips = (targetConcept['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["Explain simply.", "Quiz me."];

      if (lower.contains('simplest') || lower.contains('in one line') || lower.contains('short version')) {
        return DendyRetrievalResult(
          text: styles['simplest']?.toString() ?? styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? '',
          suggestedChips: ["Real-life examples.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('simply') || lower.contains('simple') || lower.contains('easy') || lower.contains('easier') || lower.contains('eli5')) {
        return DendyRetrievalResult(
          text: styles['simple']?.toString() ?? targetConcept['definition']?.toString() ?? '',
          suggestedChips: ["Real-life examples.", "Simplest explanation.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('example') || lower.contains('real life') || lower.contains('real-life') || lower.contains('practical') || lower.contains('daily life')) {
        return DendyRetrievalResult(
          text: styles['real_life']?.toString() ?? styles['simple']?.toString() ?? '',
          suggestedChips: ["Explain simply.", "Exam answer.", "Quiz me."],
          activeConceptId: activeId,
        );
      }
      if (lower.contains('exam') || lower.contains('definition') || lower.contains('academic') || lower.contains('formal')) {
        return DendyRetrievalResult(
          text: styles['exam']?.toString() ?? styles['standard']?.toString() ?? targetConcept['definition']?.toString() ?? '',
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
        buffer.writeln("🧠 **Dendy Pop Quiz!** 🦊\n");
        buffer.writeln("**${quizItem['question']}**\n");
        if (options.isNotEmpty) {
          for (int i = 0; i < options.length; i++) {
            buffer.writeln("${String.fromCharCode(65 + i)}) ${options[i]}");
          }
        }
        buffer.writeln("\n💡 *Tap your answer below or ask for the answer!*");
        final chips = [...options, "Show answer.", "Next question."];
        return DendyRetrievalResult(
          text: buffer.toString(),
          suggestedChips: chips,
          quizData: quizItem,
        );
      }
    }

    // Check if user answered a quiz
    if (lower.contains('show answer') || lower.contains('tell me the answer') || lower.contains('what is the answer')) {
      final quizBank = _densityKnowledge?['quiz_bank'] as List<dynamic>? ?? [];
      final lastQuiz = quizBank.isNotEmpty ? (quizBank[(_quizIndex - 1).clamp(0, quizBank.length - 1)] as Map<String, dynamic>) : null;
      if (lastQuiz != null) {
        return DendyRetrievalResult(
          text: "✅ **Answer**: **${lastQuiz['answer']}**\n\n${lastQuiz['explanation']}",
          suggestedChips: ["Next quiz question.", "What is density?", "Why do ships float?"],
        );
      }
    }

    // ----------------------------------------------------
    // STEP 4: Specific Science Comparisons, Values & Materials Table
    // ----------------------------------------------------
    // Materials Table ("density table", "common materials", "list of densities")
    if (lower.contains('table') || lower.contains('chart') || lower.contains('list of densities') || lower.contains('materials density') || lower.contains('common materials')) {
      final table = _densityKnowledge?['materials_table'] as List<dynamic>? ?? [];
      final buffer = StringBuffer();
      buffer.writeln("📊 **Common Materials Density Table**\n");
      buffer.writeln("| Material | Density (g/cm³) | Floats in Water? |");
      buffer.writeln("| :--- | :--- | :--- |");
      for (final rawMat in table) {
        final mat = rawMat as Map<String, dynamic>;
        buffer.writeln("| ${mat['material']} | ${mat['density_g_cm3']} | ${mat['floats']} |");
      }
      buffer.writeln("\n💡 *Water's density is 1.00 g/cm³. Any substance with density < 1.00 floats!*");
      return DendyRetrievalResult(
        text: buffer.toString(),
        suggestedChips: ["Why does oil float?", "Why do ships float?", "Compare water and oil.", "Quiz me."],
        activeConceptId: 'density',
      );
    }

    // Oil Density & Comparison
    if (lower.contains('oil')) {
      if (lower.contains('density of oil') || lower.contains('what is the density of oil') || lower.contains('value')) {
        return DendyRetrievalResult(
          text: "The density of oil is approximately **0.80 g/cm³** (or 800 kg/m³). Because 0.80 < 1.00 g/cm³ (water), oil floats on top of water!",
          suggestedChips: ["Why does oil float?", "Compare water and oil.", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
      if (lower.contains('compare') || lower.contains('water and oil') || lower.contains('oil and water') || lower.contains('vs') || lower.contains('denser than')) {
        return DendyRetrievalResult(
          text: "Water is denser than oil! Water has a density of **1.00 g/cm³**, while oil is only **0.80 g/cm³**. That is why cooking oil or petroleum floats in a distinct layer on top of water.",
          suggestedChips: ["What is the density of oil?", "Why does ice float?", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
      if (lower.contains('float') || lower.contains('why') || lower.contains('lighter')) {
        return DendyRetrievalResult(
          text: "Oil floats because it is less dense than water (0.80 g/cm³ vs 1.00 g/cm³). When poured into water, oil forms a layer on top because water pushes it upward with buoyant force.",
          suggestedChips: ["Compare water and oil.", "What is the density of oil?", "Explain simply.", "Quiz me."],
          activeConceptId: 'oil',
        );
      }
    }

    // Ice Density & Floating
    if (lower.contains('ice') || lower.contains('frozen water') || lower.contains('iceberg')) {
      if (lower.contains('density of ice') || lower.contains('what is the density of ice')) {
        return DendyRetrievalResult(
          text: "The density of ice is **0.92 g/cm³**. When water freezes into ice, it expands, causing the same mass to occupy more space and reducing its density.",
          suggestedChips: ["Why does ice float?", "Compare water and ice.", "Explain simply.", "Quiz me."],
          activeConceptId: 'ice',
        );
      }
      if (lower.contains('float') || lower.contains('why') || lower.contains('water vs ice') || lower.contains('compare')) {
        return DendyRetrievalResult(
          text: "Ice floats because ice has a lower density (**0.92 g/cm³**) than liquid water (**1.00 g/cm³**). Water molecules in liquid form are packed more closely than in hexagonal ice crystals!",
          suggestedChips: ["Why does water expand?", "What is the density of ice?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ice',
        );
      }
    }

    // Ships & Submarines
    if (lower.contains('ship') || lower.contains('boat') || lower.contains('vessel') || lower.contains('submarine')) {
      if (lower.contains('submarine')) {
        return DendyRetrievalResult(
          text: "Submarines dive and surface using **ballast tanks**! To dive, they fill the tanks with seawater to increase their average density above water (1.0 g/cm³). To surface, they blow compressed air into the tanks to push the water out, lowering their average density below water!",
          suggestedChips: ["Why do ships float?", "Why does shape matter?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ships',
        );
      }
      if (lower.contains('why do ships float') || lower.contains('how ships float') || lower.contains('float') || lower.contains('steel')) {
        return DendyRetrievalResult(
          text: "Ships are made of steel (density 7.80 g/cm³), but their hollow hull shape encloses a vast volume of air. This huge volume reduces their overall average density well below that of water (1.00 g/cm³), allowing them to float!",
          suggestedChips: ["What about submarines?", "Why don't steel blocks float?", "Why does shape matter?", "Explain simply.", "Quiz me."],
          activeConceptId: 'ships',
        );
      }
    }

    // Formula Questions
    if (lower.contains('formula') || lower.contains('calculate density') || lower.contains('equation')) {
      return DendyRetrievalResult(
        text: "The formula for density is **Density = Mass ÷ Volume** (ρ = m/V).\n\n• To find mass: **Mass = Density × Volume** (M = D × V)\n• To find volume: **Volume = Mass ÷ Density** (V = M/D)",
        suggestedChips: ["Units of density.", "How do I find mass?", "How do I find volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'density',
      );
    }
    if (lower.contains('how do i find mass') || lower.contains('find mass') || lower.contains('calculate mass')) {
      return DendyRetrievalResult(
        text: "To find mass, multiply density by volume: **Mass = Density × Volume** (M = D × V).",
        suggestedChips: ["How do I find volume?", "What is the formula?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mass',
      );
    }
    if (lower.contains('how do i find volume') || lower.contains('find volume') || lower.contains('calculate volume')) {
      return DendyRetrievalResult(
        text: "To find volume, divide mass by density: **Volume = Mass ÷ Density** (V = M/D).",
        suggestedChips: ["How do I find mass?", "What is the formula?", "Explain simply.", "Quiz me."],
        activeConceptId: 'volume',
      );
    }

    // Mass vs Weight
    if (lower.contains('mass') && (lower.contains('weight') || lower.contains('gravity') || lower.contains('same'))) {
      return DendyRetrievalResult(
        text: "No, mass and weight are not the same!\n\n• **Mass**: Amount of matter in an object (measured in kg, never changes anywhere).\n• **Weight**: Force due to gravity pulling on that mass (measured in Newtons, changes on the Moon or in space).",
        suggestedChips: ["Units of mass.", "What is volume?", "Explain simply.", "Quiz me."],
        activeConceptId: 'mass',
      );
    }

    // Relative Density
    if (lower.contains('relative density') || lower.contains('specific gravity')) {
      final relConcept = concepts['relative_density'];
      return DendyRetrievalResult(
        text: relConcept?['response_styles']?['standard']?.toString() ?? "Relative density compares the density of a substance with pure water: **Relative Density = Density of Substance ÷ Density of Water** (Water's relative density = 1).",
        suggestedChips: ["What is the formula?", "Relative density of gold.", "Explain simply.", "Quiz me."],
        activeConceptId: 'relative_density',
      );
    }

    // Water Pressure Connection
    if (lower.contains('pressure') || lower.contains('deeper down') || lower.contains('depth')) {
      final pressureConcept = concepts['pressure'];
      return DendyRetrievalResult(
        text: pressureConcept?['response_styles']?['standard']?.toString() ?? "Water pressure is greater deeper down because deeper water has more water above it pressing downward due to gravity.",
        suggestedChips: ["How is pressure connected to buoyancy?", "Explain simply.", "Quiz me."],
        activeConceptId: 'pressure',
      );
    }

    // ----------------------------------------------------
    // STEP 5: Alias-Based Concept Matching
    // ----------------------------------------------------
    final aliasDict = _densityKnowledge?['alias_dictionary'] as Map<String, dynamic>? ?? {};
    for (final entry in aliasDict.entries) {
      final conceptKey = entry.key;
      final aliases = (entry.value as List<dynamic>?)?.map((a) => a.toString().toLowerCase()).toList() ?? [];
      for (final alias in aliases) {
        if (cleanQ.contains(_cleanText(alias)) || lower.contains(alias)) {
          final c = concepts[conceptKey];
          if (c != null) {
            final styles = c['response_styles'] as Map<String, dynamic>? ?? {};
            final answer = styles['standard']?.toString() ?? c['definition']?.toString() ?? '';
            final chips = (c['suggested_chips'] as List<dynamic>?)?.map((x) => x.toString()).toList() ?? ["Explain simply.", "Real-life examples.", "Quiz me."];
            return DendyRetrievalResult(
              text: answer,
              suggestedChips: chips,
              activeConceptId: conceptKey,
            );
          }
        }
      }
    }

    // ----------------------------------------------------
    // STEP 6: Dendy Educational Intents (Source 2)
    // ----------------------------------------------------
    if (_dendyIntents != null && _dendyIntents!['intents'] is List) {
      final intents = _dendyIntents!['intents'] as List<dynamic>;
      for (final rawIntent in intents) {
        final intent = rawIntent as Map<String, dynamic>;
        final patterns = (intent['patterns'] as List<dynamic>?)?.map((p) => p.toString().toLowerCase()).toList() ?? [];
        for (final p in patterns) {
          final cleanP = _cleanText(p);
          if (cleanQ == cleanP || cleanQ.startsWith('$cleanP ') || cleanQ.endsWith(' $cleanP') || cleanQ.contains(' $cleanP ') || lower == p) {
            final responses = (intent['responses'] as List<dynamic>?)?.map((r) => r.toString()).toList() ?? [];
            final resp = responses.isNotEmpty ? responses.first : "Hello there! 🦊 How can I help with your science quest?";
            final chips = (intent['suggested_chips'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ["What is density?", "Why do ships float?", "Quiz me."];
            return DendyRetrievalResult(
              text: resp,
              suggestedChips: chips,
            );
          }
        }
      }
    }

    // ----------------------------------------------------
    // STEP 7: Fallback to Retrieved Chunks / Guided Science Prompt
    // ----------------------------------------------------
    final fallbackChunks = await retrieve(query: query, topK: 1);
    if (fallbackChunks.isNotEmpty) {
      return DendyRetrievalResult(
        text: fallbackChunks.first.text,
        suggestedChips: ["Explain simply.", "Why do ships float?", "Quiz me."],
        activeConceptId: 'density',
      );
    }

    return DendyRetrievalResult(
      text: "I'm ready to help you master Density and Buoyancy! 🦊 Ask me about density, why steel ships float, submarines, comparing oil and water, or tap 'Quiz me'!",
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

    CurriculumPackage? pkg = _packageCache[moduleId] ?? _packageCache['grade8_density'] ?? _packageCache.values.firstOrNull;
    if (pkg == null || pkg.chunks.isEmpty) {
      return [];
    }

    final cleanQuery = _cleanText(query);
    final queryTokens = cleanQuery.split(RegExp(r'\s+')).where((t) => t.length > 1).toSet();
    final scoredChunks = <_ScoredChunk>[];

    for (final chunk in pkg.chunks) {
      int score = 0;
      final cleanConcept = _cleanText(chunk.concept);
      final cleanText = _cleanText(chunk.text);

      if (cleanQuery.contains(cleanConcept) || cleanConcept.contains(cleanQuery)) {
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

    CurriculumPackage? pkg = _packageCache[moduleId] ?? _packageCache['grade8_density'];
    if (pkg == null) return null;

    final cleanExplanation = _cleanText(explanation);
    final explanationTokens = cleanExplanation.split(RegExp(r'\s+')).toSet();

    for (final misc in pkg.misconceptions) {
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
    return input.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

class _ScoredChunk {
  final CurriculumChunk chunk;
  final int score;
  _ScoredChunk(this.chunk, this.score);
}

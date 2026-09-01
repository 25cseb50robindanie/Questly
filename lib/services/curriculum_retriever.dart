import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/curriculum_chunk.dart';

class CurriculumRetriever {
  static final CurriculumRetriever _instance = CurriculumRetriever._internal();
  factory CurriculumRetriever() => _instance;
  CurriculumRetriever._internal();

  final Map<String, CurriculumPackage> _packageCache = {};
  List<PackageManifestEntry> _manifest = [];
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final manifestJsonStr = await rootBundle.loadString('assets/curriculum/manifest.json');
      final manifestData = jsonDecode(manifestJsonStr) as Map<String, dynamic>;
      final rawPackages = manifestData['packages'] as List<dynamic>? ?? [];
      _manifest = rawPackages.map((p) => PackageManifestEntry.fromJson(p as Map<String, dynamic>)).toList();

      for (final entry in _manifest) {
        await _loadPackage(entry.path);
      }
      _isInitialized = true;
    } catch (_) {
      // Fallback: try loading density directly
      try {
        await _loadPackage('grade8_science/density.json');
      } catch (_) {}
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

  /// Retrieves the top [topK] most relevant curriculum chunks for a query
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

      // 1. Bonus if concept matches query (+10 points)
      if (cleanQuery.contains(cleanConcept) || cleanConcept.contains(cleanQuery)) {
        score += 10;
      }
      for (final conceptWord in cleanConcept.split(RegExp(r'\s+'))) {
        if (queryTokens.contains(conceptWord)) {
          score += 5;
        }
      }

      // 2. Count keyword matches (+3 points per matching keyword)
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

      // 3. Count text overlap (+1 point per word)
      for (final token in queryTokens) {
        if (cleanText.contains(token)) {
          score += 1;
        }
      }

      if (score > 0) {
        scoredChunks.add(_ScoredChunk(chunk, score));
      }
    }

    // Sort descending by score
    scoredChunks.sort((a, b) => b.score.compareTo(a.score));

    // If query didn't match any specific keywords, return top fallback chunks
    if (scoredChunks.isEmpty) {
      return pkg.chunks.take(topK).toList();
    }

    return scoredChunks.take(topK).map((sc) => sc.chunk).toList();
  }

  /// Detects if the student's text contains a known curriculum misconception
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

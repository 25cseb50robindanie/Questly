import '../core/locator.dart';
import 'knowledge_repository.dart';

enum SupportLevel {
  SUPPORTED,
  PARTIALLY_SUPPORTED,
  NOT_SUPPORTED,
}

class RetrievedContext {
  final String content;
  final String concept;
  final String lessonId;
  final String moduleId;
  final double relevanceScore;

  RetrievedContext({
    required this.content,
    required this.concept,
    required this.lessonId,
    required this.moduleId,
    required this.relevanceScore,
  });
}

abstract class Retriever {
  Future<List<RetrievedContext>> retrieve(String query, String moduleId);
  Future<SupportLevel> evaluateSupportLevel(String query, String moduleId);
}

class KeywordRetriever implements Retriever {
  @override
  Future<List<RetrievedContext>> retrieve(String query, String moduleId) async {
    final package = await Locator.knowledgeRepository.loadModuleKnowledge(moduleId);
    if (package == null) return [];

    final normalizedQuery = query.toLowerCase();
    final queryWords = normalizedQuery
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((w) => w.trim().length > 2)
        .toList();

    if (queryWords.isEmpty) return [];

    final List<RetrievedContext> matches = [];

    for (var concept in package.concepts) {
      double score = 0.0;
      int matchCount = 0;

      for (var word in queryWords) {
        // Match in keywords list or within description body
        final matchesKeyword = concept.keywords.any((kw) => kw.contains(word) || word.contains(kw));
        final matchesText = concept.text.toLowerCase().contains(word);

        if (matchesKeyword || matchesText) {
          matchCount++;
        }
      }

      if (matchCount > 0) {
        score = matchCount / queryWords.length;
        matches.add(RetrievedContext(
          content: concept.text,
          concept: concept.concept,
          lessonId: concept.lessonId,
          moduleId: moduleId,
          relevanceScore: score,
        ));
      }
    }

    // Sort by descending score
    matches.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return matches;
  }

  @override
  Future<SupportLevel> evaluateSupportLevel(String query, String moduleId) async {
    final normalized = query.toLowerCase();

    // Strict blacklisted generic concepts checks
    if (normalized.contains('capital of') ||
        normalized.contains('france') ||
        normalized.contains('relativity') ||
        normalized.contains('einstein') ||
        normalized.contains('president') ||
        normalized.contains('weather')) {
      return SupportLevel.NOT_SUPPORTED;
    }

    final results = await retrieve(query, moduleId);
    if (results.isEmpty) {
      return SupportLevel.NOT_SUPPORTED;
    }

    final topScore = results.first.relevanceScore;
    if (topScore >= 0.20) {
      return SupportLevel.SUPPORTED;
    } else if (topScore > 0.0) {
      return SupportLevel.PARTIALLY_SUPPORTED;
    }

    return SupportLevel.NOT_SUPPORTED;
  }
}

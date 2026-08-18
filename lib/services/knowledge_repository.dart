import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ConceptDefinition {
  final String id;
  final String concept;
  final String lessonId;
  final String text;
  final List<String> keywords;

  ConceptDefinition({
    required this.id,
    required this.concept,
    required this.lessonId,
    required this.text,
    required this.keywords,
  });

  factory ConceptDefinition.fromJson(Map<String, dynamic> json) => ConceptDefinition(
        id: json['id'] as String,
        concept: json['concept'] as String,
        lessonId: json['lessonId'] as String,
        text: json['text'] as String,
        keywords: List<String>.from(json['keywords'] as List<dynamic>? ?? []),
      );
}

class Misconception {
  final String id;
  final String incorrectPattern;
  final String correction;
  final String recommendedActivityId;

  Misconception({
    required this.id,
    required this.incorrectPattern,
    required this.correction,
    required this.recommendedActivityId,
  });

  factory Misconception.fromJson(Map<String, dynamic> json) => Misconception(
        id: json['id'] as String,
        incorrectPattern: json['incorrectPattern'] as String,
        correction: json['correction'] as String,
        recommendedActivityId: json['recommendedActivityId'] as String,
      );
}

class KnowledgePackage {
  final String moduleId;
  final List<ConceptDefinition> concepts;
  final List<Misconception> misconceptions;

  KnowledgePackage({
    required this.moduleId,
    required this.concepts,
    required this.misconceptions,
  });
}

class KnowledgeRepository {
  final Map<String, KnowledgePackage> _cache = {};

  // Load a curriculum knowledge pack locally
  Future<KnowledgePackage?> loadModuleKnowledge(String moduleId) async {
    if (_cache.containsKey(moduleId)) {
      return _cache[moduleId];
    }

    try {
      // Seed files matches module IDs
      final assetName = moduleId == 'mod_density' ? 'density' : moduleId;
      final raw = await rootBundle.loadString('assets/knowledge/$assetName.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;

      final conceptsJson = decoded['concepts'] as List<dynamic>? ?? [];
      final concepts = conceptsJson.map((x) => ConceptDefinition.fromJson(x as Map<String, dynamic>)).toList();

      final misconceptionsJson = decoded['misconceptions'] as List<dynamic>? ?? [];
      final misconceptions = misconceptionsJson.map((x) => Misconception.fromJson(x as Map<String, dynamic>)).toList();

      final package = KnowledgePackage(
        moduleId: decoded['moduleId'] as String? ?? moduleId,
        concepts: concepts,
        misconceptions: misconceptions,
      );

      _cache[moduleId] = package;
      return package;
    } catch (_) {
      return null;
    }
  }

  // Get active cached concepts list directly
  List<ConceptDefinition> getLoadedConcepts(String moduleId) {
    return _cache[moduleId]?.concepts ?? [];
  }
}

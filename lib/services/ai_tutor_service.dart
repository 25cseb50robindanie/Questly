import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/curriculum_chunk.dart';
import 'curriculum_retriever.dart';
import 'llama_engine.dart';
import 'whisper_voice_service.dart';

class ConversationExchange {
  final String userMessage;
  final String dendyResponse;
  final DateTime timestamp;

  ConversationExchange({
    required this.userMessage,
    required this.dendyResponse,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AITutorService {
  static final AITutorService _instance = AITutorService._internal();
  factory AITutorService() => _instance;
  AITutorService._internal() {
    _retriever.initialize();
    _engine.initializeModel().catchError((e) {
      debugPrint('[AITutorService] Background model init notice: $e');
    });
  }

  final CurriculumRetriever _retriever = CurriculumRetriever();
  final LlamaEngine _engine = LlamaEngine();

  // Rolling conversation memory of the last 3 exchanges
  final List<ConversationExchange> _rollingMemory = [];
  String? _lastActiveConceptId;
  DendyRetrievalResult? _latestRetrievalResult;

  List<ConversationExchange> get history => List.unmodifiable(_rollingMemory);
  DendyRetrievalResult? get latestRetrievalResult => _latestRetrievalResult;
  String? get lastActiveConceptId => _lastActiveConceptId;

  void clearHistory() {
    _rollingMemory.clear();
    _lastActiveConceptId = null;
    _latestRetrievalResult = null;
  }

  void _recordExchange(String user, String dendy) {
    _rollingMemory.add(ConversationExchange(userMessage: user, dendyResponse: dendy));
    if (_rollingMemory.length > 3) {
      _rollingMemory.removeAt(0);
    }
  }

  Future<bool> isAiAvailable() async => true;

  Stream<String> askTutor(
    String studentId,
    String query,
    String moduleId,
    String lessonId,
    dynamic studentContext,
  ) {
    return askDendyStream(question: query, moduleId: moduleId);
  }

  /// Deterministically answers student queries strictly grounded in curriculum
  Future<DendyRetrievalResult> askDendyDirect({
    required String question,
    String moduleId = 'mod_density',
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return const DendyRetrievalResult(text: "What would you like to explore today? 🦊");
    }

    final result = await _retriever.retrieveAnswer(
      query: trimmed,
      lastActiveConceptId: _lastActiveConceptId,
    );

    if (result.activeConceptId != null) {
      _lastActiveConceptId = result.activeConceptId;
    }
    _latestRetrievalResult = result;
    _recordExchange(trimmed, result.text);
    return result;
  }

  /// Streams token-by-token answers from Dendy strictly grounded in retrieved curriculum
  Stream<String> askDendyStream({
    required String question,
    String moduleId = 'mod_density',
  }) async* {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    final result = await askDendyDirect(question: trimmed, moduleId: moduleId);
    final words = result.text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final chunk = (i == words.length - 1) ? words[i] : '${words[i]} ';
      yield chunk;
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  /// Evaluates student's spoken Teach-Back explanation against curriculum chunks and misconceptions
  Future<TeachBackEvaluation> evaluateTeachBack({
    required String transcript,
    String moduleId = 'mod_density',
  }) async {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) {
      return TeachBackEvaluation(
        masteryScore: 0,
        isPassed: false,
        stars: 0,
        feedbackTitle: 'No Speech Detected',
        feedbackBody: 'I didn\'t hear your explanation! Press Speak to try explaining in your own words.',
        conceptsIdentified: [],
        missingConcepts: ['Mass', 'Volume', 'Density'],
        dendyMood: 'confused',
      );
    }

    // 1. Check for misconceptions first
    final detectedMisconception = await _retriever.detectMisconception(
      explanation: trimmed,
      moduleId: moduleId,
    );

    if (detectedMisconception != null) {
      return TeachBackEvaluation(
        masteryScore: 35,
        isPassed: false,
        stars: 1,
        feedbackTitle: 'Misconception Found',
        feedbackBody: detectedMisconception.correction,
        conceptsIdentified: [],
        missingConcepts: ['Density = Mass / Volume'],
        dendyMood: 'explaining',
      );
    }

    // 2. Score concept coverage
    final chunks = await _retriever.retrieve(
      query: trimmed,
      moduleId: moduleId,
      topK: 5,
    );

    final matched = <String>[];
    final cleanTranscript = trimmed.toLowerCase();

    final coreTerms = {
      'density': 'Density (Mass / Volume)',
      'mass': 'Mass (Matter)',
      'volume': 'Volume (Space Occupied)',
      'float': 'Floating & Buoyancy',
      'sink': 'Sinking (Density > Water)',
      'ship': 'Hollow Ships & Air Volume',
      'ice': 'Ice Expansion & Density',
    };

    for (final entry in coreTerms.entries) {
      if (cleanTranscript.contains(entry.key)) {
        matched.add(entry.value);
      }
    }

    for (final c in chunks) {
      if (!matched.contains(c.concept)) {
        matched.add(c.concept);
      }
    }

    final int masteryScore = (matched.length * 33).clamp(20, 100);
    final bool isPassed = masteryScore >= 60;
    final int stars = masteryScore >= 85 ? 3 : (masteryScore >= 60 ? 2 : 1);

    final feedback = isPassed
        ? 'Outstanding explanation! 🌟 You accurately covered ${matched.take(3).join(', ')}. Keep up the curious thinking!'
        : 'Good effort! Try adding why volume matters or how water pushes upward to make your explanation even stronger.';

    return TeachBackEvaluation(
      masteryScore: masteryScore,
      isPassed: isPassed,
      stars: stars,
      feedbackTitle: isPassed ? 'Mastery Achieved! 🌟' : 'Keep Practicing! 💡',
      feedbackBody: feedback,
      conceptsIdentified: matched,
      missingConcepts: isPassed ? [] : ['Buoyancy', 'Density formula'],
      dendyMood: isPassed ? 'success' : 'thinking',
    );
  }
}

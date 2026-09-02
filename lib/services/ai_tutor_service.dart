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
  AITutorService._internal();

  final CurriculumRetriever _retriever = CurriculumRetriever();
  final LlamaEngine _engine = LlamaEngine();

  // Rolling conversation memory of the last 3 exchanges
  final List<ConversationExchange> _rollingMemory = [];

  List<ConversationExchange> get history => List.unmodifiable(_rollingMemory);

  void clearHistory() {
    _rollingMemory.clear();
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

  /// Streams token-by-token answers from Dendy strictly grounded in retrieved curriculum
  Stream<String> askDendyStream({
    required String question,
    String moduleId = 'mod_density',
  }) async* {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;

    // 1. Retrieve top 2-3 relevant curriculum chunks
    final retrievedChunks = await _retriever.retrieve(
      query: trimmed,
      moduleId: moduleId,
      topK: 3,
    );

    // 2. Format curriculum context
    final curriculumContext = retrievedChunks.map((c) => '[${c.concept}]: ${c.text}').join('\n');

    // 3. Format rolling history
    final historyContext = _rollingMemory.map((e) => 'Student: ${e.userMessage}\nDendy: ${e.dendyResponse}').join('\n');

    // 4. Build complete ChatML prompt with system rules, curriculum, and rolling history
    final promptBuilder = StringBuffer();
    promptBuilder.writeln('<|im_start|>system');
    promptBuilder.writeln('You are Dendy, Questly\'s friendly fox learning companion.');
    promptBuilder.writeln('Rules:');
    promptBuilder.writeln('- Only answer using the curriculum facts below.');
    promptBuilder.writeln('- Do not invent new science facts.');
    promptBuilder.writeln('- Keep answers simple, short, and encourage the student.');
    promptBuilder.writeln('- If no relevant curriculum exists, say: "Let\'s stay with today\'s lesson. Ask me something about density or buoyancy."');
    if (curriculumContext.isNotEmpty) {
      promptBuilder.writeln('\nCurriculum Knowledge:\n$curriculumContext');
    }
    promptBuilder.writeln('<|im_end|>');

    // Add rolling conversation history turns (last 3 exchanges)
    for (final exchange in _rollingMemory) {
      promptBuilder.writeln('<|im_start|>user\n${exchange.userMessage}<|im_end|>');
      promptBuilder.writeln('<|im_start|>assistant\n${exchange.dendyResponse}<|im_end|>');
    }

    // Add current user question
    promptBuilder.writeln('<|im_start|>user\n$trimmed<|im_end|>');
    promptBuilder.writeln('<|im_start|>assistant');

    final fullPrompt = promptBuilder.toString();
    debugPrint('[AITutorService] Full Prompt to Model:\n$fullPrompt');

    // 5. Stream response tokens from engine
    final responseBuffer = StringBuffer();
    await for (final token in _engine.generateStreaming(
      prompt: fullPrompt,
      userQuery: trimmed,
      curriculumContext: curriculumContext,
    )) {
      responseBuffer.write(token);
      yield token;
    }

    // 6. Record exchange in rolling memory
    _recordExchange(trimmed, responseBuffer.toString().trim());
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
        feedbackTitle: 'No explanation heard',
        feedbackBody: 'Please tap the microphone and speak your explanation of density and floating!',
        conceptsIdentified: [],
        missingConcepts: ['density', 'mass', 'volume', 'buoyancy'],
        dendyMood: 'confused',
      );
    }

    // 1. Check for known misconceptions
    final misconception = await _retriever.detectMisconception(
      explanation: trimmed,
      moduleId: moduleId,
    );

    // 2. Check concept coverage
    final lowerText = trimmed.toLowerCase();
    final hasMass = lowerText.contains('mass') || lowerText.contains('matter') || lowerText.contains('weight') || lowerText.contains('atoms');
    final hasVolume = lowerText.contains('volume') || lowerText.contains('space') || lowerText.contains('size') || lowerText.contains('3d');
    final hasFormula = lowerText.contains('density') || lowerText.contains('divide') || lowerText.contains('packed') || lowerText.contains('ratio');
    final hasBuoyancy = lowerText.contains('float') || lowerText.contains('sink') || lowerText.contains('water') || lowerText.contains('buoyan') || lowerText.contains('displace');

    final identified = <String>[];
    final missing = <String>[];

    int score = 35;
    if (hasMass) { score += 15; identified.add('Mass'); } else { missing.add('Mass'); }
    if (hasVolume) { score += 15; identified.add('Volume'); } else { missing.add('Volume'); }
    if (hasFormula) { score += 20; identified.add('Density Formula'); } else { missing.add('Density Formula'); }
    if (hasBuoyancy) { score += 15; identified.add('Floating & Buoyancy'); } else { missing.add('Floating & Buoyancy'); }

    // If a misconception is detected, give targeted feedback
    if (misconception != null) {
      score = score.clamp(30, 75);
      return TeachBackEvaluation(
        masteryScore: score,
        isPassed: score >= 60,
        stars: score >= 70 ? 2 : 1,
        feedbackTitle: 'Great Attempt! Notice This Key Detail:',
        feedbackBody: 'Dendy noticed: "${misconception.pattern}". ${misconception.correction}',
        conceptsIdentified: identified,
        missingConcepts: missing,
        dendyMood: 'thinking',
      );
    }

    final isPassed = score >= 60;
    final stars = score >= 85 ? 3 : (score >= 65 ? 2 : 1);

    String title = isPassed ? 'Outstanding Teaching!' : 'Good Start! Add More Details.';
    String body = isPassed
        ? 'Great job! You clearly taught Dendy how mass and volume combine into density to determine why materials float or sink.'
        : 'Try mentioning that density equals mass divided by volume (D = M/V) and how materials with less density than water float!';

    return TeachBackEvaluation(
      masteryScore: score,
      isPassed: isPassed,
      stars: stars,
      feedbackTitle: title,
      feedbackBody: body,
      conceptsIdentified: identified,
      missingConcepts: missing,
      dendyMood: isPassed ? 'success' : 'thinking',
    );
  }
}

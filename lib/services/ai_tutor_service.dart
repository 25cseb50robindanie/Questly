import 'dart:async';
import '../core/locator.dart';
import '../models/ai_provider.dart';
import '../models/doubt.dart';
import '../services/retriever.dart';

class StudentContext {
  final String language; // 'en', 'ta', 'hi'
  final String gradeLevel; // 'Grade 5'
  final String interests; // 'cricket', 'dance', 'farming'

  StudentContext({
    required this.language,
    required this.gradeLevel,
    required this.interests,
  });
}

class AITutorService {
  final AIProvider _aiProvider;
  final Retriever _retriever;

  AITutorService(this._aiProvider, this._retriever);

  // Check connectivity
  Future<bool> isAiAvailable() async {
    final baseUrl = Locator.storageService.getLanguage() == 'ta' // mock check or load from prefs
        ? "http://localhost:11434"
        : _getBaseUrl();
    return _aiProvider.isAvailable(baseUrl);
  }

  String _getBaseUrl() {
    return Locator.storageService.getString('ollama_url') ?? "http://localhost:11434";
  }

  String _getModelName() {
    return Locator.storageService.getString('ollama_model') ?? "gemma:2b";
  }

  // Orchestrate AI Tutor question answer flow
  Stream<String> askTutor(
    String studentId,
    String query,
    String moduleId,
    String lessonId,
    StudentContext studentContext,
  ) async* {
    // 1. Misconception Check
    final misconception = await _checkMisconceptions(query, moduleId);
    if (misconception != null) {
      yield misconception;
      return;
    }

    // 2. Evaluate Grounding support level
    final support = await _retriever.evaluateSupportLevel(query, moduleId);

    if (support == SupportLevel.NOT_SUPPORTED) {
      final refuseMsg = _getRefusalMessage(studentContext.language);
      
      // Save escalated doubt locally
      final doubt = Doubt(
        id: 'doubt_${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        moduleId: moduleId,
        lessonId: lessonId,
        question: query,
        language: studentContext.language,
        timestamp: DateTime.now(),
        status: 'pending',
        context: 'Not supported by available curriculum.',
        attemptedAnswer: refuseMsg,
      );
      await Locator.doubtRepository.saveDoubt(doubt);
      
      yield refuseMsg;
      return;
    }

    // 3. Retrieve relevant curriculum context
    final contexts = await _retriever.retrieve(query, moduleId);
    final contextText = contexts.map((c) => c.content).join("\n\n");

    // 4. Construct personalized prompt
    final prompt = _buildGroundingPrompt(query, contextText, studentContext);

    // 5. Query Ollama and yield streamed tokens
    final baseUrl = _getBaseUrl();
    final modelName = _getModelName();

    yield* _aiProvider.streamResponse(prompt, baseUrl, modelName);
  }

  // Check local misconception definitions
  Future<String?> _checkMisconceptions(String query, String moduleId) async {
    final package = await Locator.knowledgeRepository.loadModuleKnowledge(moduleId);
    if (package == null) return null;

    final normalized = query.toLowerCase();
    for (var mis in package.misconceptions) {
      if (normalized.contains(mis.incorrectPattern)) {
        return "${mis.correction}\n\nLet's test this concept inside the activity: ${mis.recommendedActivityId}.";
      }
    }
    return null;
  }

  String _getRefusalMessage(String language) {
    if (language == 'ta') {
      return "இந்த பாடத்தில் எனக்கு அந்த தகவல் இல்லை. உங்கள் கேள்வியை உங்கள் ஆசிரியருக்கு அனுப்புகிறேன்.";
    } else if (language == 'hi') {
      return "मेरे पास इस पाठ में वह जानकारी नहीं है। मैं आपका प्रश्न आपके शिक्षक को भेज दूँगा।";
    }
    return "I don't have enough information about that in this lesson. I've saved your question for your teacher.";
  }

  String _buildGroundingPrompt(String query, String context, StudentContext sc) {
    final langStr = sc.language == 'ta' ? 'Tamil' : (sc.language == 'hi' ? 'Hindi' : 'English');
    return """
ROLE:
You are Questly's educational AI tutor. Speak to a student in $langStr at a ${sc.gradeLevel} level.

CURRICULUM:
Only use the provided curriculum context. Do not invent facts outside this context.

PERSONALIZATION INTERESTS:
The student is interested in: ${sc.interests}. Use analogy or comparisons based on this interest (e.g. Cricket ball weight/volume comparisons) if it fits naturally to explain density, but do not force it.

RETRIEVED LESSON CONTEXT:
$context

QUESTION:
$query

INSTRUCTIONS:
1. Explain the answer simply in $langStr.
2. If the context does not contain enough information, refuse to answer and state that the lesson context is insufficient.
3. Keep the text concise and friendly.
""";
  }
}

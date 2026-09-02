import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/models/ai_provider.dart';
import 'package:questly/models/doubt.dart';
import 'package:questly/services/knowledge_repository.dart';
import 'package:questly/services/retriever.dart';
import 'package:questly/services/doubt_repository.dart';
import 'package:questly/services/ai_tutor_service.dart';

// Mock Provider for testing prompts and abstractions
class TestAIProvider implements AIProvider {
  @override
  Stream<String> streamResponse(String prompt, String baseUrl, String modelName) async* {
    yield "Grounded Response Token";
  }

  @override
  Future<bool> isAvailable(String baseUrl) async {
    return true;
  }

  @override
  Future<List<String>> getAvailableModels(String baseUrl) async {
    return ["gemma:2b"];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Questly AI Tutor Systems Tests', () {
    late KnowledgeRepository repo;
    late KeywordRetriever retriever;
    late DoubtRepository doubtRepo;
    late AITutorService tutor;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      Locator.resetForTest();
      await Locator.setup();
      repo = Locator.knowledgeRepository;
      retriever = KeywordRetriever();
      doubtRepo = Locator.doubtRepository;
      tutor = AITutorService();
    });

    test('1. AI Abstraction and Mock Tags test', () async {
      final isUp = await tutor.isAiAvailable();
      expect(isUp, isTrue);
    });

    test('2. RAG Keyword Retrieval scoring evaluations', () async {
      final package = await repo.loadModuleKnowledge('mod_density');
      expect(package, isNotNull);
      expect(package!.concepts.length, greaterThan(0));

      final contexts = await retriever.retrieve("What is the density formula?", "mod_density");
      expect(contexts, isNotEmpty);
      expect(contexts.first.concept, equals("Density Formula"));
    });

    test('3. Supported Questions evaluates as SUPPORTED', () async {
      final support = await retriever.evaluateSupportLevel("Explain why a steel ship floats.", "mod_density");
      expect(support, equals(SupportLevel.SUPPORTED));
    });

    test('4. General trivia questions evaluates as NOT_SUPPORTED', () async {
      final support = await retriever.evaluateSupportLevel("What is the capital of France?", "mod_density");
      expect(support, equals(SupportLevel.NOT_SUPPORTED));
    });

    test('5. Streaming response from AI tutor yields tokens', () async {
      final studentId = "stud_test123";
      final sc = {'language': 'en', 'gradeLevel': 'Grade 5', 'interests': 'cricket'};

      final stream = tutor.askTutor(studentId, "What is density?", "mod_density", "density_les1", sc);
      final response = await stream.join();

      expect(response, isNotEmpty);
    });

    test('6. DoubtRepository logs doubts and prevents duplicates', () async {
      const studentId = "stud_test123";

      final doubt1 = Doubt(
        id: 'd1',
        studentId: studentId,
        moduleId: 'mod_density',
        lessonId: 'density_les1',
        question: 'Who discovered relativity?',
        language: 'en',
        timestamp: DateTime.now(),
        status: 'pending',
      );

      final doubt2 = Doubt(
        id: 'd2',
        studentId: studentId,
        moduleId: 'mod_density',
        lessonId: 'density_les1',
        question: 'Who discovered relativity?',
        language: 'en',
        timestamp: DateTime.now(),
        status: 'pending',
      );

      await doubtRepo.saveDoubt(doubt1);
      await doubtRepo.saveDoubt(doubt2);

      final list = doubtRepo.getDoubts(studentId);
      final matches = list.where((d) => d.question == "Who discovered relativity?");
      expect(matches.length, equals(1)); // Duplicates properly prevented!
    });
  });
}

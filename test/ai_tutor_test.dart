import 'package:flutter_test/flutter_test.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/models/ai_provider.dart';
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
  // Ensure Flutter binding is active for asset loading
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Questly AI Tutor Systems Tests', () {
    late KnowledgeRepository repo;
    late KeywordRetriever retriever;
    late DoubtRepository doubtRepo;
    late AITutorService tutor;

    setUp(() async {
      await Locator.setup();
      repo = Locator.knowledgeRepository;
      retriever = KeywordRetriever();
      doubtRepo = Locator.doubtRepository;
      tutor = AITutorService(TestAIProvider(), retriever);
    });

    test('1. AI Abstraction and Mock Tags test', () async {
      final isUp = await tutor.isAiAvailable();
      expect(isUp, isTrue);
    });

    test('2. RAG Keyword Retrieval scoring evaluations', () async {
      // Load static seed definitions
      final package = await repo.loadModuleKnowledge('mod_density');
      expect(package, isNotNull);
      expect(package!.concepts.length, greaterThan(0));

      // Test keyword searches match concepts
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

    test('5. Out-of-curriculum question logs escalated doubts locally', () async {
      final studentId = "stud_test123";
      final sc = StudentContext(language: 'en', gradeLevel: 'Grade 5', interests: 'cricket');

      // Clear previous doubts
      final initialCount = doubtRepo.getDoubts(studentId).length;

      // Ask unsupported question
      final stream = tutor.askTutor(studentId, "What is the capital of France?", "mod_density", "density_les1", sc);
      final response = await stream.join();

      expect(response, contains("saved your question for your teacher"));

      final list = doubtRepo.getDoubts(studentId);
      expect(list.length, equals(initialCount + 1));
      expect(list.last.question, equals("What is the capital of France?"));
      expect(list.last.status, equals("pending"));
    });

    test('6. Prevents logging duplicate doubts for the same question', () async {
      final studentId = "stud_test123";
      final sc = StudentContext(language: 'en', gradeLevel: 'Grade 5', interests: 'cricket');

      // Trigger twice
      final stream1 = tutor.askTutor(studentId, "Who discovered relativity?", "mod_density", "density_les1", sc);
      await stream1.join();

      final stream2 = tutor.askTutor(studentId, "Who discovered relativity?", "mod_density", "density_les1", sc);
      await stream2.join();

      final list = doubtRepo.getDoubts(studentId);
      final matches = list.where((d) => d.question == "Who discovered relativity?");
      expect(matches.length, equals(1)); // should be unique!
    });
  });
}

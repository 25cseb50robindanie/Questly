import 'package:flutter_test/flutter_test.dart';
import 'package:questly/services/adaptive_learning_engine.dart';
import 'package:questly/services/misconception_engine.dart';

void main() {
  group('AdaptiveLearningEngine Tests', () {
    late AdaptiveLearningEngine engine;

    setUp(() {
      engine = AdaptiveLearningEngine();
    });

    test('Initial session state starts at beginner with default metrics', () {
      final session = engine.getSession('student_123', 'fractions');
      expect(session.currentDifficulty, equals(DifficultyLevel.beginner));
      expect(session.streak, equals(0));
      expect(session.confidenceScore, equals(0.5));
      expect(session.masteryScore, equals(0.0));
      expect(session.hintLevel, equals(0));
    });

    test('Consecutive correct answers scale difficulty up to intermediate and advanced', () {
      // 1st correct answer
      var state = engine.recordAnswer(
        studentId: 'student_123',
        topic: 'fractions',
        isCorrect: true,
        problemDifficulty: DifficultyLevel.beginner,
        responseTimeSeconds: 3,
      );
      expect(state.streak, equals(1));
      expect(state.consecutiveCorrect, equals(1));
      expect(state.currentDifficulty, equals(DifficultyLevel.beginner));

      // 2nd correct answer -> should level up to intermediate!
      state = engine.recordAnswer(
        studentId: 'student_123',
        topic: 'fractions',
        isCorrect: true,
        problemDifficulty: DifficultyLevel.beginner,
        responseTimeSeconds: 4,
      );
      expect(state.currentDifficulty, equals(DifficultyLevel.intermediate));
      expect(state.streak, equals(2));
      expect(state.confidenceScore, greaterThan(0.5));

      // 2 more correct answers -> should level up to advanced!
      state = engine.recordAnswer(
        studentId: 'student_123',
        topic: 'fractions',
        isCorrect: true,
        problemDifficulty: DifficultyLevel.intermediate,
      );
      state = engine.recordAnswer(
        studentId: 'student_123',
        topic: 'fractions',
        isCorrect: true,
        problemDifficulty: DifficultyLevel.intermediate,
      );
      expect(state.currentDifficulty, equals(DifficultyLevel.advanced));
    });

    test('Consecutive mistakes decrease difficulty and increase hint level', () {
      // Advance to intermediate first
      engine.recordAnswer(studentId: 'stu', topic: 'fractions', isCorrect: true, problemDifficulty: DifficultyLevel.beginner);
      engine.recordAnswer(studentId: 'stu', topic: 'fractions', isCorrect: true, problemDifficulty: DifficultyLevel.beginner);

      var state = engine.getSession('stu', 'fractions');
      expect(state.currentDifficulty, equals(DifficultyLevel.intermediate));

      // 1st mistake -> increments hint level
      state = engine.recordAnswer(studentId: 'stu', topic: 'fractions', isCorrect: false, problemDifficulty: DifficultyLevel.intermediate);
      expect(state.streak, equals(0));
      expect(state.hintLevel, equals(1));
      expect(state.currentDifficulty, equals(DifficultyLevel.intermediate));

      // 2nd mistake -> drops difficulty back to beginner!
      state = engine.recordAnswer(studentId: 'stu', topic: 'fractions', isCorrect: false, problemDifficulty: DifficultyLevel.intermediate);
      expect(state.currentDifficulty, equals(DifficultyLevel.beginner));
      expect(state.hintLevel, equals(2));
    });
  });

  group('MisconceptionEngine Diagnostics Tests', () {
    late MisconceptionEngine engine;

    setUp(() {
      engine = MisconceptionEngine();
    });

    test('Diagnoses larger_denominator_fallacy when choosing smaller fraction', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'larger_denominator_fallacy',
        topic: 'fractions',
        selectedOption: '1/8 is bigger',
        correctOption: '1/4 is bigger',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('larger_denominator_fallacy'));
      expect(diagnosis.title, contains('Larger Denominator'));
      expect(diagnosis.visualType, equals('pizza_comparison'));
      expect(diagnosis.retryProblem.options.isNotEmpty, isTrue);
    });

    test('Diagnoses denominator_confusion when counting only unshaded pieces', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'denominator_confusion',
        topic: 'fractions',
        selectedOption: '3/1',
        correctOption: '3/4',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('denominator_confusion'));
      expect(diagnosis.title, contains('Denominator'));
    });

    test('Diagnoses numerator_confusion when inverting top and bottom', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'numerator_confusion',
        topic: 'fractions',
        selectedOption: '1/4',
        correctOption: '3/4',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('numerator_confusion'));
    });

    test('Diagnoses equivalent_additive_fallacy for false additive scaling', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'equivalent_additive_fallacy',
        topic: 'fractions',
        selectedOption: '2/3',
        correctOption: '2/4',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('equivalent_additive_fallacy'));
    });

    test('Diagnoses ratio_order_inversion for reversed ratio antecedent/consequent', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'ratio_order_inversion',
        topic: 'ratios',
        selectedOption: '5 : 3',
        correctOption: '3 : 5',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('ratio_order_inversion'));
    });

    test('Diagnoses ratio_simplification_subtraction for non-multiplicative reduction', () {
      final diagnosis = engine.diagnose(
        explicitTrigger: 'ratio_simplification_subtraction',
        topic: 'ratios',
        selectedOption: '2 : 4',
        correctOption: '2 : 3',
      );

      expect(diagnosis, isNotNull);
      expect(diagnosis!.id, equals('ratio_simplification_subtraction'));
    });
  });
}

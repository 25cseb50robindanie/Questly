import 'dart:math';

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  master,
}

class AdaptiveProblem {
  final String id;
  final String topic; // 'fractions' or 'ratios'
  final String category; // 'identification', 'comparison', 'equivalent', 'simplification', 'word_problem'
  final DifficultyLevel difficulty;
  final String question;
  final String? subtitle;
  final dynamic visualData; // Visual configuration for models
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Map<int, String>? misconceptionTriggers; // optionIndex -> misconceptionId
  final String hint;

  const AdaptiveProblem({
    required this.id,
    required this.topic,
    required this.category,
    required this.difficulty,
    required this.question,
    this.subtitle,
    this.visualData,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.misconceptionTriggers,
    required this.hint,
  });
}

class AdaptiveSessionState {
  DifficultyLevel currentDifficulty;
  int consecutiveCorrect;
  int consecutiveMistakes;
  int totalAnswered;
  int totalCorrect;
  double confidenceScore; // 0.0 to 1.0
  double masteryScore; // 0.0 to 1.0
  int streak;
  int hintLevel; // 0: no hint, 1: nudge, 2: detailed hint

  AdaptiveSessionState({
    this.currentDifficulty = DifficultyLevel.beginner,
    this.consecutiveCorrect = 0,
    this.consecutiveMistakes = 0,
    this.totalAnswered = 0,
    this.totalCorrect = 0,
    this.confidenceScore = 0.5,
    this.masteryScore = 0.0,
    this.streak = 0,
    this.hintLevel = 0,
  });

  Map<String, dynamic> toJson() => {
    'currentDifficulty': currentDifficulty.index,
    'consecutiveCorrect': consecutiveCorrect,
    'consecutiveMistakes': consecutiveMistakes,
    'totalAnswered': totalAnswered,
    'totalCorrect': totalCorrect,
    'confidenceScore': confidenceScore,
    'masteryScore': masteryScore,
    'streak': streak,
    'hintLevel': hintLevel,
  };

  factory AdaptiveSessionState.fromJson(Map<String, dynamic> json) => AdaptiveSessionState(
    currentDifficulty: DifficultyLevel.values[json['currentDifficulty'] as int? ?? 0],
    consecutiveCorrect: json['consecutiveCorrect'] as int? ?? 0,
    consecutiveMistakes: json['consecutiveMistakes'] as int? ?? 0,
    totalAnswered: json['totalAnswered'] as int? ?? 0,
    totalCorrect: json['totalCorrect'] as int? ?? 0,
    confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.5,
    masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
    streak: json['streak'] as int? ?? 0,
    hintLevel: json['hintLevel'] as int? ?? 0,
  );
}

class AdaptiveLearningEngine {
  final Map<String, AdaptiveSessionState> _sessions = {};

  AdaptiveSessionState getSession(String studentId, String topic) {
    final key = '${studentId}_$topic';
    return _sessions.putIfAbsent(key, () => AdaptiveSessionState());
  }

  /// Processes student answer and dynamically adjusts difficulty, confidence, and mastery
  AdaptiveSessionState recordAnswer({
    required String studentId,
    required String topic,
    required bool isCorrect,
    required DifficultyLevel problemDifficulty,
    int responseTimeSeconds = 5,
  }) {
    final state = getSession(studentId, topic);
    state.totalAnswered++;

    if (isCorrect) {
      state.totalCorrect++;
      state.consecutiveCorrect++;
      state.consecutiveMistakes = 0;
      state.streak++;
      state.hintLevel = 0;

      // Increase confidence: faster answer = higher confidence boost
      final timeFactor = responseTimeSeconds < 6 ? 0.08 : (responseTimeSeconds < 15 ? 0.05 : 0.03);
      state.confidenceScore = (state.confidenceScore + timeFactor).clamp(0.0, 1.0);

      // Mastery calculation
      final difficultyWeight = (problemDifficulty.index + 1) * 0.15;
      state.masteryScore = (state.masteryScore + difficultyWeight).clamp(0.0, 1.0);

      // Dynamic Difficulty Level Up: 2 consecutive correct answers at current level
      if (state.consecutiveCorrect >= 2) {
        if (state.currentDifficulty == DifficultyLevel.beginner) {
          state.currentDifficulty = DifficultyLevel.intermediate;
          state.consecutiveCorrect = 0;
        } else if (state.currentDifficulty == DifficultyLevel.intermediate) {
          state.currentDifficulty = DifficultyLevel.advanced;
          state.consecutiveCorrect = 0;
        } else if (state.currentDifficulty == DifficultyLevel.advanced && state.masteryScore > 0.75) {
          state.currentDifficulty = DifficultyLevel.master;
          state.consecutiveCorrect = 0;
        }
      }
    } else {
      state.consecutiveCorrect = 0;
      state.consecutiveMistakes++;
      state.streak = 0;

      // Decrease confidence
      state.confidenceScore = (state.confidenceScore - 0.10).clamp(0.1, 1.0);

      // Increase hint level
      state.hintLevel = min(state.hintLevel + 1, 2);

      // Dynamic Difficulty Level Down: 2 consecutive mistakes
      if (state.consecutiveMistakes >= 2) {
        if (state.currentDifficulty == DifficultyLevel.master) {
          state.currentDifficulty = DifficultyLevel.advanced;
        } else if (state.currentDifficulty == DifficultyLevel.advanced) {
          state.currentDifficulty = DifficultyLevel.intermediate;
        } else if (state.currentDifficulty == DifficultyLevel.intermediate) {
          state.currentDifficulty = DifficultyLevel.beginner;
        }
        state.consecutiveMistakes = 0;
      }
    }

    return state;
  }

  /// Returns problems matching current difficulty and topic
  List<AdaptiveProblem> filterProblemsForState(
    List<AdaptiveProblem> allProblems,
    AdaptiveSessionState state,
  ) {
    var matched = allProblems.where((p) => p.difficulty == state.currentDifficulty).toList();
    if (matched.isEmpty) {
      // Fallback to closest available difficulty
      matched = allProblems;
    }
    return matched;
  }
}

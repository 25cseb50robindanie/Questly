import 'dart:convert';
import 'dart:math';
import '../core/locator.dart';

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  master,
}

class AdaptiveProblem {
  final String id;
  final String topic; // 'fractions', 'ratios', 'proportions', 'percentages', 'applications'
  final String category; // 'identification', 'comparison', 'equivalent', 'simplification', 'scaling', 'discount', 'word_problem'
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
  Set<String> activeMisconceptions;

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
    Set<String>? activeMisconceptions,
  }) : activeMisconceptions = activeMisconceptions ?? {};

  double get accuracy => totalAnswered > 0 ? (totalCorrect / totalAnswered) : 0.0;

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
    'activeMisconceptions': activeMisconceptions.toList(),
  };

  factory AdaptiveSessionState.fromJson(Map<String, dynamic> json) => AdaptiveSessionState(
    currentDifficulty: DifficultyLevel.values[(json['currentDifficulty'] as int? ?? 0).clamp(0, DifficultyLevel.values.length - 1)],
    consecutiveCorrect: json['consecutiveCorrect'] as int? ?? 0,
    consecutiveMistakes: json['consecutiveMistakes'] as int? ?? 0,
    totalAnswered: json['totalAnswered'] as int? ?? 0,
    totalCorrect: json['totalCorrect'] as int? ?? 0,
    confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.5,
    masteryScore: (json['masteryScore'] as num?)?.toDouble() ?? 0.0,
    streak: json['streak'] as int? ?? 0,
    hintLevel: json['hintLevel'] as int? ?? 0,
    activeMisconceptions: (json['activeMisconceptions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toSet() ??
        {},
  );
}

class AdaptiveLearningEngine {
  static final AdaptiveLearningEngine _instance = AdaptiveLearningEngine._internal();
  factory AdaptiveLearningEngine() => _instance;
  AdaptiveLearningEngine._internal();

  final Map<String, AdaptiveSessionState> _sessions = {};

  String _buildStorageKey(String studentId, String topic) => 'adaptive_session_${studentId}_$topic';

  AdaptiveSessionState getSession(String studentId, String topic) {
    final key = '${studentId}_$topic';
    if (_sessions.containsKey(key)) {
      return _sessions[key]!;
    }

    // Try restoring from local storage
    try {
      final raw = Locator.storageService.getString(_buildStorageKey(studentId, topic));
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final state = AdaptiveSessionState.fromJson(data);
        _sessions[key] = state;
        return state;
      }
    } catch (_) {}

    final newState = AdaptiveSessionState();
    _sessions[key] = newState;
    return newState;
  }

  void _persistSession(String studentId, String topic, AdaptiveSessionState state) {
    try {
      final raw = jsonEncode(state.toJson());
      Locator.storageService.setString(_buildStorageKey(studentId, topic), raw);
    } catch (_) {}
  }

  /// Evaluates strict Mastery conditions for unlocking Challenge (Lesson 4):
  /// 1. Minimum accuracy >= 80% (with at least 5 total answered questions)
  /// 2. Minimum mastery score >= 80% (0.80)
  /// 3. At least 5 consecutive correct answers (streak >= 5)
  /// 4. Zero active misconceptions remaining
  bool isMasteryAchieved(String studentId, String topic) {
    final state = getSession(studentId, topic);
    final hasEnoughAttempts = state.totalAnswered >= 5;
    final meetsAccuracy = state.accuracy >= 0.80;
    final meetsMastery = state.masteryScore >= 0.80;
    final meetsConsecutiveStreak = state.streak >= 5;
    final noActiveMisconceptions = state.activeMisconceptions.isEmpty;

    return hasEnoughAttempts &&
        meetsAccuracy &&
        meetsMastery &&
        meetsConsecutiveStreak &&
        noActiveMisconceptions;
  }

  /// Processes student answer and dynamically adjusts difficulty, confidence, and mastery
  AdaptiveSessionState recordAnswer({
    required String studentId,
    required String topic,
    required bool isCorrect,
    required DifficultyLevel problemDifficulty,
    int responseTimeSeconds = 5,
    String? triggeredMisconception,
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

      // Mastery calculation: higher difficulties reward more mastery
      final difficultyWeight = (problemDifficulty.index + 1) * 0.12;
      state.masteryScore = (state.masteryScore + difficultyWeight).clamp(0.0, 1.0);

      // Dynamic Difficulty Level Up: consecutive streak advances difficulty
      if (state.consecutiveCorrect >= 2) {
        if (state.currentDifficulty == DifficultyLevel.beginner) {
          state.currentDifficulty = DifficultyLevel.intermediate;
          state.consecutiveCorrect = 0;
        } else if (state.currentDifficulty == DifficultyLevel.intermediate) {
          state.currentDifficulty = DifficultyLevel.advanced;
          state.consecutiveCorrect = 0;
        } else if (state.currentDifficulty == DifficultyLevel.advanced && state.masteryScore >= 0.70) {
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

      // Slightly decrease mastery on mistakes
      state.masteryScore = (state.masteryScore - 0.05).clamp(0.0, 1.0);

      // Increase hint level
      state.hintLevel = min(state.hintLevel + 1, 2);

      // Track active misconception if detected
      if (triggeredMisconception != null && triggeredMisconception.isNotEmpty) {
        state.activeMisconceptions.add(triggeredMisconception);
      }

      // Dynamic Difficulty Level Down: 2 consecutive mistakes scales difficulty back
      if (state.consecutiveMistakes >= 2) {
        if (state.currentDifficulty == DifficultyLevel.master) {
          state.currentDifficulty = DifficultyLevel.advanced;
          state.consecutiveMistakes = 0;
        } else if (state.currentDifficulty == DifficultyLevel.advanced) {
          state.currentDifficulty = DifficultyLevel.intermediate;
          state.consecutiveMistakes = 0;
        } else if (state.currentDifficulty == DifficultyLevel.intermediate) {
          state.currentDifficulty = DifficultyLevel.beginner;
          state.consecutiveMistakes = 0;
        }
      }
    }

    _persistSession(studentId, topic, state);
    return state;
  }

  void resolveMisconception(String studentId, String topic, String misconceptionId) {
    final state = getSession(studentId, topic);
    state.activeMisconceptions.remove(misconceptionId);
    _persistSession(studentId, topic, state);
  }

  void resetSession(String studentId, String topic) {
    final key = '${studentId}_$topic';
    _sessions[key] = AdaptiveSessionState();
    _persistSession(studentId, topic, _sessions[key]!);
  }
}

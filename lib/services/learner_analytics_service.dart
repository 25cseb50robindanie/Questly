import 'dart:convert';
import 'storage_service.dart';

class LearnerAnalyticsService {
  final StorageService _storage;

  LearnerAnalyticsService(this._storage);

  Map<String, dynamic> getTopicAnalytics(String studentId, String topic) {
    final key = 'analytics_${studentId.toLowerCase()}_$topic';
    final raw = _storage.getString(key);
    if (raw == null) {
      return {
        'topic': topic,
        'mastery': 0.0,
        'confidence': 0.5,
        'totalAnswered': 0,
        'totalCorrect': 0,
        'misconceptionsEncountered': <String>[],
        'misconceptionsResolved': <String>[],
        'streak': 0,
        'bestStreak': 0,
      };
    }
    try {
      return json.decode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveTopicAnalytics(String studentId, String topic, Map<String, dynamic> data) async {
    final key = 'analytics_${studentId.toLowerCase()}_$topic';
    await _storage.setString(key, json.encode(data));
  }

  Future<void> recordMisconceptionResolved(String studentId, String topic, String misconceptionId) async {
    final analytics = getTopicAnalytics(studentId, topic);
    final resolved = List<String>.from(analytics['misconceptionsResolved'] ?? []);
    if (!resolved.contains(misconceptionId)) {
      resolved.add(misconceptionId);
      analytics['misconceptionsResolved'] = resolved;
      await saveTopicAnalytics(studentId, topic, analytics);
    }
  }
}

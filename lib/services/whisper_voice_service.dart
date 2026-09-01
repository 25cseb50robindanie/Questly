import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/locator.dart';
import 'localization_service.dart';

class TeachBackEvaluation {
  final int masteryScore;
  final bool isPassed;
  final int stars;
  final String feedbackTitle;
  final String feedbackBody;
  final List<String> conceptsIdentified;
  final List<String> missingConcepts;
  final String dendyMood;

  TeachBackEvaluation({
    required this.masteryScore,
    required this.isPassed,
    required this.stars,
    required this.feedbackTitle,
    required this.feedbackBody,
    required this.conceptsIdentified,
    required this.missingConcepts,
    required this.dendyMood,
  });

  factory TeachBackEvaluation.fromJson(Map<String, dynamic> json) {
    return TeachBackEvaluation(
      masteryScore: json['mastery_score'] as int? ?? 50,
      isPassed: json['is_passed'] as bool? ?? false,
      stars: json['stars'] as int? ?? 1,
      feedbackTitle: json['feedback_title'] as String? ?? 'Evaluation Complete',
      feedbackBody: json['feedback_body'] as String? ?? '',
      conceptsIdentified: (json['concepts_identified'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      missingConcepts: (json['missing_concepts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dendyMood: json['dendy_mood'] as String? ?? 'thinking',
    );
  }
}

class WhisperVoiceService extends ChangeNotifier {
  static final WhisperVoiceService _instance = WhisperVoiceService._internal();
  factory WhisperVoiceService() => _instance;
  WhisperVoiceService._internal();

  bool _isRecording = false;
  bool _isTranscribing = false;
  int _recordSeconds = 0;

  bool get isRecording => _isRecording;
  bool get isTranscribing => _isTranscribing;
  int get recordSeconds => _recordSeconds;

  String get _serverUrl {
    return Locator.storageService.getString('whisper_server_url') ?? 'http://127.0.0.1:8080';
  }

  /// Checks if the whisper.cpp server or local whisper service is online
  Future<bool> isServerAvailable() async {
    try {
      // Check standard health endpoint or root of whisper.cpp server
      final res = await http.get(Uri.parse('$_serverUrl/health')).timeout(const Duration(milliseconds: 1200));
      if (res.statusCode == 200) return true;
    } catch (_) {}

    try {
      final res = await http.get(Uri.parse(_serverUrl)).timeout(const Duration(milliseconds: 1200));
      return res.statusCode == 200 || res.statusCode == 404 || res.statusCode == 405;
    } catch (_) {
      return false;
    }
  }

  /// Transcribes audio bytes using the whisper.cpp server (/inference or /transcribe)
  Future<String?> transcribeAudio({
    required Uint8List audioBytes,
    String format = 'wav',
    String? language,
  }) async {
    _isTranscribing = true;
    notifyListeners();

    try {
      final activeLang = language ?? LocalizationService.currentLanguage;

      // 1. Try official whisper.cpp /inference multipart endpoint
      try {
        final uri = Uri.parse('$_serverUrl/inference');
        final request = http.MultipartRequest('POST', uri);
        request.fields['temperature'] = '0.0';
        request.fields['response_format'] = 'json';
        request.fields['language'] = activeLang;

        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            audioBytes,
            filename: 'audio.$format',
          ),
        );

        final streamed = await request.send().timeout(const Duration(seconds: 15));
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data is Map && data.containsKey('text')) {
            return (data['text'] as String).trim();
          }
        }
      } catch (_) {}

      // 2. Try JSON /transcribe-base64 endpoint
      final base64Audio = base64Encode(audioBytes);
      final response = await http.post(
        Uri.parse('$_serverUrl/transcribe-base64'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'audio_base64': base64Audio,
          'format': format,
          'language': activeLang,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text = data['text'] as String?;
        return text?.trim();
      }
    } catch (e) {
      debugPrint('[WhisperVoiceService Transcribe Error] $e');
    } finally {
      _isTranscribing = false;
      notifyListeners();
    }
    return null;
  }

  /// Evaluates student Teach-Back explanation using Whisper AI evaluator or local fallback
  Future<TeachBackEvaluation?> evaluateTeachBack({
    required String moduleId,
    required String transcript,
    String? language,
    String? topicTitle,
  }) async {
    final activeLang = language ?? LocalizationService.currentLanguage;
    try {
      final response = await http.post(
        Uri.parse('$_serverUrl/teachback/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'module_id': moduleId,
          'transcript': transcript,
          'language': activeLang,
          'topic_title': topicTitle ?? 'Density & Buoyancy',
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return TeachBackEvaluation.fromJson(data);
      }
    } catch (e) {
      debugPrint('[WhisperVoiceService TeachBack Server Error] $e');
    }

    // Local fallback evaluation rule engine
    return _localFallbackEvaluation(moduleId, transcript, activeLang);
  }

  TeachBackEvaluation _localFallbackEvaluation(String moduleId, String transcript, String lang) {
    final text = transcript.toLowerCase();

    int score = 40;
    List<String> found = [];
    List<String> missing = [];
    String title;
    String body;

    if (moduleId.contains('fraction')) {
      final hasParts = text.contains('part') || text.contains('equal') || text.contains('share');
      final hasNumDenom = text.contains('numerator') || text.contains('denominator') || text.contains('top') || text.contains('bottom');
      final hasWhole = text.contains('whole') || text.contains('total') || text.contains('divide');
      final hasEquivalent = text.contains('equivalent') || text.contains('equal') || text.contains('same');

      if (hasParts) { score += 15; found.add('equal_parts'); } else { missing.add('equal_parts'); }
      if (hasNumDenom) { score += 15; found.add('numerator_denominator'); } else { missing.add('numerator_denominator'); }
      if (hasWhole) { score += 15; found.add('whole_concept'); } else { missing.add('whole_concept'); }
      if (hasEquivalent) { score += 15; found.add('equivalent_fractions'); } else { missing.add('equivalent_fractions'); }

      final isPassed = score >= 60;
      title = isPassed ? 'Masterful Explanation!' : 'Good Effort! Keep Explaining.';
      body = isPassed
          ? 'You brilliantly explained how fractions represent equal parts of a whole and how numerators & denominators work!'
          : 'Remember to mention that the numerator is the selected parts and the denominator is the total equal parts of the whole!';

      return TeachBackEvaluation(
        masteryScore: score,
        isPassed: isPassed,
        stars: score >= 85 ? 3 : (score >= 65 ? 2 : 1),
        feedbackTitle: title,
        feedbackBody: body,
        conceptsIdentified: found,
        missingConcepts: missing,
        dendyMood: isPassed ? 'success' : 'thinking',
      );
    }

    // Default: Density & Buoyancy
    final hasMass = text.contains('mass') || text.contains('weight') || text.contains('heavy') || text.contains('atoms');
    final hasVol = text.contains('volume') || text.contains('space') || text.contains('size');
    final hasFormula = text.contains('density') || text.contains('divide') || text.contains('packed');
    final hasFloat = text.contains('float') || text.contains('sink') || text.contains('water') || text.contains('buoyan');

    if (hasMass) { score += 15; found.add('mass'); } else { missing.add('mass'); }
    if (hasVol) { score += 15; found.add('volume'); } else { missing.add('volume'); }
    if (hasFormula) { score += 15; found.add('density_formula'); } else { missing.add('density_formula'); }
    if (hasFloat) { score += 15; found.add('buoyancy'); } else { missing.add('buoyancy'); }

    final isPassed = score >= 60;
    final stars = score >= 85 ? 3 : (score >= 65 ? 2 : 1);

    title = isPassed ? 'Fantastic Teaching!' : 'Good Attempt! Add More Details.';
    body = isPassed
        ? 'You clearly explained how mass and volume determine whether an object floats or sinks!'
        : 'Try mentioning the density formula (mass ÷ volume) and how water displacement creates buoyant force.';

    return TeachBackEvaluation(
      masteryScore: score,
      isPassed: isPassed,
      stars: stars,
      feedbackTitle: title,
      feedbackBody: body,
      conceptsIdentified: found,
      missingConcepts: missing,
      dendyMood: isPassed ? 'success' : 'thinking',
    );
  }
}

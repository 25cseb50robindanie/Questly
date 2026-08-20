// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'localization_service.dart';

class ReadAloudService extends ChangeNotifier {
  static final ReadAloudService _instance = ReadAloudService._internal();
  factory ReadAloudService() => _instance;
  ReadAloudService._internal();

  bool _isSpeaking = false;
  String? _currentlySpeakingText;

  bool get isSpeaking => _isSpeaking;
  String? get currentlySpeakingText => _currentlySpeakingText;

  /// Speaks the provided text in the student's selected language
  void speak(
    String text, {
    String? languageCode,
    double rate = 0.95,
    double pitch = 1.1,
  }) {
    final activeLang = languageCode ?? LocalizationService.currentLanguage;

    // If already speaking this exact text, pressing it again stops playback
    if (_isSpeaking && _currentlySpeakingText == text) {
      stop();
      return;
    }

    // Cancel any previous speech
    stop();

    if (text.trim().isEmpty) return;

    // Translate English keys/phrases into the student's chosen language (Tamil, Hindi, or English)
    final spokenText = LocalizationService.translate(text, targetLanguage: activeLang);

    if (kIsWeb) {
      try {
        final synth = html.window.speechSynthesis;
        if (synth != null) {
          final utterance = html.SpeechSynthesisUtterance(spokenText);
          utterance.rate = rate; // 0.95 is ideal for learning comprehension
          utterance.pitch = pitch; // 1.1 gives Dendy a friendly tone
          utterance.volume = 1.0;

          // Map Questly language codes to standard BCP-47 locale tags
          switch (activeLang.toLowerCase()) {
            case 'ta':
              utterance.lang = 'ta-IN';
              break;
            case 'hi':
              utterance.lang = 'hi-IN';
              break;
            case 'en':
            default:
              utterance.lang = 'en-US';
          }

          utterance.onEnd.listen((_) {
            _isSpeaking = false;
            _currentlySpeakingText = null;
            notifyListeners();
          });

          utterance.onError.listen((_) {
            _isSpeaking = false;
            _currentlySpeakingText = null;
            notifyListeners();
          });

          _isSpeaking = true;
          _currentlySpeakingText = text;
          notifyListeners();

          synth.speak(utterance);
        }
      } catch (e) {
        debugPrint('[ReadAloudService Error] $e');
        _isSpeaking = false;
        _currentlySpeakingText = null;
        notifyListeners();
      }
    }
  }

  void stop() {
    if (kIsWeb) {
      try {
        final synth = html.window.speechSynthesis;
        if (synth != null) {
          synth.cancel();
        }
      } catch (_) {}
    }
    _isSpeaking = false;
    _currentlySpeakingText = null;
    notifyListeners();
  }

  bool isSpeakingThis(String text) {
    return _isSpeaking && _currentlySpeakingText == text;
  }
}

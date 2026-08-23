import 'package:flutter/foundation.dart';
import 'localization_service.dart';
import 'read_aloud_stub.dart' if (dart.library.html) 'read_aloud_web.dart';

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

    PlatformSpeechTts.speak(
      text: spokenText,
      languageCode: activeLang,
      rate: rate,
      pitch: pitch,
      onStart: () {
        _isSpeaking = true;
        _currentlySpeakingText = text;
        notifyListeners();
      },
      onEnd: () {
        _isSpeaking = false;
        _currentlySpeakingText = null;
        notifyListeners();
      },
      onError: () {
        _isSpeaking = false;
        _currentlySpeakingText = null;
        notifyListeners();
      },
    );
  }

  void stop() {
    PlatformSpeechTts.stop();
    _isSpeaking = false;
    _currentlySpeakingText = null;
    notifyListeners();
  }

  bool isSpeakingThis(String text) {
    return _isSpeaking && _currentlySpeakingText == text;
  }
}

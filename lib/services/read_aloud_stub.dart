import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlatformSpeechTts {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInit = false;

  static void _initHandlers(VoidCallback onStart, VoidCallback onEnd, VoidCallback onError) {
    if (!_isInit) {
      _isInit = true;
      _flutterTts.setStartHandler(() => onStart());
      _flutterTts.setCompletionHandler(() => onEnd());
      _flutterTts.setCancelHandler(() => onEnd());
      _flutterTts.setErrorHandler((msg) {
        debugPrint('[FlutterTts Error] $msg');
        onError();
      });
    }
  }

  static void speak({
    required String text,
    required String languageCode,
    required double rate,
    required double pitch,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required VoidCallback onError,
  }) async {
    try {
      _initHandlers(onStart, onEnd, onError);

      String locale;
      switch (languageCode.toLowerCase()) {
        case 'ta':
          locale = 'ta-IN';
          break;
        case 'hi':
          locale = 'hi-IN';
          break;
        case 'or':
          locale = 'or-IN';
          break;
        case 'en':
        default:
          locale = 'en-US';
      }

      await _flutterTts.setLanguage(locale);
      await _flutterTts.setSpeechRate(rate * 0.5);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.setVolume(1.0);

      onStart();
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('[TTS speak error] $e');
      onError();
    }
  }

  static void stop() {
    try {
      _flutterTts.stop();
    } catch (_) {}
  }
}

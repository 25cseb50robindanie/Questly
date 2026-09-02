import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PlatformSpeechTts {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInit = false;
  static VoidCallback? _currentOnStart;
  static VoidCallback? _currentOnEnd;
  static VoidCallback? _currentOnError;

  /// Transliterates Odia Unicode characters to corresponding Devanagari characters.
  /// Used as a phonetic bridge for systems without a native Odia TTS engine.
  static String odiaToDevanagari(String text) {
    final buffer = StringBuffer();
    for (final codeUnit in text.codeUnits) {
      if (codeUnit >= 0x0B01 && codeUnit <= 0x0B71) {
        buffer.writeCharCode(codeUnit - 0x0200);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  /// Transliterates Tamil Unicode characters to corresponding Devanagari characters.
  /// Used as a phonetic bridge when no native Tamil TTS voice engine is installed on the host OS.
  static String tamilToDevanagari(String text) {
    final buffer = StringBuffer();
    for (final codeUnit in text.codeUnits) {
      if (codeUnit >= 0x0B81 && codeUnit <= 0x0BFA) {
        if (codeUnit == 0x0BB4) {
          buffer.write('ळ');
        } else if (codeUnit == 0x0BB1) {
          buffer.write('ड़');
        } else if (codeUnit == 0x0BA9) {
          buffer.write('न');
        } else if (codeUnit == 0x0BA3) {
          buffer.write('ण');
        } else if (codeUnit == 0x0B9F) {
          buffer.write('ट');
        } else {
          buffer.writeCharCode(codeUnit - 0x0280);
        }
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }

  static void _initHandlers() {
    if (!_isInit) {
      _isInit = true;
      _flutterTts.setStartHandler(() {
        _currentOnStart?.call();
      });
      _flutterTts.setCompletionHandler(() {
        _currentOnEnd?.call();
      });
      _flutterTts.setCancelHandler(() {
        _currentOnEnd?.call();
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint('[FlutterTts Error] $msg');
        _currentOnError?.call();
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
      _currentOnStart = onStart;
      _currentOnEnd = onEnd;
      _currentOnError = onError;

      _initHandlers();

      await _flutterTts.stop();

      String locale;
      String textToSpeak = text;

      switch (languageCode.toLowerCase()) {
        case 'ta':
          bool hasNativeTamil = false;
          try {
            final res = await _flutterTts.isLanguageAvailable('ta-IN');
            hasNativeTamil = res == 1 || res == true;
          } catch (_) {}

          if (hasNativeTamil) {
            locale = 'ta-IN';
          } else {
            locale = 'hi-IN';
            textToSpeak = tamilToDevanagari(text);
          }
          break;
        case 'hi':
          locale = 'hi-IN';
          break;
        case 'or':
          bool hasNativeOdia = false;
          try {
            final res = await _flutterTts.isLanguageAvailable('or-IN');
            hasNativeOdia = res == 1 || res == true;
          } catch (_) {}

          if (hasNativeOdia) {
            locale = 'or-IN';
          } else {
            locale = 'hi-IN';
            textToSpeak = odiaToDevanagari(text);
          }
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
      await _flutterTts.speak(textToSpeak);
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

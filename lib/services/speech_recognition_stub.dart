import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

abstract class SpeechRecognitionInstance {
  void start({
    required String langCode,
    required bool continuous,
    required bool interimResults,
    required void Function() onStart,
    required void Function(String transcript) onResult,
    required void Function() onError,
    required void Function() onEnd,
  });
  void stop();
  void abort();
}

class NativeSpeechRecognitionInstance implements SpeechRecognitionInstance {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInit = false;
  bool _isListening = false;
  void Function()? _onEndCallback;

  @override
  void start({
    required String langCode,
    required bool continuous,
    required bool interimResults,
    required void Function() onStart,
    required void Function(String transcript) onResult,
    required void Function() onError,
    required void Function() onEnd,
  }) async {
    _onEndCallback = onEnd;

    try {
      if (!_isInit) {
        _isInit = await _speech.initialize(
          onStatus: (status) {
            debugPrint('[SpeechToText Status] $status');
            if (status == 'listening') {
              _isListening = true;
              onStart();
            } else if (status == 'notListening' || status == 'done') {
              if (_isListening) {
                _isListening = false;
                _onEndCallback?.call();
              }
            }
          },
          onError: (errorNotification) {
            debugPrint('[SpeechToText Error] ${errorNotification.errorMsg}');
            _isListening = false;
            onError();
          },
        );
      }

      if (!_isInit) {
        debugPrint('[SpeechToText] Initialization failed');
        onError();
        return;
      }

      // Convert locale code format (e.g., 'en-US' -> 'en_US', 'ta-IN' -> 'ta_IN')
      String targetLocale = langCode.replaceAll('-', '_');

      // Check available locales
      final locales = await _speech.locales();
      stt.LocaleName? matchedLocale;
      for (final loc in locales) {
        if (loc.localeId.toLowerCase() == targetLocale.toLowerCase() ||
            loc.localeId.toLowerCase().startsWith(langCode.split(RegExp(r'[-_]'))[0].toLowerCase())) {
          matchedLocale = loc;
          break;
        }
      }

      final localeIdToUse = matchedLocale?.localeId ?? targetLocale;

      await _speech.listen(
        onResult: (result) {
          final words = result.recognizedWords;
          if (words.isNotEmpty) {
            onResult(words);
          }
        },
        localeId: localeIdToUse,
        listenOptions: stt.SpeechListenOptions(
          listenMode: continuous ? stt.ListenMode.dictation : stt.ListenMode.confirmation,
          cancelOnError: false,
          partialResults: interimResults,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );

      _isListening = true;
      onStart();
    } catch (e) {
      debugPrint('[SpeechToText Exception] $e');
      _isListening = false;
      onError();
    }
  }

  @override
  void stop() async {
    try {
      _isListening = false;
      await _speech.stop();
      _onEndCallback?.call();
    } catch (_) {}
  }

  @override
  void abort() async {
    try {
      _isListening = false;
      await _speech.cancel();
      _onEndCallback?.call();
    } catch (_) {}
  }
}

class SpeechRecognitionPlatform {
  static bool get isSupported => true;
  static SpeechRecognitionInstance? create() => NativeSpeechRecognitionInstance();
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class PlatformSpeechTts {
  static void speak({
    required String text,
    required String languageCode,
    required double rate,
    required double pitch,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required VoidCallback onError,
  }) {
    try {
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        final utterance = html.SpeechSynthesisUtterance(text);
        utterance.rate = rate;
        utterance.pitch = pitch;
        utterance.volume = 1.0;

        switch (languageCode.toLowerCase()) {
          case 'ta':
            utterance.lang = 'ta-IN';
            break;
          case 'hi':
            utterance.lang = 'hi-IN';
            break;
          case 'or':
            utterance.lang = 'or-IN';
            break;
          case 'en':
          default:
            utterance.lang = 'en-US';
        }

        utterance.onEnd.listen((_) => onEnd());
        utterance.onError.listen((_) => onError());

        onStart();
        synth.speak(utterance);
      }
    } catch (e) {
      debugPrint('[ReadAloud Error] $e');
      onError();
    }
  }

  static void stop() {
    try {
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        synth.cancel();
      }
    } catch (_) {}
  }
}

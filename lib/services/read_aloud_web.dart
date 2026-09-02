// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';

class PlatformSpeechTts {
  static html.AudioElement? _activeAudio;
  static html.SpeechSynthesisUtterance? _activeUtterance;
  static html.SpeechSynthesisUtterance? get activeUtterance => _activeUtterance;

  /// Transliterates Odia Unicode characters to corresponding Devanagari characters.
  /// Used as a phonetic bridge for systems/browsers without a native Odia TTS engine.
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

  static void stop() {
    try {
      if (_activeAudio != null) {
        _activeAudio!.pause();
        _activeAudio = null;
      }
      final synth = html.window.speechSynthesis;
      if (synth != null) {
        synth.cancel();
      }
      _activeUtterance = null;
    } catch (_) {}
  }

  static html.SpeechSynthesisVoice? _findBestVoice(
    List<html.SpeechSynthesisVoice> voices,
    String languageCode,
  ) {
    if (voices.isEmpty) return null;
    final code = languageCode.toLowerCase().trim();

    if (code == 'ta') {
      // 1. Exact Tamil voice
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        final n = (v.name ?? '').toLowerCase();
        if (l.startsWith('ta') || n.contains('tamil')) return v;
      }
      // 2. Hindi voice (for Devanagari phonetic bridge)
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        final n = (v.name ?? '').toLowerCase();
        if (l.startsWith('hi') || n.contains('hindi')) return v;
      }
      // 3. Any Indian voice
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        if (l.contains('in')) return v;
      }
    } else if (code == 'hi') {
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        final n = (v.name ?? '').toLowerCase();
        if (l.startsWith('hi') || n.contains('hindi')) return v;
      }
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        if (l.contains('in')) return v;
      }
    } else if (code == 'or') {
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        final n = (v.name ?? '').toLowerCase();
        if (l.startsWith('or') || n.contains('odia') || n.contains('oriya')) return v;
      }
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        final n = (v.name ?? '').toLowerCase();
        if (l.startsWith('hi') || n.contains('hindi')) return v;
      }
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        if (l.contains('in')) return v;
      }
    } else {
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        if (l.startsWith('en-in')) return v;
      }
      for (final v in voices) {
        final l = (v.lang ?? '').toLowerCase();
        if (l.startsWith('en-us') || l.startsWith('en')) return v;
      }
    }

    return voices.isNotEmpty ? voices.first : null;
  }

  static void speak({
    required String text,
    required String languageCode,
    required double rate,
    required double pitch,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required VoidCallback onError,
  }) {
    stop();

    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      onEnd();
      return;
    }

    // 1. High-Fidelity Audio Stream (Google TTS Audio Pipeline)
    try {
      String queryText = cleanText;
      String langParam = languageCode.toLowerCase().trim();

      if (langParam == 'or') {
        // Transliterate Odia to Devanagari phonetics for Hindi Indic voice
        queryText = odiaToDevanagari(cleanText);
        langParam = 'hi';
      } else if (langParam != 'ta' && langParam != 'hi' && langParam != 'en') {
        langParam = 'en';
      }

      final encodedQuery = Uri.encodeComponent(queryText);
      final ttsUrl = 'https://translate.google.com/translate_tts?ie=UTF-8&q=$encodedQuery&tl=$langParam&client=tw-ob';

      final audio = html.AudioElement(ttsUrl);
      audio.setAttribute('referrerpolicy', 'no-referrer');
      audio.playbackRate = rate;
      _activeAudio = audio;

      bool hasStarted = false;

      audio.onPlay.listen((_) {
        hasStarted = true;
        onStart();
      });

      audio.onEnded.listen((_) {
        _activeAudio = null;
        onEnd();
      });

      audio.onError.listen((event) {
        _activeAudio = null;
        if (!hasStarted) {
          // Fallback to SpeechSynthesis if audio stream is blocked or unavailable
          _speakViaSpeechSynthesis(
            text: cleanText,
            languageCode: languageCode,
            rate: rate,
            pitch: pitch,
            onStart: onStart,
            onEnd: onEnd,
            onError: onError,
          );
        } else {
          onError();
        }
      });

      audio.play().catchError((err) {
        _activeAudio = null;
        _speakViaSpeechSynthesis(
          text: cleanText,
          languageCode: languageCode,
          rate: rate,
          pitch: pitch,
          onStart: onStart,
          onEnd: onEnd,
          onError: onError,
        );
      });
    } catch (_) {
      _speakViaSpeechSynthesis(
        text: cleanText,
        languageCode: languageCode,
        rate: rate,
        pitch: pitch,
        onStart: onStart,
        onEnd: onEnd,
        onError: onError,
      );
    }
  }

  static void _speakViaSpeechSynthesis({
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
      if (synth == null) {
        onError();
        return;
      }

      final voices = synth.getVoices();
      final matchedVoice = _findBestVoice(voices, languageCode);

      String textToSpeak = text;
      String targetLocale = 'en-US';

      if (languageCode == 'ta') {
        final bool hasNativeTamil = matchedVoice != null &&
            ((matchedVoice.lang ?? '').toLowerCase().startsWith('ta') ||
             (matchedVoice.name ?? '').toLowerCase().contains('tamil'));

        if (hasNativeTamil) {
          textToSpeak = text;
          targetLocale = matchedVoice.lang ?? 'ta-IN';
        } else {
          // Bridge Tamil script to Devanagari phonetics for Hindi / Indic voice engine
          textToSpeak = tamilToDevanagari(text);
          targetLocale = matchedVoice?.lang ?? 'hi-IN';
        }
      } else if (languageCode == 'hi') {
        targetLocale = matchedVoice?.lang ?? 'hi-IN';
      } else if (languageCode == 'or') {
        final bool hasNativeOdia = matchedVoice != null &&
            ((matchedVoice.lang ?? '').toLowerCase().startsWith('or') ||
             (matchedVoice.name ?? '').toLowerCase().contains('odia') ||
             (matchedVoice.name ?? '').toLowerCase().contains('oriya'));

        if (hasNativeOdia) {
          targetLocale = matchedVoice.lang ?? 'or-IN';
        } else {
          textToSpeak = odiaToDevanagari(text);
          targetLocale = matchedVoice?.lang ?? 'hi-IN';
        }
      } else {
        targetLocale = matchedVoice?.lang ?? 'en-US';
      }

      final utterance = html.SpeechSynthesisUtterance(textToSpeak);
      utterance.rate = rate;
      utterance.pitch = pitch;
      utterance.volume = 1.0;
      utterance.lang = targetLocale;

      if (matchedVoice != null) {
        utterance.voice = matchedVoice;
      }

      utterance.onStart.listen((_) {
        onStart();
      });

      utterance.onEnd.listen((_) {
        _activeUtterance = null;
        onEnd();
      });

      utterance.onError.listen((event) {
        debugPrint('[ReadAloud SpeechSynthesis Error] $event');
        _activeUtterance = null;
        onError();
      });

      _activeUtterance = utterance;

      // Delayed dispatch to prevent Chromium cancel-race bug
      Timer(const Duration(milliseconds: 40), () {
        try {
          if (synth.paused == true) {
            synth.resume();
          }
          synth.speak(utterance);
        } catch (_) {
          onError();
        }
      });
    } catch (e) {
      debugPrint('[ReadAloud Error] $e');
      _activeUtterance = null;
      onError();
    }
  }
}

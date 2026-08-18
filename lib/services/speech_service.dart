import 'dart:async';

abstract class SpeechToTextProvider {
  Future<bool> initialize();
  Future<void> startListening(Function(String text) onResult);
  Future<void> stopListening();
}

abstract class TextToSpeechProvider {
  Future<void> speak(String text, String languageCode);
  Future<void> stop();
}

// 1. Mock Speech to Text Simulator (for development/web testing)
class MockSpeechToTextProvider implements SpeechToTextProvider {
  bool _isListening = false;
  Timer? _timer;

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<void> startListening(Function(String text) onResult) async {
    _isListening = true;
    
    // Simulate student speech after 2 seconds
    _timer = Timer(const Duration(seconds: 2), () {
      if (!_isListening) return;
      
      final prompts = [
        "What is density?",
        "Why does a steel ship float?",
        "What is the density formula?",
        "Explain density using cricket.",
        "What is the capital of France?"
      ];
      
      // select randomly
      final index = DateTime.now().millisecond % prompts.length;
      onResult(prompts[index]);
      _isListening = false;
    });
  }

  @override
  Future<void> stopListening() async {
    _isListening = false;
    _timer?.cancel();
  }
}

// 2. Mock Text to Speech Simulator
class MockTextToSpeechProvider implements TextToSpeechProvider {
  @override
  Future<void> speak(String text, String languageCode) async {
    // Standard debug console log trace
    print("[MOCK TTS] Speaking in $languageCode: $text");
  }

  @override
  Future<void> stop() async {
    print("[MOCK TTS] Stopped speaking.");
  }
}

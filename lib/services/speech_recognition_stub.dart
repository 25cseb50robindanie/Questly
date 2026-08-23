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

class SpeechRecognitionPlatform {
  static bool get isSupported => false;
  static SpeechRecognitionInstance? create() => null;
}

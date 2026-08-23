import 'speech_recognition_stub.dart'
    if (dart.library.html) 'speech_recognition_web.dart';

export 'speech_recognition_stub.dart';

class SpeechRecognitionHelper {
  static bool get isSupported => SpeechRecognitionPlatform.isSupported;
  static SpeechRecognitionInstance? create() => SpeechRecognitionPlatform.create();
}

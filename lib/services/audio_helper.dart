import 'audio_helper_stub.dart'
    if (dart.library.html) 'audio_helper_web.dart';

class AudioHelper {
  static void playSound(String assetPath) {
    playNativeSound(assetPath);
  }
}

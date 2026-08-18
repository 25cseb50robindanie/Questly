import 'dart:html' as html;
import 'package:flutter/foundation.dart';

void playNativeSound(String assetPath) {
  try {
    // In Flutter web builds, the assets folder is located at assets/assets/...
    final url = 'assets/assets/$assetPath';
    final audio = html.AudioElement(url);
    audio.play();
  } catch (e) {
    debugPrint("Web audio error: $e");
  }
}

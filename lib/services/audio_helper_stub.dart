import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

void playNativeSound(String assetPath) {
  try {
    final player = AudioPlayer();
    player.play(AssetSource(assetPath));
  } catch (e) {
    debugPrint("Stub audio error: $e");
  }
}

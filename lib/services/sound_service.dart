import 'audio_helper.dart';

class SoundService {
  static bool soundEnabled = true;

  static Future<void> playClick() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playSwitch() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  // V0.3 Event-Driven Reward Sound hooks (with fallback safety)
  static Future<void> playRewardReveal() async {
    if (!soundEnabled) return;
    // Fallback to switch1 if specific reward_reveal.ogg is not present
    AudioHelper.playSound('audio/switch1.ogg');
  }

  static Future<void> playRewardClaim() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playCoinSpawn() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playCoinFly() async {
    if (!soundEnabled) return;
    // silent or click tick
  }

  static Future<void> playCoinCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  static Future<void> playXpCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  static Future<void> playCollectibleReveal() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  static Future<void> playChestOpen() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  static Future<void> playLevelUp() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }
}

import 'audio_helper.dart';

class SoundService {
  static bool soundEnabled = true;

  // 1. Button Click Sound (Updated to click2.ogg)
  static Future<void> playClick() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click2.ogg');
  }

  // 2. Switch / Interaction Toggle
  static Future<void> playSwitch() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/switch1.ogg');
  }

  // 3. Pop Sound (Star pop / Water splash / Object impact: 47313572-ui-pop-sound-316482.mp3)
  static Future<void> playStarPop() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playPop() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playWaterSplash() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  // 4. Level Up Fanfare (cartoon_music-correct-game-show-alert-499485.mp3)
  static Future<void> playLevelUp() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }

  // 5. Level Complete / 3 Stars Celebration (cartoon_music-correct-game-show-alert-499485.mp3)
  static Future<void> playLevelComplete() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }

  // 6. Reward Reveals & Claims
  static Future<void> playRewardReveal() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }

  static Future<void> playRewardClaim() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playCoinSpawn() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playCoinFly() async {
    if (!soundEnabled) return;
  }

  static Future<void> playCoinCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playXpCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playCollectibleReveal() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }

  static Future<void> playChestOpen() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }
}

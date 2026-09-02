import 'audio_helper.dart';

/// Questly Audio Service
/// 
/// Standardized audio triggers using the dedicated sound set:
/// - UI & Taps: `click1.ogg` / Pop (`47313572-ui-pop-sound-316482.mp3`)
/// - Next Lesson / Continue / Whoosh: `whoosh next.mp3`
/// - Rewards, Mystery Boxes & Claims: `coin gain.mp3`
/// - Achievements & Milestones: `arcade achievement.mp3`
/// - Level Completion Fanfare: `cartoon_music-correct-game-show-alert-499485.mp3`
class SoundService {
  static bool soundEnabled = true;

  // Rate-limiting timestamps for rapid events (e.g. slider drags, bubble bursts)
  static int _lastSliderTickMs = 0;
  static int _lastBubbleMs = 0;

  // =========================================================================
  // 1. UI SOUNDS (click1.ogg / Pop / whoosh next.mp3)
  // =========================================================================

  /// Standard crisp button tap (primary buttons, appbar actions)
  static Future<void> playClick() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playButtonTap() => playClick();

  /// Tactile card / option selection (quiz options, materials, apparatus)
  static Future<void> playCardSelect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  /// Toggle switch or segmented pill control
  static Future<void> playSwitch() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playToggle() => playSwitch();

  /// Slide-in drawer or modal panel open
  static Future<void> playPanelOpen() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Slide-out drawer or modal panel dismiss
  static Future<void> playPanelClose() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  /// Next lesson, roadmap advance, or quest continuation whoosh
  static Future<void> playContinue() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/whoosh next.mp3');
  }

  static Future<void> playWhoosh() => playContinue();

  /// Subtle slider movement tick (rate-limited to 60ms intervals)
  static Future<void> playSliderTick() async {
    if (!soundEnabled) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastSliderTickMs < 60) return;
    _lastSliderTickMs = now;
    AudioHelper.playSound('audio/click1.ogg');
  }

  // =========================================================================
  // 2. LEARNING & ADAPTIVE ENGINE HOOKS
  // =========================================================================

  /// Pop sound on correct answer or step completion
  static Future<void> playCorrect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playSuccess() => playCorrect();

  /// Encouraging soft click / tap on mistake (no harsh buzzer)
  static Future<void> playWrong() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  static Future<void> playSoftMistake() => playWrong();

  /// Dendy delivers a supportive hint or scaffolded clue
  static Future<void> playHintReveal() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Real-world example revealed or key concept insight unlocked
  static Future<void> playDiscoveryMoment() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/arcade achievement.mp3');
  }

  /// Easy Practice or supportive alternative pathway unlocked
  static Future<void> playSupportUnlocked() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/arcade achievement.mp3');
  }

  static Future<void> playEasyPracticeUnlocked() => playSupportUnlocked();

  /// Student demonstrates complete concept mastery (Teach-Back / Level 5)
  static Future<void> playMasteryCelebration() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/arcade achievement.mp3');
  }

  // =========================================================================
  // 3. REWARD & GAMIFICATION SOUNDS (coin gain.mp3 / arcade achievement.mp3)
  // =========================================================================

  /// Star popping into place during quest completion sequence
  static Future<void> playStarPop() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  static Future<void> playPop() => playStarPop();

  /// Coin spawning or popping up in reward sequence
  static Future<void> playCoinSpawn() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/coin gain.mp3');
  }

  /// Coin gain sound when collected into wallet
  static Future<void> playCoinCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/coin gain.mp3');
  }

  static Future<void> playCoinFly() async {
    if (!soundEnabled) return;
  }

  /// XP sparkle / collect sound
  static Future<void> playXpCollect() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/coin gain.mp3');
  }

  /// Mystery boxes, treasure chest open & claiming rewards
  static Future<void> playChestOpen() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/coin gain.mp3');
  }

  static Future<void> playRewardReveal() => playChestOpen();
  static Future<void> playCollectibleReveal() => playChestOpen();
  static Future<void> playRewardClaim() => playCoinCollect();

  /// Full-length celebration fanfare on level/quest completion
  static Future<void> playLevelComplete() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/cartoon_music-correct-game-show-alert-499485.mp3');
  }

  static Future<void> playLevelUp() => playLevelComplete();
  static Future<void> playCelebration() => playLevelComplete();

  /// Smaller achievements & milestone badges
  static Future<void> playAchievementUnlocked() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/arcade achievement.mp3');
  }

  // =========================================================================
  // 4. AMBIENT & EXPERIMENT PHYSICS SOUNDS
  // =========================================================================

  /// Water splash feedback
  static Future<void> playWaterSplash() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Object floating buoyant bob
  static Future<void> playFloat() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Object sinking into immersion depths
  static Future<void> playSink() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }

  /// Aquatic bubble pop
  static Future<void> playBubble() async {
    if (!soundEnabled) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastBubbleMs < 120) return;
    _lastBubbleMs = now;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Chemical reaction effervescence
  static Future<void> playExperimentReaction() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/47313572-ui-pop-sound-316482.mp3');
  }

  /// Mission milestone / laboratory step advancement whoosh
  static Future<void> playMissionAdvance() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/whoosh next.mp3');
  }

  /// Soft drop interaction
  static Future<void> playDrop() async {
    if (!soundEnabled) return;
    AudioHelper.playSound('audio/click1.ogg');
  }
}

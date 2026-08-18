import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';

class LevelUpDialog extends StatefulWidget {
  final int newLevel;
  final VoidCallback onDismissed;

  const LevelUpDialog({
    Key? key,
    required this.newLevel,
    required this.onDismissed,
  }) : super(key: key);

  @override
  _LevelUpDialogState createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animController.forward();
    SoundService.playClick();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _fadeAnim.value,
                child: child,
              ),
            );
          },
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorSystem.plum, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.purple.withOpacity(0.25),
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Badge Shield Visual
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorSystem.purple.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorSystem.purple, width: 2),
                  ),
                  child: VectorAssetHelper.levelRankIcon(
                    widget.newLevel,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                const Text(
                  'LEVEL UP!',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: ColorSystem.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LEVEL ${widget.newLevel}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Level Up Payout Cards (Production Vector Assets)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLevelUpRewardItem(
                      VectorAssetHelper.questCoinIcon(size: 24),
                      '+100',
                      'Quest Coins',
                    ),
                    const SizedBox(width: 12),
                    _buildLevelUpRewardItem(
                      VectorAssetHelper.xpStarIcon(size: 24),
                      '+50',
                      'Bonus XP',
                    ),
                    const SizedBox(width: 12),
                    _buildLevelUpRewardItem(
                      VectorAssetHelper.badgeIcon('Explorer', size: 24),
                      'RANK',
                      'Promoted',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                CustomButton(
                  text: 'CONTINUE ADVENTURE',
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  height: 42,
                  onPressed: () {
                    SoundService.playSwitch();
                    Navigator.pop(context);
                    widget.onDismissed();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelUpRewardItem(Widget iconWidget, String amount, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
      ),
      child: Column(
        children: [
          iconWidget,
          const SizedBox(height: 6),
          Text(
            amount,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: ColorSystem.purple,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

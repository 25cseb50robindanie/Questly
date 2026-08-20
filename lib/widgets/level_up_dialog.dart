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
    SoundService.playLevelUp();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isShort ? 20 : 40,
        vertical: isShort ? 10 : 20,
      ),
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
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isShort ? 380 : 420,
                constraints: BoxConstraints(
                  maxHeight: size.height * 0.92,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isShort ? 16 : 24,
                  vertical: isShort ? 12 : 20,
                ),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Top Badge Shield Visual
                      Container(
                        padding: EdgeInsets.all(isShort ? 8 : 14),
                        decoration: BoxDecoration(
                          color: ColorSystem.purple.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(color: ColorSystem.purple, width: 1.5),
                        ),
                        child: VectorAssetHelper.levelRankIcon(
                          widget.newLevel,
                          size: isShort ? 42 : 56,
                        ),
                      ),
                      SizedBox(height: isShort ? 6 : 10),

                      // Title
                      Text(
                        'LEVEL UP!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: isShort ? 18 : 22,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: ColorSystem.gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOU REACHED LEVEL ${widget.newLevel}!',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: isShort ? 10 : 14),

                      // Reward Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLevelUpRewardItem(
                            VectorAssetHelper.questCoinIcon(size: isShort ? 18 : 22),
                            '+100',
                            'Quest Coins',
                            isShort,
                          ),
                          SizedBox(width: isShort ? 8 : 12),
                          _buildLevelUpRewardItem(
                            VectorAssetHelper.xpStarIcon(size: isShort ? 18 : 22),
                            '+50',
                            'Bonus XP',
                            isShort,
                          ),
                          SizedBox(width: isShort ? 8 : 12),
                          _buildLevelUpRewardItem(
                            VectorAssetHelper.badgeIcon('Explorer', size: isShort ? 18 : 22),
                            'RANK',
                            'Promoted',
                            isShort,
                          ),
                        ],
                      ),
                      SizedBox(height: isShort ? 12 : 16),

                      CustomButton(
                        text: 'CONTINUE ADVENTURE',
                        backgroundColor: ColorSystem.purple,
                        textColor: Colors.white,
                        height: isShort ? 34 : 40,
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
              // Top-Right X Button
              Positioned(
                top: isShort ? 6 : 10,
                right: isShort ? 6 : 10,
                child: GestureDetector(
                  onTap: () {
                    SoundService.playClick();
                    Navigator.pop(context);
                    widget.onDismissed();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: ColorSystem.plum, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: ColorSystem.plum.withOpacity(0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: ColorSystem.plum, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelUpRewardItem(Widget iconWidget, String amount, String label, bool isShort) {
    return Container(
      width: isShort ? 85 : 95,
      padding: EdgeInsets.symmetric(
        vertical: isShort ? 6 : 8,
        horizontal: isShort ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
      ),
      child: Column(
        children: [
          iconWidget,
          SizedBox(height: isShort ? 3 : 5),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 10 : 11,
              fontWeight: FontWeight.w900,
              color: ColorSystem.purple,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isShort ? 7.5 : 8.5,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

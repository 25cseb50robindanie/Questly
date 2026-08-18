import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/localization_service.dart';

class QuestlyNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const QuestlyNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // Mobile landscape often has height < 360px
    final bool isCompact = screenHeight < 360;

    return Container(
      width: isCompact ? 70 : 82,
      decoration: const BoxDecoration(
        color: ColorSystem.cream,
        border: Border(
          right: BorderSide(color: ColorSystem.plum, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: isCompact ? 6 : 12),
            _buildNavItem(0, Icons.home_rounded, l('home'), isCompact),
            SizedBox(height: isCompact ? 6 : 12),
            _buildNavItem(1, Icons.explore_rounded, l('my_modules'), isCompact),
            SizedBox(height: isCompact ? 6 : 12),
            _buildNavItem(2, Icons.emoji_events_rounded, l('leaderboard'), isCompact),
            SizedBox(height: isCompact ? 6 : 12),
            _buildNavItem(3, Icons.auto_awesome_rounded, l('collection'), isCompact),
            SizedBox(height: isCompact ? 6 : 12),
            _buildNavItem(4, Icons.person_rounded, l('profile'), isCompact),
            SizedBox(height: isCompact ? 6 : 12),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isCompact) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        width: isCompact ? 60 : 70,
        height: isCompact ? 48 : 64,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? ColorSystem.lavender.withOpacity(0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? ColorSystem.plum : Colors.transparent,
            width: isActive ? 1.2 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.65),
              size: isCompact ? 18 : 24,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: isCompact ? 7.5 : 9,
                  fontWeight: FontWeight.bold,
                  color: isActive ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.55),
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

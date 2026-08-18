import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/localization_service.dart';
import 'custom_button.dart';

class LeaderboardPreview extends StatelessWidget {
  final VoidCallback onViewAllPressed;

  const LeaderboardPreview({
    Key? key,
    required this.onViewAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorSystem.plum, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: ColorSystem.plum.withOpacity(0.04),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with Trophy icon
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: ColorSystem.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                l('leaderboard').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.purple,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Description text
          Text(
            'See how you rank against your classmates in this week\'s learning quests!',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 11,
              color: ColorSystem.plum.withOpacity(0.7),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          // Action button leading to the full leaderboard
          CustomButton(
            text: l('view_leaderboard').toUpperCase(),
            backgroundColor: ColorSystem.cream,
            textColor: ColorSystem.plum,
            height: 38,
            onPressed: onViewAllPressed,
          ),
        ],
      ),
    );
  }
}

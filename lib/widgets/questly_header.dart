import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/localization_service.dart';
import 'xp_progress_bar.dart';
import 'resource_counter.dart';
import 'vector_asset_helper.dart';
import 'avatar_badge.dart';

class QuestlyHeader extends StatelessWidget {
  final Student student;
  final VoidCallback onSettingsPressed;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onProfilePressed;

  const QuestlyHeader({
    Key? key,
    required this.student,
    required this.onSettingsPressed,
    required this.onNotificationsPressed,
    required this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.studentRepository,
      builder: (context, _) {
        final currentStudent = Locator.studentRepository.getCurrentStudent() ?? student;
        final unreadCount = Locator.notificationRepository.getUnreadCount(currentStudent.questlyId);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: const BoxDecoration(
            color: ColorSystem.cream,
            border: Border(
              bottom: BorderSide(color: ColorSystem.plum, width: 2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Brand Logo & greeting
              Row(
                children: [
                  Image.asset(
                    'assets/images/questly_logo.png',
                    height: 30,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'QUESTLY',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${l('greeting_hi')}, ${currentStudent.displayName}!',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorSystem.plum,
                    ),
                  ),
                ],
              ),

              // Center: Student Level & XP Progress
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorSystem.purple,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ColorSystem.plum, width: 1.5),
                    ),
                    child: Text(
                      '${l('level')} ${currentStudent.level}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  XpProgressBar(
                    currentXp: currentStudent.xp,
                    level: currentStudent.level,
                    width: 130,
                  ),
                ],
              ),

              // Right: Coins, Alerts Bell, Profile, Settings Gears
              Row(
                children: [
                  ResourceCounter(
                    iconWidget: VectorAssetHelper.questCoinIcon(size: 20),
                    value: '${currentStudent.gold}',
                    label: 'Coins',
                  ),
                  const SizedBox(width: 14),
                  
                  // Notifications bell with badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: ColorSystem.plum, size: 24),
                        onPressed: onNotificationsPressed,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: const BoxDecoration(
                              color: ColorSystem.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Profile Avatar trigger (equipped avatar badge)
                  GestureDetector(
                    onTap: onProfilePressed,
                    child: AvatarBadge(
                      avatarId: currentStudent.equippedAvatarId,
                      size: 28,
                      showRarityBorder: true,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Settings Gear trigger
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: ColorSystem.plum, size: 24),
                    onPressed: onSettingsPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

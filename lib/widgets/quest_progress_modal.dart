import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';

enum QuestLessonStatus {
  completed,
  current,
  locked,
}

class QuestLessonData {
  final String id;
  final String title;
  final QuestLessonStatus status;
  final int? xpReward;

  const QuestLessonData({
    required this.id,
    required this.title,
    required this.status,
    this.xpReward,
  });
}

class QuestProgressModal extends StatelessWidget {
  final String questBadge;
  final String questTitle;
  final String? objective;
  final List<QuestLessonData> lessons;
  final int? xpReward;
  final int? coinReward;
  final int earnedStars;
  final VoidCallback onStartQuest;
  final void Function(QuestLessonData lesson)? onStartLesson;
  final VoidCallback? onClose;

  const QuestProgressModal({
    Key? key,
    this.questBadge = 'QUEST 1',
    required this.questTitle,
    this.objective,
    required this.lessons,
    this.xpReward,
    this.coinReward,
    this.earnedStars = 0,
    required this.onStartQuest,
    this.onStartLesson,
    this.onClose,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    String questBadge = 'QUEST 1',
    required String questTitle,
    String? objective,
    required List<QuestLessonData> lessons,
    int? xpReward,
    int? coinReward,
    int earnedStars = 0,
    required VoidCallback onStartQuest,
    void Function(QuestLessonData lesson)? onStartLesson,
  }) {
    return showDialog(
      context: context,
      builder: (context) => QuestProgressModal(
        questBadge: questBadge,
        questTitle: questTitle,
        objective: objective,
        lessons: lessons,
        xpReward: xpReward,
        coinReward: coinReward,
        earnedStars: earnedStars,
        onStartQuest: onStartQuest,
        onStartLesson: onStartLesson,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isShortScreen = size.height < 450;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: size.height * 0.92,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isShortScreen ? 16 : 20,
              vertical: isShortScreen ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: ColorSystem.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorSystem.plum, width: 2),
              boxShadow: [
                BoxShadow(
                  color: ColorSystem.plum.withOpacity(0.18),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header: Quest badge + Title + Close (X) button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: ColorSystem.purple,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            questBadge.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          questTitle.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: isShortScreen ? 13 : 15,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (onClose != null) {
                          onClose!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: isShortScreen ? 8 : 12),

                // 2. Center Content Body
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mission Objective Box if provided
                        if (objective != null && objective!.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MISSION OBJECTIVE',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: ColorSystem.purple,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  objective!,
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    color: ColorSystem.plum.withOpacity(0.85),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Section Title: Lessons in this Level
                        const Text(
                          'LESSONS IN THIS LEVEL',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.purple,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Five Lesson Cards (Vertical List)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < lessons.length; i++) ...[
                                if (i > 0) const SizedBox(height: 3),
                                _buildLessonCard(context, lessons[i]),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Rewards Info (if rewards provided)
                        if (xpReward != null || coinReward != null) ...[
                          const Text(
                            'POSSIBLE REWARDS',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (xpReward != null)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      VectorAssetHelper.xpStarIcon(size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+$xpReward XP',
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: ColorSystem.plum,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (coinReward != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      VectorAssetHelper.questCoinIcon(size: 13),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+$coinReward Coins',
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: ColorSystem.plum,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isShortScreen ? 6 : 10),

                // 3. Bottom Section: Large Purple Button (START QUEST)
                CustomButton(
                  text: 'START QUEST',
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  height: isShortScreen ? 38 : 42,
                  onPressed: () {
                    SoundService.playClick();
                    Navigator.pop(context);
                    onStartQuest();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, QuestLessonData lesson) {
    Color bg;
    Color border;
    Widget statusIcon;
    String badgeText;
    Color badgeTextColor;
    Color badgeBgColor;
    bool isClickable = false;

    switch (lesson.status) {
      case QuestLessonStatus.completed:
        bg = ColorSystem.green.withOpacity(0.12);
        border = ColorSystem.green;
        statusIcon = const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 15);
        badgeText = 'COMPLETED';
        badgeTextColor = ColorSystem.green;
        badgeBgColor = ColorSystem.green.withOpacity(0.2);
        isClickable = true;
        break;

      case QuestLessonStatus.current:
        bg = ColorSystem.purple.withOpacity(0.10);
        border = ColorSystem.purple;
        statusIcon = const Icon(Icons.play_circle_fill_rounded, color: ColorSystem.purple, size: 15);
        badgeText = 'PLAY';
        badgeTextColor = ColorSystem.purple;
        badgeBgColor = ColorSystem.purple.withOpacity(0.18);
        isClickable = true;
        break;

      case QuestLessonStatus.locked:
      default:
        bg = Colors.grey.shade100;
        border = Colors.grey.shade300;
        statusIcon = Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 13);
        badgeText = 'LOCKED';
        badgeTextColor = Colors.grey.shade500;
        badgeBgColor = Colors.transparent;
        isClickable = false;
        break;
    }

    return GestureDetector(
      onTap: isClickable
          ? () {
              SoundService.playClick();
              Navigator.pop(context);
              if (onStartLesson != null) {
                onStartLesson!(lesson);
              } else {
                onStartQuest();
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                statusIcon,
                const SizedBox(width: 6),
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: isClickable ? FontWeight.w900 : FontWeight.normal,
                    color: isClickable ? ColorSystem.plum : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: badgeTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

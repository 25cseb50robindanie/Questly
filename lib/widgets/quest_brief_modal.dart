import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/roadmap_node.dart';
import '../models/reward_definition.dart';
import '../models/roadmap_enums.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';
import '../services/localization_service.dart';

class QuestBriefModal extends StatelessWidget {
  final RoadmapNode node;
  final RoadmapNodeStatus status;
  final String studentId;
  final VoidCallback onStartQuest;
  final void Function(String lessonId)? onStartLesson;

  const QuestBriefModal({
    Key? key,
    required this.node,
    required this.status,
    required this.studentId,
    required this.onStartQuest,
    this.onStartLesson,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final earnedStars = Locator.progressionService.getNodeStars(studentId, node);
    final rewards = Locator.roadmapRepository.getRewardsForNode(node);
    final isLocked = status == RoadmapNodeStatus.locked;
    final isClaimable = status == RoadmapNodeStatus.claimable;
    final isCompleted = status == RoadmapNodeStatus.completed;
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
                // 1. Header Row: Mission Badge + Title + Close Button
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
                            '${l('quest').toUpperCase()} ${node.order}',
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
                          l(node.title).toUpperCase(),
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
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: isShortScreen ? 8 : 12),

                // 2. Scrollable Center Body
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quest Description & Objective Box
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
                              Text(
                                l('mission_objective_title'),
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                node.description.isNotEmpty
                                    ? l(node.description)
                                    : l('Master the fundamental physics concepts and complete the interactive lab simulations.'),
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

                        // Meta Details: Level Lessons List (for Level 1) or General Info
                        if (node.levelId == 'density_lvl1') ...[
                          Text(
                            l('lessons_in_this_level'),
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                            ),
                            child: Column(
                              children: [
                                _buildLessonRow(context, studentId, 'density_les1', '1. ${l('curiosity')}', isFirst: true),
                                const SizedBox(height: 3),
                                _buildLessonRow(context, studentId, 'density_les2', '2. ${l('experiment')}', isFirst: false),
                                const SizedBox(height: 3),
                                _buildLessonRow(context, studentId, 'density_les3', '3. ${l('apply')}', isFirst: false),
                                const SizedBox(height: 3),
                                _buildLessonRow(context, studentId, 'density_les4', '4. ${l('challenge')}', isFirst: false),
                                const SizedBox(height: 3),
                                _buildLessonRow(context, studentId, 'density_les5', '5. ${l('teach_dendy')}', isFirst: false),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else if (node.levelId != null &&
                            (node.levelId == 'fractions_lvl1' ||
                             node.levelId == 'ratios_lvl1' ||
                             node.levelId == 'fractions_lvl2' ||
                             node.levelId == 'proportions_lvl1' ||
                             node.levelId == 'percentages_lvl1' ||
                             node.levelId == 'applications_lvl1')) ...[
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
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                            ),
                            child: Builder(
                              builder: (context) {
                                final prefix = node.levelId == 'fractions_lvl1'
                                    ? 'fractions'
                                    : (node.levelId == 'ratios_lvl1' || node.levelId == 'fractions_lvl2'
                                        ? 'ratios'
                                        : (node.levelId == 'proportions_lvl1'
                                            ? 'proportions'
                                            : (node.levelId == 'percentages_lvl1'
                                                ? 'percentages'
                                                : 'applications')));
                                return Column(
                                  children: [
                                    _buildLessonRow(context, studentId, '${prefix}_les1', '1. Concept Learning', isFirst: true),
                                    const SizedBox(height: 3),
                                    _buildLessonRow(context, studentId, '${prefix}_les2', '2. Visual Understanding'),
                                    const SizedBox(height: 3),
                                    _buildLessonRow(context, studentId, '${prefix}_les3', '3. Guided Practice'),
                                    const SizedBox(height: 3),
                                    _buildLessonRow(context, studentId, '${prefix}_les4', '4. Challenge'),
                                    const SizedBox(height: 3),
                                    _buildLessonRow(context, studentId, '${prefix}_les5', '5. Teach Dendy'),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else ...[
                          Row(
                            children: [
                              // Est Time & Activities
                              Expanded(
                                flex: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, color: ColorSystem.purple, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        l('estimated_time_activities'),
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: ColorSystem.plum,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // 3-Star Rating Status
                              Expanded(
                                flex: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ColorSystem.gold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: ColorSystem.gold.withOpacity(0.35), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (int i = 1; i <= 3; i++) ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: VectorAssetHelper.xpStarIcon(
                                            size: 15,
                                            isFilled: i <= earnedStars,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Possible Rewards Breakdown
                        if (rewards.isNotEmpty) ...[
                          Text(
                            l('possible_rewards_title'),
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.purple,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: rewards.map((reward) {
                              Widget rewardIcon;
                              String rewardText = '';
                              if (reward.type == RewardType.xp) {
                                rewardIcon = VectorAssetHelper.xpStarIcon(size: 13);
                                rewardText = '+${reward.amount} XP';
                              } else if (reward.type == RewardType.coins) {
                                rewardIcon = VectorAssetHelper.questCoinIcon(size: 13);
                                rewardText = '+${reward.amount} ${l('quest_coins')}';
                              } else {
                                rewardIcon = VectorAssetHelper.collectibleIcon('diamond', size: 13);
                                rewardText = l(reward.name);
                              }

                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    rewardIcon,
                                    const SizedBox(width: 4),
                                    Text(
                                      rewardText,
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: ColorSystem.plum,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                ),

                SizedBox(height: isShortScreen ? 6 : 10),

                // 3. Bottom CTA Button
                CustomButton(
                  text: isLocked
                      ? l('locked_quest')
                      : (isClaimable
                          ? l('open_reward_chest')
                          : (isCompleted ? l('replay_quest') : l('start_quest'))),
                  backgroundColor: isLocked ? Colors.grey.shade400 : ColorSystem.purple,
                  textColor: Colors.white,
                  height: isShortScreen ? 38 : 42,
                  onPressed: isLocked
                      ? () {}
                      : () {
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

  Widget _buildLessonRow(
    BuildContext context,
    String studentId,
    String lessonId,
    String title, {
    bool isFirst = false,
    bool isInitialCompleted = false,
    bool isInitialUnlocked = false,
  }) {
    final isDone = isInitialCompleted || Locator.progressionService.isLessonCompleted(studentId, lessonId);
    final isUnlocked = isDone || isFirst || isInitialUnlocked || Locator.progressionService.isLessonUnlocked(studentId, lessonId);

    Color bg = Colors.white;
    Color border = ColorSystem.plum.withOpacity(0.12);
    Widget statusIcon;

    if (isDone) {
      bg = ColorSystem.green.withOpacity(0.10);
      border = ColorSystem.green;
      statusIcon = const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 15);
    } else if (isUnlocked) {
      bg = ColorSystem.purple.withOpacity(0.08);
      border = ColorSystem.purple;
      statusIcon = const Icon(Icons.play_circle_fill_rounded, color: ColorSystem.purple, size: 15);
    } else {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      statusIcon = Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 13);
    }

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              SoundService.playClick();
              Navigator.pop(context);
              if (onStartLesson != null) {
                onStartLesson!(lessonId);
              } else {
                onStartQuest();
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  title,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: isUnlocked ? FontWeight.w900 : FontWeight.normal,
                    color: isUnlocked ? ColorSystem.plum : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isDone
                    ? ColorSystem.green.withOpacity(0.2)
                    : (isUnlocked ? ColorSystem.purple.withOpacity(0.15) : Colors.transparent),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isDone ? 'COMPLETED' : (isUnlocked ? 'PLAY' : 'LOCKED'),
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isDone
                      ? ColorSystem.green
                      : (isUnlocked ? ColorSystem.purple : Colors.grey.shade500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/roadmap_node.dart';
import '../models/reward_definition.dart';
import '../models/roadmap_enums.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';

class QuestBriefModal extends StatelessWidget {
  final RoadmapNode node;
  final RoadmapNodeStatus status;
  final String studentId;
  final VoidCallback onStartQuest;

  const QuestBriefModal({
    Key? key,
    required this.node,
    required this.status,
    required this.studentId,
    required this.onStartQuest,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final earnedStars = Locator.progressionService.getNodeStars(studentId, node);
    final rewards = Locator.roadmapRepository.getRewardsForNode(node);
    final isLocked = status == RoadmapNodeStatus.locked;
    final isClaimable = status == RoadmapNodeStatus.claimable;
    final isCompleted = status == RoadmapNodeStatus.completed;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Container(
          width: 460,
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Mission Badge + Title + Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorSystem.purple,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'QUEST ${node.order}',
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
                        node.title.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.plum,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: ColorSystem.plum, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quest Description & Objective Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
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
                    const SizedBox(height: 4),
                    Text(
                      node.description.isNotEmpty
                          ? node.description
                          : 'Master the fundamental physics concepts and complete the interactive lab simulations.',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11.5,
                        color: ColorSystem.plum.withOpacity(0.85),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Meta Details Row (Activity Count, Est. Time, Star Progress)
              Row(
                children: [
                  // Est Time & Activities
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.timer_outlined, color: ColorSystem.purple, size: 14),
                              SizedBox(width: 4),
                              Text(
                                '~8 Mins • 3 Activities',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: ColorSystem.plum,
                                ),
                              ),
                            ],
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
                                size: 16,
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
              const SizedBox(height: 12),

              // Possible Rewards Breakdown
              if (rewards.isNotEmpty) ...[
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
                const SizedBox(height: 6),
                Row(
                  children: rewards.map((reward) {
                    Widget rewardIcon;
                    String rewardText = '';
                    if (reward.type == RewardType.xp) {
                      rewardIcon = VectorAssetHelper.xpStarIcon(size: 14);
                      rewardText = '+${reward.amount} XP';
                    } else if (reward.type == RewardType.coins) {
                      rewardIcon = VectorAssetHelper.questCoinIcon(size: 14);
                      rewardText = '+${reward.amount} Coins';
                    } else {
                      rewardIcon = VectorAssetHelper.collectibleIcon('diamond', size: 14);
                      rewardText = reward.name;
                    }

                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.plum,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // CTA Button (START QUEST / LOCKED / CLAIM REWARD)
              CustomButton(
                text: isLocked
                    ? 'LOCKED QUEST'
                    : (isClaimable
                        ? 'OPEN REWARD CHEST'
                        : (isCompleted ? 'REPLAY QUEST' : 'START QUEST')),
                backgroundColor: isLocked ? Colors.grey.shade400 : ColorSystem.purple,
                textColor: Colors.white,
                height: 42,
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
    );
  }
}

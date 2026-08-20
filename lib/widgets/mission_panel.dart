import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/mission.dart';
import '../models/student.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import 'custom_button.dart';
import 'vector_asset_helper.dart';

class MissionPanel extends StatefulWidget {
  final Student student;

  const MissionPanel({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  _MissionPanelState createState() => _MissionPanelState();
}

class _MissionPanelState extends State<MissionPanel> {
  MissionType _selectedTab = MissionType.daily;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.missionService,
      builder: (context, _) {
        final sId = widget.student.questlyId.toLowerCase();
        final dailyMissions = Locator.missionService.getDailyMissions(sId);
        final weeklyMissions = Locator.missionService.getWeeklyMissions(sId);
        final currentMissions = _selectedTab == MissionType.daily ? dailyMissions : weeklyMissions;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ColorSystem.plum.withOpacity(0.18), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: ColorSystem.purple.withOpacity(0.06),
                offset: const Offset(0, 3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Tab Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      VectorAssetHelper.badgeIcon('Explorer', size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedTab == MissionType.daily ? l('daily_missions') : l('weekly_missions'),
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: ColorSystem.purple,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Daily / Weekly Toggle Pills
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: ColorSystem.lavender.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ColorSystem.plum.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTabPill(l('daily'), MissionType.daily),
                        _buildTabPill(l('weekly'), MissionType.weekly),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Missions List (horizontal scroll on short landscape or row/columns)
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: currentMissions.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final mission = currentMissions[index];
                    return _buildMissionCard(mission);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabPill(String title, MissionType type) {
    final isSelected = _selectedTab == type;
    return GestureDetector(
      onTap: () {
        SoundService.playSwitch();
        setState(() {
          _selectedTab = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? ColorSystem.purple : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : ColorSystem.plum.withOpacity(0.65),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isDone = mission.isCompleted;
    final isClaimed = mission.isClaimed;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isClaimed
            ? ColorSystem.green.withOpacity(0.06)
            : (isDone ? ColorSystem.gold.withOpacity(0.08) : ColorSystem.cream.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isClaimed
              ? ColorSystem.green.withOpacity(0.3)
              : (isDone ? ColorSystem.gold : ColorSystem.plum.withOpacity(0.15)),
          width: isDone && !isClaimed ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title & Rewards Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l(mission.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VectorAssetHelper.questCoinIcon(size: 13),
                  const SizedBox(width: 2),
                  Text(
                    '+${mission.coinReward}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.gold,
                    ),
                  ),
                  if (mission.xpReward > 0) ...[
                    const SizedBox(width: 4),
                    VectorAssetHelper.xpStarIcon(size: 13),
                    const SizedBox(width: 2),
                    Text(
                      '+${mission.xpReward}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.purple,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Progress Bar & Numbers
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROGRESS',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    '${mission.current} / ${mission.target}',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: mission.progressFraction,
                  minHeight: 6,
                  backgroundColor: ColorSystem.plum.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDone ? ColorSystem.green : ColorSystem.purple,
                  ),
                ),
              ),
            ],
          ),

          // Action / Status Button
          if (isClaimed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: ColorSystem.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    l('claimed_btn'),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.green,
                    ),
                  ),
                ],
              ),
            )
          else if (isDone)
            GestureDetector(
              onTap: () {
                Locator.missionService.claimMission(
                  widget.student.questlyId,
                  mission.id,
                  mission.type,
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: ColorSystem.gold,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: ColorSystem.gold.withOpacity(0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${l('claim_reward_btn')} 🎉',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.plum,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ColorSystem.plum.withOpacity(0.1)),
              ),
              child: Center(
                child: Text(
                  '${mission.current} / ${mission.target}',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum.withOpacity(0.45),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../services/localization_service.dart';
import '../widgets/vector_asset_helper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  int _getCompletedModulesCount(String studentId) {
    final modules = Locator.moduleRepository.getModules();
    final progressList = Locator.progressRepository.getProgressList(studentId);
    int completedModules = 0;

    for (var m in modules) {
      int total = 0;
      int completed = 0;
      for (var lvl in m.levels) {
        for (var les in lvl.lessons) {
          total++;
          if (progressList.any((p) => p.lessonId == les.id && p.status == 'completed')) {
            completed++;
          }
        }
      }
      if (total > 0 && completed == total) {
        completedModules++;
      }
    }
    return completedModules;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Locator.studentRepository, Locator.collectionRepository]),
      builder: (context, _) {
        final Student? student = Locator.studentRepository.getCurrentStudent();
        if (student == null) return const SizedBox();

        final completedModules = _getCompletedModulesCount(student.questlyId);
        final badgesCount = Locator.collectionRepository.getUnlockedBadges(student.questlyId.toLowerCase()).length;
        final collectiblesCount = Locator.collectionRepository.getCollectibles(student.questlyId.toLowerCase()).where((i) => i.isUnlocked).length;

        final double screenHeight = MediaQuery.of(context).size.height;
        final bool isCompact = screenHeight < 360;

    // Avatar column child
    final Widget avatarColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: isCompact ? 60 : 80,
          height: isCompact ? 60 : 80,
          decoration: BoxDecoration(
            color: ColorSystem.lavender.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(color: ColorSystem.plum, width: 2),
          ),
          child: Icon(
            Icons.face_retouching_natural_rounded,
            color: ColorSystem.purple,
            size: isCompact ? 32 : 44,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          student.displayName,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorSystem.plum,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'ID: ${student.questlyId}',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 10,
            color: ColorSystem.plum.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VectorAssetHelper.levelRankIcon(student.level, size: 22),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ColorSystem.purple,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'LEVEL ${student.level}',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // Stats grid child using Production Vector Assets
    final Widget statsGrid = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            _buildStatCard(l('TOTAL XP'), '${student.xp}', VectorAssetHelper.xpStarIcon(size: 16)),
            const SizedBox(width: 8),
            _buildStatCard(l('COINS'), '${student.gold}', VectorAssetHelper.questCoinIcon(size: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(l('COMPLETED'), '$completedModules ${l('modules')}', const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 16)),
            const SizedBox(width: 8),
            _buildStatCard(l('BADGES'), '$badgesCount ${l('earned')}', VectorAssetHelper.badgeIcon('Explorer', size: 16)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard(l('COLLECTIBLES'), '$collectiblesCount ${l('unlocked')}', VectorAssetHelper.collectibleIcon('diamond', size: 16)),
            const SizedBox(width: 8),
            _buildStatCard(l('OFFLINE SYNC'), l('ready'), const Icon(Icons.cloud_done_rounded, color: ColorSystem.purple, size: 16)),
          ],
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l('profile').toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: ColorSystem.purple,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Main layout grid
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isCompact ? 12 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ColorSystem.plum, width: 2),
              ),
              child: isCompact
                  ? SingleChildScrollView(
                      child: Column(
                        children: [
                          avatarColumn,
                          const SizedBox(height: 12),
                          const Divider(color: ColorSystem.cream, thickness: 1.5),
                          const SizedBox(height: 8),
                          statsGrid,
                        ],
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: avatarColumn,
                        ),
                        const VerticalDivider(width: 32, thickness: 1.5, color: ColorSystem.cream),
                        Expanded(
                          flex: 12,
                          child: statsGrid,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  },
);
  }

  Widget _buildStatCard(String label, String value, Widget iconWidget) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: ColorSystem.cream.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                iconWidget,
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: ColorSystem.plum.withOpacity(0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorSystem.plum,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


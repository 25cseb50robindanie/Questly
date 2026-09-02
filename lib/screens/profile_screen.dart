import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../core/theme/theme_manager.dart';
import '../models/shop_item.dart';
import '../models/student.dart';
import '../services/localization_service.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/vector_asset_helper.dart';
import 'shop_screen.dart';

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

  int _getTotalModulesCount() {
    return Locator.moduleRepository.getModules().length;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        Locator.studentRepository,
        Locator.shopRepository,
        Locator.collectionRepository,
      ]),
      builder: (context, _) {
        final Student? student = Locator.studentRepository.getCurrentStudent();
        if (student == null) return const SizedBox();

        final completedModules = _getCompletedModulesCount(student.questlyId);
        final totalModules = _getTotalModulesCount();
        final currentTheme = ThemeManager.getTheme(student.equippedThemeId);
        final dendySkinItem = ShopCatalog.getItemById(student.equippedDendySkinId);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Profile Showcase Card
                _buildProfileShowcaseCard(context, student, currentTheme, dendySkinItem),

                const SizedBox(height: 14),

                // 2. Progression & Statistics Grid
                _buildStatsGrid(student, completedModules, totalModules, currentTheme),

                const SizedBox(height: 14),

                // 3. Equipped Cosmetics Summary & Quick Shop Access
                _buildCosmeticsDeck(context, student, currentTheme, dendySkinItem),

                const SizedBox(height: 14),

                // 4. Logout Action
                CustomButton(
                  text: l('logout').toUpperCase(),
                  backgroundColor: ColorSystem.purple,
                  textColor: Colors.white,
                  height: 40,
                  onPressed: () async {
                    await Locator.authService.logout();
                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileShowcaseCard(
    BuildContext context,
    Student student,
    QuestlyThemeData theme,
    ShopItem? dendySkinItem,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.borderColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Equipped Avatar Badge
          AvatarBadge(
            avatarId: student.equippedAvatarId,
            size: 80,
            showRarityBorder: true,
            isEquipped: true,
          ),
          const SizedBox(width: 16),

          // User Identity & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.plum,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${student.questlyId}',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 11,
                    color: ColorSystem.plum.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),

                // Level Badge & XP Progress Pill
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'LEVEL ${student.level}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColorSystem.gold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ColorSystem.gold, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VectorAssetHelper.xpStarIcon(size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${student.xp} XP',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: ColorSystem.plum,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Customize Shortcut Button
          IconButton(
            icon: const Icon(Icons.shopping_bag_rounded, color: ColorSystem.purple, size: 26),
            tooltip: l('shop'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => Scaffold(
                    appBar: AppBar(
                      title: Text(l('shop_title'), style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
                      backgroundColor: theme.cardBackground,
                      foregroundColor: ColorSystem.plum,
                      elevation: 0,
                    ),
                    body: const ShopScreen(isStandalone: true),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: ColorSystem.pink, size: 26),
            tooltip: l('logout'),
            onPressed: () async {
              await Locator.authService.logout();
              Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    Student student,
    int completedModules,
    int totalModules,
    QuestlyThemeData theme,
  ) {
    return Row(
      children: [
        // Coin Wallet
        Expanded(
          child: _buildMetricTile(
            title: l('coins'),
            value: '${student.gold}',
            icon: VectorAssetHelper.questCoinIcon(size: 22),
            accentColor: ColorSystem.gold,
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),

        // Longest Streak
        Expanded(
          child: _buildMetricTile(
            title: l('streak'),
            value: '${student.longestStreak} ${l('days')}',
            icon: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 22),
            accentColor: const Color(0xFFF97316),
            theme: theme,
          ),
        ),
        const SizedBox(width: 10),

        // Modules Completed
        Expanded(
          child: _buildMetricTile(
            title: l('completed'),
            value: '$completedModules / $totalModules',
            icon: const Icon(Icons.verified_rounded, color: ColorSystem.green, size: 22),
            accentColor: ColorSystem.green,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required Widget icon,
    required Color accentColor,
    required QuestlyThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.borderColor, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: theme.borderColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon,
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum.withValues(alpha: 0.55),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmeticsDeck(
    BuildContext context,
    Student student,
    QuestlyThemeData theme,
    ShopItem? dendySkinItem,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.borderColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l('equipped_cosmetics').toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => Scaffold(
                        appBar: AppBar(
                          title: Text(l('shop_title'), style: const TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.white,
                          foregroundColor: ColorSystem.plum,
                          elevation: 0,
                        ),
                        body: const ShopScreen(isStandalone: true),
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      l('change_in_shop'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.purple,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios_rounded, color: ColorSystem.purple, size: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Equipped Dendy Skin Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorSystem.lavender.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: DendyMascot(
                          size: 44,
                          skinId: student.equippedDendySkinId,
                          mood: DendyMood.happy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l('equipped_dendy'),
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9,
                                color: ColorSystem.plum.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              dendySkinItem != null ? l(dendySkinItem.nameKey) : l('dendy_classic'),
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Equipped Theme Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: theme.backgroundGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.borderColor, width: 1.5),
                        ),
                        child: const Icon(Icons.palette_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l('active_theme'),
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9,
                                color: ColorSystem.plum.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              l(theme.nameKey),
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

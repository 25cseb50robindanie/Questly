import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../models/collectible.dart';
import '../models/reward.dart';
import 'shop_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/resource_counter.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../widgets/vector_asset_helper.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({Key? key}) : super(key: key);

  @override
  _CollectionScreenState createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadState();
  }

  void _loadState() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Handle purchasing cosmetics
  Future<void> _handlePurchase(Reward reward) async {
    final currentStudent = Locator.studentRepository.getCurrentStudent();
    if (currentStudent == null) return;

    if (currentStudent.gold < reward.cost) {
      // Insufficient balance: display Dendy confused dialog
      SoundService.playSwitch(); // error feedback
      _showPurchaseResponse(
        title: 'INSUFFICIENT COINS',
        message: l('insufficient_coins'),
        state: DendyState.confused,
      );
      return;
    }

    // Process purchase
    final sId = currentStudent.questlyId.toLowerCase();
    final success = await Locator.collectionRepository.purchaseReward(sId, reward.id);

    if (success) {
      // Deduct coins & update student profile
      final updatedStudent = currentStudent.copyWith(
        gold: currentStudent.gold - reward.cost,
      );
      await Locator.studentRepository.updateStudentProfile(updatedStudent);
      _loadState();

      SoundService.playClick(); // success sound
      _showPurchaseResponse(
        title: 'PURCHASE SUCCESSFUL!',
        message: 'You unlocked: ${reward.name}! Go to Profile settings to customize your explorer theme.',
        state: DendyState.success,
      );
    } else {
      // Already owned
      _showPurchaseResponse(
        title: 'ALREADY OWNED',
        message: l('already_owned'),
        state: DendyState.thinking,
      );
    }
  }

  void _showPurchaseResponse({required String title, required String message, required DendyState state}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorSystem.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: ColorSystem.plum, width: 2),
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontWeight: FontWeight.w900,
              color: ColorSystem.plum,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DendyMascot(
                state: state,
                size: 72,
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 13,
                  color: ColorSystem.plum.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'AWESOME',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  color: ColorSystem.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Locator.studentRepository, Locator.collectionRepository]),
      builder: (context, _) {
        final currentStudent = Locator.studentRepository.getCurrentStudent();
        if (currentStudent == null) {
          return const Center(child: CircularProgressIndicator());
        }
        _student = currentStudent;

        final sId = currentStudent.questlyId.toLowerCase();
        final unlockedBadges = Locator.collectionRepository.getUnlockedBadges(sId);
        final allBadges = Locator.collectionRepository.getAvailableBadges();
        final collectibles = Locator.collectionRepository.getCollectibles(sId);
        final shopRewards = Locator.collectionRepository.getShopRewards(sId);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l('collection').toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: ColorSystem.purple,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Current Coin Balance
                  ResourceCounter(
                    iconWidget: VectorAssetHelper.questCoinIcon(size: 16),
                    value: '${currentStudent.gold}',
                    label: l('coins'),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Custom TabBar
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: ColorSystem.lavender.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorSystem.plum, width: 1.2),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: ColorSystem.purple,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ColorSystem.plum.withValues(alpha: 0.7),
                  labelPadding: EdgeInsets.zero,
                  labelStyle: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: l('shop').toUpperCase()),
                    Tab(text: l('badges').toUpperCase()),
                    Tab(text: l('collectibles').toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // TabBar Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Full Questly Shop with Avatars, Dendy Skins, and Themes
                    const ShopScreen(isStandalone: false),
                    // 2. Badges Grid
                    _buildBadgesGrid(allBadges, unlockedBadges),
                    // 3. Collectibles Grid
                    _buildCollectiblesGrid(collectibles),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // View grids builders
  Widget _buildBadgesGrid(List<String> allBadges, List<String> unlocked) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: allBadges.length,
      itemBuilder: (context, index) {
        final badgeName = allBadges[index];
        final isUnlocked = unlocked.contains(badgeName);

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnlocked ? ColorSystem.purple : ColorSystem.plum.withOpacity(0.2),
              width: isUnlocked ? 2 : 1.5,
            ),
            boxShadow: [
              if (isUnlocked)
                BoxShadow(
                  color: ColorSystem.purple.withOpacity(0.12),
                  offset: const Offset(0, 3),
                  blurRadius: 6,
                )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VectorAssetHelper.badgeIcon(
                badgeName,
                size: 38,
                isUnlocked: isUnlocked,
              ),
              const SizedBox(height: 6),
              Text(
                l(badgeName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isUnlocked ? ColorSystem.green.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isUnlocked ? l('completed').toUpperCase() : l('locked').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: isUnlocked ? ColorSystem.green : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCollectiblesGrid(List<Collectible> list) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.isUnlocked ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.isUnlocked ? ColorSystem.cream : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.isUnlocked ? ColorSystem.plum.withOpacity(0.2) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: VectorAssetHelper.collectibleIcon(
                    item.iconName,
                    size: 32,
                    isUnlocked: item.isUnlocked,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l(item.name),
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: item.isUnlocked ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.4),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: item.isUnlocked ? ColorSystem.purple.withOpacity(0.12) : Colors.grey.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.isUnlocked ? l('shop_owned') : l('locked').toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                              color: item.isUnlocked ? ColorSystem.purple : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l(item.description),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 9.5,
                        color: ColorSystem.plum.withOpacity(item.isUnlocked ? 0.65 : 0.35),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopGrid(List<Reward> rewards) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.1,
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final item = rewards[index];

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorSystem.plum, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColorSystem.cream,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorSystem.plum.withOpacity(0.2), width: 1),
                ),
                child: Center(
                  child: VectorAssetHelper.shopRewardIcon(item.assetPath, size: 30),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l(item.name),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            VectorAssetHelper.questCoinIcon(size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${item.cost}',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ColorSystem.plum,
                              ),
                            ),
                          ],
                        ),
                        CustomButton(
                          text: item.isPurchased ? l('shop_owned') : l('shop_buy'),
                          backgroundColor: item.isPurchased ? ColorSystem.cream : ColorSystem.purple,
                          textColor: item.isPurchased ? ColorSystem.plum : Colors.white,
                          width: 76,
                          height: 28,
                          onPressed: item.isPurchased ? () {} : () => _handlePurchase(item),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


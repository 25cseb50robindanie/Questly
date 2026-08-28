import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../core/theme/theme_manager.dart';
import '../models/shop_item.dart';
import '../models/student.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';
import '../widgets/avatar_badge.dart';
import '../widgets/custom_button.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/resource_counter.dart';
import '../widgets/vector_asset_helper.dart';

class ShopScreen extends StatefulWidget {
  final bool isStandalone;

  const ShopScreen({
    Key? key,
    this.isStandalone = false,
  }) : super(key: key);

  @override
  _ShopScreenState createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ShopCategory _selectedCategory = ShopCategory.avatar;
  ItemRarity? _selectedRarity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = ShopCategory.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleBuy(ShopItem item, Student student) async {
    if (student.gold < item.price) {
      SoundService.playSwitch();
      _showFeedbackDialog(
        title: l('insufficient_coins'),
        message: l('need_more_coins'),
        mascotState: DendyState.confused,
      );
      return;
    }

    final success = await Locator.shopRepository.purchaseItem(student.questlyId, item.id);
    if (!mounted) return;

    if (success) {
      _showPurchaseSuccessDialog(item);
    }
  }

  Future<void> _handleEquip(ShopItem item, Student student) async {
    await Locator.shopRepository.equipItem(student.questlyId, item.id);
    if (!mounted) return;
    SoundService.playClick();
  }

  void _showFeedbackDialog({
    required String title,
    required String message,
    required DendyState mascotState,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorSystem.plum, width: 2),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: ColorSystem.plum,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DendyMascot(size: 60, state: mascotState),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 13,
                color: ColorSystem.plum,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: CustomButton(
              text: l('close'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseSuccessDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: ColorSystem.gold, width: 2.5),
        ),
        title: Text(
          l('item_unlocked').toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: ColorSystem.plum,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorSystem.gold.withValues(alpha: 0.15),
              ),
              child: _buildItemPreview(item, size: 70, isEquipped: true),
            ),
            const SizedBox(height: 10),
            Text(
              l(item.nameKey),
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: ColorSystem.purple,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l('equipped_auto_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 12,
                color: ColorSystem.plum.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: CustomButton(
              text: l('awesome'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        Locator.studentRepository,
        Locator.shopRepository,
      ]),
      builder: (context, _) {
        final student = Locator.studentRepository.getCurrentStudent();
        if (student == null) return const SizedBox();

        final currentTheme = ThemeManager.currentTheme();

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isStandalone ? 12 : 0,
              vertical: widget.isStandalone ? 8 : 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Shop Header Bar (Only when opened in standalone mode)
                if (widget.isStandalone) ...[
                  _buildShopHeader(student, currentTheme),
                  const SizedBox(height: 6),
                ],

                // 2. Category Tabs (Compact 30px selector)
                _buildCategoryTabs(),

                const SizedBox(height: 6),

                // 3. Items Grid
                Expanded(
                  child: _buildItemsGrid(student),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopHeader(Student student, QuestlyThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderColor, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Text(
                l('shop_title'),
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: ColorSystem.plum,
                ),
              ),
            ],
          ),

          // Live Coin Wallet Badge
          ResourceCounter(
            iconWidget: VectorAssetHelper.questCoinIcon(size: 16),
            value: '${student.gold}',
            label: l('coins'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: ColorSystem.lavender.withValues(alpha: 0.18),
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
        unselectedLabelColor: ColorSystem.plum,
        labelPadding: EdgeInsets.zero,
        labelStyle: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
        tabs: [
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.face_rounded, size: 13),
                const SizedBox(width: 4),
                Text(l('category_avatars')),
              ],
            ),
          ),
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_fix_high_rounded, size: 13),
                const SizedBox(width: 4),
                Text(l('category_dendy')),
              ],
            ),
          ),
          Tab(
            iconMargin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.palette_rounded, size: 13),
                const SizedBox(width: 4),
                Text(l('category_themes')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(Student student) {
    final items = Locator.shopRepository.getItemsByCategory(_selectedCategory);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 720
            ? 5
            : (constraints.maxWidth > 540
                ? 4
                : (constraints.maxWidth > 360 ? 3 : 2));

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.92,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isOwned = Locator.shopRepository.isItemOwned(student.questlyId, item.id);
            final isEquipped = Locator.shopRepository.isItemEquipped(student, item);

            return _buildItemCard(item, isOwned, isEquipped, student);
          },
        );
      },
    );
  }

  Widget _buildItemCard(ShopItem item, bool isOwned, bool isEquipped, Student student) {
    final rarityColor = _getRarityColor(item.rarity);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEquipped ? ColorSystem.green : (isOwned ? ColorSystem.plum : rarityColor),
          width: isEquipped ? 2.0 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEquipped ? ColorSystem.green : rarityColor).withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Rarity & Status Tag
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: rarityColor, width: 0.8),
                  ),
                  child: Text(
                    l('rarity_${item.rarity.name}').toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                      color: rarityColor,
                    ),
                  ),
                ),
                if (isEquipped)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: ColorSystem.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l('equipped').toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Visual Preview
          Expanded(
            child: Center(
              child: _buildItemPreview(item, size: 44, isEquipped: isEquipped),
            ),
          ),

          // Name and Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l(item.nameKey),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: ColorSystem.plum,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Action Button
          Padding(
            padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
            child: _buildActionButton(item, isOwned, isEquipped, student),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(ShopItem item, {required double size, required bool isEquipped}) {
    switch (item.category) {
      case ShopCategory.avatar:
        return AvatarBadge(
          avatarId: item.id,
          size: size,
          isEquipped: isEquipped,
        );

      case ShopCategory.dendySkin:
        return SizedBox(
          width: size,
          height: size,
          child: DendyMascot(
            size: size,
            skinId: item.id,
            mood: DendyMood.happy,
          ),
        );

      case ShopCategory.theme:
        final theme = ThemeManager.getTheme(item.id);
        return Container(
          width: size,
          height: size * 0.75,
          decoration: BoxDecoration(
            gradient: theme.backgroundGradient,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: size * 0.4,
              height: size * 0.4,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: theme.borderColor, width: 1.5),
              ),
              child: Icon(Icons.palette_rounded, color: Colors.white, size: size * 0.22),
            ),
          ),
        );
    }
  }

  Widget _buildActionButton(ShopItem item, bool isOwned, bool isEquipped, Student student) {
    if (isEquipped) {
      return Container(
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColorSystem.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ColorSystem.green, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, color: ColorSystem.green, size: 12),
            const SizedBox(width: 3),
            Text(
              l('equipped'),
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: ColorSystem.green,
              ),
            ),
          ],
        ),
      );
    }

    if (isOwned) {
      return SizedBox(
        height: 24,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorSystem.purple,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: EdgeInsets.zero,
          ),
          onPressed: () => _handleEquip(item, student),
          child: Text(
            l('equip'),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    // Buy Button with Price Tag
    final canAfford = student.gold >= item.price;

    return SizedBox(
      height: 24,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: canAfford ? ColorSystem.gold : Colors.grey.shade300,
          foregroundColor: canAfford ? ColorSystem.plum : Colors.grey.shade600,
          elevation: canAfford ? 1 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        onPressed: () => _handleBuy(item, student),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VectorAssetHelper.questCoinIcon(size: 12),
            const SizedBox(width: 3),
            Text(
              '${item.price}',
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return const Color(0xFF64748B);
      case ItemRarity.rare:
        return const Color(0xFF3B82F6);
      case ItemRarity.epic:
        return const Color(0xFF8B5CF6);
      case ItemRarity.legendary:
        return const Color(0xFFF59E0B);
    }
  }
}

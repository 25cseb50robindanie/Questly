import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/color_system.dart';

class VectorAssetHelper {
  // Base path for clean vector UI assets
  static const String baseStyloo = 'assets/vector_ui';

  // Build SVG icon widget with fallback
  static Widget getVectorIcon({
    required String path,
    double size = 24,
    Color? color,
    IconData fallbackIcon = Icons.stars_rounded,
  }) {
    final fullPath = '$baseStyloo/$path';
    return SvgPicture.asset(
      fullPath,
      width: size,
      height: size,
      colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, size: size, color: color ?? ColorSystem.purple);
      },
    );
  }

  // 1. Primary Quest Coin Asset (Consistently used across all screens)
  static Widget questCoinIcon({double size = 24, int variant = 1, Color? color}) {
    final coinNumber = ((variant - 1) % 5) + 1;
    return getVectorIcon(
      path: 'icons/coin$coinNumber.svg',
      size: size,
      color: color,
      fallbackIcon: Icons.monetization_on_rounded,
    );
  }

  // 2. Primary XP / Energy Star Asset
  static Widget xpStarIcon({double size = 24, Color? color, bool empty = false, bool? isFilled, bool variant = false}) {
    final isStarEmpty = isFilled != null ? !isFilled : empty;
    final name = variant
        ? (isStarEmpty ? 'star2empty.svg' : 'star2.svg')
        : (isStarEmpty ? 'starempty.svg' : 'star.svg');
    return getVectorIcon(
      path: 'icons/$name',
      size: size,
      color: color,
      fallbackIcon: Icons.star_rounded,
    );
  }

  // 3. Reward Chest & Mystery Box Assets
  static Widget chestIcon({double size = 48, bool isOpen = false, bool isEpic = false}) {
    if (isEpic) {
      return getVectorIcon(
        path: 'icons/gold1.svg',
        size: size,
        fallbackIcon: Icons.card_giftcard_rounded,
      );
    }
    return getVectorIcon(
      path: isOpen ? 'icons/gift_red_open.svg' : 'icons/gift_red_closed.svg',
      size: size,
      fallbackIcon: Icons.card_giftcard_rounded,
    );
  }

  // 4. Badges & Medals Assets
  static Widget badgeIcon(String badgeName, {double size = 32, bool isUnlocked = true}) {
    String file = 'badge.svg';
    switch (badgeName.toLowerCase()) {
      case 'explorer':
      case 'explorer badge':
        file = isUnlocked ? 'badge.svg' : 'badge_OUT.svg';
        break;
      case 'scientist':
      case 'science token':
        file = isUnlocked ? 'scroll_badge.svg' : 'scroll_badge_OUT.svg';
        break;
      case 'float master':
      case 'rare float badge':
        file = isUnlocked ? 'badgeheart1.svg' : 'badgeheart2.svg';
        break;
      case 'density master':
      case 'density explorer':
      case 'mastery':
        file = isUnlocked ? 'trophy.svg' : 'trophy_OUT.svg';
        break;
      default:
        file = isUnlocked ? 'badge.svg' : 'badge_OUT.svg';
    }

    return getVectorIcon(
      path: 'icons/$file',
      size: size,
      fallbackIcon: isUnlocked ? Icons.workspace_premium_rounded : Icons.lock_outline_rounded,
    );
  }

  // 5. Collectibles Assets
  static Widget collectibleIcon(String key, {double size = 32, bool isUnlocked = true}) {
    String file = 'star2.svg';
    final normalized = key.toLowerCase();

    if (normalized.contains('star')) {
      file = 'star2.svg';
    } else if (normalized.contains('token') || normalized.contains('science') || normalized.contains('book')) {
      file = 'book_magic_purple.svg';
    } else if (normalized.contains('map') || normalized.contains('scroll')) {
      file = 'scroll.svg';
    } else if (normalized.contains('badge')) {
      file = isUnlocked ? 'badge.svg' : 'badge_OUT.svg';
    } else if (normalized.contains('water')) {
      file = 'water.svg';
    } else if (normalized.contains('crystal') || normalized.contains('diamond')) {
      file = 'diamond.svg';
    } else {
      file = 'star2.svg';
    }

    final widget = getVectorIcon(
      path: 'icons/$file',
      size: size,
      fallbackIcon: Icons.layers_rounded,
    );

    if (!isUnlocked) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      0.5, 0,
        ]),
        child: widget,
      );
    }
    return widget;
  }

  // 6. Shop Items Assets
  static Widget shopRewardIcon(String id, {double size = 32}) {
    switch (id) {
      case 'reward_hat':
        return getVectorIcon(path: 'icons/potion_purple.svg', size: size);
      case 'reward_frame':
        return getVectorIcon(path: 'frames/frame0.svg', size: size);
      case 'reward_bg':
        return getVectorIcon(path: 'frames backgrounds/CIRCLE_GREEN_roundpattern.svg', size: size);
      case 'reward_chest':
        return getVectorIcon(path: 'icons/gift_red_closed.svg', size: size);
      default:
        if (id.startsWith('assets/vector_ui/')) {
          return getVectorIcon(path: id.replaceFirst('assets/vector_ui/', ''), size: size);
        }
        return getVectorIcon(path: 'icons/gift_red_closed.svg', size: size);
    }
  }

  // 7. Lock & Key Icons
  static Widget lockIcon({double size = 24, bool isLocked = true, Color? color}) {
    return getVectorIcon(
      path: isLocked ? 'icons/lock.svg' : 'icons/key.svg',
      size: size,
      color: color,
      fallbackIcon: isLocked ? Icons.lock_rounded : Icons.key_rounded,
    );
  }

  // Crown & Rank Icons
  static Widget crownIcon({double size = 32, Color? color}) {
    return getVectorIcon(
      path: 'icons/trophy.svg',
      size: size,
      color: color,
      fallbackIcon: Icons.military_tech_rounded,
    );
  }

  static Widget magicBookIcon({double size = 32, Color? color}) {
    return getVectorIcon(
      path: 'icons/book_magic_purple.svg',
      size: size,
      color: color,
      fallbackIcon: Icons.menu_book_rounded,
    );
  }

  static Widget levelRankIcon(int rankLevel, {double size = 48}) {
    final rankIndex = (rankLevel % 4);
    return getVectorIcon(
      path: 'levelup/rank_$rankIndex.svg',
      size: size,
      fallbackIcon: Icons.military_tech_rounded,
    );
  }
}


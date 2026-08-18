import 'package:flutter/material.dart';
import 'vector_asset_helper.dart';

// 1. Vector Quest Gem
class QuestGemWidget extends StatelessWidget {
  final double size;
  const QuestGemWidget({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.collectibleIcon('diamond', size: size);
  }
}

// 2. Vector Knowledge Shard
class KnowledgeShardWidget extends StatelessWidget {
  final double size;
  const KnowledgeShardWidget({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.collectibleIcon('book', size: size);
  }
}

// 3. Vector Focus Potion
class FocusPotionWidget extends StatelessWidget {
  final double size;
  const FocusPotionWidget({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.shopRewardIcon('reward_hat', size: size);
  }
}

// 4. Vector Epic Winged / Gold Chest
class EpicChestWidget extends StatelessWidget {
  final double size;
  const EpicChestWidget({Key? key, this.size = 90}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.chestIcon(size: size, isEpic: true);
  }
}

// 5. Basic Chest Vector
class BasicChestWidget extends StatelessWidget {
  final double size;
  const BasicChestWidget({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.chestIcon(size: size, isEpic: false, isOpen: false);
  }
}

// 6. Mystery Gift Box Vector
class MysteryGiftWidget extends StatelessWidget {
  final double size;
  const MysteryGiftWidget({Key? key, this.size = 48}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VectorAssetHelper.chestIcon(size: size, isEpic: false, isOpen: false);
  }
}


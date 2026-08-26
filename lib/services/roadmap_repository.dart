import '../models/roadmap_node.dart';
import '../models/roadmap_enums.dart';
import '../models/reward_definition.dart';

class RoadmapRepository {
  // Static seed data for rewards
  final Map<String, RewardDefinition> _rewards = {
    // Node 1 rewards
    'rew_density_n1': RewardDefinition(
      id: 'rew_density_n1',
      type: RewardType.xp,
      name: 'Introduction XP Boost',
      amount: 50,
      rarity: RewardRarity.common,
    ),
    // Node 2 rewards
    'rew_density_n2': RewardDefinition(
      id: 'rew_density_n2',
      type: RewardType.coins,
      name: 'Mystery Coin Sack',
      amount: 10,
      rarity: RewardRarity.common,
    ),
    // Node 3 rewards
    'rew_density_n3_xp': RewardDefinition(
      id: 'rew_density_n3_xp',
      type: RewardType.xp,
      name: 'Mass & Volume XP',
      amount: 75,
      rarity: RewardRarity.common,
    ),
    'rew_density_n3_coins': RewardDefinition(
      id: 'rew_density_n3_coins',
      type: RewardType.coins,
      name: 'Mass & Volume Coins',
      amount: 10,
      rarity: RewardRarity.common,
    ),
    // Node 4 rewards (Side Quest)
    'rew_density_side_xp': RewardDefinition(
      id: 'rew_density_side_xp',
      type: RewardType.xp,
      name: 'Dendy Challenge Bonus',
      amount: 30,
      rarity: RewardRarity.rare,
    ),
    'rew_density_side_coins': RewardDefinition(
      id: 'rew_density_side_coins',
      type: RewardType.coins,
      name: 'Dendy Challenge Gold',
      amount: 10,
      rarity: RewardRarity.rare,
    ),
    // Node 5 rewards
    'rew_density_n5_xp': RewardDefinition(
      id: 'rew_density_n5_xp',
      type: RewardType.xp,
      name: 'Floatation Master XP',
      amount: 100,
      rarity: RewardRarity.common,
    ),
    'rew_density_n5_coins': RewardDefinition(
      id: 'rew_density_n5_coins',
      type: RewardType.coins,
      name: 'Floatation Master Gold',
      amount: 20,
      rarity: RewardRarity.common,
    ),
    'rew_density_n5_coll': RewardDefinition(
      id: 'rew_density_n5_coll',
      type: RewardType.collectible,
      name: 'Water Drop',
      rarity: RewardRarity.rare,
      assetPath: 'water',
    ),
    // Node 6 rewards
    'rew_density_n6_xp': RewardDefinition(
      id: 'rew_density_n6_xp',
      type: RewardType.xp,
      name: 'Archimedes Theory XP',
      amount: 120,
      rarity: RewardRarity.epic,
    ),
    'rew_density_n6_coll': RewardDefinition(
      id: 'rew_density_n6_coll',
      type: RewardType.collectible,
      name: 'Density Crystal',
      rarity: RewardRarity.epic,
      assetPath: 'crystal',
    ),
    // Node 7 rewards
    'rew_density_n7_xp': RewardDefinition(
      id: 'rew_density_n7_xp',
      type: RewardType.xp,
      name: 'Real World Physics Theory XP',
      amount: 150,
      rarity: RewardRarity.common,
    ),
    'rew_density_n7_coins': RewardDefinition(
      id: 'rew_density_n7_coins',
      type: RewardType.coins,
      name: 'Real World Physics Gold',
      amount: 30,
      rarity: RewardRarity.common,
    ),
    // Node 8 (Mastery Chest rewards)
    'rew_density_mastery_badge': RewardDefinition(
      id: 'rew_density_mastery_badge',
      type: RewardType.badge,
      name: 'Density Explorer',
      rarity: RewardRarity.legendary,
      assetPath: 'Density Explorer',
    ),
    'rew_density_mastery_coins': RewardDefinition(
      id: 'rew_density_mastery_coins',
      type: RewardType.coins,
      name: 'Mastery Gold Sack',
      amount: 100,
      rarity: RewardRarity.legendary,
    ),
    'rew_density_mastery_chest': RewardDefinition(
      id: 'rew_density_mastery_chest',
      type: RewardType.chest,
      name: 'Density Master Chest',
      rarity: RewardRarity.legendary,
      assetPath: 'Master Chest',
    ),
    // Fractions rewards
    'rew_fractions_n1': RewardDefinition(
      id: 'rew_fractions_n1',
      type: RewardType.xp,
      name: 'Fractions Intro XP',
      amount: 50,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n2': RewardDefinition(
      id: 'rew_fractions_n2',
      type: RewardType.coins,
      name: 'Fractions Coin Sack',
      amount: 10,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n3_xp': RewardDefinition(
      id: 'rew_fractions_n3_xp',
      type: RewardType.xp,
      name: 'Equivalent Spans XP',
      amount: 75,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n3_coins': RewardDefinition(
      id: 'rew_fractions_n3_coins',
      type: RewardType.coins,
      name: 'Equivalent Spans Coins',
      amount: 10,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_side_xp': RewardDefinition(
      id: 'rew_fractions_side_xp',
      type: RewardType.xp,
      name: 'Daily Fractions Bonus',
      amount: 30,
      rarity: RewardRarity.rare,
    ),
    'rew_fractions_side_coins': RewardDefinition(
      id: 'rew_fractions_side_coins',
      type: RewardType.coins,
      name: 'Daily Fractions Gold',
      amount: 10,
      rarity: RewardRarity.rare,
    ),
    'rew_fractions_n5_xp': RewardDefinition(
      id: 'rew_fractions_n5_xp',
      type: RewardType.xp,
      name: 'Bridge Builder XP',
      amount: 100,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n5_coins': RewardDefinition(
      id: 'rew_fractions_n5_coins',
      type: RewardType.coins,
      name: 'Bridge Builder Gold',
      amount: 20,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n6_xp': RewardDefinition(
      id: 'rew_fractions_n6_xp',
      type: RewardType.xp,
      name: 'Forge Master XP',
      amount: 120,
      rarity: RewardRarity.epic,
    ),
    'rew_fractions_n7_xp': RewardDefinition(
      id: 'rew_fractions_n7_xp',
      type: RewardType.xp,
      name: 'Royal Builder XP',
      amount: 150,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_n7_coins': RewardDefinition(
      id: 'rew_fractions_n7_coins',
      type: RewardType.coins,
      name: 'Royal Builder Gold',
      amount: 30,
      rarity: RewardRarity.common,
    ),
    'rew_fractions_mastery_badge': RewardDefinition(
      id: 'rew_fractions_mastery_badge',
      type: RewardType.badge,
      name: 'Fractions Explorer',
      rarity: RewardRarity.legendary,
      assetPath: 'Fractions Explorer',
    ),
    'rew_fractions_mastery_coins': RewardDefinition(
      id: 'rew_fractions_mastery_coins',
      type: RewardType.coins,
      name: 'Fractions Gold Sack',
      amount: 100,
      rarity: RewardRarity.legendary,
    ),
    'rew_fractions_mastery_chest': RewardDefinition(
      id: 'rew_fractions_mastery_chest',
      type: RewardType.chest,
      name: 'Fractions Master Chest',
      rarity: RewardRarity.legendary,
      assetPath: 'Master Chest',
    ),
  };

  // Seeding list of RoadmapNodes for any moduleId
  List<RoadmapNode> getRoadmap(String moduleId) {
    if (moduleId == 'mod_fractions') {
      return [
        RoadmapNode(
          id: 'fractions_node1',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.level,
          title: '🌱 Concept Learning',
          description: 'Learn the fundamentals of fractions and sharing a whole.',
          order: 1,
          prerequisiteNodeIds: [],
          rewardIds: ['rew_fractions_n1'],
          levelId: 'fractions_lvl1',
          lessonId: 'fractions_les1',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'fractions_node2',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.mystery,
          title: '🎁 Bonus Mystery Drop',
          description: 'A mystery gift box unlocked after learning fraction concepts.',
          order: 2,
          prerequisiteNodeIds: ['fractions_node1'],
          rewardIds: ['rew_fractions_n2'],
          isOptional: true,
        ),
        RoadmapNode(
          id: 'fractions_node3',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.level,
          title: '⚖️ Interactive Exploration',
          description: 'Explore equivalent fractions by splitting and merging pieces.',
          order: 3,
          prerequisiteNodeIds: ['fractions_node1'],
          rewardIds: ['rew_fractions_n3_xp', 'rew_fractions_n3_coins'],
          levelId: 'fractions_lvl1',
          lessonId: 'fractions_les2',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'fractions_node4',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.lesson,
          title: '🌉 Guided Practice',
          description: 'Help Nova build the first spans across the canyon.',
          order: 4,
          prerequisiteNodeIds: ['fractions_node3'],
          rewardIds: ['rew_fractions_n5_xp', 'rew_fractions_n5_coins'],
          levelId: 'fractions_lvl1',
          lessonId: 'fractions_les3',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'fractions_node5',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.milestone,
          title: '⚒️ Fraction Forge',
          description: 'Build ratio and equivalent planks to secure the bridge crossings.',
          order: 5,
          prerequisiteNodeIds: ['fractions_node4'],
          rewardIds: ['rew_fractions_n6_xp'],
          levelId: 'fractions_lvl1',
          lessonId: 'fractions_les4',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'fractions_node6',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.bonus,
          title: '👑 The King\'s Bridge',
          description: 'Use all your skills to build the ultimate bridge span.',
          order: 6,
          prerequisiteNodeIds: ['fractions_node5'],
          rewardIds: ['rew_fractions_n7_xp', 'rew_fractions_n7_coins'],
          levelId: 'fractions_lvl1',
          lessonId: 'fractions_les5',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'fractions_node7',
          moduleId: 'mod_fractions',
          type: RoadmapNodeType.mastery,
          title: '🏆 Fractions Mastery',
          description: 'Master fractions canyon crossings and unlock the fractions chest.',
          order: 7,
          prerequisiteNodeIds: ['fractions_node6'],
          rewardIds: ['rew_fractions_mastery_badge', 'rew_fractions_mastery_coins', 'rew_fractions_mastery_chest'],
          isOptional: false,
        ),
      ];
    }

    if (moduleId == 'mod_density') {
      return [
        RoadmapNode(
          id: 'density_node1',
          moduleId: 'mod_density',
          type: RoadmapNodeType.level,
          title: '🌱 Discover Density',
          description: 'Explore the foundations of density and the particle structures of matter.',
          order: 1,
          prerequisiteNodeIds: [],
          rewardIds: ['rew_density_n1'],
          levelId: 'density_lvl1',
          lessonId: 'density_les1',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'density_node2',
          moduleId: 'mod_density',
          type: RoadmapNodeType.mystery,
          title: '🎁 Bonus Mystery Drop',
          description: 'A mystery gift box unlocked after completing your first density discovery.',
          order: 2,
          prerequisiteNodeIds: ['density_node1'],
          rewardIds: ['rew_density_n2'],
          isOptional: true,
        ),
        RoadmapNode(
          id: 'density_node3',
          moduleId: 'mod_density',
          type: RoadmapNodeType.level,
          title: '⚖️ Mass & Volume',
          description: 'Learn how to calculate mass, volume displacement, and mathematical proportions.',
          order: 3,
          prerequisiteNodeIds: ['density_node1'], // Depends only on Node 1, NOT Node 2 (mystery)!
          rewardIds: ['rew_density_n3_xp', 'rew_density_n3_coins'],
          levelId: 'density_lvl1',
          lessonId: 'density_les2',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'density_node4',
          moduleId: 'mod_density',
          type: RoadmapNodeType.sideQuest,
          title: '🦊 Dendy\'s Challenge',
          description: 'Look around your room: Find three objects that float and list them down.',
          order: 4,
          prerequisiteNodeIds: ['density_node3'],
          rewardIds: ['rew_density_side_xp', 'rew_density_side_coins'],
          isOptional: true,
        ),
        RoadmapNode(
          id: 'density_node5',
          moduleId: 'mod_density',
          type: RoadmapNodeType.lesson,
          title: '🌊 Float or Sink?',
          description: 'Interact with buoyancy forces and float blocks in the virtual tank laboratory.',
          order: 5,
          prerequisiteNodeIds: ['density_node3'], // Depends only on Node 3, NOT Node 4 (side quest)!
          rewardIds: ['rew_density_n5_xp', 'rew_density_n5_coins', 'rew_density_n5_coll'],
          levelId: 'density_lvl2',
          lessonId: 'density_les3',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'density_node6',
          moduleId: 'mod_density',
          type: RoadmapNodeType.milestone,
          title: '🏆 Experiment Challenge',
          description: 'Test buoyancy thresholds by sinking items to the ocean floor.',
          order: 6,
          prerequisiteNodeIds: ['density_node5'],
          rewardIds: ['rew_density_n6_xp', 'rew_density_n6_coll'],
          levelId: 'density_lvl2',
          lessonId: 'density_les4',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'density_node7',
          moduleId: 'mod_density',
          type: RoadmapNodeType.bonus,
          title: '🧠 Real-World Challenge',
          description: 'Why can a heavy steel container ship float? Apply displacement laws to predict.',
          order: 7,
          prerequisiteNodeIds: ['density_node5'], // Depends on Node 5, NOT Node 6 (milestone)!
          rewardIds: ['rew_density_n7_xp', 'rew_density_n7_coins'],
          levelId: 'density_lvl2',
          lessonId: 'density_les5',
          isOptional: false,
        ),
        RoadmapNode(
          id: 'density_node8',
          moduleId: 'mod_density',
          type: RoadmapNodeType.mastery,
          title: '🏆 Density Mastery',
          description: 'The final destination: Master density expedition and unlock the legendary master chest.',
          order: 8,
          prerequisiteNodeIds: ['density_node7'],
          rewardIds: ['rew_density_mastery_badge', 'rew_density_mastery_coins', 'rew_density_mastery_chest'],
          isOptional: false,
        ),
      ];
    }

    // Default return logic for other modules (reusable roadmap structure generated dynamically!)
    return [
      RoadmapNode(
        id: '${moduleId}_start',
        moduleId: moduleId,
        type: RoadmapNodeType.level,
        title: '🌱 Starting Out',
        description: 'First steps in this curriculum.',
        order: 1,
        prerequisiteNodeIds: [],
        rewardIds: [],
        isOptional: false,
      ),
      RoadmapNode(
        id: '${moduleId}_end',
        moduleId: moduleId,
        type: RoadmapNodeType.mastery,
        title: '🏆 Module Mastery',
        description: 'Master this curriculum.',
        order: 2,
        prerequisiteNodeIds: ['${moduleId}_start'],
        rewardIds: [],
        isOptional: false,
      ),
    ];
  }

  RewardDefinition? getRewardById(String id) {
    return _rewards[id];
  }

  List<RewardDefinition> getRewardsForNode(RoadmapNode node) {
    return node.rewardIds
        .map((rid) => _rewards[rid])
        .where((r) => r != null)
        .cast<RewardDefinition>()
        .toList();
  }
}

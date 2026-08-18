import 'roadmap_enums.dart';

class RewardDefinition {
  final String id;
  final RewardType type;
  final String name;
  final int amount;
  final RewardRarity rarity;
  final String assetPath;

  RewardDefinition({
    required this.id,
    required this.type,
    required this.name,
    this.amount = 0,
    required this.rarity,
    this.assetPath = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'amount': amount,
        'rarity': rarity.name,
        'assetPath': assetPath,
      };

  factory RewardDefinition.fromJson(Map<String, dynamic> json) => RewardDefinition(
        id: json['id'] as String,
        type: RewardType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => RewardType.xp,
        ),
        name: json['name'] as String,
        amount: json['amount'] as int? ?? 0,
        rarity: RewardRarity.values.firstWhere(
          (e) => e.name == json['rarity'],
          orElse: () => RewardRarity.common,
        ),
        assetPath: json['assetPath'] as String? ?? '',
      );
}

class Reward {
  final String id;
  final String name;
  final int cost;
  final String assetPath;
  final bool isPurchased;

  Reward({
    required this.id,
    required this.name,
    required this.cost,
    required this.assetPath,
    this.isPurchased = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cost': cost,
        'assetPath': assetPath,
        'isPurchased': isPurchased,
      };

  factory Reward.fromJson(Map<String, dynamic> json) => Reward(
        id: json['id'] as String,
        name: json['name'] as String,
        cost: json['cost'] as int? ?? 0,
        assetPath: json['assetPath'] as String? ?? '',
        isPurchased: json['isPurchased'] as bool? ?? false,
      );

  Reward copyWith({bool? isPurchased}) {
    return Reward(
      id: id,
      name: name,
      cost: cost,
      assetPath: assetPath,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

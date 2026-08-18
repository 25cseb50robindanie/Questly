class Collectible {
  final String id;
  final String name;
  final String iconName;
  final String description;
  final int cost;
  final bool isUnlocked;

  Collectible({
    required this.id,
    required this.name,
    required this.iconName,
    required this.description,
    required this.cost,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconName': iconName,
        'description': description,
        'cost': cost,
        'isUnlocked': isUnlocked,
      };

  factory Collectible.fromJson(Map<String, dynamic> json) => Collectible(
        id: json['id'] as String,
        name: json['name'] as String,
        iconName: json['iconName'] as String,
        description: json['description'] as String? ?? '',
        cost: json['cost'] as int? ?? 0,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
      );

  Collectible copyWith({bool? isUnlocked}) {
    return Collectible(
      id: id,
      name: name,
      iconName: iconName,
      description: description,
      cost: cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

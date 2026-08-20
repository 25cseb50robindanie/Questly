enum MissionType { daily, weekly }

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int target;
  final int current;
  final int coinReward;
  final int xpReward;
  final bool isClaimed;
  final String iconType; // 'lesson', 'xp', 'experiment', 'module'

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    this.current = 0,
    required this.coinReward,
    this.xpReward = 0,
    this.isClaimed = false,
    this.iconType = 'lesson',
  });

  bool get isCompleted => current >= target;
  double get progressFraction => target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'target': target,
        'current': current,
        'coinReward': coinReward,
        'xpReward': xpReward,
        'isClaimed': isClaimed,
        'iconType': iconType,
      };

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: MissionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MissionType.daily,
        ),
        target: json['target'] as int? ?? 1,
        current: json['current'] as int? ?? 0,
        coinReward: json['coinReward'] as int? ?? 20,
        xpReward: json['xpReward'] as int? ?? 0,
        isClaimed: json['isClaimed'] as bool? ?? false,
        iconType: json['iconType'] as String? ?? 'lesson',
      );

  Mission copyWith({
    int? current,
    bool? isClaimed,
  }) =>
      Mission(
        id: id,
        title: title,
        description: description,
        type: type,
        target: target,
        current: current ?? this.current,
        coinReward: coinReward,
        xpReward: xpReward,
        isClaimed: isClaimed ?? this.isClaimed,
        iconType: iconType,
      );
}

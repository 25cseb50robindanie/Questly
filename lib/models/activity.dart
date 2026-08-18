class Activity {
  final String id;
  final String title;
  final String instruction;
  final String type;
  final double targetDensity; // e.g. 1.25
  final String targetCondition; // "float" or "sink" or "exact"
  final int xpReward;
  final int goldReward;

  Activity({
    required this.id,
    required this.title,
    required this.instruction,
    required this.type,
    required this.targetDensity,
    required this.targetCondition,
    required this.xpReward,
    required this.goldReward,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instruction': instruction,
        'type': type,
        'targetDensity': targetDensity,
        'targetCondition': targetCondition,
        'xpReward': xpReward,
        'goldReward': goldReward,
      };

  factory Activity.fromJson(Map<String, dynamic> json) => Activity(
        id: json['id'] as String,
        title: json['title'] as String,
        instruction: json['instruction'] as String,
        type: json['type'] as String? ?? 'generic',
        targetDensity: (json['targetDensity'] as num? ?? 1.0).toDouble(),
        targetCondition: json['targetCondition'] as String? ?? 'exact',
        xpReward: json['xpReward'] as int? ?? 10,
        goldReward: json['goldReward'] as int? ?? 5,
      );
}

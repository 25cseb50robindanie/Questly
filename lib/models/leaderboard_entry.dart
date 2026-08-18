class LeaderboardEntry {
  final String name;
  final int xp;
  final bool isMe;

  LeaderboardEntry({
    required this.name,
    required this.xp,
    this.isMe = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'xp': xp,
        'isMe': isMe,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        name: json['name'] as String,
        xp: json['xp'] as int? ?? 0,
        isMe: json['isMe'] as bool? ?? false,
      );
}

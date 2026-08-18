class Student {
  final String questlyId;
  final String displayName;
  final int level;
  final int xp;
  final int gold; // acts as Quest Coins
  final String language; // 'en', 'ta', 'hi'
  final String? currentModuleId;
  final String? currentLessonId;

  Student({
    required this.questlyId,
    required this.displayName,
    this.level = 1,
    this.xp = 0,
    this.gold = 0,
    this.language = 'en',
    this.currentModuleId,
    this.currentLessonId,
  });

  Map<String, dynamic> toJson() => {
        'questlyId': questlyId,
        'displayName': displayName,
        'level': level,
        'xp': xp,
        'gold': gold,
        'language': language,
        'currentModuleId': currentModuleId,
        'currentLessonId': currentLessonId,
      };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        questlyId: json['questlyId'] as String,
        displayName: json['displayName'] as String,
        level: json['level'] as int? ?? 1,
        xp: json['xp'] as int? ?? 0,
        gold: json['gold'] as int? ?? 0,
        language: json['language'] as String? ?? 'en',
        currentModuleId: json['currentModuleId'] as String?,
        currentLessonId: json['currentLessonId'] as String?,
      );

  Student copyWith({
    String? displayName,
    int? level,
    int? xp,
    int? gold,
    String? language,
    String? currentModuleId,
    String? currentLessonId,
  }) {
    return Student(
      questlyId: questlyId,
      displayName: displayName ?? this.displayName,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
      language: language ?? this.language,
      currentModuleId: currentModuleId ?? this.currentModuleId,
      currentLessonId: currentLessonId ?? this.currentLessonId,
    );
  }
}

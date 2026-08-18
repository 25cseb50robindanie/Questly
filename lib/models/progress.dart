class Progress {
  final String studentId;
  final String lessonId;
  final String status; // "notStarted", "inProgress", "completed"
  final double score;
  final int stars; // 0, 1, 2, or 3 stars
  final int attempts;
  final DateTime lastPlayed;
  final DateTime? completedAt;

  Progress({
    required this.studentId,
    required this.lessonId,
    this.status = 'notStarted',
    this.score = 0.0,
    this.stars = 0,
    this.attempts = 0,
    required this.lastPlayed,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'lessonId': lessonId,
        'status': status,
        'score': score,
        'stars': stars,
        'attempts': attempts,
        'lastPlayed': lastPlayed.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        studentId: json['studentId'] as String,
        lessonId: json['lessonId'] as String? ?? json['activityId'] as String? ?? '',
        status: json['status'] as String? ?? ((json['isCompleted'] as bool? ?? false) ? 'completed' : 'notStarted'),
        score: (json['score'] as num? ?? 0.0).toDouble(),
        stars: json['stars'] as int? ?? ((json['score'] as num? ?? 0.0) >= 1.0 ? 3 : ((json['score'] as num? ?? 0.0) >= 0.7 ? 2 : ((json['status'] == 'completed') ? 1 : 0))),
        attempts: json['attempts'] as int? ?? 1,
        lastPlayed: json['lastPlayed'] != null
            ? DateTime.parse(json['lastPlayed'] as String)
            : DateTime.now(),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'] as String)
            : null,
      );

  Progress copyWith({
    String? status,
    double? score,
    int? stars,
    int? attempts,
    DateTime? lastPlayed,
    DateTime? completedAt,
  }) {
    return Progress(
      studentId: studentId,
      lessonId: lessonId,
      status: status ?? this.status,
      score: score ?? this.score,
      stars: stars ?? this.stars,
      attempts: attempts ?? this.attempts,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}


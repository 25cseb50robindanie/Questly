class Doubt {
  final String id;
  final String studentId;
  final String moduleId;
  final String lessonId;
  final String question;
  final String language;
  final DateTime timestamp;
  final String status; // 'pending', 'escalated', 'resolved'
  final String context;
  final String attemptedAnswer;

  Doubt({
    required this.id,
    required this.studentId,
    required this.moduleId,
    required this.lessonId,
    required this.question,
    required this.language,
    required this.timestamp,
    required this.status,
    this.context = '',
    this.attemptedAnswer = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'moduleId': moduleId,
        'lessonId': lessonId,
        'question': question,
        'language': language,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
        'context': context,
        'attemptedAnswer': attemptedAnswer,
      };

  factory Doubt.fromJson(Map<String, dynamic> json) => Doubt(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        moduleId: json['moduleId'] as String,
        lessonId: json['lessonId'] as String,
        question: json['question'] as String,
        language: json['language'] as String? ?? 'en',
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: json['status'] as String? ?? 'pending',
        context: json['context'] as String? ?? '',
        attemptedAnswer: json['attemptedAnswer'] as String? ?? '',
      );
}

import 'lesson.dart';

class Level {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final String unlockCondition;
  final List<Lesson> lessons;

  Level({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    this.unlockCondition = '',
    required this.lessons,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'order': order,
        'unlockCondition': unlockCondition,
        'lessons': lessons.map((l) => l.toJson()).toList(),
      };

  factory Level.fromJson(Map<String, dynamic> json) => Level(
        id: json['id'] as String,
        moduleId: json['moduleId'] as String,
        title: json['title'] as String,
        order: json['order'] as int? ?? 1,
        unlockCondition: json['unlockCondition'] as String? ?? '',
        lessons: (json['lessons'] as List<dynamic>?)
                ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

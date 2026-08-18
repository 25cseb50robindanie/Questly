import 'activity.dart';

class Lesson {
  final String id;
  final String levelId;
  final String title;
  final int order;
  final String activityType;
  final List<Activity> activities;

  Lesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.order,
    this.activityType = 'generic',
    required this.activities,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'levelId': levelId,
        'title': title,
        'order': order,
        'activityType': activityType,
        'activities': activities.map((a) => a.toJson()).toList(),
      };

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id: json['id'] as String,
        levelId: json['levelId'] as String? ?? '',
        title: json['title'] as String,
        order: json['order'] as int? ?? 1,
        activityType: json['activityType'] as String? ?? 'generic',
        activities: (json['activities'] as List<dynamic>?)
                ?.map((a) => Activity.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

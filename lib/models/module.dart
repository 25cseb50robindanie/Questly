import 'level.dart';

class Module {
  final String id;
  final String title;
  final String subject;
  final String description;
  final List<Level> levels;

  Module({
    required this.id,
    required this.title,
    required this.subject,
    required this.description,
    required this.levels,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'description': description,
        'levels': levels.map((l) => l.toJson()).toList(),
      };

  factory Module.fromJson(Map<String, dynamic> json) => Module(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String? ?? 'SCIENCE',
        description: json['description'] as String? ?? '',
        levels: (json['levels'] as List<dynamic>?)
                ?.map((l) => Level.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

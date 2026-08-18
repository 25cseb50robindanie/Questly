import 'roadmap_enums.dart';

class RoadmapNode {
  final String id;
  final String moduleId;
  final RoadmapNodeType type;
  final String title;
  final String description;
  final int order;
  final List<String> prerequisiteNodeIds;
  final List<String> rewardIds;
  final String? levelId;
  final String? lessonId;
  final bool isOptional;

  RoadmapNode({
    required this.id,
    required this.moduleId,
    required this.type,
    required this.title,
    required this.description,
    required this.order,
    required this.prerequisiteNodeIds,
    required this.rewardIds,
    this.levelId,
    this.lessonId,
    this.isOptional = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'type': type.name,
        'title': title,
        'description': description,
        'order': order,
        'prerequisiteNodeIds': prerequisiteNodeIds,
        'rewardIds': rewardIds,
        'levelId': levelId,
        'lessonId': lessonId,
        'isOptional': isOptional,
      };

  factory RoadmapNode.fromJson(Map<String, dynamic> json) => RoadmapNode(
        id: json['id'] as String,
        moduleId: json['moduleId'] as String,
        type: RoadmapNodeType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => RoadmapNodeType.lesson,
        ),
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        order: json['order'] as int? ?? 1,
        prerequisiteNodeIds: List<String>.from(json['prerequisiteNodeIds'] as List<dynamic>? ?? []),
        rewardIds: List<String>.from(json['rewardIds'] as List<dynamic>? ?? []),
        levelId: json['levelId'] as String?,
        lessonId: json['lessonId'] as String?,
        isOptional: json['isOptional'] as bool? ?? false,
      );
}

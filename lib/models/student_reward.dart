import 'roadmap_enums.dart';

class StudentReward {
  final String rewardId;
  final RoadmapNodeStatus status;
  final DateTime? claimedAt;

  StudentReward({
    required this.rewardId,
    required this.status,
    this.claimedAt,
  });

  Map<String, dynamic> toJson() => {
        'rewardId': rewardId,
        'status': status.name,
        'claimedAt': claimedAt?.toIso8601String(),
      };

  factory StudentReward.fromJson(Map<String, dynamic> json) => StudentReward(
        rewardId: json['rewardId'] as String,
        status: RoadmapNodeStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RoadmapNodeStatus.locked,
        ),
        claimedAt: json['claimedAt'] != null
            ? DateTime.parse(json['claimedAt'] as String)
            : null,
      );

  StudentReward copyWith({
    RoadmapNodeStatus? status,
    DateTime? claimedAt,
  }) {
    return StudentReward(
      rewardId: rewardId,
      status: status ?? this.status,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

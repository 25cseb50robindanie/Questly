class NotificationItem {
  final String id;
  final String title;
  final String description;
  final bool isRead;
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    this.isRead = false,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'isRead': isRead,
        'timestamp': timestamp.toIso8601String(),
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) => NotificationItem(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        isRead: json['isRead'] as bool? ?? false,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }
}

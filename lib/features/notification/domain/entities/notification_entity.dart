/// Notification entity - pure domain object
class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final String? route;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.route,
    required this.isRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? route,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          body == other.body;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ body.hashCode;
}

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'notification_model.g.dart';

/// Notification model untuk Isar database
@collection
class NotificationModel {
  Id? isarId;

  /// UUID untuk identifikasi unik
  @Index(unique: true)
  final String? id;

  /// Judul notifikasi
  final String? title;

  /// Isi notifikasi
  final String? body;

  /// Deep link route untuk navigasi saat tap
  final String? route;

  /// Status sudah dibaca atau belum
  @Index()
  final bool isRead;

  /// Timestamp dibuat
  @Index()
  final DateTime? createdAt;

  NotificationModel({
    String? id,
    required this.title,
    required this.body,
    this.route,
    this.isRead = false,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Copy with
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? route,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      route: route ?? this.route,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'route': route,
      'isRead': isRead,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      route: json['route'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

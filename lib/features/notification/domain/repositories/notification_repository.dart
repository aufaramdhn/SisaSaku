import 'package:sisasaku/features/notification/domain/entities/notification_entity.dart';

/// Abstract repository untuk Notification
abstract class NotificationRepository {
  /// Get semua notifikasi
  Future<List<NotificationEntity>> getNotifications();

  /// Get notifikasi yang belum dibaca
  Future<List<NotificationEntity>> getUnreadNotifications();

  /// Tambah notifikasi baru
  Future<NotificationEntity> addNotification(NotificationEntity notification);

  /// Tandai notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id);

  /// Hapus notifikasi
  Future<void> deleteNotification(String id);

  /// Hapus semua notifikasi
  Future<void> deleteAllNotifications();
}

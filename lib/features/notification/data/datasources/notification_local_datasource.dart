import 'package:isar/isar.dart';
import 'package:sisasaku/features/notification/data/models/notification_model.dart';
import 'package:sisasaku/core/errors/exceptions.dart';

/// Local datasource untuk Notification (Isar)
class NotificationLocalDatasource {
  final Isar isar;

  NotificationLocalDatasource(this.isar);

  /// Get semua notifikasi (terbaru dulu)
  Future<List<NotificationModel>> getNotifications() async {
    try {
      return await isar.notificationModels
          .where()
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      throw DatabaseException(message: 'Gagal mengambil notifikasi: $e');
    }
  }

  /// Get notifikasi yang belum dibaca
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      return await isar.notificationModels
          .where()
          .isReadEqualTo(false)
          .sortByCreatedAtDesc()
          .findAll();
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal mengambil notifikasi belum dibaca: $e',
      );
    }
  }

  /// Tambah notifikasi baru
  Future<NotificationModel> addNotification(
    NotificationModel notification,
  ) async {
    try {
      await isar.writeTxn(() async {
        await isar.notificationModels.put(notification);
      });
      return notification;
    } catch (e) {
      throw DatabaseException(message: 'Gagal menambah notifikasi: $e');
    }
  }

  /// Tandai notifikasi sebagai sudah dibaca
  Future<void> markAsRead(String id) async {
    try {
      final notification =
          await isar.notificationModels.where().idEqualTo(id).findFirst();
      if (notification != null) {
        final updated = notification.copyWith(isRead: true);
        await isar.writeTxn(() async {
          await isar.notificationModels.put(updated);
        });
      }
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menandai notifikasi sebagai dibaca: $e',
      );
    }
  }

  /// Hapus notifikasi berdasarkan ID
  Future<void> deleteNotification(String id) async {
    try {
      final notification =
          await isar.notificationModels.where().idEqualTo(id).findFirst();
      if (notification != null) {
        await isar.writeTxn(() async {
          await isar.notificationModels.delete(notification.isarId!);
        });
      }
    } catch (e) {
      throw DatabaseException(message: 'Gagal menghapus notifikasi: $e');
    }
  }

  /// Hapus semua notifikasi
  Future<void> deleteAllNotifications() async {
    try {
      await isar.writeTxn(() async {
        await isar.notificationModels.clear();
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Gagal menghapus semua notifikasi: $e',
      );
    }
  }
}

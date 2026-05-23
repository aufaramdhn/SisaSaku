import 'package:sisasaku/features/notification/domain/repositories/notification_repository.dart';

/// Use case untuk menghapus notifikasi
class DeleteNotificationUsecase {
  final NotificationRepository repository;

  DeleteNotificationUsecase({required this.repository});

  Future<void> call(String id) {
    return repository.deleteNotification(id);
  }
}

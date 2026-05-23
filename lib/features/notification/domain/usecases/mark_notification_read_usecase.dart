import 'package:sisasaku/features/notification/domain/repositories/notification_repository.dart';

/// Use case untuk menandai notifikasi sebagai sudah dibaca
class MarkNotificationReadUsecase {
  final NotificationRepository repository;

  MarkNotificationReadUsecase({required this.repository});

  Future<void> call(String id) {
    return repository.markAsRead(id);
  }
}

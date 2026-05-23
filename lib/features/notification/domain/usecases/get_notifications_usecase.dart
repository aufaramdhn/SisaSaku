import 'package:sisasaku/features/notification/domain/entities/notification_entity.dart';
import 'package:sisasaku/features/notification/domain/repositories/notification_repository.dart';

/// Use case untuk mengambil semua notifikasi
class GetNotificationsUsecase {
  final NotificationRepository repository;

  GetNotificationsUsecase({required this.repository});

  Future<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}

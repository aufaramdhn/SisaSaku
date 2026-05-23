import 'package:sisasaku/features/notification/data/datasources/notification_local_datasource.dart';
import 'package:sisasaku/features/notification/data/models/notification_model.dart';
import 'package:sisasaku/features/notification/domain/entities/notification_entity.dart';
import 'package:sisasaku/features/notification/domain/repositories/notification_repository.dart';
import 'package:sisasaku/core/errors/exceptions.dart';

/// Repository implementation untuk Notification
class NotificationRepositoryImpl extends NotificationRepository {
  final NotificationLocalDatasource localDatasource;

  NotificationRepositoryImpl(this.localDatasource);

  /// Convert model to entity
  NotificationEntity _modelToEntity(NotificationModel model) {
    return NotificationEntity(
      id: model.id ?? '',
      title: model.title ?? '',
      body: model.body ?? '',
      route: model.route,
      isRead: model.isRead,
      createdAt: model.createdAt ?? DateTime.now(),
    );
  }

  /// Convert entity to model
  NotificationModel _entityToModel(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.body,
      route: entity.route,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
    );
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final models = await localDatasource.getNotifications();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<List<NotificationEntity>> getUnreadNotifications() async {
    try {
      final models = await localDatasource.getUnreadNotifications();
      return models.map(_modelToEntity).toList();
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<NotificationEntity> addNotification(
    NotificationEntity notification,
  ) async {
    try {
      final model = _entityToModel(notification);
      final result = await localDatasource.addNotification(model);
      return _modelToEntity(result);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await localDatasource.markAsRead(id);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await localDatasource.deleteNotification(id);
    } on DatabaseException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      await localDatasource.deleteAllNotifications();
    } on DatabaseException {
      rethrow;
    }
  }
}

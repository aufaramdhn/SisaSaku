import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:sisasaku/features/notification/data/datasources/notification_local_datasource.dart';
import 'package:sisasaku/features/notification/data/models/notification_model.dart';
import 'package:sisasaku/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:sisasaku/features/notification/domain/entities/notification_entity.dart';

/// Fake [NotificationLocalDatasource] that stores notifications in memory.
///
/// Uses `implements` to avoid needing a real Isar instance. The fake simply
/// echoes the model passed to [addNotification] back to the caller, exactly
/// like the real datasource does on success. This keeps the test focused on
/// the mapping logic inside [NotificationRepositoryImpl].
class FakeNotificationLocalDatasource implements NotificationLocalDatasource {
  final List<NotificationModel> _store = [];

  @override
  Isar get isar => throw UnimplementedError('Isar not used in fake');

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return List.from(_store);
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    return _store.where((n) => !n.isRead).toList();
  }

  @override
  Future<NotificationModel> addNotification(
    NotificationModel notification,
  ) async {
    _store.add(notification);
    return notification;
  }

  @override
  Future<void> markAsRead(String id) async {
    // Not exercised by this property test.
  }

  @override
  Future<void> deleteNotification(String id) async {
    // Not exercised by this property test.
  }

  @override
  Future<void> deleteAllNotifications() async {
    _store.clear();
  }
}

/// Generates a random [NotificationEntity] with varied field values:
///  - some with `route == null`, some with a route set
///  - varied `isRead`
///  - varied non-empty `id`, `title`, `body`
///  - varied `createdAt` over a wide timestamp range
NotificationEntity _generateEntity(Random random, int index) {
  // Roughly 30% of generated entities have a null route.
  final hasRoute = random.nextInt(10) >= 3;
  final isRead = random.nextBool();

  // Vary title and body lengths and characters.
  final title = _randomString(random, 1 + random.nextInt(40));
  final body = _randomString(random, 1 + random.nextInt(120));

  // Random timestamp in microseconds resolution to exercise full DateTime
  // precision. Range: ~1970 .. ~2086.
  final micros = random.nextInt(1 << 32) * 1000 + random.nextInt(1000);
  final createdAt = DateTime.fromMicrosecondsSinceEpoch(micros);

  return NotificationEntity(
    id: 'notif-$index-${random.nextInt(1 << 30)}',
    title: title,
    body: body,
    route: hasRoute ? '/route/${random.nextInt(1000)}/sub-${random.nextInt(100)}' : null,
    isRead: isRead,
    createdAt: createdAt,
  );
}

const _alphabet =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _-./';

String _randomString(Random random, int length) {
  final buffer = StringBuffer();
  for (var i = 0; i < length; i++) {
    buffer.write(_alphabet[random.nextInt(_alphabet.length)]);
  }
  return buffer.toString();
}

void main() {
  group('Property 4: Notification model-entity mapping round-trip', () {
    // **Validates: Requirements 3.7**
    //
    // For any valid NotificationEntity, converting it to a NotificationModel
    // and back to an entity through NotificationRepositoryImpl should produce
    // an entity with identical field values for id, title, body, route,
    // isRead, and createdAt.
    test(
      'round-trip preserves all fields for 500 random entities',
      () async {
        const seed = 42;
        const sampleCount = 500;
        final random = Random(seed);

        final fakeDatasource = FakeNotificationLocalDatasource();
        final repository = NotificationRepositoryImpl(fakeDatasource);

        for (var i = 0; i < sampleCount; i++) {
          final original = _generateEntity(random, i);

          // Round-trip: entity -> model -> (storage) -> model -> entity.
          // addNotification calls _entityToModel, hands it to the datasource,
          // then maps the returned model back via _modelToEntity.
          final roundTripped = await repository.addNotification(original);

          expect(
            roundTripped.id,
            original.id,
            reason: 'id mismatch at iteration $i (original=$original)',
          );
          expect(
            roundTripped.title,
            original.title,
            reason: 'title mismatch at iteration $i (original=$original)',
          );
          expect(
            roundTripped.body,
            original.body,
            reason: 'body mismatch at iteration $i (original=$original)',
          );
          expect(
            roundTripped.route,
            original.route,
            reason: 'route mismatch at iteration $i (original=$original)',
          );
          expect(
            roundTripped.isRead,
            original.isRead,
            reason: 'isRead mismatch at iteration $i (original=$original)',
          );
          expect(
            roundTripped.createdAt,
            original.createdAt,
            reason: 'createdAt mismatch at iteration $i (original=$original)',
          );
        }
      },
    );

    // Confirms the round-trip property also holds when fetching via
    // getNotifications, exercising the bulk model->entity mapping path.
    test(
      'round-trip via getNotifications preserves all fields for 100 random entities',
      () async {
        const seed = 1337;
        const sampleCount = 100;
        final random = Random(seed);

        final fakeDatasource = FakeNotificationLocalDatasource();
        final repository = NotificationRepositoryImpl(fakeDatasource);

        final originals = <NotificationEntity>[];
        for (var i = 0; i < sampleCount; i++) {
          final entity = _generateEntity(random, i);
          originals.add(entity);
          await repository.addNotification(entity);
        }

        final retrieved = await repository.getNotifications();

        expect(retrieved, hasLength(originals.length));

        // Match by id since getNotifications doesn't guarantee order.
        final retrievedById = {for (final e in retrieved) e.id: e};

        for (final original in originals) {
          final fetched = retrievedById[original.id];
          expect(
            fetched,
            isNotNull,
            reason: 'missing entity for id=${original.id}',
          );
          expect(fetched!.id, original.id);
          expect(fetched.title, original.title);
          expect(fetched.body, original.body);
          expect(fetched.route, original.route);
          expect(fetched.isRead, original.isRead);
          expect(fetched.createdAt, original.createdAt);
        }
      },
    );
  });
}

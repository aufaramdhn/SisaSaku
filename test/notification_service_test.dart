import 'package:flutter_test/flutter_test.dart';
import 'package:sisasaku/core/services/notification_service.dart';

void main() {
  test('resolves plain payload as bill detail route', () {
    expect(
      NotificationPayloads.resolveNavigationPath('bill-123'),
      '/bill/bill-123',
    );
  });

  test('resolves json payload route for bill detail', () {
    expect(
      NotificationPayloads.resolveNavigationPath(
        '{"route":"bill_detail","billId":"abc-123"}',
      ),
      '/bill/abc-123',
    );
  });

  test('resolves json payload route for notification detail', () {
    expect(
      NotificationPayloads.resolveNavigationPath(
        '{"route":"notification_detail","notificationId":"notif-1"}',
      ),
      '/notifications/notif-1',
    );
  });

  test('returns null for unsupported payload', () {
    expect(
      NotificationPayloads.resolveNavigationPath('{"route":"unknown"}'),
      isNull,
    );
  });
}

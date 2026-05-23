import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sisasaku/core/services/local_preferences_service.dart';
import 'package:sisasaku/features/bill/presentation/providers/bill_provider.dart';
import 'package:sisasaku/features/notification/presentation/pages/notification_data.dart';

final notificationRefreshProvider = StateProvider<int>((ref) => 0);

final notificationsProvider = FutureProvider<List<AppNotificationItem>>((
  ref,
) async {
  ref.watch(notificationRefreshProvider);
  final bills = await ref.watch(billsProvider.future);
  final readIds = await LocalPreferencesService.getReadNotificationIds();
  return buildBillNotifications(bills, readIds);
});

final markNotificationReadProvider = FutureProvider.family<void, String>((
  ref,
  notificationId,
) async {
  await LocalPreferencesService.markNotificationRead(notificationId);
  ref.read(notificationRefreshProvider.notifier).state++;
});

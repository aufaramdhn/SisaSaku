import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../constants/supabase_config.dart';
import '../../firebase_options.dart';
import '../../features/bill/data/models/bill_model.dart';
import 'local_preferences_service.dart';

const _billReminderChannelId = 'pengingat_tagihan';
const _remoteMessageChannelId = 'push_remote_umum';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      return;
    }
  }
}

class NotificationPayloads {
  static String? resolveNavigationPath(String? payload) {
    final trimmed = payload?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (!trimmed.startsWith('{')) {
      return '/bill/$trimmed';
    }

    try {
      final json = jsonDecode(trimmed);
      if (json is! Map<String, dynamic>) return null;
      return routeFromData(json);
    } catch (_) {
      return null;
    }
  }

  static String? routeFromData(Map<String, dynamic> data) {
    final route = data['route']?.toString();
    switch (route) {
      case 'bill_detail':
        final billId =
            data['billId']?.toString() ?? data['bill_id']?.toString();
        if (billId == null || billId.isEmpty) return null;
        return '/bill/$billId';
      case 'notification_detail':
        final notificationId =
            data['notificationId']?.toString() ??
            data['notification_id']?.toString();
        if (notificationId == null || notificationId.isEmpty) return null;
        return '/notifications/$notificationId';
      case 'notifications':
        return '/notifications';
      default:
        return null;
    }
  }

  static String encodeBillDetail({required String billId}) {
    return jsonEncode({'route': 'bill_detail', 'billId': billId});
  }
}

/// Wrapper for local and remote notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String?> _notificationTapController =
      StreamController<String?>.broadcast();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;
  bool _localInitialized = false;
  bool _remoteInitialized = false;

  /// Stream to listen for notification tap events.
  Stream<String?> get onNotificationTap => _notificationTapController.stream;

  bool get isRemoteConfigured => Firebase.apps.isNotEmpty;

  Future<void> init() async {
    if (!_localInitialized) {
      await _initLocalNotifications();
      _localInitialized = true;
    }
    if (!_remoteInitialized) {
      await _initRemoteMessaging();
      _remoteInitialized = true;
    }
  }

  Future<void> _initLocalNotifications() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _notificationTapController.add(
          NotificationPayloads.resolveNavigationPath(response.payload),
        );
      },
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _billReminderChannelId,
        'Pengingat Tagihan',
        description: 'Notifikasi pengingat tagihan mendatang',
        importance: Importance.high,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _remoteMessageChannelId,
        'Push Notification',
        description: 'Notifikasi remote dari cloud',
        importance: Importance.high,
      ),
    );
  }

  Future<void> _initRemoteMessaging() async {
    if (!isRemoteConfigured) {
      await LocalPreferencesService.setRemotePushError(
        'Firebase belum dikonfigurasi di aplikasi ini.',
      );
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      _foregroundMessageSubscription?.cancel();
      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );

      _messageOpenedSubscription?.cancel();
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
        message,
      ) {
        _notificationTapController.add(_resolveRemoteMessageRoute(message));
      });

      _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((
        token,
      ) async {
        await LocalPreferencesService.setRemotePushToken(token);
        await LocalPreferencesService.setRemotePushError(null);
        await syncRemoteTokenToCloud();
      });

      final token = await _messaging.getToken();
      await LocalPreferencesService.setRemotePushToken(token);
      await LocalPreferencesService.setRemotePushError(null);

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _notificationTapController.add(
          _resolveRemoteMessageRoute(initialMessage),
        );
      }
    } catch (e) {
      await LocalPreferencesService.setRemotePushError(e.toString());
      debugPrint('Remote push init skipped: $e');
    }
  }

  Future<void> requestPermissions() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    final macosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (isRemoteConfigured) {
      try {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        final token = await _messaging.getToken();
        await LocalPreferencesService.setRemotePushToken(token);
      } catch (e) {
        await LocalPreferencesService.setRemotePushError(e.toString());
      }
    }
  }

  Future<String?> getRemotePushToken() async {
    final cached = await LocalPreferencesService.getRemotePushToken();
    if (cached != null && cached.isNotEmpty) return cached;
    if (!isRemoteConfigured) return null;
    try {
      final fresh = await _messaging.getToken();
      await LocalPreferencesService.setRemotePushToken(fresh);
      return fresh;
    } catch (_) {
      return null;
    }
  }

  Future<void> syncRemoteTokenToCloud() async {
    if (!isRemoteConfigured || !SupabaseConfig.isConfigured) {
      return;
    }

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    final token = await getRemotePushToken();
    if (token == null || token.isEmpty) return;

    final platform = switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      _ => Platform.operatingSystem,
    };

    await client.from('device_push_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'platform': platform,
      'is_active': true,
      'last_seen_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,token');
    await LocalPreferencesService.setRemotePushError(null);
  }

  Future<void> deactivateRemoteTokenInCloud({String? userId}) async {
    if (!isRemoteConfigured || !SupabaseConfig.isConfigured) return;

    final token = await getRemotePushToken();
    if (token == null || token.isEmpty) return;

    final client = Supabase.instance.client;
    final effectiveUserId = userId ?? client.auth.currentUser?.id;
    if (effectiveUserId == null || effectiveUserId.isEmpty) return;

    await client
        .from('device_push_tokens')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('user_id', effectiveUserId)
        .eq('token', token);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final payload = _resolvePayloadString(message);
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _remoteMessageChannelId,
        'Push Notification',
        channelDescription: 'Notifikasi remote dari cloud',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      _stableNotificationId(message),
      notification.title,
      notification.body,
      notificationDetails,
      payload: payload,
    );
  }

  String? _resolveRemoteMessageRoute(RemoteMessage message) {
    final payload = _resolvePayloadString(message);
    return NotificationPayloads.resolveNavigationPath(payload);
  }

  String? _resolvePayloadString(RemoteMessage message) {
    final data = message.data;
    final routePayload = NotificationPayloads.routeFromData(data);
    if (routePayload != null) {
      return jsonEncode(data);
    }
    final billId = data['bill_id'] ?? data['billId'];
    if (billId != null) {
      return NotificationPayloads.encodeBillDetail(billId: billId.toString());
    }
    return null;
  }

  int _stableNotificationId(RemoteMessage message) {
    return message.messageId?.hashCode ??
        message.sentTime?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;
  }

  /// Schedule a bill reminder notification.
  Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      _billReminderChannelId,
      'Pengingat Tagihan',
      channelDescription: 'Notifikasi pengingat tagihan mendatang',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  Future<void> cancelBillReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
  }

  /// Reschedule all bill reminders on app startup.
  /// - Bills with waktuPengingat in the future: schedule notification
  /// - Bills with tanggalJatuhTempo in the past and not paid: show immediate notification
  Future<void> rescheduleAllBillReminders(Isar isar) async {
    try {
      final now = DateTime.now();
      final bills = await isar.billModels
          .filter()
          .statusEqualTo('upcoming')
          .or()
          .statusEqualTo('pending')
          .or()
          .statusEqualTo('overdue')
          .findAll();

      for (final bill in bills) {
        final billId = bill.id;
        if (billId == null) continue;

        final notificationId = billId.hashCode;

        // Cancel any existing notification for this bill
        await cancelBillReminder(notificationId);

        final waktuPengingat = bill.waktuPengingat;
        final tanggalJatuhTempo = bill.tanggalJatuhTempo;
        final nama = bill.nama ?? 'Tagihan';
        final payload = NotificationPayloads.encodeBillDetail(billId: billId);

        // If waktuPengingat is in the future, schedule it
        if (waktuPengingat != null && waktuPengingat.isAfter(now)) {
          await scheduleBillReminder(
            id: notificationId,
            title: 'Pengingat Tagihan',
            body: 'Tagihan "$nama" akan jatuh tempo.',
            scheduledDate: waktuPengingat,
            payload: payload,
          );
        }

        // If tanggalJatuhTempo is in the past (overdue), show immediate notification
        if (tanggalJatuhTempo != null && tanggalJatuhTempo.isBefore(now)) {
          await _showImmediateOverdueNotification(
            id: notificationId + 100000,
            nama: nama,
            payload: payload,
          );
        }
      }
    } catch (e) {
      debugPrint('rescheduleAllBillReminders error: $e');
    }
  }

  Future<void> _showImmediateOverdueNotification({
    required int id,
    required String nama,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _billReminderChannelId,
      'Pengingat Tagihan',
      channelDescription: 'Notifikasi pengingat tagihan mendatang',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id,
      'Tagihan Terlambat',
      'Tagihan "$nama" sudah melewati jatuh tempo!',
      notificationDetails,
      payload: payload,
    );
  }
}

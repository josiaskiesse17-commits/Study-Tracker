import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart';

/// A thin wrapper around [flutter_local_notifications] for scheduling
/// opportunity reminders.
///
/// Supported platforms: Android and iOS. On other platforms (web, desktop)
/// the service gracefully degrades — reminders cannot be scheduled and
/// [isSupported] returns false.
class NotificationService {
  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Whether scheduled notifications are supported on this platform.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Initializes the plugin. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    if (!isSupported) {
      _initialized = true;
      return;
    }

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Requests notification permission from the user. On platforms where
  /// notifications are not supported, returns false without error.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;

    await initialize();

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        return await iosPlugin.requestPermissions(
              alert: true,
              badge: false,
              sound: true,
            ) ??
            false;
      }
      return false;
    }

    // Android 13+ requires runtime permission for notifications.
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        return await androidPlugin.requestNotificationsPermission() ?? false;
      }
    }

    return true;
  }

  /// Schedules a reminder notification for an opportunity.
  ///
  /// [opportunityId] is used to derive a stable notification ID so that
  /// editing an opportunity replaces the existing reminder instead of
  /// creating a duplicate.
  ///
  /// Returns the notification ID that was scheduled, or null if notifications
  /// are not supported or permission was denied.
  Future<int?> scheduleReminder({
    required String opportunityId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    int typeOffset = 0,
  }) async {
    if (!isSupported) return null;

    await initialize();

    final notificationId = _notificationId(opportunityId, typeOffset);

    final androidDetails = const AndroidNotificationDetails(
      'opportunity_reminders',
      'Opportunity Reminders',
      channelDescription: 'Reminders for scholarships and events',
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzDate = TZDateTime.from(scheduledAt, local);

    await _plugin.zonedSchedule(
      notificationId,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );

    return notificationId;
  }

  /// Cancels a previously scheduled reminder for an opportunity.
  Future<void> cancelReminder(
    String opportunityId, {
    int typeOffset = 0,
  }) async {
    if (!isSupported) return;
    await initialize();
    final id = _notificationId(opportunityId, typeOffset);
    await _plugin.cancel(id);
  }

  /// Cancels all reminders for an opportunity (both date and next-action).
  Future<void> cancelAllReminders(String opportunityId) async {
    await cancelReminder(opportunityId, typeOffset: 0);
    await cancelReminder(opportunityId, typeOffset: 1);
  }

  /// Derives a stable notification ID from an opportunity ID and type offset.
  int _notificationId(String opportunityId, int typeOffset) {
    final combined = '$opportunityId-$typeOffset';
    return combined.hashCode.abs() % (1 << 29);
  }

  void _onNotificationTapped(NotificationResponse details) {
    // Notification tap handling can be extended to deep-link into the app.
    debugPrint('Notification tapped: ${details.payload}');
  }
}

/// Provider for the notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_colors.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Initialize Timezone Database
    tz.initializeTimeZones();

    // TR odaklı: yerel zamanı İstanbul olarak sabitle.
    // (Cihaz farklı bir bölgedeyse bile saat kayması/"hemen bildirim" riskini azaltır.)
    try {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    } catch (_) {
      // Fallback: tz.local
    }

    // Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _initialized = true;
  }

  /// Schedules a billing reminder notification
  /// - Reminder time: 1 day before the billing date at 09:00 (local)
  /// - If reminder time is in the past / too close, it will NOT schedule (prevents instant firing).
  Future<void> scheduleBillingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Always cancel existing with same id to avoid collisions.
      await flutterLocalNotificationsPlugin.cancel(id);

      // Normalize scheduledDate to date-only to avoid timezone/UTC drift.
      final paymentDateLocal = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      // Calculate 1 day before the billing date
      final reminderDate = paymentDateLocal.subtract(const Duration(days: 1));

      // Reminder at 09:00 local time
      final reminderTz = tz.TZDateTime(
        tz.local,
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
        0,
      );

      final nowTz = tz.TZDateTime.now(tz.local);

      // If reminder time is in the past or too close, don't schedule.
      // (iOS can fire immediately when scheduled in the past)
      if (!reminderTz.isAfter(nowTz.add(const Duration(minutes: 2)))) {
        if (kDebugMode) {
          debugPrint(
            "Notification skipped (too close/past). id=$id reminder=$reminderTz now=$nowTz payment=$paymentDateLocal",
          );
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          "Notification scheduled. id=$id reminder=$reminderTz payment=$paymentDateLocal tz=${tz.local.name}",
        );
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        reminderTz,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'billing_channel',
            'Abonelik Hatırlatıcıları',
            channelDescription:
                'Aboneliğinizin ödeme tarihinden 1 gün önce sizi bilgilendirir',
            importance: Importance.max,
            priority: Priority.high,
            color: AppColors.primaryAccent,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // Do not set matchDateTimeComponents here; we want a single fire.
      );
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  /// Cancels a specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Cancels all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}

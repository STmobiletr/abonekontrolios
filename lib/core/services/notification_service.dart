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

  Future<void> init() async {
    // Initialize Timezone Database
    tz.initializeTimeZones();

    // Uygulama TR odaklı olduğu için yerel zamanı İstanbul olarak sabitliyoruz.
    // (Cihaz farklı bir bölgedeyse bile saat kayması/"hemen bildirim" sorununu azaltır.)
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

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Schedules a billing reminder notification
  Future<void> scheduleBillingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Calculate 1 day before the billing date
      final reminderDate = scheduledDate.subtract(const Duration(days: 1));

      // Tarih seçiciden gelen saat genelde 00:00 oluyor. Hatırlatmayı sabah 09:00'a çekiyoruz.
      final reminderAtMorning = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
        0,
      );

      // If the date is in the past, don't schedule
      if (reminderAtMorning.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(reminderAtMorning, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'billing_channel',
            'Abonelik Hatırlatıcıları',
            channelDescription: 'Aboneliğinizin ödeme tarihinden 1 gün önce sizi bilgilendirir',
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
    // cancelAll genelde pending + delivered bildirimleri temizler,
    // fakat bazı iOS sürümlerinde ekstra platform çağrısı gerekebilir.
    await flutterLocalNotificationsPlugin.cancelAll();

    // iOS/macOS spesifik temizleme (varsa)
    final ios = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await ios?.cancelAll();

    final macos = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    await macos?.cancelAll();
  }

  /// Cancels all scheduled notifications (alias for full cleanup).
  Future<void> cancelAllScheduledNotifications() async {
    await cancelAllNotifications();
  }
}

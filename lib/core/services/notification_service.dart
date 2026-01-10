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
  /// Hatırlatma: ödeme tarihinden 1 gün önce, sabah 09:00.
  ///
  /// iOS bazen geçmiş/yanlış hesaplanan zamanlarda bildirimi "hemen" gösterebilir.
  /// Bu yüzden TZDateTime ile aynı timezone'da (tz.local) hesap yapıp,
  /// geçmişe/çok yakına düşen zamanları asla planlamıyoruz.
  Future<void> scheduleBillingNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Ödeme tarihinden 1 gün önce 09:00 (tz.local)
      final tzReminder = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        9,
        0,
      ).subtract(const Duration(days: 1));

      final tzNow = tz.TZDateTime.now(tz.local);

      // Çok yakın/geçmiş -> asla planlama (iOS'ta anında düşme bug'ını engeller)
      if (!tzReminder.isAfter(tzNow.add(const Duration(minutes: 5)))) {
        debugPrint(
          "Skip scheduling (past/too soon). id=$id now=$tzNow reminder=$tzReminder pay=$scheduledDate",
        );
        return;
      }

      // Aynı ID ile eski bir plan varsa temizle
      await flutterLocalNotificationsPlugin.cancel(id);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzReminder,
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
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint("Scheduled notification. id=$id at=$tzReminder pay=$scheduledDate");
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

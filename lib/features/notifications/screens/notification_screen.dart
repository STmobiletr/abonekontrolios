import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_colors.dart';

/// Screen to display scheduled notifications
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<PendingNotificationRequest> _pendingNotifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final notifications = await NotificationService()
        .flutterLocalNotificationsPlugin
        .pendingNotificationRequests();
    setState(() {
      _pendingNotifications = notifications;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Bildirimler",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _pendingNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: textColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Gelen bildirim yok",
                            style: TextStyle(
                              color: textColor.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _pendingNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _pendingNotifications[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: GlassBox(
                            borderRadius: 16,
                            color: isDark
                                ? AppColors.glassDarkTint.withOpacity(0.05)
                                : AppColors.glassLightTint.withOpacity(0.05),
                            borderColor: isDark
                                ? AppColors.darkGlassBorder
                                : AppColors.lightGlassBorder,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.primaryAccent.withOpacity(
                                            0.1,
                                          )
                                        : AppColors.lightPrimary.withOpacity(
                                            0.1,
                                          ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.notifications_active,
                                    color: isDark
                                        ? AppColors.primaryAccent
                                        : AppColors.lightPrimary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notification.title ?? "Notification",
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.body ?? "",
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

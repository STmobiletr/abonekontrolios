import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/ui/glass_box.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../../core/services/notification_service.dart';

/// Bildirimler ekranı.
///
/// Bu ekran, cihazın bildirim merkezine düşen "geçmiş" bildirimleri listelemez.
/// Kullanıcının isteğine göre sadece "ödeme tarihine 1 gün kalan" abonelikleri
/// gösterir. Böylece abonelik ekler eklemez yanlış bir şekilde "1 gün kaldı"
/// mesajı görünmez.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final Box<SubscriptionModel> _subscriptionsBox;
  late final Box _dismissalsBox;

  @override
  void initState() {
    super.initState();
    _subscriptionsBox = Hive.box<SubscriptionModel>('subscriptions');
    _dismissalsBox = Hive.box('notification_dismissals');
  }

  int _daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  bool _isDismissed(SubscriptionModel subscription) {
    final dismissedFor = _dismissalsBox.get(subscription.id) as String?;
    if (dismissedFor == null) return false;
    return dismissedFor == subscription.nextBillingDate.toIso8601String();
  }

  List<SubscriptionModel> _dueInOneDay({bool includeDismissed = false}) {
    final items = _subscriptionsBox.values
        .where((s) => _daysUntil(s.nextBillingDate) == 1)
        .where((s) => includeDismissed || !_isDismissed(s))
        .toList();
    items.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return items;
  }

  String _formatMoney(SubscriptionModel s) {
    // Uygulama genelinde bu format yeterli; daha sonra istersen para formatını
    // locale'e göre iyileştiririz.
    return '${s.currency} ${s.price.toStringAsFixed(2)}';
  }

  Future<void> _clearScheduledNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bildirimleri temizle'),
        content: const Text(
          'Telefonunuza planlanan bildirimler temizlenecek. '
          'Abonelikler silinmez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.cancelAllNotifications();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Planlanan bildirimler temizlendi')),
    );
  }

  Future<void> _clearInAppNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bildirimleri sil'),
        content: const Text(
          'Bu ekrandaki bildirimler kaldırılacak. '
          'Abonelikleriniz silinmez.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dueNow = _dueInOneDay(includeDismissed: true);
    for (final subscription in dueNow) {
      await _dismissalsBox.put(
        subscription.id,
        subscription.nextBillingDate.toIso8601String(),
      );
    }

    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bildirimler silindi')),
    );
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
                    'Bildirimler',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _dismissalsBox.listenable(),
                builder: (context, _, __) {
                  return StreamBuilder<BoxEvent>(
                    stream: _subscriptionsBox.watch(),
                    builder: (context, __) {
                      final due = _dueInOneDay();

                      if (due.isEmpty) {
                        return Center(
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
                                '1 gün kalan ödeme yok',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.5),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: due.length,
                        itemBuilder: (context, index) {
                          final sub = due[index];
                          final title = '${AppStrings.upcomingCharge}${sub.name}';
                          final body =
                              '${AppStrings.youWillBeCharged}${_formatMoney(sub)}. '
                              'Ödeme tarihi: ${AppStrings.formatDate(sub.nextBillingDate)}. '
                              '${AppStrings.chargeDisclaimer}';

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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.primaryAccent
                                              .withOpacity(0.1)
                                          : AppColors.lightPrimary
                                              .withOpacity(0.1),
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
                                          title,
                                          style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          body,
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
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _clearInAppNotifications,
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: const Text('Bildirimleri sil'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _clearScheduledNotifications,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Planlanan bildirimleri temizle'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

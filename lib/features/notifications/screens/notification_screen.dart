import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../subscriptions/models/subscription_model.dart';

/// Bildirimler ekranı
///
/// Bu ekran iOS/Android sistem bildirim geçmişini değil,
/// "1 gün sonra ödeme var" koşulunu sağlayan abonelikleri gösterir.
///
/// Böylece:
/// - Abonelik ekler eklemez "bildirim var" gibi görünmez
/// - Uygulamadan çıkınca liste kaybolmaz (Hive'dan okunur)
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  int _daysBetweenDateOnly(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box<SubscriptionModel>('subscriptions');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(AppStrings.notifications),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<SubscriptionModel> box, _) {
          final now = DateTime.now();

          final upcoming = box.values.where((sub) {
            final days = _daysBetweenDateOnly(now, sub.nextBillingDate);
            return days == 1; // sadece 1 gün kala
          }).toList()
            ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

          if (upcoming.isEmpty) {
            return Center(
              child: Text(
                'Henüz yaklaşan bildirim yok.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: upcoming.length,
            itemBuilder: (context, index) {
              final sub = upcoming[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassBox(
                  borderRadius: 16,
                  color: isDark
                      ? AppColors.glassDarkTint.withOpacity(0.05)
                      : AppColors.glassLightTint.withOpacity(0.05),
                  borderColor:
                      isDark ? AppColors.darkGlassBorder : AppColors.lightGlassBorder,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppStrings.upcomingCharge}${sub.name}',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${AppStrings.youWillBeCharged}₺${sub.price.toStringAsFixed(2)}. '
                              'Ödeme tarihi: ${AppStrings.formatDate(sub.nextBillingDate)}. '
                              '${AppStrings.chargeDisclaimer}',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 13,
                                height: 1.25,
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
      ),
    );
  }
}

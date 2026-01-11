import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/ui/glass_box.dart';
import '../../subscriptions/models/subscription_model.dart';

/// Bildirimler ekranı:
/// - Artık "pending scheduled notifications" listesini göstermiyor.
/// - Sadece ödeme tarihine **1 gün kalan** abonelikleri gösteriyor.
///
/// Böylece abonelik eklerken "hemen bildirim geldi" gibi görünen problem bitiyor.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final Box<SubscriptionModel> _box;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<SubscriptionModel>('subscriptions');
  }

  bool _isOneDayBefore(DateTime billingDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(billingDate.year, billingDate.month, billingDate.day);
    return target.difference(today).inDays == 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
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
                    AppStrings.notifications,
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
              child: StreamBuilder<BoxEvent>(
                stream: _box.watch(),
                builder: (context, _) {
                  final due = _box.values.where((s) => _isOneDayBefore(s.nextBillingDate)).toList()
                    ..sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));

                  if (due.isEmpty) {
                    return Center(
                      child: Text(
                        "Şu an 1 gün kala ödeme yok.",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: due.length,
                    itemBuilder: (context, index) {
                      final sub = due[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassBox(
                          borderRadius: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryAccent.withOpacity(0.15),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${AppStrings.upcomingCharge}${sub.name}",
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${AppStrings.youWillBeCharged}₺${sub.price.toStringAsFixed(2)}. "
                                        "Ödeme tarihi: ${AppStrings.formatDate(sub.nextBillingDate)}. "
                                        "${AppStrings.chargeDisclaimer}",
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.75),
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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

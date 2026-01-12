import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/ui/banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/url_utils.dart';
import '../../subscriptions/models/subscription_model.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../../subscriptions/screens/add_subscription_screen.dart';
import '../../settings/providers/settings_provider.dart';

/// Screen to display subscription details
class SubscriptionDetailScreen extends ConsumerWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return subscriptionsAsync.when(
      loading: () => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Text("Error: $err", style: TextStyle(color: textColor)),
        ),
      ),
      data: (subscriptions) {
        // Find the subscription by ID
        final subscription = subscriptions.firstWhere(
          (s) => s.id == subscriptionId,
          orElse: () => SubscriptionModel(
            id: 'deleted',
            name: 'Deleted',
            price: 0,
            currency: '',
            billingCycle: '',
            nextBillingDate: DateTime.now(),
            colorHex: '#000000',
          ),
        );

        // Handle deleted subscription
        if (subscription.id == 'deleted') {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Text(
                AppStrings.subscriptionNotFound,
                style: TextStyle(color: textColor),
              ),
            ),
          );
        }

        final color = subscription.colorHex != null
            ? Color(
                int.parse("0xFF${subscription.colorHex!.replaceAll('#', '')}"),
              )
            : Theme.of(context).primaryColor;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(subscription.name, style: TextStyle(color: textColor)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Card
                GlassBox(
                  borderRadius: 24,
                  color: color.withOpacity(0.2),
                  borderColor: isDark ? Colors.white10 : Colors.black12,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            subscription.name.isNotEmpty
                                ? subscription.name[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        subscription.name,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${ref.watch(settingsNotifierProvider).currencySymbol} ${subscription.price.toStringAsFixed(2)} / ${AppStrings.billingCycleLabel(subscription.billingCycle)}",
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
                _buildDetailRow(
                  context,
                  AppStrings.nextBilling,
                  AppStrings.formatDate(subscription.nextBillingDate),
                ),
                if (subscription.cancellationUrl != null &&
                    subscription.cancellationUrl!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final normalizedUrl = normalizeUrl(
                          subscription.cancellationUrl!,
                        );
                        final Uri url = Uri.parse(normalizedUrl);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          debugPrint('Could not launch $url');
                        }
                      },
                      icon: const Icon(Icons.link_off, color: Colors.white),
                      label: Text(
                        AppStrings.cancelSubscription,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // Edit/Delete Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddSubscriptionScreen(
                                subscription: subscription,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? textColor.withOpacity(0.1)
                              : AppColors.lightPrimary.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.edit,
                          style: TextStyle(
                            color: isDark ? textColor : AppColors.lightPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Delete from Hive
                          ref
                              .read(subscriptionRepositoryProvider)
                              .deleteSubscription(subscription.id);

                          // Go back to Dashboard
                          Navigator.pop(context);

                          // Show confirmation
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppStrings.subscriptionRemoved),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.dangerAccent.withOpacity(0.2)
                              : AppColors.lightDanger.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppStrings.delete,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.dangerAccent
                                : AppColors.lightDanger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
          // Uncomment the above line to enable ads
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return GlassBox(
      borderRadius: 16,
      color: isDark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.05),
      borderColor: isDark ? Colors.white10 : Colors.black12,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

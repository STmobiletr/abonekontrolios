import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_strings.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:intl/intl.dart';

/// Widget to display the total monthly spending summary
class SummaryCard extends ConsumerWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCost = ref.watch(totalMonthlyCostProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark
        ? Colors.white.withOpacity(0.7)
        : Colors.black54;

    return Container(
      height: 220,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: GlassBox(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        color: Theme.of(context).colorScheme.primary,
        borderColor: isDark ? Colors.white10 : Colors.black12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.nfc, color: subTextColor, size: 40),
                Text(
                  AppStrings.subZeroCard,
                  style: TextStyle(
                    color: subTextColor,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Middle (The Money)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.totalMonthlySpend,
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  "${ref.watch(settingsNotifierProvider).currencySymbol}${totalCost.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(isDark ? 0.5 : 0.0),
                        blurRadius: 20,
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.now()),
                  style: TextStyle(color: subTextColor),
                ),
                Image.network(
                  "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1280px-Mastercard-logo.svg.png",
                  height: 30,
                  errorBuilder: (c, o, s) =>
                      Icon(Icons.credit_card, color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

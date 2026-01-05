import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_strings.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/constants/app_colors.dart';

/// Widget to display spending chart
class SpendingChart extends ConsumerWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return subscriptionsAsync.when(
      data: (subs) {
        if (subs.isEmpty) return const SizedBox();

        // Calculate Data
        Map<String, double> categoryTotals = {};
        double grandTotal = 0;

        for (var sub in subs) {
          // Normalize price to monthly
          double monthlyPrice = sub.billingCycle == 'Yearly'
              ? sub.price / 12
              : sub.price;

          grandTotal += monthlyPrice;

          // Add to category
          if (categoryTotals.containsKey(sub.category)) {
            categoryTotals[sub.category] =
                categoryTotals[sub.category]! + monthlyPrice;
          } else {
            categoryTotals[sub.category] = monthlyPrice;
          }
        }

        // Build Sections
        List<PieChartSectionData> sections = [];
        int colorIndex = 0;
        List<Color> colors = isDark
            ? AppColors.chartColorsDark
            : AppColors.chartColorsLight;

        categoryTotals.forEach((category, amount) {
          final percent = (amount / grandTotal) * 100;
          sections.add(
            PieChartSectionData(
              color: colors[colorIndex % colors.length],
              value: amount,
              title: '${percent.toStringAsFixed(0)}%',
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          );
          colorIndex++;
        });

        // Render Chart
        return Container(
          margin: const EdgeInsets.all(20),
          child: GlassBox(
            borderRadius: 24,
            padding: const EdgeInsets.all(20),
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            borderColor: isDark ? Colors.white10 : Colors.black12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.spendingBreakdown,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend (Detailed List)
                Column(
                  children: categoryTotals.entries.map((entry) {
                    final index = categoryTotals.keys.toList().indexOf(
                      entry.key,
                    );
                    final color = colors[index % colors.length];
                    final percent = (entry.value / grandTotal) * 100;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${percent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${ref.watch(settingsNotifierProvider).currencySymbol}${entry.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}

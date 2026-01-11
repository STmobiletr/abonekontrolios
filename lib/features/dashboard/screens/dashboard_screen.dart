import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/ui/banner_ad_widget.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../widgets/summary_card.dart';
import '../../subscriptions/screens/add_subscription_screen.dart';
import 'subscription_detail_screen.dart';
import 'spending_chart_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../settings/providers/settings_provider.dart';
import '../../notifications/screens/notification_screen.dart';

/// Main Dashboard Screen
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptionsAsync = ref.watch(subscriptionListProvider);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hamburger Menu
                  IconButton(
                    icon: Icon(Icons.menu_rounded, color: textColor, size: 28),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  Text(
                    AppStrings.dashboard,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Notification Icon
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: textColor,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Header Card
            const SummaryCard(),

            // List Label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Row(
                children: [
                  Text(
                    AppStrings.yourSubscriptions,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sort, color: Colors.grey),
                    onPressed: () => _showSortOptions(context, ref),
                  ),
                ],
              ),
            ),

            // Animated List
            Expanded(
              child: subscriptionsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text("Error: $err")),
                data: (subs) {
                  if (subs.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noSubsYet,
                        style: TextStyle(color: textColor.withOpacity(0.5)),
                      ),
                    );
                  }

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: subs.length,
                      itemBuilder: (context, index) {
                        final sub = subs[index];

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SubscriptionDetailScreen(
                                            subscriptionId: sub.id,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  height: 80,
                                  child: GlassBox(
                                    borderRadius: 16,
                                    color: isDark
                                        ? AppColors.lightSurface
                                        : AppColors.darkSurface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        // Icon/Logo Placeholder
                                        Container(
                                          width: 45,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: sub.colorHex != null
                                                ? Color(
                                                    int.parse(
                                                      "0xFF${sub.colorHex!.replaceAll('#', '')}",
                                                    ),
                                                  )
                                                : Colors.black26,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              sub.name.isNotEmpty
                                                  ? sub.name[0].toUpperCase()
                                                  : "?",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Details
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sub.name,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? AppColors.darkText
                                                      : AppColors.lightText,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                "${AppStrings.billingCycleLabel(sub.billingCycle)} • ${AppStrings.formatDate(sub.nextBillingDate)}",
                                                style: TextStyle(
                                                  color:
                                                      (isDark
                                                              ? AppColors
                                                                    .darkText
                                                              : AppColors
                                                                    .lightText)
                                                          .withOpacity(0.5),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Price
                                        Text(
                                          "${ref.watch(settingsNotifierProvider).currencySymbol}${sub.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkText
                                                : AppColors.lightText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSubscriptionScreen(),
            ),
          );
        },
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      // Uncomment the above line to enable ads
    );
  }

  // Drawer Widget
  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: GlassBox(
        borderRadius: 0,
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        gradientOpacity: isDark ? null : 0.9,
        borderColor: isDark ? null : AppColors.lightGlassBorder,
        child: Column(
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0),
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/Logo.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Drawer Items
            _buildDrawerItem(
              context,
              icon: Icons.dashboard_rounded,
              title: AppStrings.dashboard,
              onTap: () => Navigator.pop(context),
            ),
            _buildDrawerItem(
              context,
              icon: Icons.pie_chart_rounded,
              title: AppStrings.analytics,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpendingChartScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              icon: Icons.settings_rounded,
              title: AppStrings.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),

            const Spacer(),

            // Footer
            SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Text(
                AppStrings.version,
                style: TextStyle(
                  color: textColor.withOpacity(0.3),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return ListTile(
      leading: Icon(icon, color: textColor.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: textColor.withOpacity(0.05),
    );
  }

  void _showSortOptions(BuildContext context, WidgetRef ref) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.sortBy,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortNameAsc,
                  SortOption.nameAsc,
                  Icons.sort_by_alpha,
                ),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortNameDesc,
                  SortOption.nameDesc,
                  Icons.sort_by_alpha,
                ),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortPriceHigh,
                  SortOption.priceHighToLow,
                  Icons.arrow_downward,
                ),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortPriceLow,
                  SortOption.priceLowToHigh,
                  Icons.arrow_upward,
                ),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortDateNewest,
                  SortOption.dateNewest,
                  Icons.calendar_today,
                ),
                _buildSortOption(
                  context,
                  ref,
                  AppStrings.sortDateOldest,
                  SortOption.dateOldest,
                  Icons.calendar_today,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    SortOption option,
    IconData icon,
  ) {
    final currentSort = ref.watch(sortOptionNotifierProvider);
    final isSelected = currentSort == option;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : textColor.withOpacity(0.7),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        ref.read(sortOptionNotifierProvider.notifier).setSortOption(option);
        Navigator.pop(context);
      },
    );
  }
}

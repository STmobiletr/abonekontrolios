import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/glass_box.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/ui/banner_ad_widget.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/settings_provider.dart';
import '../../subscriptions/providers/subscription_providers.dart';

/// Screen to manage application settings
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new, color: textColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  Text(
                    AppStrings.settings,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // General Section
              _buildSectionHeader(context, AppStrings.general),
              _buildSettingTile(
                context,
                icon: Icons.currency_lira,
                title: AppStrings.currency,
                subtitle: '${settings.currency} (₺)',
                onTap: () {
                  _showCurrencyPicker(context, ref);
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.language,
                title: AppStrings.language,
                subtitle: settings.language,
                onTap: () {
                  _showLanguagePicker(context, ref);
                },
              ),

              const SizedBox(height: 20),

              // Appearance Section
              _buildSectionHeader(context, AppStrings.appearance),
              _buildSettingTile(
                context,
                icon: Icons.dark_mode,
                title: AppStrings.theme,
                subtitle: settings.isDarkMode
                    ? AppStrings.cyberDark
                    : AppStrings.lightMode,
                trailing: Switch(
                  value: settings.isDarkMode,
                  onChanged: (val) {
                    notifier.toggleTheme(val);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Notifications Section
              _buildSectionHeader(context, AppStrings.notifications),
              _buildSettingTile(
                context,
                icon: Icons.notifications_active,
                title: AppStrings.billingReminders,
                subtitle: settings.notificationsEnabled
                    ? AppStrings.billingRemindersEnabled
                    : AppStrings.billingRemindersDisabled,
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (val) {
                    notifier.toggleNotifications(val);
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Data Section
              _buildSectionHeader(context, AppStrings.data),
              _buildSettingTile(
                context,
                icon: Icons.cloud_upload,
                title: AppStrings.backupRestore,
                subtitle: AppStrings.backupRestoreSubtitle,
                onTap: () {
                  _showBackupRestoreOptions(context);
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.delete_forever,
                title: AppStrings.clearAllData,
                subtitle: AppStrings.clearAllDataSubtitle,
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  _showClearDataDialog(context, ref);
                },
              ),

              const SizedBox(height: 20),

              // About Section
              _buildSectionHeader(context, AppStrings.about),
              _buildSettingTile(
                context,
                icon: Icons.info_outline,
                title: AppStrings.version,
                subtitle: AppStrings.versionBeta,
                onTap: () {},
              ),
              const SizedBox(height: 40),
              Center(
                child: Text(
                  AppStrings.madeBy,
                  style: TextStyle(color: textColor.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      // Uncomment the above line to enable ads
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currencies = ["TRY"];
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.selectCurrency,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...currencies.map(
                  (currency) => ListTile(
                    title: Text(currency, style: TextStyle(color: textColor)),
                    onTap: () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setCurrency(currency);
                      Navigator.pop(context);
                    },
                    trailing:
                        ref.read(settingsNotifierProvider).currency == currency
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languages = ["Türkçe"];
        return Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.selectLanguage,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...languages.map(
                  (language) => ListTile(
                    title: Text(language, style: TextStyle(color: textColor)),
                    onTap: () {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setLanguage(language);
                      Navigator.pop(context);
                    },
                    trailing:
                        ref.read(settingsNotifierProvider).language == language
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          AppStrings.clearDataDialogTitle,
          style: TextStyle(color: textColor),
        ),
        content: Text(
          AppStrings.clearDataDialogContent,
          style: TextStyle(color: textColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              // Clear Settings
              ref.read(settingsNotifierProvider.notifier).clearAllData();
              // Clear Subscriptions
              ref.read(subscriptionRepositoryProvider).clearAllSubscriptions();
              Navigator.pop(context);
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassBox(
        borderRadius: 16,
        color: isDark
            ? AppColors.glassDarkTint.withOpacity(0.05)
            : AppColors.glassLightTint.withOpacity(0.05),
        padding: const EdgeInsets.all(0),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? defaultTextColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? defaultTextColor, size: 24),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? defaultTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: TextStyle(
                    color: (textColor ?? defaultTextColor).withOpacity(0.5),
                    fontSize: 12,
                  ),
                )
              : null,
          trailing:
              trailing ??
              Icon(
                Icons.arrow_forward_ios,
                color: defaultTextColor.withOpacity(0.2),
                size: 16,
              ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showBackupRestoreOptions(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.lightText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.backupRestore,
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(
                  Icons.save_alt,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  AppStrings.createBackup,
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  AppStrings.createBackupSubtitle,
                  style: TextStyle(color: textColor.withOpacity(0.5)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.creatingBackup),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  final success = await BackupService().createBackup();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? AppStrings.backupSuccess
                              : AppStrings.backupFailed,
                        ),
                        backgroundColor: success
                            ? AppColors.primaryAccent
                            : AppColors.dangerAccent,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.restore,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  AppStrings.restoreBackup,
                  style: TextStyle(color: textColor),
                ),
                subtitle: Text(
                  AppStrings.restoreBackupSubtitle,
                  style: TextStyle(color: textColor.withOpacity(0.5)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Show loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.restoringBackup),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  final success = await BackupService().restoreBackup();

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? AppStrings.restoreSuccess
                              : AppStrings.restoreFailed,
                        ),
                        backgroundColor: success
                            ? AppColors.primaryAccent
                            : AppColors.dangerAccent,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

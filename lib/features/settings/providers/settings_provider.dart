import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/notification_service.dart';
import '../../subscriptions/providers/subscription_providers.dart';
import '../../../core/constants/app_strings.dart';

part 'settings_provider.g.dart';

/// State class for application settings
class SettingsState {
  final bool isDarkMode;
  final String currency;
  final bool notificationsEnabled;
  final bool onboardingComplete;
  final String language;

  const SettingsState({
    this.isDarkMode = true,
    this.currency = 'TRY',
    this.notificationsEnabled = true,
    this.onboardingComplete = false,
    this.language = 'Türkçe',
  });

  String get currencySymbol => '₺';


  SettingsState copyWith({
    bool? isDarkMode,
    String? currency,
    bool? notificationsEnabled,
    bool? onboardingComplete,
    String? language,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      language: language ?? this.language,
    );
  }
}

/// Notifier to manage application settings
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  late Box _box;

  @override
  SettingsState build() {
    _box = Hive.box('settings');

    final isDarkMode =
        _box.get('isDarkMode', defaultValue: true) as bool? ?? true;
    final _storedCurrency =
        _box.get('currency', defaultValue: 'TRY') as String? ?? 'TRY';
    // Uygulama yalnızca Türk Lirası (TRY) kullanır.
    final currency = 'TRY';
    if (_storedCurrency != 'TRY') {
      // Persist without blocking build()
      _box.put('currency', 'TRY');
    }
    final notificationsEnabled =
        _box.get('notificationsEnabled', defaultValue: true) as bool? ?? true;
    final onboardingComplete =
        _box.get('onboarding_complete', defaultValue: false) as bool? ?? false;
    // Uygulama yalnızca Türkçe dilini kullanır.
    final _storedLanguage =
        _box.get('language', defaultValue: 'Türkçe') as String? ?? 'Türkçe';
    final language = 'Türkçe';
    if (_storedLanguage != 'Türkçe') {
      // Persist without blocking build()
      _box.put('language', 'Türkçe');
    }

    return SettingsState(
      isDarkMode: isDarkMode,
      currency: currency,
      notificationsEnabled: notificationsEnabled,
      onboardingComplete: onboardingComplete,
      language: language,
    );
  }

  Future<void> toggleTheme(bool isDark) async {
    await _box.put('isDarkMode', isDark);
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> setCurrency(String currencyCode) async {
    // Uygulama yalnızca Türk Lirası (TRY) kullanır.
    const forced = 'TRY';
    await _box.put('currency', forced);
    state = state.copyWith(currency: forced);
  }

  Future<void> setLanguage(String language) async {
    // Uygulama yalnızca Türkçe dilini kullanır.
    const forced = 'Türkçe';
    await _box.put('language', forced);
    state = state.copyWith(language: forced);
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    await _box.put('notificationsEnabled', isEnabled);
    state = state.copyWith(notificationsEnabled: isEnabled);

    if (!isEnabled) {
      await NotificationService().cancelAllNotifications();
    } else {
      final subscriptions = ref
          .read(subscriptionRepositoryProvider)
          .getSubscriptions();
      for (final sub in subscriptions) {
        final notifId = sub.id.hashCode;
        await NotificationService().cancelNotification(notifId);
        await NotificationService().scheduleBillingNotification(
          id: notifId,
          title: "${AppStrings.upcomingCharge}${sub.name}",
          body: "${AppStrings.youWillBeCharged}${state.currencySymbol}${sub.price.toStringAsFixed(2)}. "
              "Ödeme tarihi: ${AppStrings.formatDate(sub.nextBillingDate)}. ${AppStrings.chargeDisclaimer}",
          scheduledDate: sub.nextBillingDate,
        );
      }
    }
  }

  Future<void> completeOnboarding() async {
    await _box.put('onboarding_complete', true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> clearAllData() async {
    await _box.clear();
    state = const SettingsState();
  }
}
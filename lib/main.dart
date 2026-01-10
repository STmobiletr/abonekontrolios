import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/ad_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/services/notification_service.dart';
import 'core/utils/stable_notif_id.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';
import 'features/subscriptions/models/subscription_model.dart';
import 'features/settings/providers/settings_provider.dart';

/// App initialization
void main() async {
  runZonedGuarded(
    () async {
      // Ensure Flutter bindings are ready
      WidgetsFlutterBinding.ensureInitialized();

      // Ads initialize
      try {
        await AdService.initialize();
      } catch (e) {
        debugPrint("Failed to initialize Mobile Ads: $e");
      }

      // Catch Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint("Flutter Error: ${details.exception}");
      };

      // Initialize Hive
      try {
        await Hive.initFlutter();
        // Register Adapter
        Hive.registerAdapter(SubscriptionModelAdapter());

        // Open Boxes
        try {
          await Hive.openBox<SubscriptionModel>('subscriptions');
          await Hive.openBox('settings');
        } catch (e) {
          debugPrint("Error opening Hive box: $e");
          // Delete corrupted box and restart
          await Hive.deleteBoxFromDisk('subscriptions');
          await Hive.openBox<SubscriptionModel>('subscriptions');
        }
      } catch (e) {
        debugPrint("Failed to initialize Hive: $e");
      }

      // Initialize Notifications
      try {
        await await NotificationService().init();
      } catch (e) {
        debugPrint("Failed to initialize Notifications: $e");
      }


      // Bildirimler açıksa: eski planları temizle ve mevcut aboneliklere göre yeniden planla
      try {
        final settingsBox = Hive.box('settings');
        final bool notificationsEnabled =
            settingsBox.get('notificationsEnabled', defaultValue: true) as bool? ?? true;

        if (notificationsEnabled) {
          await NotificationService().cancelAllNotifications();

          final subsBox = Hive.box<SubscriptionModel>('subscriptions');
          for (final sub in subsBox.values) {
            final notifId = stableNotifId(sub.id);
            await NotificationService().scheduleBillingNotification(
              id: notifId,
              title: "${AppStrings.upcomingCharge}${sub.name}",
              body:
                  "${AppStrings.youWillBeCharged}₺${sub.price.toStringAsFixed(2)}. "
                  "Ödeme tarihi: ${AppStrings.formatDate(sub.nextBillingDate)}. ${AppStrings.chargeDisclaimer}",
              scheduledDate: sub.nextBillingDate,
            );
          }
        }
      } catch (e) {
        debugPrint("Failed to reschedule notifications: $e");
      }

      // Run App
      runApp(const ProviderScope(child: AboneKontrolApp()));
    },
    (error, stack) {
      debugPrint("Caught Unhandled Error: $error");
      debugPrint(stack.toString());
    },
  );
}

/// Root Widget
class AboneKontrolApp extends ConsumerWidget {
  const AboneKontrolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsBox = Hive.box('settings');
    final bool hasSeenOnboarding =
        settingsBox.get('onboarding_complete', defaultValue: false) as bool? ??
        false;

    // Watch settings for theme changes
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'SubZero Subscription Manager',
      theme: ThemeData(
        brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: settings.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: settings.isDarkMode
            ? const ColorScheme.dark(
                primary: AppColors.primaryAccent,
                error: AppColors.dangerAccent,
                surface: AppColors.darkSurface,
                onSurface: AppColors.darkText,
              )
            : const ColorScheme.light(
                primary: AppColors.lightPrimary,
                error: AppColors.lightDanger,
                surface: AppColors.lightSurface,
                onSurface: AppColors.lightText,
              ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: settings.isDarkMode ? Colors.white : Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: settings.isDarkMode ? Colors.white : Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            color: settings.isDarkMode
                ? AppColors.darkText
                : AppColors.lightText,
          ),
          bodyMedium: TextStyle(
            color: settings.isDarkMode
                ? AppColors.darkText
                : AppColors.lightText,
          ),
        ),
      ),
      home: hasSeenOnboarding
          ? const DashboardScreen()
          : const OnboardingScreen(),
    );
  }
}

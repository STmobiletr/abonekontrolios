import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob helper for banner ads (iOS + Android).
/// - Provides `initialize()` for places that want to await ads init.
/// - Provides `createBannerAd()` for widgets that manage their own banner instance.
/// - Also exposes `banner` as a shared banner ValueNotifier (if you prefer a single global banner).
class AdService {
  AdService._();

  static bool _initialized = false;

  /// Optional shared banner (some widgets may listen to this).
  static final ValueNotifier<BannerAd?> banner = ValueNotifier<BannerAd?>(null);

  static Timer? _retryTimer;
  static int _retrySeconds = 30;

  // Production ad unit ids
  static const String _androidBannerProd = 'ca-app-pub-1508482824588822/5603669055';
  static const String _iosBannerProd = 'ca-app-pub-1508482824588822/1698554380';

  // Google test banner ids
  static const String _androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId {
    // In debug mode use test ads (prevents accidental invalid traffic).
    if (kDebugMode) {
      if (Platform.isAndroid) return _androidBannerTest;
      if (Platform.isIOS) return _iosBannerTest;
    }

    if (Platform.isAndroid) return _androidBannerProd;
    if (Platform.isIOS) return _iosBannerProd;

    throw UnsupportedError('Unsupported platform');
  }

  /// Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await MobileAds.instance.initialize();
    } catch (e) {
      debugPrint('Failed to initialize Mobile Ads: $e');
    }

    // If some part of the app expects a shared banner, start it here.
    _loadSharedBanner();
  }

  /// Creates a BannerAd instance. Caller decides when to load/dispose.
  static BannerAd createBannerAd({
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
    AdSize size = AdSize.banner,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Ad loaded: ${ad.adUnitId}');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad failed to load: ${ad.adUnitId}, $error');
          onAdFailedToLoad?.call(ad, error);
          // Do NOT dispose here; caller may dispose. (Avoid double-dispose.)
        },
      ),
    );
  }

  /// Shared banner loader with exponential backoff.
  /// IMPORTANT: Avoid referencing the banner variable inside its own initializer
  /// (that was the compile error in your build log).
  static void _loadSharedBanner() {
    banner.value?.dispose();
    banner.value = null;

    final BannerAd bannerAd = createBannerAd(
      onAdLoaded: (ad) {
        _retryTimer?.cancel();
        _retrySeconds = 30;
        banner.value = ad as BannerAd;
      },
      onAdFailedToLoad: (ad, _) {
        ad.dispose();
        banner.value = null;
        _scheduleRetry();
      },
    );

    // Use the local `bannerAd` just for calling load()
    bannerAd.load();
  }

  static void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _retrySeconds), _loadSharedBanner);
    _retrySeconds = (_retrySeconds * 2).clamp(30, 600);
  }

  static void disposeShared() {
    _retryTimer?.cancel();
    _retryTimer = null;
    banner.value?.dispose();
    banner.value = null;
    _retrySeconds = 30;
    _initialized = false;
  }
}

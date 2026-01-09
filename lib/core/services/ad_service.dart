import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static bool _initialized = false;

  static final ValueNotifier<BannerAd?> banner = ValueNotifier<BannerAd?>(null);

  static Timer? _retryTimer;
  static int _retrySeconds = 30;

  static const String _androidBannerProd = 'ca-app-pub-1508482824588822/5603669055';
  static const String _iosBannerProd = 'ca-app-pub-1508482824588822/1698554380';

  static String get bannerAdUnitId {
    final bool forceTest = const bool.fromEnvironment('FORCE_TEST_ADS', defaultValue: false);
    if (forceTest && kDebugMode) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }

    if (Platform.isAndroid) return _androidBannerProd;
    if (Platform.isIOS) return _iosBannerProd;

    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await MobileAds.instance.initialize();
    } catch (_) {}

    _loadSharedBanner();
  }

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
        onAdLoaded: (ad) => onAdLoaded?.call(ad),
        onAdFailedToLoad: (ad, error) {
          onAdFailedToLoad?.call(ad, error);
          ad.dispose();
        },
      ),
    );
  }

  static void _loadSharedBanner() {
    // Eski banner varsa temizle
    banner.value?.dispose();
    banner.value = null;

    final BannerAd bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _retryTimer?.cancel();
          _retrySeconds = 30;
          banner.value = ad as BannerAd;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          banner.value = null;
          _scheduleRetry();
        },
      ),
    );

    bannerAd.load();
  }

static void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _retrySeconds), _loadSharedBanner);
    _retrySeconds = (_retrySeconds * 2).clamp(30, 600);
  }

  static void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
    banner.value?.dispose();
    banner.value = null;
    _initialized = false;
    _retrySeconds = 30;
  }
}

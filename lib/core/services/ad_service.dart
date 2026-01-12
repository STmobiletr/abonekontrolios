import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static bool _initialized = false;

  // İstersen başka yerlerde dinlemek için tutuyoruz (mevcut yapınla uyumlu)
  static final ValueNotifier<BannerAd?> banner = ValueNotifier<BannerAd?>(null);

  static Timer? _retryTimer;
  static int _retrySeconds = 30;

  // ✅ Senin PROD banner id’lerin
  static const String _androidBannerProd = 'ca-app-pub-1508482824588822/5603669055';
  static const String _iosBannerProd = 'ca-app-pub-1508482824588822/1698554380';

  // ✅ Google demo TEST banner id’leri (TestFlight’ta da çalışır)
  static const String _androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';

  static bool get _forceTestAds =>
      const bool.fromEnvironment('FORCE_TEST_ADS', defaultValue: true);

  static String get bannerAdUnitId {
    if (_forceTestAds) {
      if (Platform.isAndroid) return _androidBannerTest;
      if (Platform.isIOS) return _iosBannerTest;
    }

    if (Platform.isAndroid) return _androidBannerProd;
    if (Platform.isIOS) return _iosBannerProd;

    throw UnsupportedError('Unsupported platform');
  }

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await MobileAds.instance.initialize();
    debugPrint('AdService: FORCE_TEST_ADS=$_forceTestAds unitId=$bannerAdUnitId');
    _loadSharedBanner();
  }

  static BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad,
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

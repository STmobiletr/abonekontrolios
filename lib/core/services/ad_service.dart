import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();

  static bool _initialized = false;

  // ✅ PROD banner id’leri
  static const String _androidBannerProd = 'ca-app-pub-1508482824588822/5603669055';
  static const String _iosBannerProd = 'ca-app-pub-1508482824588822/1698554380';

  // ✅ Google demo TEST banner id’leri (TestFlight’ta da çalışır)
  static const String _androidBannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';

  /// Codemagic / build komutundan açılır:
  /// flutter build ipa ... --dart-define=FORCE_TEST_ADS=true
  static bool get _forceTestAds =>
      const bool.fromEnvironment('FORCE_TEST_ADS', defaultValue: false);

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

    if (kDebugMode) {
      debugPrint('AdService init: FORCE_TEST_ADS=$_forceTestAds, unitId=$bannerAdUnitId');
    }
    await MobileAds.instance.initialize();
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
}

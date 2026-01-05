import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111'; // Android TEST Banner ID
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716'; // iOS Test Banner ID
      }
    }
    // Replace with production IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-1508482824588822/5603669055';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1508482824588822/1698554380';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static BannerAd createBannerAd({
    Function(Ad)? onAdLoaded,
    Function(Ad, LoadAdError)? onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Ad loaded: ${ad.adUnitId}');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: ${ad.adUnitId}, $error');
          onAdFailedToLoad?.call(ad, error);
          ad.dispose();
        },
      ),
    );
  }
}

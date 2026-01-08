import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reklam yönetimi (Banner).
///
/// Amaçlar:
/// 1) Uygulama içinde "Ad error" gibi debug yazıları göstermemek.
/// 2) Reklam isteğini aşırı sık göndermemek ("too many recently failed requests" hatasını engeller).
/// 3) Banner'ı paylaşarak sayfalar arası gidip-gelmede tekrar tekrar yüklememek.
class AdService {
  /// AdMob App ID (Info.plist içinde GADApplicationIdentifier ile aynı olmalı)
  /// iOS: ca-app-pub-xxxx~yyyy
  static const String _admobAppId = 'ca-app-pub-1508482824588822~4999505148';

  /// Banner Ad Unit ID
  /// iOS: ca-app-pub-xxxx/yyyy
  static const String _bannerUnitId = 'ca-app-pub-1508482824588822/1698554380';

  /// Eğer ileride reklamları kapatmak istersen bunu false yap.
  static bool enabled = true;

  /// Tek banner'ı paylaşalım.
  static BannerAd? _sharedBanner;
  static bool _isLoading = false;
  static DateTime? _lastAttempt;

  /// Fail olunca hemen tekrar yüklemeye çalışma.
  static const Duration _cooldown = Duration(seconds: 30);

  /// UI tarafı banner gelince yeniden çizsin diye.
  static final ValueNotifier<BannerAd?> bannerNotifier = ValueNotifier<BannerAd?>(null);

  /// SDK init (main.dart içinde await edilmesi daha iyi).
  static Future<void> ensureInitialized() async {
    if (!enabled) return;
    // MobileAds.instance.initialize() tekrar çağrılırsa sorun yok.
    await MobileAds.instance.initialize();
  }

  /// Banner'ı yükle (varsa tekrar yüklemez).
  static void ensureBannerLoaded({AdSize size = AdSize.banner}) {
    if (!enabled) {
      _disposeBanner();
      return;
    }

    if (bannerNotifier.value != null) {
      // Zaten hazır.
      return;
    }

    if (_isLoading) return;

    final now = DateTime.now();
    if (_lastAttempt != null && now.difference(_lastAttempt!) < _cooldown) {
      return;
    }
    _lastAttempt = now;
    _isLoading = true;

    // Eski varsa kapat.
    _sharedBanner?.dispose();
    _sharedBanner = null;

    final banner = BannerAd(
      adUnitId: _bannerUnitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          _sharedBanner = ad as BannerAd;
          bannerNotifier.value = _sharedBanner;
        },
        onAdFailedToLoad: (ad, error) {
          _isLoading = false;
          ad.dispose();
          // Debug yazısı göstermek YOK. Sadece sessizce banner'ı kapat.
          bannerNotifier.value = null;
          // Bir sonraki deneme cooldown sonrası olur.
        },
      ),
    );

    banner.load();
  }

  static void _disposeBanner() {
    try {
      _sharedBanner?.dispose();
    } catch (_) {}
    _sharedBanner = null;
    bannerNotifier.value = null;
    _isLoading = false;
  }

  /// İstersen ileride bazı ekranlarda reklam istemezsen çağır.
  static void disableAds() {
    enabled = false;
    _disposeBanner();
  }

  /// Bilgi amaçlı: App ID burada saklı, ama iOS tarafında asıl yer Info.plist.
  static String get admobAppId => _admobAppId;
}

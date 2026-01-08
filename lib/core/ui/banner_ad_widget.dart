import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

/// Optional: show AdMob load errors on screen in release builds (TestFlight),
/// without switching to test ads.
/// Enable in Codemagic build args:
///   --dart-define=SHOW_AD_DEBUG=true
const bool _showAdDebug = bool.fromEnvironment('SHOW_AD_DEBUG', defaultValue: false);

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  LoadAdError? _lastError;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _lastError = null;

    _bannerAd = AdService.createBannerAd(
      onAdLoaded: (ad) {
        if (!mounted) return;
        setState(() {
          _isLoaded = true;
          _lastError = null;
        });
      },
      onAdFailedToLoad: (ad, error) {
        // NOTE: TestFlight is release, so console logs aren't visible easily.
        // We keep a copy of the error so you can see the real reason (NO_FILL, NETWORK, etc.)
        // on screen when SHOW_AD_DEBUG=true.
        if (kDebugMode) {
          debugPrint('Banner failed: ${error.code} - ${error.message}');
        }
        ad.dispose();
        if (!mounted) return;
        setState(() {
          _isLoaded = false;
          _bannerAd = null;
          _lastError = error;
        });

        // Simple retry: avoid a permanently blank UI if the first request returns no-fill.
        Future.delayed(const Duration(seconds: 20), () {
          if (mounted && _bannerAd == null) {
            _loadAd();
          }
        });
      },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reserve banner height so layout doesn't jump.
    const double fallbackHeight = 50;

    if (_bannerAd == null || !_isLoaded) {
      if (_showAdDebug && _lastError != null) {
        return Container(
          height: fallbackHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Ad error: ${_lastError!.code} - ${_lastError!.message}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        );
      }
      return const SizedBox(height: fallbackHeight);
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

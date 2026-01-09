import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  Timer? _retry;
  int _retrySeconds = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _retry?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    _loaded = false;

    final ad = AdService.createBannerAd(
      onAdLoaded: (_) {
        if (!mounted) return;
        setState(() {
          _loaded = true;
          _retrySeconds = 30;
        });
      },
      onAdFailedToLoad: (_, __) {
        if (!mounted) return;
        setState(() => _loaded = false);
        _scheduleRetry();
      },
    );

    _bannerAd = ad;
    ad.load();
  }

  void _scheduleRetry() {
    _retry?.cancel();
    _retry = Timer(Duration(seconds: _retrySeconds), _load);
    _retrySeconds = (_retrySeconds * 2).clamp(30, 600);
  }

  @override
  void dispose() {
    _retry?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _bannerAd;
    if (ad == null || !_loaded) return const SizedBox.shrink();

    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

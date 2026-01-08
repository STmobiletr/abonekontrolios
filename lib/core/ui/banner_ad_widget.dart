import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// Banner reklam alanı.
///
/// Not: Burada asla debug/error yazısı göstermiyoruz. Reklam gelmezse alan gizlenir.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    // Banner'ı merkezi servis üzerinden hazırla.
    AdService.ensureBannerLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BannerAd?>(
      valueListenable: AdService.banner,
      builder: (context, ad, _) {
        if (ad == null) return const SizedBox.shrink();
        return SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        );
      },
    );
  }
}

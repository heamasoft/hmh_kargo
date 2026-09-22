import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/ads_api.dart';
import '../services/api_client.dart';
import '../theme/app_colors.dart';
import '../utils/launcher.dart';
import 'product_image.dart';

/// The home page's ad slider: the images admins publish (Me → Ads), sliding by
/// themselves every few seconds. The last copy shows at once on launch, then
/// the fresh list replaces it. Hidden entirely while there are no ads.
class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  State<AdsCarousel> createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  late final AdsApi _api = AdsApi(context.read<ApiClient>());

  /// Each slide is 94% of the slider's width; a sliver of the next peeks in.
  static const _fraction = 0.94;

  /// The slot has the images' own shape, so an image fills it with nothing
  /// cut on any screen. Upload ads at 1600 × 800 px (any 2:1 size works).
  static const _aspect = 2.0;

  /// On tablets the slider stops widening here, so it doesn't fill the screen.
  static const _maxWidth = 760.0;

  final _page = PageController(viewportFraction: _fraction);
  List<Ad> _ads = const [];
  int _index = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _api.cached();
    if (mounted && saved != null && _ads.isEmpty) _show(saved);
    try {
      final fresh = await _api.list();
      if (mounted) _show(fresh);
    } on ApiException {
      // keep whatever is showing
    }
  }

  void _show(List<Ad> ads) {
    setState(() {
      _ads = ads;
      if (_index >= ads.length) _index = 0;
    });
    _auto?.cancel();
    if (ads.length > 1) {
      _auto = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_page.hasClients) return;
        _page.animateToPage(
          (_index + 1) % _ads.length,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ads.isEmpty) return const SizedBox.shrink();
    final boxWidth = MediaQuery.sizeOf(context).width.clamp(0.0, _maxWidth);
    // Exactly the images' 2:1 shape — the earlier taller slot (1.7:1) made
    // the cover-fit trim the sides of every banner.
    // (Each slide has 5 px of spacing on either side — the image is 10 px narrower.)
    final height = (boxWidth * _fraction - 10) / _aspect;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Center(
        child: SizedBox(
          width: boxWidth,
          child: Column(
            children: [
              SizedBox(
                height: height,
                child: PageView.builder(
                  controller: _page,
                  itemCount: _ads.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final ad = _ads[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: GestureDetector(
                        onTap: ad.linkUrl == null ? null : () => openUrl(ad.linkUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ProductImage(
                            url: ad.imageUrl,
                            gradient: const [AppColors.cloud, AppColors.line],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_ads.length > 1) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _ads.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _index ? AppColors.pomegranate : AppColors.line,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

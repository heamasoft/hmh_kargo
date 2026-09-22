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
  final _page = PageController(viewportFraction: 0.92);
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
        _page.animateToPage((_index + 1) % _ads.length,
            duration: const Duration(milliseconds: 450), curve: Curves.easeOutCubic);
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
    final width = MediaQuery.sizeOf(context).width;
    // A 2:1 banner, capped so it doesn't swallow a tablet screen.
    final height = (width * 0.92 / 2).clamp(120.0, 260.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
    );
  }
}

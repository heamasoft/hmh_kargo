import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Network product image with a gradient placeholder that also serves as the
/// fallback when the image can't load (offline / demo seeds).
///
/// For captured store images we send a same-origin Referer + a browser
/// User-Agent, which gets past most CDN hotlink protection (e.g. Shein).
class ProductImage extends StatelessWidget {
  final String url;
  final List<Color> gradient;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, required this.gradient, this.fit = BoxFit.cover});

  /// Headers that make hotlink-protected CDNs serve the image (mobile only —
  /// browsers manage these themselves on web).
  Map<String, String>? _headers() {
    if (kIsWeb) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return {
      'Referer': '${uri.scheme}://${uri.host}/',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 15) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Mobile Safari/537.36',
    };
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradient),
      ),
      child: const SizedBox.expand(),
    );

    if (url.trim().isEmpty) return placeholder;

    if (kIsWeb) {
      return Image.network(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) => progress == null ? child : placeholder,
        errorBuilder: (context, error, stack) => placeholder,
      );
    }

    // Kept on the phone after the first download, so photos show instantly
    // on every later visit and launch instead of downloading again — and
    // decoded at the size they're shown, not the CDN's full resolution.
    return LayoutBuilder(
      builder: (context, box) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final w = box.maxWidth.isFinite ? (box.maxWidth * dpr).round() : null;
        return CachedNetworkImage(
          imageUrl: url,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          httpHeaders: _headers(),
          memCacheWidth: w,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (context, _) => placeholder,
          errorWidget: (context, _, __) => placeholder,
        );
      },
    );
  }
}

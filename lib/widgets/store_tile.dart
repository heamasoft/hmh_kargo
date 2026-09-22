import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A store: its logo (or monogram glyph) with the name beneath — no card around
/// it, the icon itself is the tile. Tapping opens the store in the in-app WebView.
class StoreTile extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const StoreTile({super.key, required this.store, required this.onTap});

  /// The icon's side — shared with the "More" tile so the grid lines up.
  static const iconSize = 64.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StoreIcon(store: store),
            const SizedBox(height: 9),
            Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// The store's logo on a white rounded square — any logo shape fits — while it
/// loads or if it can't, the coloured monogram glyph.
class _StoreIcon extends StatelessWidget {
  const _StoreIcon({required this.store});
  final Store store;

  static const _size = StoreTile.iconSize;
  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    final tint = Color.lerp(store.glyphColor, Colors.white, 0.22)!;
    final glyph = Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, store.glyphColor],
        ),
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: store.glyphColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(store.glyph, style: AppFonts.display(fontSize: 22, color: Colors.white)),
    );

    final icon = store.iconUrl;
    if (icon == null) return glyph;

    return CachedNetworkImage(
      imageUrl: icon,
      placeholder: (_, __) => glyph,
      errorWidget: (_, __, ___) => glyph,
      imageBuilder: (context, image) => Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.midnight.withValues(alpha: 0.10),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image(image: image, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
        ),
      ),
    );
  }
}

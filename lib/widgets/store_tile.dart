import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A store: its logo on a rounded white tile, the name, and where it ships
/// from. No card around it — the logo is the tile. Tapping opens the store.
class StoreTile extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const StoreTile({super.key, required this.store, required this.onTap});

  /// The icon's side — shared with the "More" tile so the grid lines up.
  static const iconSize = 66.0;
  static const iconRadius = 22.0;

  /// The white rounded tile every logo sits on.
  static BoxDecoration iconDecoration({Color color = Colors.white}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(iconRadius),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnight.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
            const SizedBox(height: 1),
            Text(
              store.region == 'turkiye' ? l.turkiye : l.international,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 10.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The logo, fastest source first: bundled in the app (instant) → loaded from
/// the web (a plain white tile while it loads — no letter flashing first) →
/// the coloured monogram glyph only if there is no logo at all.
class _StoreIcon extends StatelessWidget {
  const _StoreIcon({required this.store});
  final Store store;

  static const _size = StoreTile.iconSize;

  Widget _onTile(Widget image) => Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(10),
        decoration: StoreTile.iconDecoration(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final bundled = store.bundledIcon;
    if (bundled != null) {
      return _onTile(Image.asset(bundled, fit: BoxFit.contain, filterQuality: FilterQuality.medium));
    }

    final url = store.iconUrl;
    if (url == null) return _glyph();
    return CachedNetworkImage(
      imageUrl: url,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Container(width: _size, height: _size, decoration: StoreTile.iconDecoration()),
      errorWidget: (_, __, ___) => _glyph(),
      imageBuilder: (context, image) =>
          _onTile(Image(image: image, fit: BoxFit.contain, filterQuality: FilterQuality.medium)),
    );
  }

  Widget _glyph() {
    final tint = Color.lerp(store.glyphColor, Colors.white, 0.22)!;
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, store.glyphColor],
        ),
        borderRadius: BorderRadius.circular(StoreTile.iconRadius),
      ),
      alignment: Alignment.center,
      child: Text(store.glyph, style: AppFonts.display(fontSize: 22, color: Colors.white)),
    );
  }
}

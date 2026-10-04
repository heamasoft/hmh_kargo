import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A store: its mark on a rounded tile, the name, and where it ships
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

/// The store's mark: its initials on its own colour.
///
/// Deliberately not the shop's logo. A logo is the shop's trademark, and this
/// app buys from these shops rather than acting for them, so it names them
/// without wearing their badge — which is also what App Review asks for under
/// guideline 4.1.
class _StoreIcon extends StatelessWidget {
  const _StoreIcon({required this.store});
  final Store store;

  static const _size = StoreTile.iconSize;

  @override
  Widget build(BuildContext context) => _glyph();

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

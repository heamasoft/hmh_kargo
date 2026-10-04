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

  /// The app's own colours for store marks.
  ///
  /// The shop's own colour is deliberately not among them: a tile in a shop's
  /// exact colour, carrying its initials, is still wearing that shop's
  /// identity. These are this app's palette, and they say nothing about anyone
  /// else.
  static const _marks = <List<Color>>[
    [Color(0xFF3B3270), Color(0xFF211B3E)],
    [Color(0xFFE05A4F), Color(0xFFB5362E)],
    [Color(0xFFF2A33C), Color(0xFFD98521)],
    [Color(0xFF2E9E6B), Color(0xFF1F7A51)],
    [Color(0xFF4A6FD4), Color(0xFF32519F)],
    [Color(0xFF8C6BD5), Color(0xFF6949AE)],
    [Color(0xFF3F7C8C), Color(0xFF2C5A66)],
    [Color(0xFFC2577B), Color(0xFF9B3F5F)],
  ];

  /// Worked out from the store's key, so a shop keeps the same mark on every
  /// screen, between launches, and however the list is ordered.
  List<Color> get _colors {
    var h = 0;
    for (final unit in store.id.codeUnits) {
      h = (h * 31 + unit) & 0x7fffffff;
    }
    return _marks[h % _marks.length];
  }

  /// What the shop sells, as a symbol: it tells two shops apart at a glance
  /// where their initials would not, and it is ours to draw.
  IconData get _symbol {
    switch (store.categoryKey) {
      case 'catTech':
      case 'catGadgets':
        return Icons.devices_other_rounded;
      case 'catHome':
      case 'catKitchen':
        return Icons.chair_rounded;
      case 'catBeauty':
        return Icons.spa_rounded;
      case 'catKids':
      case 'catToys':
        return Icons.toys_rounded;
      case 'catEverything':
      case 'catAll':
        return Icons.storefront_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }

  /// The shop's initials — its name shortened, which is nobody's mark.
  String get _initials {
    final glyph = store.glyph.trim();
    if (glyph.isNotEmpty) return glyph.toUpperCase();
    final name = store.name.trim();
    if (name.isEmpty) return '•';
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  Widget _glyph() {
    return Container(
      width: _size,
      height: _size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _colors,
        ),
        borderRadius: BorderRadius.circular(StoreTile.iconRadius),
      ),
      child: Stack(
        children: [
          // The symbol sits large and faint behind the initials, as the tile's
          // texture rather than a second thing to read.
          PositionedDirectional(
            bottom: -8,
            end: -6,
            child: Icon(_symbol, size: 42, color: Colors.white.withValues(alpha: 0.18)),
          ),
          Center(
            child: Text(_initials, style: AppFonts.display(fontSize: 21, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

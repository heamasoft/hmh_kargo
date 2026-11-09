import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/store_link.dart';

/// A website the shopper can open, drawn like a browser's saved link: a plain
/// white tile with a neutral symbol, and the site's web address in plain text.
///
/// Deliberately nothing of the shop's own — no logo, no brand colour, no
/// initials, no styled name (App Review, guideline 4.1(b)). The address is how
/// any browser names a site; the shop shows itself only on its own website,
/// once the shopper opens it.
class StoreTile extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  const StoreTile({super.key, required this.store, required this.onTap});

  /// The icon's side — shared with the "More" tile so the grid lines up.
  static const iconSize = 60.0;
  static const iconRadius = 18.0;

  /// The white rounded tile every symbol sits on.
  static BoxDecoration iconDecoration({Color color = Colors.white}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(iconRadius),
        border: Border.all(color: AppColors.line),
      );

  /// "www.trendyol.com" → "trendyol.com": the address, as a browser shows it.
  static String address(Store s) {
    final host = Uri.tryParse(s.url)?.host ?? '';
    return host.isEmpty ? s.name.toLowerCase() : registrableDomain(host);
  }

  /// What the site sells, as a neutral symbol of our own.
  static IconData symbolFor(Store s) {
    switch (s.categoryKey) {
      case 'catTech':
      case 'catGadgets':
        return Icons.laptop_rounded;
      case 'catHome':
      case 'catKitchen':
        return Icons.weekend_outlined;
      case 'catBeauty':
        return Icons.spa_outlined;
      case 'catKids':
      case 'catToys':
        return Icons.toys_outlined;
      case 'catEverything':
      case 'catAll':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.checkroom_rounded;
    }
  }

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
            Container(
              width: iconSize,
              height: iconSize,
              decoration: iconDecoration(),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(symbolFor(store), size: 26, color: AppColors.ink),
                  // A small globe: this opens a website, as in a browser.
                  const PositionedDirectional(
                    end: 6,
                    bottom: 6,
                    child: Icon(Icons.language_rounded, size: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address(store),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w600),
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

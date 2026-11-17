import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/store.dart';
import '../theme/app_colors.dart';
import '../utils/store_link.dart';

/// A website the shopper can open: a photo of what it sells, and the site's
/// web address in plain text, the way a browser names it.
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

  /// Sites with a photo picked for them in assets/stores/.
  static const _photoKeys = {
    'shein', 'trendyol', 'zara', 'mango', 'hm', 'bershka',
    'stradivarius', 'polo', 'karaca', 'hepsiburada',
  };

  /// A photo of what the site sells — clothes on a rail, cookware, a
  /// keyboard. Free stock photos (Unsplash License), each checked to show no
  /// logo, brand name or readable label: they say what the shop sells, never
  /// whose shop it is. A site without its own photo takes its category's.
  static String photoFor(Store s) {
    final key = s.id.toLowerCase();
    if (_photoKeys.contains(key)) return 'assets/stores/$key.jpg';
    switch (s.categoryKey) {
      case 'catTech':
      case 'catGadgets':
        return 'assets/stores/cat_tech.jpg';
      case 'catHome':
      case 'catKitchen':
        return 'assets/stores/cat_home.jpg';
      case 'catBeauty':
        return 'assets/stores/cat_beauty.jpg';
      case 'catKids':
      case 'catToys':
        return 'assets/stores/cat_kids.jpg';
      case 'catEverything':
      case 'catAll':
        return 'assets/stores/cat_everything.jpg';
      default:
        return 'assets/stores/cat_fashion.jpg';
    }
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
              clipBehavior: Clip.antiAlias,
              child: store.logoUrl != null
                  // A mark set for this store in the dashboard (stores.logo_url)
                  // — one we made ourselves for the tile. Falls back to the
                  // neutral symbol if it can't load.
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: CachedNetworkImage(
                        imageUrl: store.logoUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) =>
                            Icon(symbolFor(store), size: 26, color: AppColors.ink),
                      ),
                    )
                  // Otherwise a photo of the kind of thing the site sells.
                  : Image.asset(
                      photoFor(store),
                      fit: BoxFit.cover,
                      width: iconSize,
                      height: iconSize,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(symbolFor(store), size: 26, color: AppColors.ink),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

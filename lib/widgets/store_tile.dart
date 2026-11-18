import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/store_link.dart';

/// A website the shopper can open: a photo of what it sells, with the shop's
/// name written under it (and, on the Shop page, what it sells).
///
/// No logo of the shop's own and no look-alike of one (App Review, guideline
/// 4.1(b)): the photo shows the kind of goods, the name is plain text. A logo
/// set for the store in the dashboard (stores.logo_url) replaces the photo.
class StoreTile extends StatelessWidget {
  final Store store;
  final VoidCallback onTap;

  /// Shows what the site sells under its name (the Shop page).
  final bool showCategory;

  const StoreTile({super.key, required this.store, required this.onTap, this.showCategory = false});

  /// The picture's side — shared with the "More" tile so the grid lines up.
  static const iconSize = 68.0;
  static const iconRadius = 22.0;

  /// The white-edged rounded square every picture sits in.
  static BoxDecoration iconDecoration({Color color = Colors.white}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(iconRadius),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x1F211B3E), blurRadius: 16, offset: Offset(0, 6)),
        ],
      );

  /// "www.trendyol.com" → "trendyol.com": the address, as a browser shows it.
  static String address(Store s) {
    final host = Uri.tryParse(s.url)?.host ?? '';
    return host.isEmpty ? s.name.toLowerCase() : registrableDomain(host);
  }

  /// What the site sells, in the shopper's language.
  static String categoryLabel(AppLocalizations l, Store s) {
    switch (s.categoryKey) {
      case 'catTech':
        return l.catTech;
      case 'catGadgets':
        return l.catGadgets;
      case 'catEverything':
      case 'catAll':
        return l.catEverything;
      case 'catApparel':
        return l.catApparel;
      default:
        return l.catFashion;
    }
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

  /// The store's picture: its dashboard logo when it has one, else the photo.
  static Widget picture(Store store, {double? width, double? height}) {
    if (store.logoUrl != null) {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: CachedNetworkImage(
          imageUrl: store.logoUrl!,
          fit: BoxFit.contain,
          errorWidget: (_, __, ___) => Icon(symbolFor(store), size: 26, color: AppColors.ink),
        ),
      );
    }
    return Image.asset(
      photoFor(store),
      fit: BoxFit.cover,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(symbolFor(store), size: 26, color: AppColors.ink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: iconDecoration(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(iconRadius - 3),
              child: picture(store, width: iconSize, height: iconSize),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            store.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          if (showCategory)
            Text(
              categoryLabel(AppLocalizations.of(context), store),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppFonts.body(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

/// Shrinks a little while pressed, then springs back — the touch feel of
/// every tile on Home and Shop.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import 'fav_button.dart';
import 'product_image.dart';

/// Grid/scroll product tile with image, store tag, heart, name and IQD price.
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final double? width;
  final double imageHeight;
  final bool showFav;
  final bool showPrice;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.width,
    this.imageHeight = 170,
    this.showFav = true,
    this.showPrice = true,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg - 2),
          child: SizedBox(
            height: imageHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(url: product.imageUrl, gradient: product.gradient),
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.midnight.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.store.toUpperCase(),
                      style: AppFonts.body(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (showFav)
                  Positioned(top: 8, right: 8, child: FavButton(product: product)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
        ),
        if (showPrice) ...[
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_price(product.priceIqd)} ',
                  style: AppFonts.display(fontSize: 14, letterSpacing: -0.3),
                ),
                TextSpan(
                  text: l.iqd,
                  style: AppFonts.body(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: width != null ? SizedBox(width: width, child: card) : card,
    );
  }

  static String _price(int v) {
    // lightweight thousands formatter to avoid a dependency here
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

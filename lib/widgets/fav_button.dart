import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/favorite_item.dart';
import '../models/product.dart';
import '../providers/favorites_provider.dart';
import '../theme/app_colors.dart';
import 'heama_toast.dart';

/// The round heart toggle shown on product images.
class FavButton extends StatelessWidget {
  final Product product;
  final double size;

  const FavButton({super.key, required this.product, this.size = 30});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final on = favs.isFavorite(product.id);
    return GestureDetector(
      onTap: () {
        final saved = context
            .read<FavoritesProvider>()
            .toggle(FavoriteItem.fromProduct(product));
        if (saved) {
          showHeamaToast(context, AppLocalizations.of(context).savedToFav);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: on ? Colors.white : Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          on ? Icons.favorite : Icons.favorite_border,
          size: size * 0.53,
          color: on ? AppColors.pomegranate : AppColors.ink,
        ),
      ),
    );
  }
}

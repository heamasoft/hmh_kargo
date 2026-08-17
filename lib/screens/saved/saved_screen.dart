import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../models/store.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/product_card.dart';
import '../webstore/open_store.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final favs = context.watch<FavoritesProvider>();
    final items = favs.items.map((f) => f.toProduct()).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 18, 4),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 32),
                  const SizedBox(width: 10),
                  Text(l.savedItems, style: AppFonts.display(fontSize: 21)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
              child: Text(l.savedSub, style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            ),
            Expanded(
              child: favs.count == 0
                  ? _empty(l)
                  : GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.56,
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                      children: items
                          .map((p) => ProductCard(
                                product: p,
                                onTap: () => _open(context, p),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens a saved item in its store's WebView (or product detail as fallback).
  void _open(BuildContext context, Product p) {
    final stores = context.read<CatalogProvider>().stores;
    Store? store;
    for (final s in stores) {
      if (p.storeId != null && s.storeId == p.storeId) {
        store = s;
        break;
      }
    }
    store ??= stores.cast<Store?>().firstWhere(
        (s) => s!.name.toLowerCase() == p.store.toLowerCase(),
        orElse: () => null);
    final url = p.sourceUrl;
    if (store != null && url != null && url.trim().isNotEmpty) {
      openProductInStore(context, store, url.trim());
    } else {
      Navigator.pushNamed(context, Routes.product, arguments: p);
    }
  }

  Widget _empty(AppLocalizations l) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, size: 44, color: AppColors.muted),
              const SizedBox(height: 12),
              Text(l.noSavedTitle,
                  textAlign: TextAlign.center,
                  style: AppFonts.display(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(l.noSavedSub,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 13, color: AppColors.muted, height: 1.5)),
            ],
          ),
        ),
      );
}

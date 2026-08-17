import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/ui_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_keys.dart';
import '../../models/product.dart';
import '../../providers/catalog_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/launcher.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/product_card.dart';

/// A store shown "inside Heama" — an in-app browser chrome over a native grid.
class StorefrontScreen extends StatefulWidget {
  const StorefrontScreen({super.key});

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen> {
  int _cat = 0;
  static const _sheinUrl = 'https://www.shein.com';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final slug = UiConstants.categorySlug(UiConstants.sheinCatKeys[_cat]);
    context.read<CatalogProvider>().loadProducts(store: 'shein', category: slug);
  }

  void _openProduct(Product p) =>
      Navigator.pushNamed(context, Routes.product, arguments: p);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _browserBar(l),
            _insideNote(l),
            _sheinHeader(l),
            _categoryChips(l),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 20),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 12, 18, 11),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(l.popularNow,
                              style: AppFonts.display(fontSize: 16.5, fontWeight: FontWeight.w700)),
                        ),
                        GestureDetector(
                          onTap: () => openUrl(_sheinUrl),
                          child: Text('${l.viewOnSite} ↗',
                              style: AppFonts.body(
                                  fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                        ),
                      ],
                    ),
                  ),
                  if (catalog.loadingProducts)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (catalog.products.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text('No products here yet.',
                            style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.56,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: catalog.products
                            .map((p) => ProductCard(product: p, onTap: () => _openProduct(p)))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _browserBar(AppLocalizations l) => Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          children: [
            BackChip(onTap: () => Navigator.pop(context), size: 30),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => openUrl(_sheinUrl),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 12, color: AppColors.green),
                      const SizedBox(width: 7),
                      Text('shein.com', style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.refresh, size: 18, color: AppColors.ink),
          ],
        ),
      );

  Widget _insideNote(AppLocalizations l) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: const BoxDecoration(
          color: AppColors.hintBg,
          border: Border(bottom: BorderSide(color: AppColors.hintBorder)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(l.sheinInsideHeama,
                  style: AppFonts.body(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.hintText)),
            ),
            GestureDetector(
              onTap: () => openUrl(_sheinUrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.midnight, borderRadius: BorderRadius.circular(8)),
                child: Text(l.openRealSite,
                    style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      );

  Widget _sheinHeader(AppLocalizations l) => Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Text('SHEIN', style: AppFonts.display(fontSize: 18, color: Colors.white, letterSpacing: 1)),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => openUrl('https://www.shein.com/pdsearch/dress'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 14, color: Color(0xFF888888)),
                      const SizedBox(width: 7),
                      Text(l.searchShein,
                          style: AppFonts.body(fontSize: 12.5, color: const Color(0xFF888888))),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _categoryChips(AppLocalizations l) => SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          itemCount: UiConstants.sheinCatKeys.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final on = i == _cat;
            return GestureDetector(
              onTap: () {
                setState(() => _cat = i);
                _load();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: on ? AppColors.ink : AppColors.cloud,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l.byKey(UiConstants.sheinCatKeys[i]),
                  style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: on ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            );
          },
        ),
      );
}

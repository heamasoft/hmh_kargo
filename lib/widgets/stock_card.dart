import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/cart.dart';
import '../models/stock_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/format.dart';
import '../utils/launcher.dart';
import 'product_image.dart';

/// A card for one in-stock product: photo (tap to open the product page),
/// title, colour/size chips, all-in price and an Add button. Used in the home
/// "Ready now" row and the full stock screen.
class StockCard extends StatelessWidget {
  final StockItem item;
  final VoidCallback? onAdd;
  final bool busy;

  const StockCard({super.key, required this.item, this.onAdd, this.busy = false});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(color: Color(0x0A101828), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo — tap to open the real product page in the browser.
          Expanded(
            child: GestureDetector(
              onTap: item.sourceUrl.isEmpty ? null : () => openUrl(item.sourceUrl),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: item.imageUrl, gradient: CartLine.defaultGradient),
                  // "In stock" ribbon, top-left.
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(l.readyNowTitle,
                          style: AppFonts.body(
                              fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  // Open-link badge, top-right.
                  if (item.sourceUrl.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Color(0x1A000000), blurRadius: 4),
                          ],
                        ),
                        child: const Icon(Icons.open_in_new, size: 14, color: AppColors.ink),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.storeLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(item.storeLabel.toUpperCase(),
                        style: AppFonts.body(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: AppColors.pomegranate)),
                  ),
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
                if (_hasVariant) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      if ((item.color ?? '').isNotEmpty)
                        _chip(Icons.palette_outlined, item.color!),
                      if ((item.size ?? '').isNotEmpty)
                        _chip(Icons.straighten, item.size!),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  formatMoney(item.price, item.currency, iqdLabel: l.iqd),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.display(fontSize: 15, color: AppColors.green),
                ),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: _addButton(l)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasVariant =>
      (item.color ?? '').isNotEmpty || (item.size ?? '').isNotEmpty;

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.cloud,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.muted),
          const SizedBox(width: 3),
          Text(label,
              style: AppFonts.body(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
        ],
      ),
    );
  }

  Widget _addButton(AppLocalizations l) {
    return GestureDetector(
      onTap: busy ? null : onAdd,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: busy ? AppColors.muted : AppColors.pomegranate,
          borderRadius: BorderRadius.circular(10),
        ),
        child: busy
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(l.addToCart,
                      style: AppFonts.body(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/shell_controller.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'store_tile.dart';

/// Home's row of shortcuts: bring a whole cart in, follow an order, what is
/// already in Iraq, and what the shopper saved. (The link box and the wallet's
/// Top up sit in the header above.)
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = [
      (Icons.shopping_cart_checkout_rounded, AppColors.pomegranate, l.icTitle,
          () => Navigator.pushNamed(context, Routes.sheinCart)),
      (Icons.local_shipping_outlined, AppColors.transitText, l.trackOrder,
          () => context.read<ShellController>().goToTab(3)),
      (Icons.inventory_2_outlined, AppColors.green, l.readyNowTitle,
          () => Navigator.pushNamed(context, Routes.stock)),
      (Icons.favorite_border_rounded, AppColors.pomegranateDark, l.navFavourites,
          () => Navigator.pushNamed(context, Routes.saved)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in actions)
            Expanded(
              child: Pressable(
                onTap: a.$4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Color(0x12211B3E), blurRadius: 14, offset: Offset(0, 4)),
                          ],
                        ),
                        child: Icon(a.$1, size: 25, color: a.$2),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.$3,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w700, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

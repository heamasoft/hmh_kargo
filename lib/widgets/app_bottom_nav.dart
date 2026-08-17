import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/approvals_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The app's bottom navigation bar (Home · Stores · Cart · Orders · Me).
/// Used by the main shell, and by full-screen sub-pages (e.g. the stock screen)
/// so they keep the same footer. [current] highlights a tab (-1 = none active).
class AppBottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const AppBottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cartCount = context.watch<CartProvider>().count;
    // Pending shipping-fee approvals badge the Orders tab so the customer sees
    // there's something waiting for their answer.
    final approvalCount = context.watch<ApprovalsProvider>().count;
    final items = [
      (Icons.home_outlined, Icons.home, l.navHome, 0),
      (Icons.storefront_outlined, Icons.storefront, l.navStores, 0),
      (Icons.shopping_cart_outlined, Icons.shopping_cart, l.navCart, cartCount),
      (Icons.receipt_long_outlined, Icons.receipt_long, l.navOrders, approvalCount),
      (Icons.person_outline, Icons.person, l.navMe, 0),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final (outline, filled, label, badge) = items[i];
              final active = current == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            active ? filled : outline,
                            size: 24,
                            color: active ? AppColors.pomegranate : AppColors.muted,
                          ),
                          if (badge > 0)
                            PositionedDirectional(
                              end: -8,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 16),
                                decoration: const BoxDecoration(
                                  color: AppColors.pomegranate,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$badge',
                                  textAlign: TextAlign.center,
                                  style: AppFonts.body(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: AppFonts.body(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.pomegranate : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

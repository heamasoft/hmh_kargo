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

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.midnight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x59211B3E), blurRadius: 30, offset: Offset(0, 12)),
          ],
        ),
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
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: active ? 44 : 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: active ? AppColors.pomegranate : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            active ? filled : outline,
                            size: active ? 20 : 22,
                            color: active ? Colors.white : AppColors.onDarkMuted,
                          ),
                          if (badge > 0)
                            PositionedDirectional(
                              end: active ? 2 : -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.saffron,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$badge',
                                  style: AppFonts.body(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.saffronInk,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(
                        fontSize: 10.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                        color: active ? Colors.white : AppColors.onDarkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

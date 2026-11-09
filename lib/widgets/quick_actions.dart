import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/shell_controller.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'paste_link_button.dart';

/// Home's row of shortcuts to what the service does: take a link, take a
/// whole cart, follow an order, add money. All ours — no shop is named.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  void _topUp(BuildContext context) {
    if (!context.read<AuthProvider>().isAuthenticated) {
      Navigator.pushNamed(context, Routes.login);
      return;
    }
    Navigator.pushNamed(context, Routes.topUp);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = [
      (Icons.add_link_rounded, l.productLink, () => PasteLinkButton.askForProductLink(context)),
      (Icons.shopping_cart_checkout_rounded, l.icTitle,
          () => Navigator.pushNamed(context, Routes.sheinCart)),
      (Icons.local_shipping_outlined, l.trackOrder,
          () => context.read<ShellController>().goToTab(3)),
      (Icons.account_balance_wallet_outlined, l.topUp, () => _topUp(context)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in actions)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: a.$3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.pomegranate.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(a.$1, size: 23, color: AppColors.pomegranate),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.$2,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2),
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

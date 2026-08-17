import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/order.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Small chip showing how an order was paid:
///  - wallet            → "Paid by wallet" (green)
///  - cash on delivery  → "Cash on delivery" (pomegranate — still owed) or
///                         "Paid on delivery" (green — cash collected)
class PaymentBadge extends StatelessWidget {
  final Order order;
  const PaymentBadge({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    late final IconData icon;
    late final String label;
    late final Color color;
    late final Color bg;

    switch (order.paymentStatus) {
      case 'cod':
        icon = Icons.payments_outlined;
        label = l.cashOnDelivery;
        color = AppColors.midnight700;
        bg = AppColors.cloud;
      case 'refunded':
        icon = Icons.replay_rounded;
        label = l.refundedToWallet;
        color = AppColors.green;
        bg = AppColors.greenTint;
      default: // 'paid'
        icon = Icons.account_balance_wallet_outlined;
        label = l.paidByWallet;
        color = AppColors.green;
        bg = AppColors.greenTint;
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: AppFonts.body(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

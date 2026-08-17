import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/launcher.dart';
import '../../widgets/back_chip.dart';

/// Explains how a customer adds money to their wallet: transfer via FIB, or
/// contact us on WhatsApp / phone to top up.
class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});

  // Wallet top-up contact numbers (display, WhatsApp id, dial number).
  static const _numbers = [
    (display: '+964 750 773 3847', wa: '9647507733847', tel: '+9647507733847'),
    (display: '+964 750 442 6898', wa: '9647504426898', tel: '+9647504426898'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
          children: [
            Row(
              children: [
                BackChip(onTap: () => Navigator.pop(context), size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(l.topUpTitle, style: AppFonts.display(fontSize: 20))),
              ],
            ),
            const SizedBox(height: 14),
            Text(l.topUpIntro,
                style: AppFonts.body(fontSize: 13.5, color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 18),

            // 1) FIB transfer.
            _card(
              icon: Icons.account_balance_outlined,
              title: l.topUpFibTitle,
              child: Text(l.topUpFibBody,
                  style: AppFonts.body(fontSize: 13, color: AppColors.ink, height: 1.45)),
            ),
            const SizedBox(height: 12),

            // 2) Cash — arranged by contacting us on WhatsApp / phone.
            _card(
              icon: Icons.payments_outlined,
              title: l.topUpCashTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.topUpContactBody,
                      style: AppFonts.body(fontSize: 13, color: AppColors.ink, height: 1.45)),
                  const SizedBox(height: 12),
                  for (final n in _numbers) _contactRow(l, n.display, n.wa, n.tel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.cloud, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 19, color: AppColors.ink),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(title,
                    style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _contactRow(AppLocalizations l, String display, String wa, String tel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(display,
              style: AppFonts.body(
                  fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: _btn(
                  label: l.actionWhatsapp,
                  icon: Icons.chat_bubble_outline,
                  bg: const Color(0xFF25D366),
                  fg: Colors.white,
                  onTap: () => openUrl('https://wa.me/$wa'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _btn(
                  label: l.actionCall,
                  icon: Icons.call,
                  bg: AppColors.cloud,
                  fg: AppColors.ink,
                  onTap: () => openUrl('tel:$tel'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btn({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 7),
            Text(label,
                style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}

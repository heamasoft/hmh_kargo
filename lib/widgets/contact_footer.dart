import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/launcher.dart';

/// How to reach a person, at the bottom of the account and About pages.
///
/// Two WhatsApp numbers, one per side of the business, and the shop's
/// Instagram. The numbers are split the way the orders are — the stores priced
/// in dollars and charged in dinars, and the Turkish ones — so a shopper
/// writes to whoever is handling their parcel rather than to a switchboard.
class ContactFooter extends StatelessWidget {
  const ContactFooter({super.key});

  /// The shop this number handles, written out at the owner's instruction.
  /// Not translated: it is a shop's name, the same in every language — and it
  /// is the one brand name the app still prints, so it lives here alone and is
  /// easy to find if App Review asks for it to go.
  static const _sheinDesk = 'Shein';

  /// wa.me wants the number in full international form, no plus and no zero.
  static const _waInternational = 'https://wa.me/9647507075295';
  static const _waTurkiye = 'https://wa.me/9647503186064';
  static const _instagram = 'https://instagram.com/hmh_kargo';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),
      child: Column(
        children: [
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 16),
          Text(l.contactUs,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
          const SizedBox(height: 10),
          _row(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            // Named at the owner's instruction: customers ask for this number
            // by the shop they are ordering from, not by "international".
            label: _sheinDesk,
            value: '0750 707 5295',
            url: _waInternational,
          ),
          _row(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            label: l.turkiye,
            value: '0750 318 6064',
            url: _waTurkiye,
          ),
          const SizedBox(height: 4),
          _row(
            context,
            icon: Icons.photo_camera_outlined,
            label: null,
            value: '@hmh_kargo',
            url: _instagram,
          ),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String? label,
    required String value,
    required String url,
  }) {
    return InkWell(
      onTap: () => openUrl(url),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.pomegranate),
            const SizedBox(width: 8),
            if (label != null) ...[
              Text('$label · ',
                  style: AppFonts.body(
                      fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
            ],
            Text(value,
                style: AppFonts.body(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

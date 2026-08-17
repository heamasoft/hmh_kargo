import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/launcher.dart';

/// App credit shown at the bottom of the profile page: developer name, a phone
/// number, and a "click here to visit" link (the raw URL is never shown).
class DeveloperFooter extends StatelessWidget {
  const DeveloperFooter({super.key});

  static const _phone = '07504848085';
  static const _tel = 'tel:07504848085';
  static const _site = 'https://qrcode.heama-soft.com/';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 8),
      child: Column(
        children: [
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 16),
          Text(l.developedBy,
              textAlign: TextAlign.center,
              style: AppFonts.body(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => openUrl(_tel),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.call, size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Text(_phone,
                    style: AppFonts.body(
                        fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => openUrl(_site),
            child: Text(l.footerVisit,
                style: AppFonts.body(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pomegranate,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}

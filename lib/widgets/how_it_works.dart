import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// "How it works" — three steps, in our words, about our service.
class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.link_rounded, l.howStep1Title, l.howStep1Sub),
      (Icons.shopping_bag_outlined, l.howStep2Title, l.howStep2Sub),
      (Icons.local_shipping_outlined, l.howStep3Title, l.howStep3Sub),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.howItWorks, style: AppFonts.display(fontSize: 16.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.pomegranate.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(steps[i].$1, size: 19, color: AppColors.pomegranate),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${steps[i].$2}',
                          style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(steps[i].$3,
                          style: AppFonts.body(fontSize: 12, color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

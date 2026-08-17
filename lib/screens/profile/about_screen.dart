import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/developer_footer.dart';

/// "About HMH KARGO" — what the app does and how it works, plus the developer
/// credit footer.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
          children: [
            Row(
              children: [
                BackChip(onTap: () => Navigator.pop(context), size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(l.aboutTitle, style: AppFonts.display(fontSize: 20))),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset('assets/logo/hmh_kargo_emblem.png', width: 64, height: 64),
            ),
            const SizedBox(height: 18),
            Text(l.aboutBody,
                style: AppFonts.body(fontSize: 14, color: AppColors.ink, height: 1.55)),
            const SizedBox(height: 20),
            Text(l.aboutHowTitle,
                style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(l.aboutHowBody,
                style: AppFonts.body(fontSize: 14, color: AppColors.ink, height: 1.55)),
            const DeveloperFooter(),
          ],
        ),
      ),
    );
  }
}

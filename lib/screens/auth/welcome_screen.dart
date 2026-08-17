import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/language_sheet.dart';
import '../../widgets/primary_button.dart';

/// Onboarding entry screen: brand hero, language picker, and the account paths.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _emblem = 'assets/logo/hmh_kargo_emblem_white.png';

  String _langLabel(String code) => switch (code) {
        'ar' => 'العربية',
        'ku' => 'کوردی',
        _ => 'English',
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.6, -0.9),
            end: Alignment(0.4, 1),
            colors: [AppColors.welcomeTop, AppColors.welcomeBottom],
          ),
        ),
        child: Stack(
          children: [
            // Soft decorative rings for depth.
            Positioned(
              top: 70,
              right: -80,
              child: _ring(260, AppColors.saffron.withValues(alpha: 0.16)),
            ),
            Positioned(
              bottom: -60,
              left: -70,
              child: _ring(220, Colors.white.withValues(alpha: 0.05)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand row + language selector.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(_emblem, width: 32, height: 32),
                            const SizedBox(width: 10),
                            Text(l.appName,
                                style: AppFonts.display(fontSize: 20, color: Colors.white)),
                          ],
                        ),
                        _LangButton(label: _langLabel(lang)),
                      ],
                    ),
                    const Spacer(flex: 5),
                    // Hero emblem with a soft glow.
                    Center(
                      child: Container(
                        width: 156,
                        height: 156,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.14),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(_emblem, width: 104, height: 104),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '${l.welcomeTitleLine1}\n'),
                          TextSpan(
                            text: l.welcomeTitleLine2,
                            style: AppFonts.display(
                                fontSize: 31, color: AppColors.saffron, height: 1.14),
                          ),
                        ],
                        style: AppFonts.display(fontSize: 31, color: Colors.white, height: 1.14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.welcomeSubtitle,
                      style: AppFonts.body(
                        fontSize: 14,
                        color: AppColors.onDarkMuted,
                        height: 1.55,
                      ),
                    ),
                    const Spacer(flex: 6),
                    PrimaryButton(
                      label: l.createAccount,
                      onPressed: () => Navigator.pushNamed(context, Routes.registerName),
                    ),
                    const SizedBox(height: 11),
                    PrimaryButton(
                      label: l.haveAccount,
                      style: HeamaButtonStyle.ghost,
                      onPressed: () => Navigator.pushNamed(context, Routes.login),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ring(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
      );
}

/// Pill that opens the language picker sheet.
class _LangButton extends StatelessWidget {
  final String label;
  const _LangButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showLanguageSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: 12, end: 8, top: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: AppFonts.body(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(width: 1),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

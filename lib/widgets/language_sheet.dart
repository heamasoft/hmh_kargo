import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Bottom sheet to pick the app language (EN / AR / KU).
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<LocaleProvider>();
    final current = provider.locale.languageCode;

    final options = <(String, String, String)>[
      ('en', l.languageEnglish, 'English'),
      ('ar', l.languageArabic, 'العربية'),
      ('ku', l.languageKurdish, 'کوردی'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.languageMenu, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 12),
            ...options.map((o) {
              final (code, name, native) = o;
              final selected = code == current;
              return GestureDetector(
                onTap: () {
                  context.read<LocaleProvider>().setLocale(Locale(code));
                  Navigator.pop(context);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.cloud : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected ? AppColors.pomegranate : AppColors.line,
                        width: selected ? 1.4 : 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(native,
                                style: AppFonts.body(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(name,
                                style: AppFonts.body(
                                    fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle,
                            color: AppColors.pomegranate, size: 22)
                      else
                        const Icon(Icons.circle_outlined,
                            color: AppColors.line, size: 22),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

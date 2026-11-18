import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'motion.dart';
import 'paste_link_button.dart';

/// The big "Paste a product or cart link" box at the top of Home.
///
/// Tapping it opens the link box with the clipboard already in it; a product
/// link opens the add sheet, a shared cart link opens the cart import.
class PasteLinkBox extends StatelessWidget {
  const PasteLinkBox({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void open() => PasteLinkButton.askForProductLink(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: open,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 7, 7, 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.link_rounded, size: 21, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.pasteBoxHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Shimmer(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      color: AppColors.pomegranate,
                      child: Text(l.pasteAction,
                          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _tick(l.pasteOneProduct),
            _tick(l.pasteWholeCart),
          ],
        ),
      ],
    );
  }

  Widget _tick(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_rounded, size: 13, color: AppColors.onDarkMuted),
            const SizedBox(width: 5),
            Text(label,
                style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.onDarkMuted)),
          ],
        ),
      );
}

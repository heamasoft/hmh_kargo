import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

enum HeamaButtonStyle { pomegranate, ink, ghost, cloud }

/// The pill/rounded action button used across the app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final HeamaButtonStyle style;
  final Widget? leading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = HeamaButtonStyle.pomegranate,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    BoxBorder? border;
    switch (style) {
      case HeamaButtonStyle.pomegranate:
        bg = AppColors.pomegranate;
        fg = Colors.white;
        break;
      case HeamaButtonStyle.ink:
        bg = AppColors.ink;
        fg = Colors.white;
        break;
      case HeamaButtonStyle.ghost:
        bg = Colors.white.withValues(alpha: 0.10);
        fg = Colors.white;
        border = Border.all(color: Colors.white.withValues(alpha: 0.20));
        break;
      case HeamaButtonStyle.cloud:
        bg = AppColors.cloud;
        fg = AppColors.ink;
        break;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.md + 1),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadii.md + 1),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md + 1),
            border: border,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Text(
                label,
                style: AppFonts.body(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

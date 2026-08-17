import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// A form field with a bold label above and an optional error line below.
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? error;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
          if (error != null) ...[
            const SizedBox(height: 8),
            Text(
              error!,
              style: AppFonts.body(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.pomegranate,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

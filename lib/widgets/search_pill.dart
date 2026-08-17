import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The rounded, tappable search field placeholder.
class SearchPill extends StatelessWidget {
  final String hint;
  final VoidCallback? onTap;

  const SearchPill({super.key, required this.hint, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 16, color: AppColors.muted),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                hint,
                style: AppFonts.body(fontSize: 13.5, color: AppColors.muted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

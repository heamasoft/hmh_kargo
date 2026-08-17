import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Rounded back button whose arrow respects the active text direction (RTL/LTR).
class BackChip extends StatelessWidget {
  final VoidCallback onTap;
  final double size;
  const BackChip({super.key, required this.onTap, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Icon(
          isRtl ? Icons.arrow_forward : Icons.arrow_back,
          size: size * 0.5,
          color: AppColors.ink,
        ),
      ),
    );
  }
}

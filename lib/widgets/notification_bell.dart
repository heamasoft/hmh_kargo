import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/approvals_provider.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The bell in the Home header: what the admin is waiting on the customer to
/// answer — a changed shipping price today. The count sits on the bell so it is
/// seen from the first screen, and tapping goes straight to the answers.
///
/// It reads [ApprovalsProvider], which the shell keeps fresh, so the number
/// appears on its own without the customer opening anything.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.onDark = true});

  /// On the navy header the bell is white; on a white page it is ink.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final count = context.watch<ApprovalsProvider>().count;
    final color = onDark ? Colors.white : AppColors.ink;

    return Semantics(
      button: true,
      label: count > 0 ? 'Notifications, $count waiting' : 'Notifications',
      child: InkResponse(
        onTap: () => Navigator.pushNamed(context, Routes.approvals),
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                count > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                size: 23,
                color: color,
              ),
              if (count > 0)
                PositionedDirectional(
                  top: -3,
                  end: -4,
                  child: _Badge(count: count, onDark: onDark),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The red count. Rings in the header colour so it reads as a badge rather than
/// a dot that happens to sit there.
class _Badge extends StatelessWidget {
  const _Badge({required this.count, required this.onDark});
  final int count;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final label = count > 9 ? '9+' : '$count';

    return Container(
      constraints: const BoxConstraints(minWidth: 17),
      height: 17,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.pomegranate,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: onDark ? AppColors.midnight : Colors.white,
          width: 1.6,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppFonts.body(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1.05,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/debug_log.dart';
import 'heama_toast.dart';

/// Shows what the app has been doing, on the phone it is doing it on.
///
/// A problem that only happens on someone else's device — an import that
/// stops on one iPhone and not on any we can run from a computer — leaves no
/// trace that anyone can read: the console only exists while the app is run
/// from a machine, and a TestFlight tester has no machine. The trail of traced
/// lines is kept in memory in every build, and this puts it in front of them
/// with one button to copy it, so they can send it on.
///
/// It is read-only, holds nothing but what the app traced this session, and is
/// only reachable where something has visibly gone wrong.
Future<void> showTraceSheet(BuildContext context) {
  final l = AppLocalizations.of(context);
  final lines = DebugTrail.lines;

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheet) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration:
                    BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: Text(l.traceTitle, style: AppFonts.display(fontSize: 17))),
                // The point of the screen: getting these lines to someone who
                // can read them.
                TextButton.icon(
                  onPressed: lines.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: DebugTrail.text));
                          if (ctx.mounted) showHeamaToast(ctx, l.traceCopied);
                        },
                  icon: const Icon(Icons.copy_all_outlined, size: 16),
                  label: Text(l.traceCopy,
                      style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(l.traceSub, style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
            const SizedBox(height: 10),
            Expanded(
              child: lines.isEmpty
                  ? Center(
                      child: Text(l.traceEmpty,
                          style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.cloud,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: ListView.builder(
                        controller: scroll,
                        // Newest last, as it happened; the end is where the
                        // trouble is, so that is where it opens.
                        reverse: true,
                        itemCount: lines.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: SelectableText(
                            lines[lines.length - 1 - i],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 10.5,
                              height: 1.35,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            SafeArea(top: false, child: const SizedBox(height: 8)),
          ],
        ),
      ),
    ),
  );
}

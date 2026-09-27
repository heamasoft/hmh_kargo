import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../screens/webstore/open_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// "I have a link" — from the Home header, for a product found anywhere.
///
/// The shopper has just come from Shein's or Trendyol's own app with a link on
/// the clipboard, so the box opens with it already in place and they press
/// Fetch. It saves opening the right store first and finding the paste field
/// inside it, and a link to a shop we don't carry still works — it goes to the
/// add-by-hand sheet instead.
class PasteLinkButton extends StatelessWidget {
  const PasteLinkButton({super.key, this.onDark = true});

  /// On the navy header the icon is white; on a white page it is ink.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l.productLink,
      child: InkResponse(
        onTap: () => _ask(context),
        radius: 24,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.add_link_rounded,
            size: 23,
            color: onDark ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Future<void> _ask(BuildContext context) async {
    final l = AppLocalizations.of(context);
    // Whatever they copied in the store's app — usually the link itself.
    final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (!context.mounted) return;

    final field = TextEditingController(text: clip.trim());
    final typed = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.productLink, style: AppFonts.display(fontSize: 17)),
        content: TextField(
          controller: field,
          autofocus: true,
          maxLines: 2,
          minLines: 1,
          keyboardType: TextInputType.url,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(hintText: 'https://…', isDense: true),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, field.text.trim()),
            child: Text(l.fetchDetails,
                style: AppFonts.body(
                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
    field.dispose();
    if (!context.mounted || typed == null || typed.isEmpty) return;
    openPastedLink(context, typed);
  }
}

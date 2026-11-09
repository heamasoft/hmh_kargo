import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../router.dart';
import '../screens/cart/manual_item_sheet.dart';
import '../screens/webstore/open_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// "Order from any website": one address box, and the two other ways in.
///
/// It stands where a list of shops used to. HMH KARGO is a buying and shipping
/// service, not a shop window for anyone: it names no store and shows no
/// store's mark (guideline 4.1). The shopper says where they want to buy —
/// a site, a product link, a shared cart — and the app takes it from there.
class OrderAnywhereCard extends StatefulWidget {
  const OrderAnywhereCard({super.key});

  @override
  State<OrderAnywhereCard> createState() => _OrderAnywhereCardState();
}

class _OrderAnywhereCardState extends State<OrderAnywhereCard> {
  final _field = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _field.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _go() {
    final text = _field.text.trim();
    if (text.isEmpty) {
      _focus.requestFocus();
      return;
    }
    _focus.unfocus();
    openWebsite(context, text);
  }

  Future<void> _paste() async {
    final clip = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim() ?? '';
    if (!mounted || clip.isEmpty) return;
    _field.text = clip;
    _field.selection = TextSelection.collapsed(offset: clip.length);
    _go();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnight.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.midnight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(l.anyWebsiteTitle, style: AppFonts.display(fontSize: 16.5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.anyWebsiteSub,
            style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
            decoration: BoxDecoration(
              color: AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.language_rounded, size: 17, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _field,
                    focusNode: _focus,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    autocorrect: false,
                    onSubmitted: (_) => _go(),
                    style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      hintText: l.anyWebsiteHint,
                      hintStyle: AppFonts.body(fontSize: 13, color: AppColors.muted),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.anyWebsitePaste,
                  onPressed: _paste,
                  icon: const Icon(Icons.content_paste_rounded, size: 19, color: AppColors.ink),
                ),
                Material(
                  color: AppColors.pomegranate,
                  borderRadius: BorderRadius.circular(11),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: _go,
                    child: const SizedBox(
                      width: 40,
                      height: 38,
                      child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Action(
                  icon: Icons.shopping_cart_checkout_rounded,
                  label: l.anyWebsiteImportCart,
                  onTap: () => Navigator.pushNamed(context, Routes.sheinCart),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Action(
                  icon: Icons.edit_note_rounded,
                  label: l.anyWebsiteByHand,
                  onTap: () => showManualItemSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cloud,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "How it works" — three steps, in our words, about our service.
class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.link_rounded, l.howStep1Title, l.howStep1Sub),
      (Icons.shopping_bag_outlined, l.howStep2Title, l.howStep2Sub),
      (Icons.local_shipping_outlined, l.howStep3Title, l.howStep3Sub),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.howItWorks, style: AppFonts.display(fontSize: 16.5, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.pomegranate.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(steps[i].$1, size: 19, color: AppColors.pomegranate),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${steps[i].$2}',
                          style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(steps[i].$3,
                          style: AppFonts.body(fontSize: 12, color: AppColors.muted, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

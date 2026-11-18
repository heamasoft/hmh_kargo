import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// The HMH Kargo button in Safari (iPhone and iPad).
///
/// The app carries a Safari extension that puts "Add to HMH Kargo cart" on
/// shopping websites in Safari. iOS installs it with the app but leaves it off
/// until the shopper switches it on, and tells the app nothing about it — so
/// the shopper tells us, from the guide, once they have.
class SafariButton {
  static const _onKey = 'safari_button_on_v1';
  static const _hiddenKey = 'safari_button_card_hidden_v1';

  static bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether the shopper said they switched the button on. Stores then open
  /// in the Safari app, where the button is (not in the sheet over the app,
  /// which runs no extensions).
  static Future<bool> isOn() async {
    if (!supported) return false;
    try {
      return (await SharedPreferences.getInstance()).getBool(_onKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _set(String key, bool v) async {
    try {
      (await SharedPreferences.getInstance()).setBool(key, v);
    } catch (_) {}
  }

  /// The steps to switch it on. True when the shopper says it's on.
  static Future<bool> showGuide(BuildContext context) async {
    final on = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _Guide(),
    );
    if (on == true) await _set(_onKey, true);
    return on == true;
  }
}

class _Guide extends StatelessWidget {
  const _Guide();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [
      (Icons.settings_outlined, l.safariBtnStep1),
      (Icons.toggle_on_outlined, l.safariBtnStep2),
      (Icons.verified_user_outlined, l.safariBtnStep3),
      (Icons.add_shopping_cart_rounded, l.safariBtnStep4),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.safariBtnTitle, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 6),
            Text(l.safariBtnSub,
                style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 16),
            for (final s in steps)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.pomegranate.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(s.$1, size: 19, color: AppColors.pomegranate),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(s.$2,
                          style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.3)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pomegranate,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(l.safariBtnDone,
                    style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l.safariBtnLater,
                    style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// On Home (iPhone and iPad only), until the button is on or the card is
/// closed: "Add from Safari in one tap".
class SafariButtonCard extends StatefulWidget {
  const SafariButtonCard({super.key});

  @override
  State<SafariButtonCard> createState() => _SafariButtonCardState();
}

class _SafariButtonCardState extends State<SafariButtonCard> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!SafariButton.supported) return;
    var show = false;
    try {
      final p = await SharedPreferences.getInstance();
      show = !(p.getBool(SafariButton._onKey) ?? false) &&
          !(p.getBool(SafariButton._hiddenKey) ?? false);
    } catch (_) {}
    if (mounted && show) setState(() => _show = true);
  }

  Future<void> _open() async {
    final on = await SafariButton.showGuide(context);
    if (on && mounted) setState(() => _show = false);
  }

  void _hide() {
    SafariButton._set(SafariButton._hiddenKey, true);
    setState(() => _show = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Material(
        color: AppColors.pomegranate.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.pomegranate,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.safariBtnTitle,
                          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(l.safariBtnShow,
                          style: AppFonts.body(
                              fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.pomegranate)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _hide,
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

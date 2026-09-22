import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../router.dart';
import '../../services/push_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../providers/shell_controller.dart';
import '../../widgets/developer_footer.dart';
import '../../widgets/language_sheet.dart';
import 'rate_cards.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  /// The "Top up with" section (FIB, cash). Off until top-ups go live.
  static const _showTopUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isAuthenticated) {
        context.read<WalletProvider>().load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final reg = context.watch<RegistrationProvider>();
    // Prefer the signed-in user returned by the API.
    final authUser = context.watch<AuthProvider>().user;
    final w = context.watch<WalletProvider>();
    final balance = w.balanceIqd;
    final balanceUsd = w.balanceUsd;
    final name = (authUser != null && authUser.name.isNotEmpty)
        ? authUser.name
        : (reg.name.trim().isEmpty ? 'Aland Hassan' : reg.name.trim());
    final cityKey = reg.cityKey.isEmpty ? 'cityErbil' : reg.cityKey;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.midnight, AppColors.midnight700],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.saffron, AppColors.pomegranate]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(initial, style: AppFonts.display(fontSize: 20, color: Colors.white)),
                    ),
                    const SizedBox(width: 13),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(name, style: AppFonts.display(fontSize: 17, color: Colors.white))],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Two balance cards side by side: dinars and dollars.
          Transform.translate(
            offset: const Offset(0, -12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  // IntrinsicHeight lets both cards match the taller one without the
                  // unbounded-height crash that CrossAxisAlignment.stretch causes
                  // inside a ListView.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _balanceCard(
                            l.iqd,
                            formatIqd(balance),
                            onTap: () => Navigator.pushNamed(context, Routes.walletLedger, arguments: 'IQD'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _balanceCard(
                            'USD',
                            formatMoney(balanceUsd, 'USD'),
                            onTap: () => Navigator.pushNamed(context, Routes.walletLedger, arguments: 'USD'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // What $100 and 100 TL come to in dinars; tap for a calculator.
          _label(l.exchangeRates),
          const RateCards(),
          // Top-up methods are hidden until they go live (flip [_showTopUp]).
          if (_showTopUp) ...[
            _label(l.topUpWith),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  // FIB top-ups aren't live yet — shown, but greyed out as "Soon".
                  _method('🏦', 'FIB', soon: true),
                  const SizedBox(width: 9),
                  _method('💵', l.cash),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          _MenuList(cityKey: cityKey),
          const DeveloperFooter(),
        ],
      ),
    );
  }

  // One balance card (currency code chip + amount). Tapping it opens that
  // currency's ledger.
  Widget _balanceCard(String code, String amount, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
        boxShadow: const [BoxShadow(color: Color(0x22211B3E), blurRadius: 26, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(7)),
                child: Text(
                  code,
                  style: AppFonts.body(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted),
                ),
              ),
              const Spacer(),
              if (onTap != null) const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: AppFonts.display(fontSize: 24)),
          ),
        ],
      ),
    ),
  );

  Widget _method(String emoji, String label, {bool soon = false}) {
    return Expanded(
      child: Opacity(
        opacity: soon ? 0.5 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 6),
              Text(label, style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w700)),
              if (soon) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    'Soon',
                    style: AppFonts.body(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.muted),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 4, 18, 9),
    child: Text(
      text.toUpperCase(),
      style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
    ),
  );
}

class _MenuList extends StatelessWidget {
  final String cityKey;
  const _MenuList({required this.cityKey});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAdmin = context.watch<AuthProvider>().user?.isAdmin ?? false;
    final items = <({IconData icon, String label, VoidCallback? onTap, bool soon})>[
      (
        icon: Icons.person_outline,
        label: l.accountTitle,
        soon: false,
        onTap: () => Navigator.pushNamed(context, Routes.account),
      ),
      // Admins only: create and manage discount codes.
      if (isAdmin)
        (
          icon: Icons.local_offer_outlined,
          label: l.coupons,
          soon: false,
          onTap: () => Navigator.pushNamed(context, Routes.coupons),
        ),
      (
        icon: Icons.inventory_2_outlined,
        label: l.myOrders,
        soon: false,
        onTap: () => context.read<ShellController>().goToTab(3),
      ),
      (
        icon: Icons.favorite_border,
        label: l.savedItems,
        soon: false,
        onTap: () => Navigator.pushNamed(context, Routes.saved),
      ),
      (
        icon: Icons.location_on_outlined,
        label: l.addresses,
        soon: false,
        onTap: () => Navigator.pushNamed(context, Routes.addresses),
      ),
      (
        icon: Icons.account_balance_wallet_outlined,
        label: l.topUpTitle,
        soon: false,
        onTap: () => Navigator.pushNamed(context, Routes.topUp),
      ),
      (
        icon: Icons.info_outline,
        label: l.aboutTitle,
        soon: false,
        onTap: () => Navigator.pushNamed(context, Routes.about),
      ),
      // Rewards & points — not available yet.
      (icon: Icons.card_giftcard_outlined, label: l.rewards, soon: true, onTap: null),
      (
        icon: Icons.language,
        label: '${l.languageMenu} · ${_langName(l, context)}',
        soon: false,
        onTap: () => showLanguageSheet(context),
      ),
      (icon: Icons.logout, label: l.logout, soon: false, onTap: () => _confirmLogout(context, l)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: items.map((it) {
          final disabled = it.onTap == null;
          return Opacity(
            opacity: disabled ? 0.45 : 1,
            child: GestureDetector(
              onTap: it.onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.cloud,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(it.icon, size: 18, color: AppColors.ink),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        it.label,
                        style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (it.soon)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.cloud,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          'Soon',
                          style: AppFonts.body(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.logout, style: AppFonts.display(fontSize: 17)),
        content: Text(
          l.logoutConfirm,
          style: AppFonts.body(fontSize: 13.5, color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              MaterialLocalizations.of(ctx).cancelButtonLabel,
              style: AppFonts.body(fontSize: 13, color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Stop push notifications for this phone, then end the session.
              context.read<PushService>().unregister();
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(context, Routes.welcome, (r) => false);
            },
            child: Text(
              l.logout,
              style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate),
            ),
          ),
        ],
      ),
    );
  }

  String _langName(AppLocalizations l, BuildContext context) {
    final code = context.watch<LocaleProvider>().locale.languageCode;
    switch (code) {
      case 'ar':
        return l.languageArabic;
      case 'ku':
        return l.languageKurdish;
      default:
        return l.languageEnglish;
    }
  }
}

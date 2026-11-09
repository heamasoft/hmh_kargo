import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/order_anywhere_card.dart';
import '../../widgets/store_tile.dart';
import '../webstore/open_store.dart';

/// The Shop tab: order from any website, or open one of the usual ones.
///
/// The usual ones are drawn the way a browser shows saved links — the web
/// address in plain text on a plain tile — never with a shop's logo, colour or
/// styled name (guideline 4.1(b)). Above them, the shopper can type any other
/// site or paste a link, which is what the service is: we buy wherever they
/// shop.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.shopTitle, style: AppFonts.display(fontSize: 21)),
                    const SizedBox(height: 4),
                    Text(l.shopSub,
                        style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
                    const SizedBox(height: 16),
                    const OrderAnywhereCard(),
                    const SizedBox(height: 22),
                    Text(l.websitesTitle,
                        style: AppFonts.display(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(l.websitesNote,
                        style: AppFonts.body(fontSize: 12, color: AppColors.muted, height: 1.4)),
                  ],
                ),
              ),
              if (catalog.loadingStores && catalog.stores.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else ...[
                _SitesSection(title: l.international, stores: catalog.internationalStores),
                _SitesSection(title: l.turkiye, stores: catalog.turkiyeStores),
              ],
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 24, 18, 0),
                child: HowItWorks(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
                child: Text(
                  l.brandDisclaimer,
                  style: AppFonts.body(fontSize: 11.5, color: AppColors.muted, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SitesSection extends StatelessWidget {
  final String title;
  final List<Store> stores;
  const _SitesSection({required this.title, required this.stores});

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Text(title,
              style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.muted)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              final w = (c.maxWidth - gap * 3) / 4;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: stores
                    .map((s) => SizedBox(
                          width: w,
                          child: StoreTile(store: s, onTap: () => openStore(context, s)),
                        ))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

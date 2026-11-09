import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/store_link.dart';
import '../../widgets/how_it_works.dart';
import '../../widgets/store_tile.dart';
import '../webstore/open_store.dart';

/// The Shop tab: the websites a shopper can open and order from — searched,
/// filtered by where they ship from, and counted.
///
/// Each is drawn the way a browser shows a saved link — the web address in
/// plain text on a plain tile — or with a mark set in the dashboard. A link
/// from anywhere else still works from the paste button on Home: we buy
/// wherever they shop.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

enum _Region { all, international, turkiye }

class _StoresScreenState extends State<StoresScreen> {
  final _search = TextEditingController();
  String _query = '';
  _Region _region = _Region.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadStores();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Store> _shown(List<Store> all) {
    final q = _query.trim().toLowerCase();
    return all.where((s) {
      if (_region == _Region.international && s.region == 'turkiye') return false;
      if (_region == _Region.turkiye && s.region != 'turkiye') return false;
      if (q.isEmpty) return true;
      final host = Uri.tryParse(s.url)?.host ?? '';
      return s.name.toLowerCase().contains(q) || registrableDomain(host).contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();
    final shown = _shown(catalog.stores);

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
                    const SizedBox(height: 14),
                    _searchBox(l),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _chip(l.filterAll, _Region.all),
                        const SizedBox(width: 8),
                        _chip(l.international, _Region.international),
                        const SizedBox(width: 8),
                        _chip(l.turkiye, _Region.turkiye),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(l.websitesCount(shown.length),
                        style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(l.websitesNote,
                        style: AppFonts.body(fontSize: 11.5, color: AppColors.muted, height: 1.4)),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              if (catalog.loadingStores && catalog.stores.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Center(
                    child: Text('—', style: AppFonts.display(fontSize: 22, color: AppColors.muted)),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      const gap = 8.0;
                      final w = (c.maxWidth - gap * 3) / 4;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: shown
                            .map((s) => SizedBox(
                                  width: w,
                                  child: StoreTile(store: s, onTap: () => openStore(context, s)),
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
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

  Widget _searchBox(AppLocalizations l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.cloud,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, size: 17, color: AppColors.muted),
            const SizedBox(width: 9),
            Expanded(
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                autocorrect: false,
                style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  hintText: l.searchStores,
                  hintStyle: AppFonts.body(fontSize: 13.5, color: AppColors.muted),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _search.clear();
                  setState(() => _query = '');
                },
                child: const Icon(Icons.close, size: 16, color: AppColors.muted),
              ),
          ],
        ),
      );

  Widget _chip(String label, _Region value) {
    final active = _region == value;
    return GestureDetector(
      onTap: () => setState(() => _region = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.midnight : AppColors.cloud,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppFonts.body(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

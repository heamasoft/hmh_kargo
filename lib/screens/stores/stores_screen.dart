import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/store_tile.dart';
import '../webstore/open_store.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _search = TextEditingController();
  String _query = '';

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

  List<Store> _filter(List<Store> list) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((s) => s.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final catalog = context.watch<CatalogProvider>();
    final intl = _filter(catalog.internationalStores);
    final turkiye = _filter(catalog.turkiyeStores);
    final noResults = _query.trim().isNotEmpty && intl.isEmpty && turkiye.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
              child: Text(l.stores, style: AppFonts.display(fontSize: 21)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Text(l.storesSub,
                  style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cloud,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: AppColors.muted),
                    const SizedBox(width: 9),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
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
              ),
            ),
            if (catalog.loadingStores && catalog.stores.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (noResults)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Text('—', style: AppFonts.display(fontSize: 22, color: AppColors.muted)),
                ),
              )
            else ...[
              _StoresSection(title: l.international, stores: intl),
              _StoresSection(title: l.turkiye, stores: turkiye),
            ],
          ],
        ),
      ),
    );
  }
}

class _StoresSection extends StatelessWidget {
  final String title;
  final List<Store> stores;
  const _StoresSection({required this.title, required this.stores});

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 11),
          child: Text(title, style: AppFonts.display(fontSize: 16.5, fontWeight: FontWeight.w700)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          // Wrap (not fixed-aspect grid) so cards size to content — no overflow.
          child: LayoutBuilder(
            builder: (context, c) {
              const gap = 11.0;
              final w = (c.maxWidth - gap * 2) / 3;
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/store_link.dart';
import '../../widgets/motion.dart';
import '../../widgets/paste_link_button.dart';
import '../../widgets/store_tile.dart';
import '../cart/manual_item_sheet.dart';
import '../home/home_sections.dart';
import '../webstore/open_store.dart';

/// The Shop tab: search the websites, filter them by where they ship from,
/// the two most popular as big cards, then every other one with what it sells,
/// and a way to buy from a site that isn't listed.
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
    // The first two (the dashboard's order) as big cards — only on the full,
    // unfiltered list, so a search shows plain results.
    final featured = (_query.isEmpty && _region == _Region.all) ? shown.take(2).toList() : <Store>[];
    final rest = shown.skip(featured.length).toList();

    return Scaffold(
      backgroundColor: AppColors.cloud,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              _header(l),
              // "Have a link?" sits over the header's lower edge.
              Transform.translate(
                offset: const Offset(0, -40),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: RiseIn(delay: Duration(milliseconds: 140), child: _HaveALinkCard()),
                ),
              ),
              RiseIn(
                delay: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      _chip('${l.filterAll} · ${catalog.stores.length}', _Region.all),
                      const SizedBox(width: 8),
                      _chip(l.international, _Region.international),
                      const SizedBox(width: 8),
                      _chip(l.turkiye, _Region.turkiye),
                    ],
                  ),
                ),
              ),
              if (catalog.loadingStores && catalog.stores.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  child: Center(child: Text('—', style: AppFonts.display(fontSize: 22, color: AppColors.muted))),
                )
              else ...[
                if (featured.isNotEmpty)
                  RiseIn(
                    delay: const Duration(milliseconds: 260),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeSectionTitle(title: l.mostPopular),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (var i = 0; i < featured.length; i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                Expanded(child: _FeaturedCard(store: featured[i], delay: i * 1500)),
                              ],
                              if (featured.length == 1) const Expanded(child: SizedBox()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (rest.isNotEmpty)
                  RiseIn(
                    delay: const Duration(milliseconds: 330),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: Text(l.allWebsites, style: AppFonts.display(fontSize: 20))),
                              Text(l.websitesCount(shown.length),
                                  style: AppFonts.body(
                                      fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.muted)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          FourGrid(
                            rowGap: 18,
                            children: [
                              for (final s in rest)
                                StoreTile(store: s, showCategory: true, onTap: () => openStore(context, s)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
              const RiseIn(
                delay: Duration(milliseconds: 400),
                child: Padding(padding: EdgeInsets.fromLTRB(18, 26, 18, 0), child: _NotOnListCard()),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: Text(
                  l.brandDisclaimer,
                  textAlign: TextAlign.center,
                  style: AppFonts.body(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted, height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.midnight,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -60,
            top: -70,
            child: IgnorePointer(
              child: Container(
                width: 210,
                height: 210,
                decoration: const BoxDecoration(color: AppColors.midnight700, shape: BoxShape.circle),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 64),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RiseIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.shopTitle, style: AppFonts.display(fontSize: 30, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(l.shopSub,
                            style: AppFonts.body(
                                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  RiseIn(delay: RiseIn.step, child: _searchBox(l)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox(AppLocalizations l) => Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: AppColors.onDarkMuted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                autocorrect: false,
                cursorColor: Colors.white,
                style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: l.searchStores,
                  hintStyle: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted),
                ),
              ),
            ),
            if (_query.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _search.clear();
                  setState(() => _query = '');
                },
                child: const Icon(Icons.close_rounded, size: 18, color: AppColors.onDarkMuted),
              ),
          ],
        ),
      );

  Widget _chip(String label, _Region value) {
    final active = _region == value;
    return GestureDetector(
      onTap: () => setState(() => _region = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.midnight : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppColors.midnight : AppColors.line),
        ),
        child: Text(label,
            style: AppFonts.body(
                fontSize: 13, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.ink)),
      ),
    );
  }
}

/// "Have a link? A product or a whole shared cart" — Paste.
class _HaveALinkCard extends StatelessWidget {
  const _HaveALinkCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    void open() => PasteLinkButton.askForProductLink(context);
    return Pressable(
      onTap: open,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Color(0x24211B3E), blurRadius: 30, offset: Offset(0, 14))],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.pomTintChip, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.link_rounded, size: 21, color: AppColors.pomegranate),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.haveLink, style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('${l.pasteOneProduct} · ${l.pasteWholeCart}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Shimmer(
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                color: AppColors.pomegranate,
                child: Text(l.pasteAction,
                    style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A big card for one of the most popular websites: a slowly zooming photo,
/// the name, what it sells, and an arrow.
class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.store, this.delay = 0});

  final Store store;
  final int delay;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _zoom =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4500));

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _zoom.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = widget.store;
    return Pressable(
      onTap: () => openStore(context, s),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Color(0x14211B3E), blurRadius: 18, offset: Offset(0, 6))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 120,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _zoom,
                  builder: (_, child) => Transform.scale(
                    scale: 1 + 0.06 * Curves.easeInOut.transform(_zoom.value),
                    child: child,
                  ),
                  child: StoreTile.picture(s, width: double.infinity, height: 120),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w800)),
                        Text(StoreTile.categoryLabel(l, s),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.body(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: AppColors.midnight, borderRadius: BorderRadius.circular(11)),
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Website not on the list?" — buy from anywhere, by link or by hand.
class _NotOnListCard extends StatelessWidget {
  const _NotOnListCard();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.midnight, borderRadius: BorderRadius.circular(22)),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(color: AppColors.midnight700, shape: BoxShape.circle),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.notOnList, style: AppFonts.display(fontSize: 17, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(l.notOnListSub,
                          style: AppFonts.body(
                              fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.onDarkMuted, height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Pressable(
                  onTap: () => showManualItemSheet(context),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.saffron, borderRadius: BorderRadius.circular(13)),
                    child: Text(l.addByHand,
                        style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.saffronInk)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

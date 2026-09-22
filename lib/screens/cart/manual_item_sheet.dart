import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/store.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../services/api_client.dart';
import '../../services/capture_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/link_text.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';

/// Adds a product the in-app stores don't carry: its link and price, with an
/// optional colour, size and note. It becomes a normal cart line — and so a
/// normal order item — priced by the server's usual rule.
Future<void> showManualItemSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManualItemSheet(),
    );

class _ManualItemSheet extends StatefulWidget {
  const _ManualItemSheet();

  @override
  State<_ManualItemSheet> createState() => _ManualItemSheetState();
}

class _ManualItemSheetState extends State<_ManualItemSheet> {
  final _link = TextEditingController();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _color = TextEditingController();
  final _size = TextEditingController();
  final _note = TextEditingController();

  /// Currencies a price can be typed in when the link's shop isn't one of ours.
  static const _currencies = ['USD', 'TRY', 'IQD'];
  String _currency = 'USD';
  int _qty = 1;
  bool _adding = false;
  String? _linkError;
  String? _priceError;

  /// The name and photo read from the link, when the shop lets the server
  /// read it. The name stays editable; typing in it stops any overwrite.
  bool _nameAuto = true;
  bool _loadingName = false;
  String? _image;
  Timer? _lookup;
  String _lookedUp = '';

  /// The catalogue store the link belongs to, if any — its currency and cart
  /// rules then apply (the server prices a known store in its own currency).
  Store? _store;

  @override
  void dispose() {
    _lookup?.cancel();
    for (final c in [_link, _name, _price, _color, _size, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _url {
    var u = linkFromPaste(_link.text.trim());
    if (u.isNotEmpty && !u.startsWith('http')) u = 'https://$u';
    return u;
  }

  /// "m.shein.com" / "www.trendyol.com" → "shein.com" / "trendyol.com"
  /// ("zara.com.tr"-style hosts keep three labels).
  static String _domain(String host) {
    final parts = host.toLowerCase().split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return host.toLowerCase();
    final second = parts[parts.length - 2];
    final keep = parts.length >= 3 && const ['com', 'co', 'org', 'net'].contains(second) ? 3 : 2;
    return parts.sublist(parts.length - keep).join('.');
  }

  void _onLinkChanged(String _) {
    final host = Uri.tryParse(_url)?.host ?? '';
    // Trendyol's app shares short ty.gl links.
    final domain = host.toLowerCase() == 'ty.gl' ? 'trendyol.com' : _domain(host);
    Store? match;
    if (domain.contains('.')) {
      for (final s in context.read<CatalogProvider>().stores) {
        final sh = Uri.tryParse(s.url)?.host ?? '';
        if (sh.isNotEmpty && _domain(sh) == domain) {
          match = s;
          break;
        }
      }
    }
    setState(() {
      _store = match;
      _linkError = null;
    });
    // Read the product's name once typing pauses on a real link.
    _lookup?.cancel();
    if (Uri.tryParse(_url)?.hasAuthority ?? false) {
      _lookup = Timer(const Duration(milliseconds: 600), _loadName);
    }
  }

  /// Asks the server to read the link's page for its name and photo. A shop
  /// that blocks the server (or an unreadable page) just leaves the name for
  /// the shopper to type — never an error.
  Future<void> _loadName() async {
    final url = _url;
    if (url == _lookedUp || !_nameAuto) return;
    _lookedUp = url;
    setState(() => _loadingName = true);
    try {
      final api = CaptureApi(context.read<ApiClient>());
      // An app share link (Shein onelink, Trendyol ty.gl) → the product page.
      final page = (await api.resolve(url)).url;
      final r = await api.scrape(page);
      if (!mounted || url != _url || !_nameAuto) return;
      final title = r.title.trim();
      setState(() {
        if (title.isNotEmpty) _name.text = title;
        if (r.imageUrl.isNotEmpty) _image = r.imageUrl;
      });
    } on ApiException catch (_) {
      // Can't read it — the shopper types the name.
    } finally {
      if (mounted) setState(() => _loadingName = false);
    }
  }

  String get _effectiveCurrency =>
      (_store != null && _store!.currency.isNotEmpty) ? _store!.currency.toUpperCase() : _currency;

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final url = _url;
    final uri = Uri.tryParse(url);
    final price = double.tryParse(_price.text.trim().replaceAll(',', '.')) ?? 0;
    setState(() {
      _linkError = (uri == null || !uri.hasAuthority) ? l.linkRequired : null;
      _priceError = price <= 0 ? l.priceRequired : null;
    });
    if (_linkError != null || _priceError != null || _adding) return;

    String? opt(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    // A name is optional; the shop's address stands in so the line isn't blank.
    final title = opt(_name) ?? uri!.host.replaceFirst('www.', '');

    setState(() => _adding = true);
    final cart = context.read<CartProvider>();
    try {
      final priced = await CaptureApi(context.read<ApiClient>()).price(
        storeKey: _store?.id,
        sourceUrl: url,
        title: title,
        imageUrl: _image,
        sourcePrice: price,
        sourceCurrency: _effectiveCurrency,
        color: opt(_color),
        size: opt(_size),
      );
      final ok = await cart.addCaptured(
        priced,
        color: opt(_color),
        size: opt(_size),
        note: opt(_note),
        qty: _qty,
      );
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context);
        showHeamaToast(context, l.addedToCart(title));
      } else {
        showHeamaToast(context, cart.error ?? 'Could not add the item.');
      }
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
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
                const SizedBox(height: 16),
                Text(l.addByLink, style: AppFonts.display(fontSize: 19)),
                const SizedBox(height: 4),
                Text(l.addByLinkSub, style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 16),
                _field(l.productLink, _link,
                    hint: 'https://…',
                    keyboard: TextInputType.url,
                    error: _linkError,
                    onChanged: _onLinkChanged),
                if (_store != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.fromStore(_store!.name),
                        style: AppFonts.body(
                            fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.green)),
                  ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 44,
                          height: 52,
                          child: ProductImage(url: _image!, gradient: const [AppColors.cloud, AppColors.line]),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: _field(l.productName, _name,
                          // Filled from the link when possible; any edit keeps it.
                          onChanged: (_) => _nameAuto = false,
                          suffix: _loadingName
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2)),
                                )
                              : null),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _field(l.productPrice, _price,
                          hint: _effectiveCurrency == 'IQD' ? '10000' : '0.00',
                          keyboard: const TextInputType.numberWithOptions(decimal: true),
                          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          error: _priceError,
                          onChanged: (_) {
                            if (_priceError != null) setState(() => _priceError = null);
                          }),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: _currencyPicker(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _field('${l.colour} (${l.optional})', _color)),
                    const SizedBox(width: 10),
                    Expanded(child: _field('${l.size} (${l.optional})', _size)),
                  ],
                ),
                const SizedBox(height: 12),
                _field('${l.itemNote} (${l.optional})', _note, hint: l.itemNoteHint, maxLines: 2),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(l.quantity, style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    _qtyButton(Icons.remove, _qty > 1 ? () => setState(() => _qty--) : null),
                    SizedBox(
                      width: 36,
                      child: Text('$_qty',
                          textAlign: TextAlign.center,
                          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                    _qtyButton(Icons.add, _qty < 99 ? () => setState(() => _qty++) : null),
                  ],
                ),
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: _adding ? null : _add,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.pomegranate,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _adding
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(l.addToCart,
                            style: AppFonts.body(
                                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// A known store fixes the currency (the server prices it in the store's);
  /// otherwise the shopper says which currency the price is in.
  Widget _currencyPicker() {
    if (_store != null) {
      return _chip(_effectiveCurrency == 'TRY' ? 'TL' : _effectiveCurrency, selected: true);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in _currencies) ...[
          GestureDetector(
            onTap: () => setState(() => _currency = c),
            child: _chip(c == 'TRY' ? 'TL' : c, selected: _currency == c),
          ),
          if (c != _currencies.last) const SizedBox(width: 6),
        ],
      ],
    );
  }

  Widget _chip(String text, {required bool selected}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.midnight : AppColors.cloud,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.midnight : AppColors.line),
        ),
        child: Text(text,
            style: AppFonts.body(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.ink)),
      );

  Widget _qtyButton(IconData icon, VoidCallback? onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.cloud,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, size: 16, color: onTap == null ? AppColors.line : AppColors.ink),
        ),
      );

  Widget _field(String label, TextEditingController c,
      {String? hint,
      TextInputType? keyboard,
      List<TextInputFormatter>? formatters,
      String? error,
      int maxLines = 1,
      Widget? suffix,
      ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: error != null ? AppColors.pomegranate : AppColors.muted)),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          keyboardType: keyboard,
          inputFormatters: formatters,
          maxLines: maxLines,
          onChanged: onChanged,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
              isDense: true, hintText: hint, errorText: error, suffixIcon: suffix),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/captured_product.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_client.dart';
import '../../services/capture_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';
import '../../providers/shell_controller.dart';

/// Bottom sheet that turns a product URL into a cart item. The server scrapes
/// the link; the user confirms/edits details and picks a variant + quantity.
class CaptureSheet extends StatefulWidget {
  final String? initialUrl;
  final String? initialTitle;
  final String? initialImage;
  final double? initialPrice;
  final String? initialCurrency;
  final String? initialColor;
  final String? initialSize;

  /// The product's SKU / id, captured from the page — stored with the item so the
  /// admin can find the exact product to order.
  final String? initialSku;

  /// Whether the product offers this attribute. If true, the field is shown and
  /// required; if false, it's hidden (nothing to choose). Defaults true so the
  /// web paste flow (which can't detect) still shows both.
  final bool offersColor;
  final bool offersSize;

  /// Option labels scraped from the page. When non-empty the field shows
  /// tappable chips instead of a blank text box.
  final List<String> colorOptions;
  final List<String> sizeOptions;
  final String storeKey;

  /// Auto-run the SERVER scrape on open (used for the web paste flow).
  final bool autoServerFetch;

  const CaptureSheet({
    super.key,
    this.initialUrl,
    this.initialTitle,
    this.initialImage,
    this.initialPrice,
    this.initialCurrency,
    this.initialColor,
    this.initialSize,
    this.initialSku,
    this.offersColor = true,
    this.offersSize = true,
    this.colorOptions = const [],
    this.sizeOptions = const [],
    required this.storeKey,
    this.autoServerFetch = false,
  });

  @override
  State<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends State<CaptureSheet> {
  late final TextEditingController _url;
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _currency = TextEditingController(text: 'USD');
  final _color = TextEditingController();
  final _size = TextEditingController();
  final _note = TextEditingController();
  int _qty = 1;
  String _imageUrl = '';

  CapturedProduct? _priced;
  bool _fetching = false;
  bool _pricing = false;
  bool _adding = false;
  bool _showVariantErrors = false;
  String? _error;
  bool _triedFetch = false;

  late final CaptureApi _capture;

  @override
  void initState() {
    super.initState();
    _capture = CaptureApi(context.read<ApiClient>());
    _url = TextEditingController(text: widget.initialUrl ?? '');
    _title.text = widget.initialTitle ?? '';
    _imageUrl = widget.initialImage ?? '';
    // Auto-load whatever we detected from the page; the shopper can change it.
    // Both colour and size are required (typed in when we didn't detect them).
    _color.text = widget.initialColor ?? '';
    _size.text = widget.initialSize ?? '';
    if (widget.initialCurrency != null && widget.initialCurrency!.isNotEmpty) {
      _currency.text = widget.initialCurrency!;
    }
    _triedFetch = widget.initialTitle != null || widget.initialImage != null;

    if (widget.initialPrice != null && widget.initialPrice! > 0) {
      // Details came from the page (mobile) — just convert the price to IQD.
      _price.text = widget.initialPrice!.toStringAsFixed(2);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reprice());
    } else if (widget.autoServerFetch && _url.text.trim().isNotEmpty) {
      // Web: let the server scrape the pasted link.
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    }
  }

  @override
  void dispose() {
    for (final c in [_url, _title, _price, _currency, _color, _size, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  double get _priceValue =>
      double.tryParse(_price.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

  /// Ask the server to scrape the URL and prefill the fields.
  Future<void> _fetch() async {
    final url = _url.text.trim();
    if (url.isEmpty || _fetching) return;
    setState(() {
      _fetching = true;
      _error = null;
      _triedFetch = true;
    });
    try {
      final r = await _capture.scrape(url);
      _imageUrl = r.imageUrl;
      _title.text = r.title;
      _currency.text = r.sourceCurrency;
      if (r.auto && r.sourcePrice > 0) {
        _price.text = r.sourcePrice.toStringAsFixed(2);
        _priced = r;
      } else {
        _priced = null; // no price found — user must enter it
      }
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      if (mounted) setState(() => _fetching = false);
    }
  }

  /// Reprice after the user edits the price/title/currency.
  Future<void> _reprice() async {
    if (_priceValue <= 0 || _title.text.trim().isEmpty) return;
    setState(() => _pricing = true);
    try {
      _priced = await _capture.price(
        storeKey: widget.storeKey,
        sourceUrl: _url.text.trim().isEmpty ? 'https://${widget.storeKey}.com' : _url.text.trim(),
        title: _title.text.trim(),
        imageUrl: _imageUrl,
        sourcePrice: _priceValue,
        sourceCurrency: _currency.text.trim().isEmpty ? 'USD' : _currency.text.trim().toUpperCase(),
      );
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      _priced = null;
    } finally {
      if (mounted) setState(() => _pricing = false);
    }
  }

  // An attribute is required only when the product offers a real CHOICE — a list
  // of options to pick from. Clothing has size + colour options; many home goods
  // (Karaca) have neither, and a single detected colour is just pre-filled info,
  // never forced.
  bool get _sizeRequired => widget.sizeOptions.length >= 2 || widget.offersSize;
  bool get _colorRequired => widget.colorOptions.length >= 2;

  // "Exclusive" stores must be ordered on their own (Shein only). Every other
  // store — including Trendyol — may be mixed together in one cart. Kept in sync
  // with the server's `exclusive_stores` setting.
  static const _exclusiveStores = {'shein'};
  String _cartGroup(String? storeKey) {
    final k = (storeKey ?? '').toLowerCase();
    return _exclusiveStores.contains(k) ? 'x:$k' : 'mixed';
  }

  /// If adding this product would break the rule, returns the name of the
  /// exclusive store that must be ordered alone; otherwise null.
  String? _exclusiveBlocker(CartProvider cart) {
    if (cart.items.isEmpty) return null;
    final cur = cart.items.first;
    final newGroup = _cartGroup(widget.storeKey);
    final curGroup = _cartGroup(cur.storeKey);
    if (newGroup == curGroup) return null;
    return curGroup.startsWith('x:')
        ? cur.store // the exclusive store already in the cart
        : (_priced?.storeName ?? widget.storeKey); // the exclusive store we're adding
  }

  Future<void> _add() async {
    if (_adding) return;
    final l = AppLocalizations.of(context);
    final cart = context.read<CartProvider>();
    // Require colour/size only when the product offers them.
    if ((_colorRequired && _color.text.trim().isEmpty) ||
        (_sizeRequired && _size.text.trim().isEmpty)) {
      setState(() => _showVariantErrors = true);
      return;
    }
    if (_priced == null) {
      await _reprice();
      if (_priced == null) return;
    }
    // Exclusive-store rule: banner + disabled button already reflect this, and the
    // server enforces it too — just stop if blocked.
    if (_exclusiveBlocker(cart) != null) {
      return;
    }
    setState(() => _adding = true);
    final ok = await cart.addCaptured(
      _priced!,
      color: _color.text.trim().isEmpty ? null : _color.text.trim(),
      size: _size.text.trim().isEmpty ? null : _size.text.trim(),
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      sku: widget.initialSku,
      qty: _qty,
    );
    if (!mounted) return;
    setState(() => _adding = false);
    if (!ok) {
      showHeamaToast(context, cart.error ?? 'Could not add.');
      return;
    }
    // Do all context-dependent work BEFORE popping — after Navigator.pop the
    // sheet's context is deactivated, and using it (toast / provider lookup)
    // throws a framework assertion.
    showHeamaToast(context, l.addedToCart(_title.text.trim()));
    context.read<ShellController>().goToTab(2);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorErr = _showVariantErrors && _colorRequired && _color.text.trim().isEmpty
        ? l.required
        : null;
    final sizeErr = _showVariantErrors && _sizeRequired && _size.text.trim().isEmpty
        ? l.required
        : null;
    final colorLabel = _colorRequired ? l.colour : '${l.colour} (${l.optional})';
    final sizeLabel = _sizeRequired ? l.size : '${l.size} (${l.optional})';
    // Exclusive-store rule: if adding this product would mix an exclusive store
    // (Shein/Trendyol) with others, block it inline and disable the button.
    final cart = context.watch<CartProvider>();
    final blockName = _exclusiveBlocker(cart);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(l.captureSheetTitle, style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 2),
            Text(l.captureCheckDetails,
                style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
            if (blockName != null) ...[
              const SizedBox(height: 12),
              _blockBanner(l.exclusiveOrder(blockName)),
            ],
            const SizedBox(height: 14),
            // Scrollable form fields
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // URL + fetch
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _field(l.productLink, _url,
                              keyboard: TextInputType.url, onSubmitted: (_) => _fetch()),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _fetch,
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(12)),
                            alignment: Alignment.center,
                            child: _fetching
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : Text(l.fetchDetails,
                                    style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                    if (_triedFetch && !_fetching && _priced == null && _error == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(l.couldntCapture,
                            style: AppFonts.body(fontSize: 11.5, color: AppColors.hintText)),
                      ),
                    const SizedBox(height: 14),
                    // image + title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 74,
                            child: ProductImage(url: _imageUrl, gradient: const [Color(0xFFC9B6E8), Color(0xFFE9C7D6)]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _field(l.captureSheetTitle, _title, maxLines: 2)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _field(l.priceOnSite, _price,
                              keyboard: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() => _priced = null),
                              onSubmitted: (_) => _reprice()),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: _field('CUR', _currency, onSubmitted: (_) => _reprice())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _iqdRow(l),
                    const SizedBox(height: 12),
                    // Colour + size — both required. Detected values are
                    // auto-loaded (as chips when the page gave a list, else a
                    // pre-filled text box); the shopper can change them, and an
                    // unlisted variant can be typed via the ✎ chip.
                    _variantSection(colorLabel, _color, widget.colorOptions,
                        errorText: colorErr, onChanged: (_) => setState(() {})),
                    const SizedBox(height: 14),
                    _variantSection(sizeLabel, _size, widget.sizeOptions,
                        errorText: sizeErr, onChanged: (_) => setState(() {})),
                    const SizedBox(height: 14),
                    // Optional note — a special requirement the admin should see.
                    _field('${l.itemNote} (${l.optional})', _note,
                        maxLines: 2, hintText: l.itemNoteHint),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(l.quantity, style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        _qtyBtn('−', () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('$_qty', style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                        _qtyBtn('+', () => setState(() => _qty++)),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            // Pinned footer button
            const SizedBox(height: 10),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 4),
              child: GestureDetector(
                onTap: (_adding || blockName != null) ? null : _add,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                      color: blockName != null ? AppColors.line : AppColors.pomegranate,
                      borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  child: _adding
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.addToCart,
                          style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: blockName != null ? AppColors.muted : Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inline warning shown when the cart already holds items from another store.
  Widget _blockBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.pomegranate.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.pomegranate.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.pomegranate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppFonts.body(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pomegranate,
                    height: 1.35)),
          ),
        ],
      ),
    );
  }

  Widget _iqdRow(AppLocalizations l) {
    // Shein/manual are charged in IQD ("All-in, in dinars"); other stores in USD.
    final isUsd = _priced?.chargeCurrency.toUpperCase() == 'USD';
    final label = isUsd ? l.allInPrice : l.allInDinars;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.muted)),
          ),
          if (_pricing)
            const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          else if (_error != null)
            Flexible(
              child: Text(_error!,
                  textAlign: TextAlign.end,
                  style: AppFonts.body(fontSize: 11.5, color: AppColors.pomegranate)),
            )
          else if (_priced != null)
            Text(formatMoney(_priced!.chargeAmount, _priced!.chargeCurrency, iqdLabel: l.iqd),
                style: AppFonts.display(fontSize: 17))
          else
            GestureDetector(
              onTap: _reprice,
              child: Text('— ${l.iqd}', style: AppFonts.display(fontSize: 17, color: AppColors.muted)),
            ),
        ],
      ),
    );
  }

  /// A required variant picker. When the page gave a list of options we render
  /// tappable chips (auto-selecting the value we detected); otherwise a free text
  /// box pre-filled with what we detected. The ✎ chip lets an unlisted variant be
  /// typed, so a missed option is never a dead end.
  Widget _variantSection(String label, TextEditingController c, List<String> options,
      {String? errorText, ValueChanged<String>? onChanged}) {
    if (options.isEmpty) {
      return _variantField(label, c, const [],
          errorText: errorText, onChanged: onChanged);
    }
    final val = c.text.trim();
    final isCustom = val.isNotEmpty && !options.contains(val);
    final shown = [...options, if (isCustom) val];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: errorText != null ? AppColors.pomegranate : AppColors.muted)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in shown)
              _chip(o, selected: val == o, onTap: () {
                setState(() => c.text = o);
                onChanged?.call(o);
              }),
            _pencilChip(() async {
              final v = await _promptCustom(val);
              if (v == null || !mounted) return;
              setState(() => c.text = v);
              onChanged?.call(v);
            }),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(errorText,
                style: AppFonts.body(fontSize: 11.5, color: AppColors.pomegranate)),
          ),
      ],
    );
  }

  Widget _chip(String text, {required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.pomegranate : AppColors.cloud,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: selected ? AppColors.pomegranate : AppColors.line),
        ),
        child: Text(text,
            style: AppFonts.body(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.ink)),
      ),
    );
  }

  Widget _pencilChip(VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.cloud,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.line),
          ),
          child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.muted),
        ),
      );

  /// Small dialog to type a variant that wasn't in the scraped list. Delegates to
  /// a dedicated stateful dialog that owns its text controller, so the controller
  /// is disposed cleanly with the widget (a manual dispose right after the dialog
  /// closes tripped the `_dependents.isEmpty` framework assertion).
  Future<String?> _promptCustom(String initial) {
    return showDialog<String>(
      context: context,
      builder: (_) => _VariantPromptDialog(initial: initial),
    );
  }

  /// An editable field pre-filled with what we scraped. If the page also gave a
  /// list of options, a dropdown arrow lets you quick-pick one — but you can
  /// always just type, so a missed/odd variant is never a dead end.
  Widget _variantField(String label, TextEditingController c, List<String> options,
      {String? errorText, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: errorText != null ? AppColors.pomegranate : AppColors.muted)),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          onChanged: onChanged,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            errorText: errorText,
            suffixIcon: options.isEmpty
                ? null
                : PopupMenuButton<String>(
                    tooltip: '',
                    icon: const Icon(Icons.expand_more, size: 20, color: AppColors.muted),
                    onSelected: (v) {
                      c.text = v;
                      onChanged?.call(v);
                      setState(() {});
                    },
                    itemBuilder: (_) => options
                        .map((o) => PopupMenuItem(
                            value: o,
                            child: Text(o,
                                style: AppFonts.body(
                                    fontSize: 14, fontWeight: FontWeight.w600))))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType? keyboard,
      ValueChanged<String>? onChanged,
      ValueChanged<String>? onSubmitted,
      int maxLines = 1,
      String? errorText,
      String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: errorText != null ? AppColors.pomegranate : AppColors.muted)),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          keyboardType: keyboard,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          maxLines: maxLines,
          minLines: 1,
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            errorText: errorText,
            hintText: hintText,
            hintStyle: AppFonts.body(fontSize: 12.5, color: AppColors.hintText),
          ),
        ),
      ],
    );
  }

  Widget _qtyBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: AppColors.cloud, borderRadius: BorderRadius.circular(9)),
          alignment: Alignment.center,
          child: Text(label, style: AppFonts.body(fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      );
}

/// A tiny "type a value" dialog that owns its text controller and disposes it in
/// its own [dispose] — the correct lifecycle for a dialog text field. Returns the
/// trimmed text via Navigator.pop, or null if empty / cancelled.
class _VariantPromptDialog extends StatefulWidget {
  final String initial;
  const _VariantPromptDialog({required this.initial});

  @override
  State<_VariantPromptDialog> createState() => _VariantPromptDialogState();
}

class _VariantPromptDialogState extends State<_VariantPromptDialog> {
  late final TextEditingController _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _c.text.trim();
    Navigator.pop(context, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final m = MaterialLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: TextField(
        controller: _c,
        autofocus: true,
        style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(isDense: true),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(m.cancelButtonLabel,
              style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(m.okButtonLabel,
              style: AppFonts.body(
                  fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.pomegranate)),
        ),
      ],
    );
  }
}

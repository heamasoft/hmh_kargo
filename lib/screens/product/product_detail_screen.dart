import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/format.dart';
import '../../utils/launcher.dart';
import '../../widgets/back_chip.dart';
import '../../widgets/fav_button.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/product_image.dart';
import '../../providers/shell_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? _color;
  int? _size;
  bool _error = false;

  Product get p => widget.product;

  bool _adding = false;

  Future<void> _addToCart() async {
    if (_adding) return;
    final l = AppLocalizations.of(context);
    if (_color == null || _size == null) {
      setState(() => _error = true);
      return;
    }
    final colorName = p.colors[_color!].name;
    final size = p.sizes[_size!];
    setState(() => _adding = true);
    final ok = await context.read<CartProvider>().addProduct(p, color: colorName, size: size);
    if (!mounted) return;
    setState(() => _adding = false);
    if (!ok) {
      final msg = context.read<CartProvider>().error ?? 'Could not add to cart.';
      showHeamaToast(context, msg);
      return;
    }
    showHeamaToast(context, l.addedToCart('$colorName $size'));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.popUntil(context, (r) => r.isFirst);
      context.read<ShellController>().goToTab(2);
    });
  }

  String _capText(AppLocalizations l) {
    if (!_error) return l.detectedProduct;
    if (_color == null && _size == null) return l.chooseColorAndSize;
    if (_color == null) return l.chooseColorFirst;
    return l.chooseSizeFirst;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colorMissing = _error && _color == null;
    final sizeMissing = _error && _size == null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // browser bar
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => openUrl('https://www.shein.com'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.cloud,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 12, color: AppColors.green),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text('shein.com/…-p-30421185.html',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.refresh, size: 18, color: AppColors.ink),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // image
                  SizedBox(
                    height: 340,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImage(url: p.imageUrl, gradient: p.gradient),
                        PositionedDirectional(
                          start: 14,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(p.store.toUpperCase(),
                                style: AppFonts.display(
                                    fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
                          ),
                        ),
                        PositionedDirectional(
                          end: 14,
                          top: 14,
                          child: FavButton(product: p, size: 38),
                        ),
                      ],
                    ),
                  ),
                  // title + rating + price
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            style: AppFonts.body(
                                fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.35)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('★★★★★',
                                style: TextStyle(color: AppColors.saffron, fontSize: 12)),
                            const SizedBox(width: 6),
                            Text('${p.rating}',
                                style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('  ·  ${l.reviewsCount(p.reviews)}  ·  ${l.soldCount}',
                                style: AppFonts.body(fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(p.usd,
                                style: AppFonts.display(fontSize: 24, color: Colors.black)),
                            const SizedBox(width: 9),
                            Text(p.oldUsd,
                                style: AppFonts.body(
                                    fontSize: 13,
                                    color: AppColors.muted,
                                    decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 9),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.pomTintChip,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(l.sale,
                                  style: AppFonts.body(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.pomegranate)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // colour
                  _optionHeader(l.colour, required: true, picked: _color != null
                      ? p.colors[_color!].name
                      : null),
                  _ShakeOnError(
                    shake: colorMissing,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: List.generate(p.colors.length, (i) {
                          final sel = _color == i;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _color = i;
                              _error = false;
                            }),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: p.colors[i].color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: sel ? AppColors.ink : AppColors.line,
                                    spreadRadius: sel ? 2 : 1.5,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // size
                  _optionHeader(l.size, required: true, picked: _size != null
                      ? '${l.size} ${p.sizes[_size!]}'
                      : null),
                  _ShakeOnError(
                    shake: sizeMissing,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: List.generate(p.sizes.length, (i) {
                          final sel = _size == i;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _size = i;
                              _error = false;
                            }),
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 42),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sel ? AppColors.ink : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: sel ? AppColors.ink : AppColors.line),
                              ),
                              child: Text(
                                p.sizes[i],
                                style: AppFonts.body(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  // delivery
                  _optionHeader(l.deliveryToIraq),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                    child: Text(l.deliveryInfo,
                        style: AppFonts.body(fontSize: 12, color: AppColors.muted, height: 1.5)),
                  ),
                ],
              ),
            ),
            _captureBar(l),
          ],
        ),
      ),
    );
  }

  Widget _optionHeader(String title, {bool required = false, String? picked}) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 9),
      child: Row(
        children: [
          Text(title.toUpperCase(),
              style: AppFonts.body(
                  fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          if (required)
            Text(' *',
                style: AppFonts.body(
                    fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.pomegranate)),
          const Spacer(),
          if (required)
            picked == null
                ? Text(l.required,
                    style: AppFonts.body(fontSize: 11, color: AppColors.muted))
                : Text(picked,
                    style: AppFonts.body(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
        ],
      ),
    );
  }

  Widget _captureBar(AppLocalizations l) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [BoxShadow(color: Color(0x22211B3E), blurRadius: 18, offset: Offset(0, -6))],
      ),
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 14),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _error ? AppColors.pomegranate : AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _capText(l),
                    style: AppFonts.body(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: _error ? AppColors.pomegranate : AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.allInDinars,
                        style: AppFonts.body(
                            fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                    Text.rich(
                      TextSpan(
                        text: '${formatIqd(p.priceIqd)} ',
                        style: AppFonts.display(fontSize: 19),
                        children: [
                          TextSpan(
                            text: l.iqd,
                            style: AppFonts.body(
                                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _addToCart,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.pomegranate,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(l.addToCart,
                              style: AppFonts.body(
                                  fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Briefly shakes its child horizontally when [shake] flips to true.
class _ShakeOnError extends StatefulWidget {
  final bool shake;
  final Widget child;
  const _ShakeOnError({required this.shake, required this.child});

  @override
  State<_ShakeOnError> createState() => _ShakeOnErrorState();
}

class _ShakeOnErrorState extends State<_ShakeOnError> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  @override
  void didUpdateWidget(covariant _ShakeOnError old) {
    super.didUpdateWidget(old);
    if (widget.shake && !old.shake) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final dx = (_c.value == 0) ? 0.0 : 5 * (1 - _c.value) * _sinLike(_c.value);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }

  // cheap oscillation without importing dart:math into the widget tree
  double _sinLike(double t) {
    final x = (t * 4) % 2;
    return x < 1 ? (1 - 2 * x) : (2 * x - 3);
  }
}

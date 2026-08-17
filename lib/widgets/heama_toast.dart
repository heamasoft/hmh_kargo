import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

// The currently-visible toast's remover, so a new toast replaces the old one.
VoidCallback? _dismissCurrent;

/// Shows the dark rounded confirmation pill at the TOP of the app (over any
/// sheet/dialog). Auto-dismisses; a new toast replaces the current one.
void showHeamaToast(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _dismissCurrent?.call();

  late final OverlayEntry entry;
  var removed = false;
  void remove() {
    if (removed) return;
    removed = true;
    entry.remove();
    if (_dismissCurrent == remove) _dismissCurrent = null;
  }

  entry = OverlayEntry(builder: (_) => _HeamaToast(message: message, onDismiss: remove));
  _dismissCurrent = remove;
  overlay.insert(entry);
}

class _HeamaToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;
  const _HeamaToast({required this.message, required this.onDismiss});

  @override
  State<_HeamaToast> createState() => _HeamaToastState();
}

class _HeamaToastState extends State<_HeamaToast> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Timer? _hold;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _hold = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;
      await _c.reverse();
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _hold?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          child: Align(
            alignment: Alignment.topCenter,
            child: FadeTransition(
              opacity: _c,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.35), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 16, color: Color(0xFF7CE0AE)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: AppFonts.body(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

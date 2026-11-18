import 'package:flutter/material.dart';

/// Slides [child] up into place and fades it in, [delay] after it first
/// appears. Home and Shop use it to bring their sections in one after another.
class RiseIn extends StatefulWidget {
  const RiseIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  /// The gap between one section and the next.
  static const step = Duration(milliseconds: 70);

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(offset: Offset(0, 18 * (1 - _t.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

/// A band of light that sweeps across [child] every few seconds — on the
/// main Paste button, to draw the eye to it.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child, this.radius = 13});

  final Widget child;
  final double radius;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  // Sweeps in the first 60% of the cycle, then rests.
                  final p = (_c.value / 0.6).clamp(0.0, 1.0);
                  return FractionalTranslation(
                    translation: Offset(-1.2 + 3.2 * p, 0),
                    child: FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: 0.3,
                      child: Transform(
                        transform: Matrix4.skewX(-0.35),
                        child: Container(color: Colors.white.withValues(alpha: 0.28)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

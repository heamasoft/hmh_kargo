import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Modern light splash shown while the saved session is being restored. A soft
/// white→blue gradient, a glowing logo that scales in, the wordmark rising
/// underneath, and a smooth blue spinner.
class HeamaSplash extends StatefulWidget {
  const HeamaSplash({super.key});

  @override
  State<HeamaSplash> createState() => _HeamaSplashState();
}

// Modern blue accent for the light splash.
const Color _blue = Color(0xFF2E6BE6);

class _HeamaSplashState extends State<HeamaSplash> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1150),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _in.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFEAF2FF), Color(0xFFD6E6FF)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _logo(),
                    const SizedBox(height: 28),
                    _wordmark(l),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 46,
                child: Center(child: _loader()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logo in a white card with a pulsing blue glow, scaling + fading in.
  Widget _logo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_in, _loop]),
      builder: (_, __) {
        final e = _in.value.clamp(0.0, 1.0);
        final fade = Curves.easeOut.transform(e);
        final scale = 0.72 + 0.28 * Curves.easeOutBack.transform(e);
        final breathe = (0.5 - (0.5 - _loop.value).abs()) * 2; // triangle wave
        return Opacity(
          opacity: fade,
          child: Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 172,
                  height: 172,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _blue.withValues(alpha: 0.22 * (0.55 + 0.45 * breathe) * fade),
                        _blue.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: _blue.withValues(alpha: 0.10)),
                    boxShadow: [
                      BoxShadow(
                        color: _blue.withValues(alpha: 0.20 * fade),
                        blurRadius: 34,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Image.asset('assets/logo/hmh_kargo_emblem.png',
                      width: 76, height: 76),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // "Heama" + tagline, rising and fading in slightly after the logo.
  Widget _wordmark(AppLocalizations l) {
    return AnimatedBuilder(
      animation: _in,
      builder: (_, child) {
        final v = Curves.easeOut.transform(((_in.value - 0.3) / 0.7).clamp(0.0, 1.0));
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 16), child: child),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('HMH KARGO',
                  style: AppFonts.display(fontSize: 32, color: AppColors.ink, letterSpacing: 1.0)),
            ),
          ),
          const SizedBox(height: 7),
          Text(l.welcomeTitleLine2,
              style: AppFonts.body(
                  fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.muted)),
        ],
      ),
    );
  }

  // A smooth rotating blue arc — the loading animation.
  Widget _loader() {
    return AnimatedBuilder(
      animation: _loop,
      builder: (_, __) {
        return Transform.rotate(
          angle: _loop.value * 2 * math.pi,
          child: CustomPaint(size: const Size(30, 30), painter: _SpinnerPainter()),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 2.5;
    // Faint full track.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = _blue.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    // Bright sweeping arc.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 0.6,
      false,
      Paint()
        ..color = _blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

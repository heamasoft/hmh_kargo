import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Heama monogram: a rounded midnight tile with a dashed saffron arc,
/// a pomegranate dot and a small white box — a shopping bag over a route.
class HeamaLogo extends StatelessWidget {
  final double size;
  const HeamaLogo({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40; // design is a 40x40 grid
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(12 * s),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.midnight700);

    // Dashed arc across the middle.
    final arc = Paint()
      ..color = AppColors.saffron
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(9 * s, 25 * s);
    path.quadraticBezierTo(20 * s, 16 * s, 31 * s, 25 * s);
    _drawDashed(canvas, path, arc, dash: 1 * s, gap: 4 * s);

    // Pomegranate dot.
    canvas.drawCircle(
      Offset(20 * s, 14 * s),
      4.3 * s,
      Paint()..color = AppColors.pomegranate,
    );

    // Small white box (the parcel).
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(15.5 * s, 24.5 * s, 9 * s, 7 * s),
      Radius.circular(1.6 * s),
    );
    canvas.drawRRect(box, Paint()..color = AppColors.white);
  }

  void _drawDashed(Canvas canvas, Path source, Paint paint,
      {required double dash, required double gap}) {
    for (final metric in source.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = dist + dash;
        canvas.drawPath(
          metric.extractPath(dist, next.clamp(0, metric.length)),
          paint,
        );
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

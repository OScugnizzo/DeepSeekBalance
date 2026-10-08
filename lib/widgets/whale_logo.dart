import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small, friendly whale mark used as the app's logo.
///
/// Drawn with a [CustomPainter] so it stays crisp at any size and visually
/// matches the generated launcher icon.
class WhaleLogo extends StatelessWidget {
  const WhaleLogo({
    super.key,
    this.size = 44,
    this.background = true,
  });

  final double size;
  final bool background;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.3),
          gradient: background
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.brand, AppColors.brandDeep],
                )
              : null,
          boxShadow: background
              ? [
                  BoxShadow(
                    color: AppColors.brand.withValues(alpha: isDark ? 0.45 : 0.3),
                    blurRadius: size * 0.35,
                    offset: Offset(0, size * 0.12),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(background ? size * 0.1 : 0),
          child: CustomPaint(
            painter: _WhalePainter(
              body: Colors.white,
              detail: const Color(0xFF16213E),
              spout: const Color(0xFFBFD0FF),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhalePainter extends CustomPainter {
  _WhalePainter({
    required this.body,
    required this.detail,
    required this.spout,
  });

  final Color body;
  final Color detail;
  final Color spout;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = s * 0.46;
    final cy = s * 0.58;
    final r = s * 0.3;

    final bodyPaint = Paint()..color = body;
    final detailPaint = Paint()
      ..color = detail
      ..style = PaintingStyle.fill;

    // Tail fluke.
    final tail = Path()
      ..moveTo(cx + r * 0.7, cy - r * 0.12)
      ..quadraticBezierTo(cx + r * 1.62, cy - r * 1.15, cx + r * 1.95, cy - r * 0.5)
      ..quadraticBezierTo(cx + r * 1.5, cy, cx + r * 1.95, cy + r * 0.5)
      ..quadraticBezierTo(cx + r * 1.62, cy + r * 1.15, cx + r * 0.7, cy + r * 0.12)
      ..close();
    canvas.drawPath(tail, bodyPaint);

    // Body.
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // Water spout.
    final spoutPaint = Paint()..color = spout;
    canvas.drawCircle(Offset(cx - r * 0.05, cy - r * 1.5), r * 0.14, spoutPaint);
    canvas.drawCircle(Offset(cx - r * 0.42, cy - r * 1.72), r * 0.1, spoutPaint);
    canvas.drawCircle(Offset(cx + r * 0.32, cy - r * 1.72), r * 0.1, spoutPaint);

    // Eye.
    canvas.drawCircle(
      Offset(cx - r * 0.38, cy - r * 0.18),
      r * 0.11,
      detailPaint,
    );
    canvas.drawCircle(
      Offset(cx - r * 0.42, cy - r * 0.24),
      r * 0.035,
      Paint()..color = Colors.white,
    );

    // Smile.
    final smile = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(cx - r * 0.18, cy + r * 0.02),
          radius: r * 0.42,
        ),
        math.pi * 0.18,
        math.pi * 0.64,
      );
    canvas.drawPath(
      smile,
      Paint()
        ..color = detail
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.09
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_WhalePainter oldDelegate) =>
      oldDelegate.body != body ||
      oldDelegate.detail != detail ||
      oldDelegate.spout != spout;
}

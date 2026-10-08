import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

/// Brand-colored spinner: a rotating gradient arc with a soft counter-rotating
/// halo. Used for both the initial load and manual refreshes.
class BrandLoader extends StatefulWidget {
  const BrandLoader({super.key, this.size = 46});

  final double size;

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _BrandLoaderPainter(_controller.value),
        ),
      ),
    );
  }
}

class _BrandLoaderPainter extends CustomPainter {
  _BrandLoaderPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final stroke = maxRadius * 0.26;

    // Soft halo.
    canvas.drawCircle(
      center,
      maxRadius - stroke / 2,
      Paint()
        ..color = AppColors.brand.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: const [
        AppColors.brandDeep,
        AppColors.brand,
        Color(0xFF8FA4FF),
        Color(0x004D6BFE),
      ],
      stops: const [0.0, 0.35, 0.7, 1.0],
      transform: GradientRotation(progress * math.pi * 2),
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: maxRadius - stroke / 2,
    );
    canvas.drawArc(
      rect,
      progress * math.pi * 2,
      math.pi * 1.35,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_BrandLoaderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Convenience for haptic micro-interactions, guarded for platform support.
void lightImpact() {
  HapticFeedback.lightImpact().catchError((_) {});
}

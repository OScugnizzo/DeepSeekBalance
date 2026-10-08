import 'package:flutter/material.dart';

import '../services/peak_hours_service.dart';
import '../theme/app_theme.dart';

/// Color-coded pill that communicates DeepSeek's current traffic window.
///
/// Red = peak (higher usage / latency), Green = off-peak.
class TrafficIndicator extends StatelessWidget {
  const TrafficIndicator({
    super.key,
    required this.traffic,
    this.compact = false,
  });

  final TrafficStatus traffic;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = traffic.isPeak ? AppColors.peak : AppColors.offPeak;
    final label = traffic.isPeak ? 'Peak' : 'Off-Peak';
    final nextSwitch = traffic.nextSwitchLabel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: color, size: compact ? 8 : 9),
          SizedBox(width: compact ? 6 : 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 12 : 13,
                  letterSpacing: 0.2,
                ),
              ),
              if (compact)
                Text(
                  nextSwitch,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = (t < 0.5 ? t : 1 - t) * 2; // 0 -> 1 -> 0
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + pulse * 0.9,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: 0.35 * (1 - pulse)),
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

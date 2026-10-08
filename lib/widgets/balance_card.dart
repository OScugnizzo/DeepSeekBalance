import 'package:flutter/material.dart';

import '../models/balance_response.dart';
import '../services/peak_hours_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'traffic_indicator.dart';

/// The hero component: a rounded, softly-tinted card showing total balance,
/// account status and the live traffic window.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.traffic,
    required this.isLoading,
    this.lastUpdated,
  });

  final BalanceResponse? balance;
  final TrafficStatus traffic;
  final bool isLoading;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final info = balance?.primary;
    final available = balance?.isAvailable ?? false;
    final hasData = info != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1B2136), const Color(0xFF12151E)]
              : [Colors.white, const Color(0xFFF0F3FF)],
        ),
        border: Border.all(color: context.cardOutline),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: isDark ? 0.10 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -18,
            child: Opacity(
              opacity: isDark ? 0.06 : 0.05,
              child: const Icon(
                Icons.water_rounded,
                size: 128,
                color: AppColors.brand,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'TOTAL BALANCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: context.mutedText,
                      ),
                    ),
                  ),
                  TrafficIndicator(traffic: traffic, compact: true),
                ],
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: isLoading && !hasData
                    ? const _BalanceSkeleton(key: ValueKey('skeleton'))
                    : _AnimatedMoney(
                        key: const ValueKey('money'),
                        value: info?.totalBalance ?? 0,
                        currency: info?.currency ?? 'USD',
                        dimmed: !hasData,
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _AvailabilityBadge(available: available && hasData),
                  const Spacer(),
                  if (lastUpdated != null)
                    Text(
                      'Updated ${_formatTime(lastUpdated!)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.mutedText,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.offPeak : AppColors.peak;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            available ? 'Active' : 'Unavailable',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMoney extends StatelessWidget {
  const _AnimatedMoney({
    super.key,
    required this.value,
    required this.currency,
    required this.dimmed,
  });

  final double value;
  final String currency;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width;
    final fontSize = size < 360 ? 34.0 : 40.0;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text(
          dimmed ? '—' : formatCurrency(animated, currency),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
            color: dimmed
                ? context.mutedText
                : Theme.of(context).colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 40,
      decoration: BoxDecoration(
        color: context.cardOutline.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

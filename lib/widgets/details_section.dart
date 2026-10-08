import 'package:flutter/material.dart';

import '../models/balance_response.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

/// Breakdown of the account balance (topped-up vs. granted).
class DetailsSection extends StatelessWidget {
  const DetailsSection({super.key, required this.balance, required this.isLoading});

  final BalanceResponse? balance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final infos = balance?.balanceInfos ?? const [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: context.cardOutline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (infos.isEmpty)
            ..._placeholderRows(context)
          else
            for (var i = 0; i < infos.length; i++) ...[
              _DetailRow(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Topped-up',
                value: formatCurrency(
                  infos[i].toppedUpBalance,
                  infos[i].currency,
                ),
                badge: infos.length > 1 ? infos[i].currency : null,
              ),
              Divider(height: 1, color: context.cardOutline),
              _DetailRow(
                icon: Icons.redeem_rounded,
                label: 'Granted / Bonus',
                value: formatCurrency(
                  infos[i].grantedBalance,
                  infos[i].currency,
                ),
                badge: infos.length > 1 ? infos[i].currency : null,
              ),
            ],
        ],
      ),
    );
  }

  List<Widget> _placeholderRows(BuildContext context) {
    return [
      _DetailRow(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Topped-up',
        value: isLoading ? '•••' : '—',
      ),
      Divider(height: 1, color: context.cardOutline),
      const _DetailRow(
        icon: Icons.redeem_rounded,
        label: 'Granted / Bonus',
        value: '—',
      ),
    ];
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.brandSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: AppColors.brand),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.brandSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brand,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:meta/meta.dart';

import 'balance_info.dart';

/// Response model for `GET https://api.deepseek.com/user/balance`.
@immutable
class BalanceResponse {
  const BalanceResponse({
    required this.isAvailable,
    required this.balanceInfos,
  });

  final bool isAvailable;
  final List<BalanceInfo> balanceInfos;

  /// The DeepSeek account is considered usable when the API reports it as
  /// available and at least one currency entry was returned.
  bool get hasBalance => balanceInfos.isNotEmpty;

  /// Primary entry promoted to the big balance card. Prefers a positive
  /// balance, otherwise falls back to the first available entry.
  BalanceInfo? get primary {
    if (balanceInfos.isEmpty) return null;
    return balanceInfos.firstWhere(
      (info) => info.totalBalance > 0,
      orElse: () => balanceInfos.first,
    );
  }

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    final rawInfos = json['balance_infos'];
    final infos = <BalanceInfo>[];
    if (rawInfos is List) {
      for (final entry in rawInfos) {
        if (entry is Map<String, dynamic>) {
          infos.add(BalanceInfo.fromJson(entry));
        }
      }
    }
    return BalanceResponse(
      isAvailable: json['is_available'] as bool? ?? false,
      balanceInfos: List.unmodifiable(infos),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'is_available': isAvailable,
    'balance_infos': balanceInfos.map((info) => info.toJson()).toList(),
  };
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'balance_history.freezed.dart';
part 'balance_history.g.dart';

@freezed
sealed class BalanceHistory with _$BalanceHistory {
  const factory BalanceHistory({
    required DateTime date,
    required double balance,
    String? walletId, // null = Net Worth, has value = specific wallet
  }) = _BalanceHistory;

  factory BalanceHistory.fromJson(Map<String, dynamic> json) =>
      _$BalanceHistoryFromJson(json);
}

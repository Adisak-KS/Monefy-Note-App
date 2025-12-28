// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'balance_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BalanceHistory _$BalanceHistoryFromJson(Map<String, dynamic> json) =>
    _BalanceHistory(
      date: DateTime.parse(json['date'] as String),
      balance: (json['balance'] as num).toDouble(),
      walletId: json['walletId'] as String?,
    );

Map<String, dynamic> _$BalanceHistoryToJson(_BalanceHistory instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'balance': instance.balance,
      'walletId': instance.walletId,
    };

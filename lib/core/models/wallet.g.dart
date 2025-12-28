// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$WalletTypeEnumMap, json['type']),
  balance: (json['balance'] as num?)?.toDouble() ?? 0,
  currency: json['currency'] as String? ?? 'THB',
  icon: json['icon'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$WalletTypeEnumMap[instance.type]!,
  'balance': instance.balance,
  'currency': instance.currency,
  'icon': instance.icon,
  'color': instance.color,
};

const _$WalletTypeEnumMap = {
  WalletType.cash: 'cash',
  WalletType.bank: 'bank',
  WalletType.creditCard: 'creditCard',
  WalletType.eWallet: 'eWallet',
  WalletType.debt: 'debt',
};

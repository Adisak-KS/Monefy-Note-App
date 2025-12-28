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
  includeInTotal: json['includeInTotal'] as bool? ?? true,
  isArchived: json['isArchived'] as bool? ?? false,
  icon: json['icon'] as String?,
  color: json['color'] as String?,
  iconCodePoint: (json['iconCodePoint'] as num?)?.toInt(),
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$WalletTypeEnumMap[instance.type]!,
  'balance': instance.balance,
  'currency': instance.currency,
  'includeInTotal': instance.includeInTotal,
  'isArchived': instance.isArchived,
  'icon': instance.icon,
  'color': instance.color,
  'iconCodePoint': instance.iconCodePoint,
};

const _$WalletTypeEnumMap = {
  WalletType.cash: 'cash',
  WalletType.bank: 'bank',
  WalletType.creditCard: 'creditCard',
  WalletType.eWallet: 'eWallet',
  WalletType.investment: 'investment',
  WalletType.debt: 'debt',
  WalletType.crypto: 'crypto',
  WalletType.savings: 'savings',
  WalletType.loan: 'loan',
  WalletType.insurance: 'insurance',
  WalletType.gold: 'gold',
};

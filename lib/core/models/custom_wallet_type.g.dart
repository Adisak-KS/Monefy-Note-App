// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_wallet_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CustomWalletType _$CustomWalletTypeFromJson(Map<String, dynamic> json) =>
    _CustomWalletType(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      isLiability: json['isLiability'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CustomWalletTypeToJson(_CustomWalletType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'isLiability': instance.isLiability,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

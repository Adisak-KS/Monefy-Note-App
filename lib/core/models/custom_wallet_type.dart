import 'package:freezed_annotation/freezed_annotation.dart';

part 'custom_wallet_type.freezed.dart';
part 'custom_wallet_type.g.dart';

@freezed
sealed class CustomWalletType with _$CustomWalletType {
  const factory CustomWalletType({
    required String id,
    required String name,
    required String iconName,
    required String colorHex,
    @Default(false) bool isLiability,
    DateTime? createdAt,
  }) = _CustomWalletType;

  factory CustomWalletType.fromJson(Map<String, dynamic> json) =>
      _$CustomWalletTypeFromJson(json);
}

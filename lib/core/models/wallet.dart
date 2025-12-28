import 'package:freezed_annotation/freezed_annotation.dart';
import 'wallet_type.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
sealed class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required String name,
    required WalletType type,
    @Default(0) double balance,
    @Default('THB') String currency,
    @Default(true) bool includeInTotal,
    @Default(false) bool isArchived,
    String? icon,
    String? color,
    int? iconCodePoint, // Custom icon code point, null = use WalletType default icon
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

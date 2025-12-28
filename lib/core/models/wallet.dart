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
    String? icon,
    String? color,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'category.dart';
import 'transaction_type.dart';
import 'wallet.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

@freezed
sealed class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required TransactionType type,
    required double amount,
    required DateTime date,
    required String categoryId,
    required String walletId,
    String? description,
    Category? category,
    Wallet? wallet,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
}

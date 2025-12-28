import 'package:flutter/material.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import 'transaction_tile.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Function(String id)? onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = transactions[index];
          final category = categories.where((c) => c.id == transaction.categoryId).firstOrNull;

          return TransactionTile(
            transaction: transaction,
            category: category,
            onDelete: () => onDelete?.call(transaction.id),
          );
        },
        childCount: transactions.length,
      ),
    );
  }
}

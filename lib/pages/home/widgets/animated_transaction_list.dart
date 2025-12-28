import 'package:flutter/material.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import 'transaction_tile.dart';

class AnimatedTransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final List<Category> categories;
  final Function(String id)? onDelete;
  final Function(Transaction transaction)? onEdit;

  const AnimatedTransactionList({
    super.key,
    required this.transactions,
    required this.categories,
    this.onDelete,
    this.onEdit,
  });

  @override
  State<AnimatedTransactionList> createState() => _AnimatedTransactionListState();
}

class _AnimatedTransactionListState extends State<AnimatedTransactionList> {
  final GlobalKey<SliverAnimatedListState> _listKey = GlobalKey<SliverAnimatedListState>();
  late List<Transaction> _currentList;

  @override
  void initState() {
    super.initState();
    _currentList = List.from(widget.transactions);
  }

  @override
  void didUpdateWidget(AnimatedTransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateList(oldWidget.transactions, widget.transactions);
  }

  void _updateList(List<Transaction> oldList, List<Transaction> newList) {
    final oldIds = oldList.map((t) => t.id).toSet();
    final newIds = newList.map((t) => t.id).toSet();

    // Find added items (in new but not in old)
    final addedIds = newIds.difference(oldIds);
    // Find removed items (in old but not in new)
    final removedIds = oldIds.difference(newIds);

    // Handle removals first
    for (final id in removedIds) {
      final index = _currentList.indexWhere((t) => t.id == id);
      if (index != -1) {
        final removedItem = _currentList.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
          (context, animation) => _buildRemovedItem(removedItem, animation),
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    // Handle additions
    for (final id in addedIds) {
      final newItem = newList.firstWhere((t) => t.id == id);
      // Insert at the beginning (newest first)
      _currentList.insert(0, newItem);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 300));
    }

    // Update order if needed (when items are reordered but not added/removed)
    if (addedIds.isEmpty && removedIds.isEmpty) {
      _currentList = List.from(newList);
    }
  }

  Widget _buildRemovedItem(Transaction transaction, Animation<double> animation) {
    final category = widget.categories.where((c) => c.id == transaction.categoryId).firstOrNull;

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: TransactionTile(
          transaction: transaction,
          category: category,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: _listKey,
      initialItemCount: _currentList.length,
      itemBuilder: (context, index, animation) {
        if (index >= _currentList.length) return const SizedBox.shrink();

        final transaction = _currentList[index];
        final category = widget.categories.where((c) => c.id == transaction.categoryId).firstOrNull;

        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: TransactionTile(
                transaction: transaction,
                category: category,
                onTap: () => widget.onEdit?.call(transaction),
                onDelete: () => widget.onDelete?.call(transaction.id),
              ),
            ),
          ),
        );
      },
    );
  }
}

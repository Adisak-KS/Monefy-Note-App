import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/models/wallet.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'custom_date_picker.dart';

class AddTransactionSheet extends StatefulWidget {
  final Transaction? existingTransaction;

  const AddTransactionSheet({super.key, this.existingTransaction});

  bool get isEditMode => existingTransaction != null;

  static Future<void> show(BuildContext context, {Transaction? transaction}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: AddTransactionSheet(existingTransaction: transaction),
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  TransactionType _type = TransactionType.expense;
  Category? _selectedCategory;
  Wallet? _selectedWallet;
  DateTime _selectedDate = DateTime.now();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTransaction;
    if (existing != null) {
      _type = existing.type;
      _amountController.text = existing.amount.toString();
      _descriptionController.text = existing.description ?? '';
      _selectedDate = existing.date;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<HomeCubit>().state;
      if (state is HomeLoaded) {
        setState(() {
          if (existing != null) {
            _selectedWallet = state.wallets.firstWhere(
              (w) => w.id == existing.walletId,
              orElse: () => state.wallets.first,
            );
            _selectedCategory = state.categories.firstWhere(
              (c) => c.id == existing.categoryId,
              orElse: () => state.categories.first,
            );
          } else if (state.wallets.isNotEmpty) {
            _selectedWallet = state.wallets.first;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 50),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              _buildHeader(theme),
              _buildTypeToggle(theme),
              _buildAmountField(theme),
              _buildDateSelector(theme),
              _buildWalletSelector(theme),
              _buildCategorySelector(theme),
              _buildDescriptionField(theme),
              _buildSaveButton(theme),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.isEditMode ? 'home.edit_transaction'.tr() : 'home.add_transaction'.tr(),
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTypeToggle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<TransactionType>(
        segments: [
          ButtonSegment(
            value: TransactionType.expense,
            label: Text('home.expense'.tr()),
            icon: const Icon(Icons.arrow_upward),
          ),
          ButtonSegment(
            value: TransactionType.income,
            label: Text('home.income'.tr()),
            icon: const Icon(Icons.arrow_downward),
          ),
        ],
        selected: {_type},
        onSelectionChanged: (selected) {
          setState(() {
            _type = selected.first;
            _selectedCategory = null;
          });
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0.00',
          prefixText: '฿ ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'home.date'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      isToday
                          ? 'home.today'.tr()
                          : DateFormat('EEE, d MMM yyyy', context.locale.toString()).format(_selectedDate),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletSelector(ThemeData theme) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded || state.wallets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'home.wallet'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.wallets.length,
                  itemBuilder: (context, index) {
                    final wallet = state.wallets[index];
                    final isSelected = _selectedWallet?.id == wallet.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(wallet.name),
                        avatar: Icon(_getWalletIcon(wallet.type.name), size: 18),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedWallet = wallet);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        final categories = state.categories.where((c) => c.type == _type).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 8),
                child: Text(
                  'home.category'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategory?.id == category.id;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = category);
                          HapticFeedback.selectionClick();
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          hintText: 'home.note'.tr(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.notes),
        ),
        maxLines: 1,
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: _save,
          child: Text('common.save'.tr()),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await CustomDatePicker.show(
      context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  IconData _getWalletIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments;
      case 'bank':
        return Icons.account_balance;
      case 'creditCard':
        return Icons.credit_card;
      case 'eWallet':
        return Icons.phone_android;
      case 'debt':
        return Icons.money_off;
      default:
        return Icons.wallet;
    }
  }

  void _save() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('home.error_amount'.tr())),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('home.error_category'.tr())),
      );
      return;
    }

    if (_selectedWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('home.error_wallet'.tr())),
      );
      return;
    }

    final description = _descriptionController.text.isNotEmpty
        ? _descriptionController.text
        : null;

    if (widget.isEditMode) {
      context.read<HomeCubit>().updateTransaction(
            id: widget.existingTransaction!.id,
            type: _type,
            amount: amount,
            categoryId: _selectedCategory!.id,
            walletId: _selectedWallet!.id,
            date: _selectedDate,
            description: description,
          );
    } else {
      context.read<HomeCubit>().addTransaction(
            type: _type,
            amount: amount,
            categoryId: _selectedCategory!.id,
            walletId: _selectedWallet!.id,
            date: _selectedDate,
            description: description,
          );
    }

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }
}

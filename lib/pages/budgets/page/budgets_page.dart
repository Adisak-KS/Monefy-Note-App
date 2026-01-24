import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/budget.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../injection.dart';
import '../../categories/bloc/category_cubit.dart';
import '../../categories/bloc/category_state.dart';
import '../bloc/budget_cubit.dart';
import '../bloc/budget_state.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_form_dialog.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BudgetCubit>()..loadBudgets()),
        BlocProvider(create: (_) => getIt<CategoryCubit>()..loadCategories()),
      ],
      child: const _BudgetsPageContent(),
    );
  }
}

class _BudgetsPageContent extends StatefulWidget {
  const _BudgetsPageContent();

  @override
  State<_BudgetsPageContent> createState() => _BudgetsPageContentState();
}

class _BudgetsPageContentState extends State<_BudgetsPageContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const PageGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildMonthSelector(context),
                Expanded(
                  child: BlocBuilder<BudgetCubit, BudgetState>(
                    builder: (context, state) {
                      if (state is BudgetLoading) {
                        return const _LoadingState();
                      }

                      if (state is BudgetError) {
                        return _ErrorState(message: state.message);
                      }

                      if (state is BudgetLoaded) {
                        return _buildBudgetList(context, state);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          return FloatingActionButton.extended(
            onPressed: () => _showAddBudgetDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: Text('budgets.add_budget'.tr()),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'budgets.title'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state is! BudgetLoaded) return const SizedBox.shrink();

        final monthName = _getMonthName(state.selectedMonth);
        final year = state.selectedYear;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<BudgetCubit>().previousMonth();
                },
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              GestureDetector(
                onTap: () => _showMonthPicker(context, state),
                child: Text(
                  '$monthName $year',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.read<BudgetCubit>().nextMonth();
                },
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetList(BuildContext context, BudgetLoaded state) {
    if (state.budgets.isEmpty) {
      return _EmptyState(onAdd: () => _showAddBudgetDialog(context));
    }

    return Column(
      children: [
        // Summary card
        _buildSummaryCard(context, state),
        // Budget list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.budgets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final budget = state.budgets[index];
              final category = state.categories
                  .where((c) => c.id == budget.categoryId)
                  .firstOrNull;

              return BudgetCard(
                budget: budget,
                category: category,
                onTap: () => _showEditBudgetDialog(context, budget, state),
                onDelete: () {
                  context.read<BudgetCubit>().deleteBudget(budget.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('budgets.deleted'.tr()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetLoaded state) {
    final theme = Theme.of(context);
    final totalBudget =
        state.budgets.fold<double>(0, (sum, b) => sum + b.amount);
    final totalSpent = state.budgets.fold<double>(0, (sum, b) => sum + b.spent);
    final remaining = totalBudget - totalSpent;
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                context,
                'budgets.total_budget'.tr(),
                '฿${totalBudget.toStringAsFixed(0)}',
                Colors.white,
              ),
              _buildSummaryItem(
                context,
                'budgets.spent'.tr(),
                '฿${totalSpent.toStringAsFixed(0)}',
                Colors.white70,
              ),
              _buildSummaryItem(
                context,
                'budgets.remaining'.tr(),
                '฿${remaining.toStringAsFixed(0)}',
                remaining >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                percentage > 1 ? Colors.redAccent : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}% ${'budgets.used'.tr()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final budgetCubit = context.read<BudgetCubit>();
    final categoryState = context.read<CategoryCubit>().state;

    if (categoryState is! CategoryLoaded) return;

    final budgetState = budgetCubit.state;
    final usedCategoryIds = budgetState is BudgetLoaded
        ? budgetState.budgets.map((b) => b.categoryId).toList()
        : <String>[];

    // Use expense categories for budgets
    final allCategories = [
      ...categoryState.expenseCategories,
      ...categoryState.incomeCategories,
    ];

    BudgetFormDialog.show(
      context,
      categories: allCategories,
      usedCategoryIds: usedCategoryIds,
      onSave: (categoryId, amount, note) {
        budgetCubit.addBudget(
          categoryId: categoryId,
          amount: amount,
          note: note,
        );
      },
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    Budget budget,
    BudgetLoaded state,
  ) {
    final budgetCubit = context.read<BudgetCubit>();
    final categoryState = context.read<CategoryCubit>().state;

    if (categoryState is! CategoryLoaded) return;

    final usedCategoryIds = state.budgets
        .where((b) => b.id != budget.id)
        .map((b) => b.categoryId)
        .toList();

    // Use expense categories for budgets
    final allCategories = [
      ...categoryState.expenseCategories,
      ...categoryState.incomeCategories,
    ];

    BudgetFormDialog.show(
      context,
      budget: budget,
      categories: allCategories,
      usedCategoryIds: usedCategoryIds,
      onSave: (categoryId, amount, note) {
        budgetCubit.updateBudget(
          budget.copyWith(
            categoryId: categoryId,
            amount: amount,
            note: note,
          ),
        );
      },
    );
  }

  void _showMonthPicker(BuildContext context, BudgetLoaded state) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'budgets.select_month'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == state.selectedMonth;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<BudgetCubit>().setMonth(month);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getMonthName(month, short: true),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month, {bool short = false}) {
    final months = short
        ? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        : ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'common.loading'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'common.error'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                context.read<BudgetCubit>().loadBudgets();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text('common.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'budgets.empty_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'budgets.empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: Text('budgets.add_first'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction_type.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../injection.dart';
import '../bloc/category_cubit.dart';
import '../bloc/category_state.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/category_list_item.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryCubit>()..loadCategories(),
      child: const _CategoriesPageContent(),
    );
  }
}

class _CategoriesPageContent extends StatefulWidget {
  const _CategoriesPageContent();

  @override
  State<_CategoriesPageContent> createState() => _CategoriesPageContentState();
}

class _CategoriesPageContentState extends State<_CategoriesPageContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final type = _tabController.index == 0
          ? TransactionType.expense
          : TransactionType.income;
      context.read<CategoryCubit>().switchTab(type);
    }
  }

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
                _buildTabBar(context),
                Expanded(
                  child: BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const _LoadingState();
                      }

                      if (state is CategoryError) {
                        return _ErrorState(message: state.message);
                      }

                      if (state is CategoryLoaded) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCategoryList(
                              context,
                              state.expenseCategories,
                              TransactionType.expense,
                            ),
                            _buildCategoryList(
                              context,
                              state.incomeCategories,
                              TransactionType.income,
                            ),
                          ],
                        );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text('categories.add'.tr()),
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
            'categories.title'.tr(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'categories.expense'.tr()),
          Tab(text: 'categories.income'.tr()),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<Category> categories,
    TransactionType type,
  ) {
    if (categories.isEmpty) {
      return _EmptyState(type: type);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryListItem(
          category: category,
          onTap: () => _showEditCategoryDialog(context, category),
          onEdit: () => _showEditCategoryDialog(context, category),
          onDelete: () {
            context.read<CategoryCubit>().deleteCategory(category.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('categories.deleted'.tr()),
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
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final cubit = context.read<CategoryCubit>();
    final state = cubit.state;
    final type = state is CategoryLoaded
        ? state.selectedTab
        : TransactionType.expense;

    CategoryFormDialog.show(
      context,
      defaultType: type,
      onSave: (name, icon, color) {
        cubit.addCategory(
          name: name,
          type: type,
          icon: icon,
          color: color,
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final cubit = context.read<CategoryCubit>();

    CategoryFormDialog.show(
      context,
      category: category,
      defaultType: category.type,
      onSave: (name, icon, color) {
        cubit.updateCategory(
          category.copyWith(
            name: name,
            icon: icon,
            color: color,
          ),
        );
      },
    );
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
                context.read<CategoryCubit>().loadCategories();
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
  final TransactionType type;

  const _EmptyState({required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = type == TransactionType.expense;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (isExpense ? Colors.red : Colors.green).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpense
                    ? Icons.remove_circle_outline_rounded
                    : Icons.add_circle_outline_rounded,
                size: 56,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'categories.empty_title'.tr(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'categories.empty_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

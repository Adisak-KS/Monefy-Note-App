import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../core/widgets/profile_drawer.dart';
import '../../../injection.dart';
import '../bloc/statistics_cubit.dart';
import '../bloc/statistics_state.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/overview_cards.dart';
import '../widgets/statistics_filter_selector.dart';
import '../widgets/statistics_header.dart';
import '../widgets/top_categories_list.dart';
import '../widgets/trend_bar_chart.dart';
import '../widgets/wallet_stats_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StatisticsCubit>()..loadStatistics(),
      child: const _StatisticsPageContent(),
    );
  }
}

class _StatisticsPageContent extends StatefulWidget {
  const _StatisticsPageContent();

  @override
  State<_StatisticsPageContent> createState() => _StatisticsPageContentState();
}

class _StatisticsPageContentState extends State<_StatisticsPageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      body: Stack(
        children: [
          const PageGradientBackground(),
          SafeArea(
            child: Column(
              children: [
                Builder(
                  builder: (context) => StatisticsHeader(
                    onMenuTap: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<StatisticsCubit, StatisticsState>(
                    builder: (context, state) {
                      if (state is StatisticsLoading) {
                        return const _LoadingState();
                      }

                      if (state is StatisticsError) {
                        return _ErrorState(message: state.message);
                      }

                      if (state is StatisticsLoaded) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: RefreshIndicator(
                            onRefresh: () => context
                                .read<StatisticsCubit>()
                                .loadStatistics(),
                            child: _buildContent(context, state),
                          ),
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
    );
  }

  Widget _buildContent(BuildContext context, StatisticsLoaded state) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Date Filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: StatisticsFilterSelector(
              selectedFilter: state.filterType,
              customDateRange: state.customDateRange,
              onFilterChanged: (filter, customRange) {
                context.read<StatisticsCubit>().changeFilter(
                      filter,
                      customRange: customRange,
                    );
              },
            ),
          ),
        ),
        // Overview Cards
        SliverToBoxAdapter(
          child: OverviewCards(
            totalIncome: state.totalIncome,
            totalExpense: state.totalExpense,
            balance: state.balance,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Trend Bar Chart
        SliverToBoxAdapter(
          child: TrendBarChart(
            data: state.dailyStatistics,
            title: 'statistics.daily_trend'.tr(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Expense Pie Chart
        SliverToBoxAdapter(
          child: CategoryPieChart(
            data: state.expenseByCategory,
            title: 'statistics.expense_by_category'.tr(),
            isExpense: true,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Income Pie Chart
        SliverToBoxAdapter(
          child: CategoryPieChart(
            data: state.incomeByCategory,
            title: 'statistics.income_by_category'.tr(),
            isExpense: false,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Top Expense Categories
        SliverToBoxAdapter(
          child: TopCategoriesList(
            data: state.expenseByCategory,
            title: 'statistics.top_expenses'.tr(),
            isExpense: true,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Wallet Statistics
        SliverToBoxAdapter(
          child: WalletStatsCard(data: state.walletStatistics),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
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
                context.read<StatisticsCubit>().loadStatistics();
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/transaction.dart';
import '../../../injection.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/add_transaction_fab.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/date_filter_selector.dart';
import '../widgets/empty_transaction_state.dart';
import '../widgets/expense_mini_chart.dart';
import '../widgets/home_header.dart';
import '../widgets/home_loading_shimmer.dart';
import '../widgets/quick_actions.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/section_header.dart';
import '../widgets/wallet_balance_row.dart';
import '../widgets/animated_transaction_list.dart';
import '../../../core/widgets/profile_drawer.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadTodayData(),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;
  double _lastScrollPosition = 0;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final currentPosition = _scrollController.position.pixels;
    final scrollDelta = currentPosition - _lastScrollPosition;

    // Only respond to significant scroll changes
    if (scrollDelta.abs() > 10) {
      final shouldShowFab = scrollDelta < 0 || currentPosition <= 0;
      if (_isFabVisible != shouldShowFab) {
        setState(() {
          _isFabVisible = shouldShowFab;
        });
      }
      _lastScrollPosition = currentPosition;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (previous, current) {
        if (previous is HomeLoaded && current is HomeLoaded) {
          return previous.recentlyDeletedTransaction == null &&
              current.recentlyDeletedTransaction != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is HomeLoaded && state.recentlyDeletedTransaction != null) {
          _showUndoSnackBar(context);
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop || _isDialogShowing) return;
          _isDialogShowing = true;

          final shouldExit = await showExitConfirmationDialog(context);

          _isDialogShowing = false;

          if (shouldExit) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          drawer: const ProfileDrawer(),
          body: Stack(
          children: [
            // Gradient Background
            const _GradientBackground(),
            // Content
            SafeArea(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const HomeLoadingShimmer();
                  }

                  if (state is HomeError) {
                    return Center(child: Text(state.message));
                  }

                  if (state is HomeLoaded) {
                    return RefreshIndicator(
                      onRefresh: () => context.read<HomeCubit>().loadTodayData(),
                      child: _buildContent(context, state),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
          floatingActionButton: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isFabVisible ? 1.0 : 0.0,
              child: const AddTransactionFab(),
            ),
          ),
        ),
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('home.transaction_deleted'.tr()),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'home.undo'.tr(),
          onPressed: () {
            context.read<HomeCubit>().undoDelete();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    final transactions = state.filteredTransactions;
    final hasTransactions = transactions.isNotEmpty;
    final hasNoSearchResults =
        state.isSearching && state.searchQuery.isNotEmpty && !hasTransactions;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: HomeHeader()),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        const SliverToBoxAdapter(child: SearchBarWidget()),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        const SliverToBoxAdapter(child: DateFilterSelector()),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: BalanceSummaryCard(
            totalIncome: state.totalIncome,
            totalExpense: state.totalExpense,
            balance: state.balance,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        const SliverToBoxAdapter(child: ExpenseMiniChart()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: WalletBalanceRow()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: QuickActions()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (hasTransactions)
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'home.recent_transactions'.tr(),
              onSeeAll: () {},
            ),
          ),
        if (hasTransactions) const SliverToBoxAdapter(child: SizedBox(height: 16)),
        if (hasNoSearchResults)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                'home.search_no_results'.tr(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ),
          )
        else if (!hasTransactions)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyTransactionState(),
          )
        else
          AnimatedTransactionList(
            transactions: transactions,
            categories: state.categories,
            onDelete: (id) => _confirmDelete(context, id),
            onEdit: (transaction) => _openEditSheet(context, transaction),
          ),
        if (hasTransactions)
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeleteConfirmationSheet(
        onCancel: () => Navigator.of(context).pop(false),
        onDelete: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.heavyImpact();
      context.read<HomeCubit>().deleteTransaction(id);
    }
  }

  void _openEditSheet(BuildContext context, Transaction transaction) {
    AddTransactionSheet.show(context, transaction: transaction);
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0D1117),
                  const Color(0xFF161B22),
                  const Color(0xFF0D1117),
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF1F5F9),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Large primary gradient blob - top right
          Positioned(
            top: -size.height * 0.15,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.8,
              height: size.width * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                          theme.colorScheme.primary.withValues(alpha: 0.05),
                          Colors.transparent,
                        ]
                      : [
                          theme.colorScheme.primary.withValues(alpha: 0.12),
                          theme.colorScheme.primary.withValues(alpha: 0.04),
                          Colors.transparent,
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Secondary gradient blob - left side
          Positioned(
            top: size.height * 0.25,
            left: -size.width * 0.4,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.secondary.withValues(alpha: 0.12),
                          theme.colorScheme.secondary.withValues(alpha: 0.04),
                          Colors.transparent,
                        ]
                      : [
                          theme.colorScheme.secondary.withValues(alpha: 0.10),
                          theme.colorScheme.secondary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Tertiary accent blob - bottom right
          Positioned(
            bottom: size.height * 0.1,
            right: -size.width * 0.2,
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          theme.colorScheme.tertiary.withValues(alpha: 0.10),
                          theme.colorScheme.tertiary.withValues(alpha: 0.03),
                          Colors.transparent,
                        ]
                      : [
                          theme.colorScheme.tertiary.withValues(alpha: 0.08),
                          theme.colorScheme.tertiary.withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Small floating accent - top left
          Positioned(
            top: size.height * 0.08,
            left: size.width * 0.1,
            child: Container(
              width: size.width * 0.25,
              height: size.width * 0.25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF7C3AED).withValues(alpha: 0.12),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFF7C3AED).withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          // Subtle mesh overlay for depth
          Positioned(
            bottom: size.height * 0.35,
            left: size.width * 0.3,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isDark
                      ? [
                          const Color(0xFF06B6D4).withValues(alpha: 0.08),
                          Colors.transparent,
                        ]
                      : [
                          const Color(0xFF06B6D4).withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
          // Soft glow accent - center right (for dark mode enhancement)
          if (isDark)
            Positioned(
              top: size.height * 0.45,
              right: size.width * 0.05,
              child: Container(
                width: size.width * 0.35,
                height: size.width * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF472B6).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          // Noise texture overlay for premium feel
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.01 : 0.02),
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.05 : 0.01),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmationSheet extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const _DeleteConfirmationSheet({
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Colors.red.shade600,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'home.delete_confirm_title'.tr(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'home.delete_confirm_message'.tr(),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onCancel();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('common.cancel'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onDelete();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('common.delete'.tr()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

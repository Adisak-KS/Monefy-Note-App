import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/wallet_type.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/delete_wallet_dialog.dart';
import '../../../core/widgets/page_gradient_background.dart';
import '../../../injection.dart';
import '../bloc/wallet_cubit.dart';
import '../bloc/wallet_state.dart';
import '../widgets/wallet_header.dart';
import '../widgets/balance_overview_card.dart';
import '../widgets/wallet_statistics_card.dart';
import '../widgets/wallet_list_tile.dart';
import '../widgets/wallet_group_header.dart';
import '../widgets/wallet_skeleton.dart';
import '../features/add_wallet/page/add_wallet_page.dart';
import '../features/add_wallet_type/page/add_wallet_type_page.dart';
import '../features/transfer/page/transfer_page.dart';
import '../features/wallet_detail/page/wallet_detail_page.dart';
import '../../home/widgets/section_header.dart';
import '../../../core/widgets/profile_drawer.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WalletCubit>()..loadWallets(),
      child: const _WalletPageContent(),
    );
  }
}

class _WalletPageContent extends StatefulWidget {
  const _WalletPageContent();

  @override
  State<_WalletPageContent> createState() => _WalletPageContentState();
}

class _WalletPageContentState extends State<_WalletPageContent>
    with SingleTickerProviderStateMixin {
  final Map<WalletType, bool> _expandedGroups = {};
  bool _hideBalance = false;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _fabController.forward();
    });

    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletCubit, WalletState>(
      listenWhen: (previous, current) {
        if (previous is WalletLoaded && current is WalletLoaded) {
          return previous.recentlyDeletedWallet == null &&
              current.recentlyDeletedWallet != null;
        }
        return false;
      },
      listener: (context, state) {
        if (state is WalletLoaded && state.recentlyDeletedWallet != null) {
          _showUndoSnackBar(context);
        }
      },
      child: Scaffold(
        drawer: const ProfileDrawer(),
        body: Stack(
          children: [
            // Gradient Background
            const PageGradientBackground(),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Fixed Header
                  Builder(
                    builder: (context) => WalletHeader(
                      onAvatarTap: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  // Scrollable Content
                  Expanded(
                    child: BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, state) {
                        if (state is WalletLoading) {
                          return const WalletSkeleton();
                        }

                        if (state is WalletError) {
                          return Center(child: Text(state.message));
                        }

                        if (state is WalletLoaded) {
                          return RefreshIndicator(
                            onRefresh: () =>
                                context.read<WalletCubit>().loadWallets(),
                            child: _buildContent(context, state),
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
        floatingActionButton: BlocBuilder<WalletCubit, WalletState>(
          builder: (context, state) {
            final walletState = state is WalletLoaded ? state : null;
            final canTransfer =
                walletState != null && walletState.wallets.length >= 2;

            return ScaleTransition(
              scale: _fabScaleAnimation,
              child: _SpeedDialFAB(
                onAddWallet: () => _showAddWalletPage(context),
                onAddWalletType: () => _showAddWalletTypePage(context),
                canTransfer: canTransfer,
                onTransfer: canTransfer
                    ? () => _showTransferPage(context, walletState)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WalletLoaded state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter wallets by search query
    final activeWallets = state.activeWallets.where((wallet) {
      if (_searchQuery.isEmpty) return true;
      return wallet.name.toLowerCase().contains(_searchQuery) ||
          wallet.type.name.toLowerCase().contains(_searchQuery);
    }).toList();

    // Group active wallets (not archived) by type
    final groupedWallets = <WalletType, List<Wallet>>{};
    for (final wallet in activeWallets) {
      groupedWallets.putIfAbsent(wallet.type, () => []).add(wallet);
    }

    // Sort types by predefined order
    final sortedTypes = WalletType.values
        .where((type) => groupedWallets.containsKey(type))
        .toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Collapsible sticky summary header
        SliverPersistentHeader(
          pinned: true,
          delegate: _CollapsibleSummaryDelegate(
            maxHeight: 320,
            minHeight: 64,
            totalBalance: state.totalBalance,
            totalDebt: state.totalDebt,
            hideBalance: _hideBalance,
            onToggleHide: () {
              HapticFeedback.lightImpact();
              setState(() => _hideBalance = !_hideBalance);
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        SliverToBoxAdapter(
          child: WalletStatisticsCard(
            wallets: state.activeWallets,
            totalBalance: state.totalBalance,
            totalDebt: state.totalDebt,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Sticky header for "My Wallets"
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyHeaderDelegate(
            minHeight: 56,
            maxHeight: 56,
            child: Container(
              color: isDark
                  ? theme.scaffoldBackgroundColor
                  : theme.scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SectionHeader(
                      title: 'wallet.my_wallets'.tr(),
                      onSeeAll: null,
                    ),
                  ),
                  // Search toggle button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchController.clear();
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isSearching
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isSearching
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: _isSearching
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Search bar
        if (_isSearching)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBar(theme, isDark),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (state.activeWallets.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(onAddTap: () => _showAddWalletPage(context)),
          )
        else if (activeWallets.isEmpty && _searchQuery.isNotEmpty)
          SliverToBoxAdapter(child: _buildNoSearchResults(theme))
        else
          ...sortedTypes.expand((type) {
            final wallets = groupedWallets[type]!;
            // Only include wallets with includeInTotal in group total
            final totalBalance = wallets
                .where((w) => w.includeInTotal)
                .fold<double>(0, (sum, w) => sum + w.balance);
            final isExpanded =
                _expandedGroups[type] ?? (_searchQuery.isNotEmpty);

            return [
              SliverToBoxAdapter(
                child: WalletGroupHeader(
                  type: type,
                  totalBalance: totalBalance,
                  walletCount: wallets.length,
                  isExpanded: isExpanded,
                  hideBalance: _hideBalance,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _expandedGroups[type] = !isExpanded;
                    });
                  },
                ),
              ),
              if (isExpanded)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final wallet = wallets[index];
                    return WalletListTile(
                      wallet: wallet,
                      index: index,
                      hideBalance: _hideBalance,
                      onTap: () => WalletDetailPage.navigate(context, wallet),
                      onEdit: () => _showEditWalletSheet(context, wallet),
                      onDuplicate: () => _duplicateWallet(context, wallet),
                      onTransfer: state.activeWallets.length >= 2
                          ? () => _showTransferPage(context, state)
                          : null,
                      onArchive: () => _archiveWallet(context, wallet),
                      onDelete: () => _deleteWallet(context, wallet),
                    );
                  }, childCount: wallets.length),
                ),
            ];
          }),
        // Archived wallets section
        if (state.archivedWallets.isNotEmpty && _searchQuery.isEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _ArchivedWalletsSection(
              archivedWallets: state.archivedWallets,
              hideBalance: _hideBalance,
              onUnarchive: (wallet) => _unarchiveWallet(context, wallet),
              onDelete: (wallet) => _deleteWallet(context, wallet),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'wallet.search_hint'.tr(),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.primary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () => _searchController.clear(),
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'wallet.no_results'.tr(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'wallet.no_results_hint'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text('wallet.deleted'.tr()),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.inverseSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'wallet.undo'.tr(),
          textColor: theme.colorScheme.primary,
          onPressed: () {
            context.read<WalletCubit>().undoDelete();
          },
        ),
      ),
    );
  }

  Future<void> _showAddWalletPage(BuildContext context) async {
    final cubit = context.read<WalletCubit>();
    final wallet = await AddWalletPage.navigate(context);
    if (wallet != null) {
      cubit.addWallet(wallet);
    }
  }

  Future<void> _showAddWalletTypePage(BuildContext context) async {
    final result = await AddWalletTypePage.navigate(context);
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'wallet.custom_types'.tr()}: ${result.name}'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _showEditWalletSheet(
    BuildContext context,
    dynamic wallet,
  ) async {
    final cubit = context.read<WalletCubit>();
    final updatedWallet = await AddWalletPage.navigate(context, wallet: wallet);
    if (updatedWallet != null) {
      cubit.updateWallet(updatedWallet);
    }
  }

  Future<void> _deleteWallet(BuildContext context, Wallet wallet) async {
    final confirmed = await showDeleteWalletDialog(context, wallet);
    if (confirmed && context.mounted) {
      context.read<WalletCubit>().deleteWallet(wallet.id);
    }
  }

  void _duplicateWallet(BuildContext context, Wallet wallet) {
    HapticFeedback.mediumImpact();
    context.read<WalletCubit>().duplicateWallet(wallet);
  }

  void _archiveWallet(BuildContext context, Wallet wallet) {
    HapticFeedback.mediumImpact();
    context.read<WalletCubit>().archiveWallet(wallet.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('wallet.archived'.tr()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _unarchiveWallet(BuildContext context, Wallet wallet) {
    HapticFeedback.mediumImpact();
    context.read<WalletCubit>().unarchiveWallet(wallet.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('wallet.unarchived'.tr()),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _showTransferPage(
    BuildContext context,
    WalletLoaded state,
  ) async {
    final cubit = context.read<WalletCubit>();
    final result = await TransferPage.navigate(context, wallets: state.wallets);
    if (result != null) {
      cubit.transfer(
        fromWalletId: result.fromWalletId,
        toWalletId: result.toWalletId,
        amount: result.amount,
      );
    }
  }
}

class _SpeedDialFAB extends StatefulWidget {
  final VoidCallback onAddWallet;
  final VoidCallback onAddWalletType;
  final VoidCallback? onTransfer;
  final bool canTransfer;

  const _SpeedDialFAB({
    required this.onAddWallet,
    required this.onAddWalletType,
    this.onTransfer,
    this.canTransfer = true,
  });

  @override
  State<_SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<_SpeedDialFAB>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _rotateAnimation;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() => _isOpen = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed Dial Options
        ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.bottomRight,
          child: FadeTransition(
            opacity: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Transfer Option
                _SpeedDialOption(
                  icon: Icons.swap_horiz_rounded,
                  label: 'wallet.transfer'.tr(),
                  gradient: widget.canTransfer
                      ? AppColors.purpleGradient
                      : [
                          theme.colorScheme.outline.withValues(alpha: 0.5),
                          theme.colorScheme.outline.withValues(alpha: 0.5),
                        ],
                  enabled: widget.canTransfer,
                  onTap: widget.canTransfer
                      ? () {
                          _close();
                          widget.onTransfer?.call();
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                // Add Wallet Type Option
                _SpeedDialOption(
                  icon: Icons.category_rounded,
                  label: 'wallet.add_wallet_type'.tr(),
                  gradient: AppColors.amberGradient,
                  onTap: () {
                    _close();
                    widget.onAddWalletType();
                  },
                ),
                const SizedBox(height: 12),
                // Add Wallet Option
                _SpeedDialOption(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'wallet.add_wallet'.tr(),
                  gradient: AppColors.incomeGradient,
                  onTap: () {
                    _close();
                    widget.onAddWallet();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // Main FAB
        GestureDetector(
          onTap: _toggle,
          child: AnimatedBuilder(
            animation: Listenable.merge([_controller, _pulseController]),
            builder: (context, child) {
              return Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOpen
                        ? [
                            theme.colorScheme.error,
                            theme.colorScheme.error.withValues(alpha: 0.8),
                          ]
                        : [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isOpen
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary)
                              .withValues(
                                alpha: 0.3 + (_pulseController.value * 0.15),
                              ),
                      blurRadius: 15 + (_pulseController.value * 5),
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: RotationTransition(
                  turns: _rotateAnimation,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SpeedDialOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool enabled;

  const _SpeedDialOption({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<_SpeedDialOption> createState() => _SpeedDialOptionState();
}

class _SpeedDialOptionState extends State<_SpeedDialOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: widget.enabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.enabled
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.enabled
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.enabled
          ? () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Icon Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatefulWidget {
  final VoidCallback onAddTap;

  const _EmptyState({required this.onAddTap});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated wallet icon with rings
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner gradient circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'wallet.empty_title'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'wallet.empty_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Add wallet button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onAddTap();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'wallet.add_first_wallet'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedWalletsSection extends StatefulWidget {
  final List<Wallet> archivedWallets;
  final bool hideBalance;
  final void Function(Wallet) onUnarchive;
  final void Function(Wallet) onDelete;

  const _ArchivedWalletsSection({
    required this.archivedWallets,
    required this.hideBalance,
    required this.onUnarchive,
    required this.onDelete,
  });

  @override
  State<_ArchivedWalletsSection> createState() =>
      _ArchivedWalletsSectionState();
}

class _ArchivedWalletsSectionState extends State<_ArchivedWalletsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      )
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.7,
                      ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.archive_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'wallet.archived_wallets'.tr(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.archivedWallets.length} ${'wallet.wallets'.tr()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Wallet list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const SizedBox(height: 8),
                ...widget.archivedWallets.map((wallet) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ArchivedWalletTile(
                      wallet: wallet,
                      hideBalance: widget.hideBalance,
                      onUnarchive: () => widget.onUnarchive(wallet),
                      onDelete: () => widget.onDelete(wallet),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedWalletTile extends StatelessWidget {
  final Wallet wallet;
  final bool hideBalance;
  final VoidCallback onUnarchive;
  final VoidCallback onDelete;

  const _ArchivedWalletTile({
    required this.wallet,
    required this.hideBalance,
    required this.onUnarchive,
    required this.onDelete,
  });

  Color _parseColor(String? colorHex, WalletType type) {
    if (colorHex != null) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return type.color;
  }

  IconData _getIcon(Wallet wallet) {
    if (wallet.iconCodePoint != null) {
      return IconData(wallet.iconCodePoint!, fontFamily: 'MaterialIcons');
    }
    return wallet.type.icon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _parseColor(wallet.color, wallet.type);
    final icon = _getIcon(wallet);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallet.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  hideBalance
                      ? '฿ ••••••'
                      : '฿ ${wallet.balance.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unarchive button
              GestureDetector(
                onTap: onUnarchive,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.unarchive_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _CollapsibleSummaryDelegate extends SliverPersistentHeaderDelegate {
  final double maxHeight;
  final double minHeight;
  final double totalBalance;
  final double totalDebt;
  final bool hideBalance;
  final VoidCallback onToggleHide;

  _CollapsibleSummaryDelegate({
    required this.maxHeight,
    required this.minHeight,
    required this.totalBalance,
    required this.totalDebt,
    required this.hideBalance,
    required this.onToggleHide,
  });

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate collapse progress (0 = fully expanded, 1 = fully collapsed)
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final netBalance = totalBalance - totalDebt;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.scaffoldBackgroundColor
            : theme.scaffoldBackgroundColor,
        boxShadow: progress > 0.5
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05 * progress),
                  blurRadius: 8 * progress,
                  offset: Offset(0, 2 * progress),
                ),
              ]
            : null,
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Expanded view (Original BalanceOverviewCard)
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: (1 - progress * 2).clamp(0.0, 1.0),
                child: BalanceOverviewCard(
                  totalBalance: totalBalance,
                  totalDebt: totalDebt,
                  hideBalance: hideBalance,
                  onToggleHide: onToggleHide,
                ),
              ),
            ),
            // Collapsed view (Compact row)
            Positioned.fill(
              child: Opacity(
                opacity: ((progress - 0.5) * 2).clamp(0.0, 1.0),
                child: _CollapsedSummaryRow(
                  netBalance: netBalance,
                  totalBalance: totalBalance,
                  totalDebt: totalDebt,
                  hideBalance: hideBalance,
                  onToggleHide: onToggleHide,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_CollapsibleSummaryDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        totalBalance != oldDelegate.totalBalance ||
        totalDebt != oldDelegate.totalDebt ||
        hideBalance != oldDelegate.hideBalance;
  }
}

class _CollapsedSummaryRow extends StatelessWidget {
  final double netBalance;
  final double totalBalance;
  final double totalDebt;
  final bool hideBalance;
  final VoidCallback onToggleHide;

  static final _currencyFormat = NumberFormat('#,##0.00');

  const _CollapsedSummaryRow({
    required this.netBalance,
    required this.totalBalance,
    required this.totalDebt,
    required this.hideBalance,
    required this.onToggleHide,
  });

  String _formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Net balance with icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          // Net balance value
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wallet.net_balance'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
                Text(
                  hideBalance ? '฿••••••' : '฿${_formatCurrency(netBalance)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: netBalance >= 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          // Assets indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.income.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.income,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hideBalance ? '฿••••••' : '฿${_formatCurrency(totalBalance)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Debt indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.expense,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  hideBalance ? '฿••••••' : '฿${_formatCurrency(totalDebt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.expense,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle visibility button
          GestureDetector(
            onTap: onToggleHide,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                hideBalance
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

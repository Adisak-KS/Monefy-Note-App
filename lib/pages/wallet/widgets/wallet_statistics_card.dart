import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/wallet.dart';
import '../../../core/models/balance_history.dart';
import '../../../core/theme/app_colors.dart';

enum StatisticsPeriod { week, month, quarter }

enum StatisticsMode { netWorth, byWallet }

class WalletStatisticsCard extends StatefulWidget {
  final List<Wallet> wallets;
  final double totalBalance;
  final double totalDebt;

  const WalletStatisticsCard({
    super.key,
    required this.wallets,
    required this.totalBalance,
    required this.totalDebt,
  });

  @override
  State<WalletStatisticsCard> createState() => _WalletStatisticsCardState();
}

class _WalletStatisticsCardState extends State<WalletStatisticsCard>
    with SingleTickerProviderStateMixin {
  StatisticsMode _mode = StatisticsMode.netWorth;
  StatisticsPeriod _period = StatisticsPeriod.week;
  String? _selectedWalletId;
  int? _touchedIndex;
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.wallets.isNotEmpty) {
      _selectedWalletId = widget.wallets.first.id;
    }
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _expandController.value = 0.0; // Start collapsed
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  double get _netWorth => widget.totalBalance - widget.totalDebt;

  String get _periodLabel => switch (_period) {
        StatisticsPeriod.week => '7D',
        StatisticsPeriod.month => '30D',
        StatisticsPeriod.quarter => '90D',
      };

  // Calculate mock percentage change
  double get _percentChange {
    final data = _generateMockData();
    if (data.length < 2) return 0;
    final first = data.first.balance;
    final last = data.last.balance;
    if (first == 0) return 0;
    return ((last - first) / first.abs()) * 100;
  }

  List<BalanceHistory> _generateMockData() {
    final now = DateTime.now();
    final days = switch (_period) {
      StatisticsPeriod.week => 7,
      StatisticsPeriod.month => 30,
      StatisticsPeriod.quarter => 90,
    };

    final baseValue = _mode == StatisticsMode.netWorth
        ? widget.totalBalance - widget.totalDebt
        : widget.wallets
                .where((w) => w.id == _selectedWalletId)
                .firstOrNull
                ?.balance ??
            0;

    return List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - 1 - index));
      // Generate mock trend data with some variation
      final variation = (index / days) * 0.2;
      final randomFactor = 0.9 + (index % 5) * 0.05;
      final value = baseValue * (0.85 + variation) * randomFactor;

      return BalanceHistory(
        date: date,
        balance: value,
        walletId: _mode == StatisticsMode.byWallet ? _selectedWalletId : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = _generateMockData();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkCardAlt]
              : [Colors.white, AppColors.lightBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse button
          GestureDetector(
            onTap: _toggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'statistics.title'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? Colors.white60 : Colors.grey.shade600,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                // Collapsed summary
                if (!_isExpanded) ...[
                  const SizedBox(height: 12),
                  _buildCollapsedSummary(theme, isDark, data),
                ],
              ],
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Mode Toggle
                _buildModeToggle(theme, isDark),
                const SizedBox(height: 12),

                // Wallet Selector (only show in byWallet mode)
                if (_mode == StatisticsMode.byWallet) ...[
                  _buildWalletDropdown(theme, isDark),
                  const SizedBox(height: 12),
                ],

                // Chart
                SizedBox(
                  height: 180,
                  child: _buildChart(theme, isDark, data),
                ),
                const SizedBox(height: 16),

                // Period Selector
                _buildPeriodSelector(theme, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedSummary(
    ThemeData theme,
    bool isDark,
    List<BalanceHistory> data,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 2,
    );
    final percentChange = _percentChange;
    final isPositive = percentChange >= 0;

    return Row(
      children: [
        // Net Worth and % Change
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'wallet.net_worth'.tr(),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    currencyFormat.format(_netWorth),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: (isPositive ? Colors.green : Colors.red)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}% ($_periodLabel)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Mini Sparkline
        SizedBox(
          width: 80,
          height: 36,
          child: _buildMiniSparkline(theme, data),
        ),
      ],
    );
  }

  Widget _buildMiniSparkline(ThemeData theme, List<BalanceHistory> data) {
    if (data.isEmpty) return const SizedBox();

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.balance);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final isPositive = spots.last.y >= spots.first.y;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: isPositive ? Colors.green : Colors.red,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  (isPositive ? Colors.green : Colors.red)
                      .withValues(alpha: 0.2),
                  (isPositive ? Colors.green : Colors.red)
                      .withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              label: 'wallet.net_worth'.tr(),
              isSelected: _mode == StatisticsMode.netWorth,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _mode = StatisticsMode.netWorth);
              },
              theme: theme,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              label: 'statistics.by_wallet'.tr(),
              isSelected: _mode == StatisticsMode.byWallet,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _mode = StatisticsMode.byWallet);
              },
              theme: theme,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? ColorUtils.getContrastColor(theme.colorScheme.primary)
                  : isDark
                      ? Colors.white70
                      : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletDropdown(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedWalletId,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white70 : Colors.grey.shade700,
          ),
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          items: widget.wallets.map((wallet) {
            return DropdownMenuItem<String>(
              value: wallet.id,
              child: Text(
                wallet.name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade900,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            HapticFeedback.lightImpact();
            setState(() => _selectedWalletId = value);
          },
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme, bool isDark, List<BalanceHistory> data) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey,
          ),
        ),
      );
    }

    final spots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.balance);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;
    final padding = range * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: range > 0 ? range / 4 : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (data.length / 4).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();

                final date = data[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('d/M').format(date),
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY - padding,
        maxY: maxY + padding,
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (event, response) {
            setState(() {
              _touchedIndex = response?.lineBarSpots?.firstOrNull?.spotIndex;
            });
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.primary,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final currencyFormat = NumberFormat.currency(
                  locale: 'th_TH',
                  symbol: '฿',
                  decimalDigits: 0,
                );
                return LineTooltipItem(
                  currencyFormat.format(spot.y),
                  TextStyle(
                    color: ColorUtils.getContrastColor(theme.colorScheme.primary),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isHighlighted = index == _touchedIndex;
                return FlDotCirclePainter(
                  radius: isHighlighted ? 6 : 3,
                  color: theme.colorScheme.primary,
                  strokeWidth: isHighlighted ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodChip(
          label: '7D',
          period: StatisticsPeriod.week,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildPeriodChip(
          label: '30D',
          period: StatisticsPeriod.month,
          theme: theme,
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildPeriodChip(
          label: '90D',
          period: StatisticsPeriod.quarter,
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPeriodChip({
    required String label,
    required StatisticsPeriod period,
    required ThemeData theme,
    required bool isDark,
  }) {
    final isSelected = _period == period;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _period = period);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.white70
                    : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/statistics_state.dart';

class TrendBarChart extends StatefulWidget {
  final List<DailyStatistic> data;
  final String title;
  final bool showTrendLine;

  const TrendBarChart({
    super.key,
    required this.data,
    required this.title,
    this.showTrendLine = true,
  });

  @override
  State<TrendBarChart> createState() => _TrendBarChartState();
}

class _TrendBarChartState extends State<TrendBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
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
    final isDark = theme.brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return _buildEmptyState(theme, isDark);
    }

    // Calculate max value for chart scaling
    double maxY = 0;
    double totalIncome = 0;
    double totalExpense = 0;
    for (final stat in widget.data) {
      if (stat.income > maxY) maxY = stat.income;
      if (stat.expense > maxY) maxY = stat.expense;
      totalIncome += stat.income;
      totalExpense += stat.expense;
    }
    maxY = maxY * 1.25;
    if (maxY == 0) maxY = 100;

    // Limit to last 7 days for better visualization
    final displayData = widget.data.length > 7
        ? widget.data.sublist(widget.data.length - 7)
        : widget.data;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _animation.value)),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: theme.colorScheme.primary
                      .withValues(alpha: isDark ? 0.15 : 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary
                        .withValues(alpha: isDark ? 0.08 : 0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary
                              .withValues(alpha: isDark ? 0.08 : 0.15),
                          theme.colorScheme.primary
                              .withValues(alpha: isDark ? 0.02 : 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.trending_up_rounded,
                                color: ColorUtils.getContrastColor(theme.colorScheme.primary),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${displayData.length} ${'home.filter_day'.tr()}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.65),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Summary Stats Row
                        Row(
                          children: [
                            _SummaryChip(
                              icon: Icons.south_west_rounded,
                              label: 'home.income'.tr(),
                              amount: totalIncome,
                              color: AppColors.income,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            _SummaryChip(
                              icon: Icons.north_east_rounded,
                              label: 'home.expense'.tr(),
                              amount: totalExpense,
                              color: AppColors.expense,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chart Section - Responsive
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 360;
                      final chartHeight = isCompact ? 180.0 : 220.0;
                      final barWidth = isCompact ? 8.0 : 12.0;
                      final touchedBarWidth = isCompact ? 12.0 : 16.0;

                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          isCompact ? 8 : 12,
                          20,
                          isCompact ? 12 : 20,
                          20,
                        ),
                        child: SizedBox(
                          height: chartHeight,
                          child: Stack(
                            children: [
                              BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxY,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (group) => isDark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : theme.colorScheme.surface,
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  tooltipMargin: 8,
                                  getTooltipItem:
                                      (group, groupIndex, rod, rodIndex) {
                                    final stat = displayData[groupIndex];
                                    final isIncome = rodIndex == 0;
                                    final value =
                                        isIncome ? stat.income : stat.expense;
                                    final format = NumberFormat('#,##0');
                                    final dateFormat = DateFormat('MMM d');
                                    final currency =
                                        context.read<CurrencyCubit>().state;
                                    return BarTooltipItem(
                                      '${dateFormat.format(stat.date)}\n',
                                      theme.textTheme.labelSmall!.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.65),
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              '${isIncome ? 'home.income'.tr() : 'home.expense'.tr()}: ',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '${currency.symbol}${format.format(value)}',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isIncome
                                                ? AppColors.income
                                                : AppColors.expense,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  if (event.isInterestedForInteractions) {
                                    HapticFeedback.selectionClick();
                                  }
                                  setState(() {
                                    if (response == null ||
                                        response.spot == null) {
                                      touchedGroupIndex = -1;
                                      return;
                                    }
                                    touchedGroupIndex =
                                        response.spot!.touchedBarGroupIndex;
                                  });
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0) {
                                        return const SizedBox.shrink();
                                      }
                                      final format = NumberFormat.compact();
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: Text(
                                          format.format(value),
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withValues(alpha: 0.55),
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 36,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 ||
                                          index >= displayData.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final stat = displayData[index];
                                      final dayFormat = DateFormat('E');
                                      final isTouched =
                                          touchedGroupIndex == index;
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isTouched ? 8 : 0,
                                                vertical: isTouched ? 4 : 0,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isTouched
                                                    ? theme.colorScheme.primary
                                                        .withValues(alpha: 0.1)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                dayFormat.format(stat.date),
                                                style: theme
                                                    .textTheme.labelSmall
                                                    ?.copyWith(
                                                  color: isTouched
                                                      ? theme.colorScheme.primary
                                                      : theme.colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.65),
                                                  fontWeight: isTouched
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: maxY / 4,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.08),
                                    strokeWidth: 1,
                                    dashArray: [6, 4],
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups:
                                  displayData.asMap().entries.map((entry) {
                                final index = entry.key;
                                final stat = entry.value;
                                final isTouched = index == touchedGroupIndex;

                                return BarChartGroupData(
                                  x: index,
                                  barsSpace: 4,
                                  barRods: [
                                    BarChartRodData(
                                      toY: stat.income * _animation.value,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF22C55E),
                                          AppColors.emerald,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      width: isTouched
                                          ? touchedBarWidth
                                          : barWidth,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                      borderSide: isTouched
                                          ? BorderSide(
                                              color: AppColors.income
                                                  .withValues(alpha: 0.5),
                                              width: 2,
                                            )
                                          : BorderSide.none,
                                    ),
                                    BarChartRodData(
                                      toY: stat.expense * _animation.value,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFEF4444),
                                          AppColors.orange,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      width: isTouched
                                          ? touchedBarWidth
                                          : barWidth,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(6),
                                      ),
                                      borderSide: isTouched
                                          ? BorderSide(
                                              color: AppColors.expense
                                                  .withValues(alpha: 0.5),
                                              width: 2,
                                            )
                                          : BorderSide.none,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                          // Trend Line Overlay
                          if (widget.showTrendLine && displayData.length > 1)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 50,
                                right: isCompact ? 12 : 20,
                                top: 0,
                                bottom: 36,
                              ),
                              child: LineChart(
                                LineChartData(
                                  minY: 0,
                                  maxY: maxY,
                                  lineTouchData: const LineTouchData(enabled: false),
                                  gridData: const FlGridData(show: false),
                                  titlesData: const FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    // Expense trend line
                                    LineChartBarData(
                                      spots: displayData.asMap().entries.map((entry) {
                                        return FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.expense * _animation.value,
                                        );
                                      }).toList(),
                                      isCurved: true,
                                      curveSmoothness: 0.3,
                                      color: AppColors.expense.withValues(alpha: 0.7),
                                      barWidth: 2.5,
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: AppColors.expense,
                                            strokeWidth: 1.5,
                                            strokeColor: isDark ? Colors.black : Colors.white,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.expense.withValues(alpha: 0.15),
                                            AppColors.expense.withValues(alpha: 0.02),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color:
              theme.colorScheme.outline.withValues(alpha: isDark ? 0.1 : 0.15),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'statistics.no_data'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool isDark;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<CurrencyCubit>().state;
    final format = NumberFormat('#,##0');

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.3),
            width: 1.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 14),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${currency.symbol}${format.format(amount)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/theme/app_colors.dart';

/// Monthly comparison chart showing current vs previous month
class MonthlyComparisonChart extends StatefulWidget {
  final double currentMonthIncome;
  final double currentMonthExpense;
  final double previousMonthIncome;
  final double previousMonthExpense;
  final String currentMonthLabel;
  final String previousMonthLabel;

  const MonthlyComparisonChart({
    super.key,
    required this.currentMonthIncome,
    required this.currentMonthExpense,
    required this.previousMonthIncome,
    required this.previousMonthExpense,
    required this.currentMonthLabel,
    required this.previousMonthLabel,
  });

  @override
  State<MonthlyComparisonChart> createState() => _MonthlyComparisonChartState();
}

class _MonthlyComparisonChartState extends State<MonthlyComparisonChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

  double _calculatePercentChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = context.watch<CurrencyCubit>().state;
    final format = NumberFormat('#,##0');

    final incomeChange = _calculatePercentChange(
      widget.currentMonthIncome,
      widget.previousMonthIncome,
    );
    final expenseChange = _calculatePercentChange(
      widget.currentMonthExpense,
      widget.previousMonthExpense,
    );

    // Calculate max for chart scaling
    double maxY = 0;
    final values = [
      widget.currentMonthIncome,
      widget.currentMonthExpense,
      widget.previousMonthIncome,
      widget.previousMonthExpense,
    ];
    for (final v in values) {
      if (v > maxY) maxY = v;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

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
                  color: theme.colorScheme.secondary
                      .withValues(alpha: isDark ? 0.15 : 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary
                        .withValues(alpha: isDark ? 0.08 : 0.12),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
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
                          theme.colorScheme.secondary
                              .withValues(alpha: isDark ? 0.08 : 0.15),
                          theme.colorScheme.secondary
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
                                    theme.colorScheme.secondary,
                                    theme.colorScheme.secondary
                                        .withValues(alpha: 0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.secondary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.compare_arrows_rounded,
                                color: ColorUtils.getContrastColor(
                                    theme.colorScheme.secondary),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'statistics.monthly_comparison'.tr(),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.previousMonthLabel} vs ${widget.currentMonthLabel}',
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
                        // Change indicators
                        Row(
                          children: [
                            _ChangeIndicator(
                              label: 'home.income'.tr(),
                              change: incomeChange,
                              color: AppColors.income,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 12),
                            _ChangeIndicator(
                              label: 'home.expense'.tr(),
                              change: expenseChange,
                              color: AppColors.expense,
                              isDark: isDark,
                              invertColors: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Chart
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
                    child: SizedBox(
                      height: 200,
                      child: BarChart(
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
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final isIncome = groupIndex == 0;
                                final isCurrent = rodIndex == 1;
                                final value = rod.toY / _animation.value;
                                return BarTooltipItem(
                                  '${isCurrent ? widget.currentMonthLabel : widget.previousMonthLabel}\n',
                                  theme.textTheme.labelSmall!.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${currency.symbol}${format.format(value)}',
                                      style: theme.textTheme.titleSmall?.copyWith(
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
                                if (response == null || response.spot == null) {
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
                                  if (value == 0) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      NumberFormat.compact().format(value),
                                      style: theme.textTheme.labelSmall?.copyWith(
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
                                  final labels = ['home.income'.tr(), 'home.expense'.tr()];
                                  if (value.toInt() >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w500,
                                      ),
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
                          barGroups: [
                            // Income comparison
                            BarChartGroupData(
                              x: 0,
                              barsSpace: 8,
                              barRods: [
                                BarChartRodData(
                                  toY: widget.previousMonthIncome * _animation.value,
                                  color: AppColors.income.withValues(alpha: 0.4),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: widget.currentMonthIncome * _animation.value,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF22C55E), AppColors.emerald],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                            // Expense comparison
                            BarChartGroupData(
                              x: 1,
                              barsSpace: 8,
                              barRods: [
                                BarChartRodData(
                                  toY: widget.previousMonthExpense * _animation.value,
                                  color: AppColors.expense.withValues(alpha: 0.4),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                BarChartRodData(
                                  toY: widget.currentMonthExpense * _animation.value,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEF4444), AppColors.orange],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  width: 24,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Legend
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          label: widget.previousMonthLabel,
                          color: theme.colorScheme.outline,
                          isFaded: true,
                        ),
                        const SizedBox(width: 24),
                        _LegendItem(
                          label: widget.currentMonthLabel,
                          color: theme.colorScheme.primary,
                          isFaded: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChangeIndicator extends StatelessWidget {
  final String label;
  final double change;
  final Color color;
  final bool isDark;
  final bool invertColors;

  const _ChangeIndicator({
    required this.label,
    required this.change,
    required this.color,
    required this.isDark,
    this.invertColors = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change >= 0;
    // For expenses, positive change is bad (inverted colors)
    final displayColor = invertColors
        ? (isPositive ? AppColors.expense : AppColors.income)
        : (isPositive ? AppColors.income : AppColors.expense);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.2 : 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: displayColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: displayColor,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
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
                    '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: displayColor,
                    ),
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

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isFaded;

  const _LegendItem({
    required this.label,
    required this.color,
    required this.isFaded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isFaded ? color.withValues(alpha: 0.4) : color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

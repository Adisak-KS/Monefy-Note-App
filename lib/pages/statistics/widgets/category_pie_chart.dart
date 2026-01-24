import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bloc/statistics_state.dart';

class CategoryPieChart extends StatefulWidget {
  final List<CategoryStatistic> data;
  final String title;
  final bool isExpense;

  const CategoryPieChart({
    super.key,
    required this.data,
    required this.title,
    this.isExpense = true,
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart>
    with SingleTickerProviderStateMixin {
  int touchedIndex = -1;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;

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
    _rotationAnimation = Tween<double>(begin: -0.25, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _defaultColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEF4444), // Red
    Color(0xFF84CC16), // Lime
    Color(0xFFF97316), // Orange
    Color(0xFF14B8A6), // Teal
  ];

  Color _parseColor(String? colorHex, int index) {
    if (colorHex != null) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return _defaultColors[index % _defaultColors.length];
  }

  double get _totalAmount =>
      widget.data.fold(0.0, (sum, item) => sum + item.amount);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.data.isEmpty) {
      return _buildEmptyState(theme, isDark);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _animation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: (widget.isExpense
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E))
                .withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E))
                  .withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                  colors: widget.isExpense
                      ? [
                          const Color(0xFFEF4444).withValues(alpha: 0.08),
                          const Color(0xFFEF4444).withValues(alpha: 0.02),
                        ]
                      : [
                          const Color(0xFF22C55E).withValues(alpha: 0.08),
                          const Color(0xFF22C55E).withValues(alpha: 0.02),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isExpense
                            ? [
                                const Color(0xFFEF4444),
                                const Color(0xFFF97316),
                              ]
                            : [
                                const Color(0xFF22C55E),
                                const Color(0xFF10B981),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isExpense
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E))
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.donut_large_rounded,
                      color: Colors.white,
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
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.data.length} ${'home.category'.tr()}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total Amount Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      '฿${NumberFormat('#,##0').format(_totalAmount)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.isExpense
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chart Section - Responsive
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 360;
                final chartSize = isCompact
                    ? constraints.maxWidth * 0.5
                    : (constraints.maxWidth * 0.45).clamp(140.0, 180.0);
                final centerRadius = chartSize * 0.3;

                if (isCompact) {
                  // Vertical layout for small screens
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        // Pie Chart
                        SizedBox(
                          height: chartSize,
                          width: chartSize,
                          child: _buildPieChart(centerRadius),
                        ),
                        const SizedBox(height: 16),
                        // Legend - Horizontal Wrap
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.data
                              .take(5)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) =>
                                  _buildCompactLegendItem(entry.value, entry.key))
                              .toList(),
                        ),
                      ],
                    ),
                  );
                }

                // Horizontal layout for larger screens
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Row(
                    children: [
                      // Pie Chart with Center Content
                      SizedBox(
                        height: chartSize,
                        width: chartSize,
                        child: _buildPieChart(centerRadius),
                      ),
                      const SizedBox(width: 16),
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.data
                              .take(5)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) =>
                                  _buildLegendItem(entry.value, entry.key))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: (widget.isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E))
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.donut_large_rounded,
              size: 40,
              color: (widget.isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E))
                  .withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'statistics.no_data'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(double centerRadius) {
    final selectedData = touchedIndex >= 0 && touchedIndex < widget.data.length
        ? widget.data[touchedIndex]
        : null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated Pie Chart
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: child,
            );
          },
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event.isInterestedForInteractions) {
                    HapticFeedback.selectionClick();
                  }
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 4,
              centerSpaceRadius: centerRadius,
              startDegreeOffset: -90,
              sections: _buildSections(),
            ),
          ),
        ),
        // Center Content
        _CenterContent(
          selectedData: selectedData,
          totalAmount: _totalAmount,
          isExpense: widget.isExpense,
          parseColor: _parseColor,
          touchedIndex: touchedIndex,
        ),
      ],
    );
  }

  Widget _buildCompactLegendItem(CategoryStatistic data, int index) {
    final theme = Theme.of(context);
    final color = _parseColor(data.category.color, index);
    final isTouched = index == touchedIndex;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          touchedIndex = touchedIndex == index ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isTouched
              ? color.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: isTouched
              ? Border.all(color: color.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              data.category.name,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                color: isTouched ? color : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${data.percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 38.0 : 30.0;
      final color = _parseColor(item.category.color, index);

      return PieChartSectionData(
        color: color,
        value: item.amount,
        title: '',
        radius: radius * _animation.value,
        borderSide: isTouched
            ? BorderSide(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3,
              )
            : BorderSide.none,
      );
    }).toList();
  }

  Widget _buildLegendItem(CategoryStatistic data, int index) {
    final theme = Theme.of(context);
    final color = _parseColor(data.category.color, index);
    final isTouched = index == touchedIndex;
    final currencyFormat = NumberFormat('#,##0');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          touchedIndex = touchedIndex == index ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isTouched ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isTouched
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Color Indicator with Animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isTouched ? 14 : 10,
              height: isTouched ? 14 : 10,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTouched ? 5 : 3),
                boxShadow: isTouched
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.category.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isTouched ? FontWeight.w700 : FontWeight.w500,
                      color: isTouched
                          ? color
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isTouched)
                    Text(
                      '${data.transactionCount} ${'home.transactions'.tr()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color.withValues(alpha: 0.7),
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '฿${currencyFormat.format(data.amount)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isTouched ? color : theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isTouched ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${data.percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterContent extends StatelessWidget {
  final CategoryStatistic? selectedData;
  final double totalAmount;
  final bool isExpense;
  final Color Function(String?, int) parseColor;
  final int touchedIndex;

  const _CenterContent({
    required this.selectedData,
    required this.totalAmount,
    required this.isExpense,
    required this.parseColor,
    required this.touchedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat('#,##0');

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: selectedData != null
          ? Column(
              key: ValueKey(touchedIndex),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedData!.category.icon ?? '📦',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  '${selectedData!.percentage.toStringAsFixed(0)}%',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: parseColor(selectedData!.category.color, touchedIndex),
                  ),
                ),
                Text(
                  '฿${currencyFormat.format(selectedData!.amount)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            )
          : Column(
              key: const ValueKey('total'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isExpense
                      ? Icons.shopping_bag_rounded
                      : Icons.savings_rounded,
                  size: 28,
                  color: isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E),
                ),
                const SizedBox(height: 4),
                Text(
                  isExpense ? 'home.expense'.tr() : 'home.income'.tr(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
    );
  }
}

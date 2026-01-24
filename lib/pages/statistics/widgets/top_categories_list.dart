import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/cubit/currency_cubit.dart';
import '../../../core/utils/icon_utils.dart';
import '../bloc/statistics_state.dart';

class TopCategoriesList extends StatelessWidget {
  final List<CategoryStatistic> data;
  final String title;
  final bool isExpense;

  const TopCategoriesList({
    super.key,
    required this.data,
    required this.title,
    this.isExpense = true,
  });

  static const _defaultColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
    Color(0xFF6C5CE7),
    Color(0xFFFD79A8),
    Color(0xFF00B894),
    Color(0xFFE17055),
  ];

  Color _parseColor(String? colorHex, int index) {
    if (colorHex != null) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return _defaultColors[index % _defaultColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.1 : 0.15),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isExpense
                      ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                      : const Color(0xFF22C55E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.leaderboard_rounded,
                  color: isExpense
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF22C55E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category Items
          ...data.take(5).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final stat = entry.value;
            return _CategoryItem(
              stat: stat,
              index: index,
              color: _parseColor(stat.category.color, index),
              isExpense: isExpense,
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final CategoryStatistic stat;
  final int index;
  final Color color;
  final bool isExpense;

  const _CategoryItem({
    required this.stat,
    required this.index,
    required this.color,
    required this.isExpense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<CurrencyCubit>().state;
    final currencyFormat = NumberFormat('#,##0');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: index < 3
                  ? [
                      const Color(0xFFFFD700),
                      const Color(0xFFC0C0C0),
                      const Color(0xFFCD7F32),
                    ][index]
                      .withValues(alpha: 0.2)
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: index < 3
                      ? [
                          const Color(0xFFFFD700),
                          const Color(0xFF808080),
                          const Color(0xFFCD7F32),
                        ][index]
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category Color & Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                IconUtils.getIconData(stat.category.icon ?? 'category'),
                size: 20,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.category.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${stat.transactionCount} ${'home.transactions'.tr()}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${stat.percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '${currency.symbol}${currencyFormat.format(stat.amount)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }
}

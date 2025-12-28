import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/category.dart';
import '../../../core/models/transaction.dart';
import '../../../core/models/transaction_type.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import 'section_header.dart';

class ExpenseMiniChart extends StatefulWidget {
  const ExpenseMiniChart({super.key});

  @override
  State<ExpenseMiniChart> createState() => _ExpenseMiniChartState();
}

class _ExpenseMiniChartState extends State<ExpenseMiniChart>
    with SingleTickerProviderStateMixin {
  int? touchedIndex;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        final expenseData = _calculateExpenseByCategory(
          state.todayTransactions,
          state.categories,
        );

        if (expenseData.isEmpty) return const SizedBox.shrink();

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _animation.value)),
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'home.expense_by_category'.tr(),
                onSeeAll: () {},
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .shadow
                          .withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      height: 140,
                      width: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        response == null ||
                                        response.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = response
                                        .touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                              sections: _buildSections(expenseData),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${expenseData.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'home.category'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: expenseData
                            .take(4)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) => _buildLegendItem(
                                  entry.value,
                                  entry.key,
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CategoryExpense> _calculateExpenseByCategory(
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenseTransactions.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    for (final t in expenseTransactions) {
      categoryTotals[t.categoryId] =
          (categoryTotals[t.categoryId] ?? 0) + t.amount;
    }

    final totalExpense =
        expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);

    final result = <_CategoryExpense>[];
    for (final entry in categoryTotals.entries) {
      final category = categories.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Category(
          id: entry.key,
          name: 'Unknown',
          type: TransactionType.expense,
        ),
      );

      result.add(_CategoryExpense(
        category: category,
        amount: entry.value,
        percentage: (entry.value / totalExpense) * 100,
      ));
    }

    result.sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  List<PieChartSectionData> _buildSections(List<_CategoryExpense> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? 32.0 : 26.0;
      final color = _parseColor(item.category.color) ??
          _defaultColors[index % _defaultColors.length];

      return PieChartSectionData(
        color: color,
        value: item.amount,
        title: '',
        radius: radius,
        borderSide: isTouched
            ? BorderSide(color: color.withValues(alpha: 0.5), width: 4)
            : BorderSide.none,
      );
    }).toList();
  }

  Widget _buildLegendItem(_CategoryExpense data, int index) {
    final theme = Theme.of(context);
    final color = _parseColor(data.category.color) ??
        _defaultColors[index % _defaultColors.length];
    final isTouched = index == touchedIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isTouched ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              data.category.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isTouched ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${data.percentage.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String? colorHex) {
    if (colorHex != null) {
      try {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      } catch (_) {}
    }
    return null;
  }

  static const _defaultColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFDDA0DD),
    Color(0xFF98D8C8),
  ];
}

class _CategoryExpense {
  final Category category;
  final double amount;
  final double percentage;

  _CategoryExpense({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/date_filter_type.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class DateFilterSelector extends StatefulWidget {
  const DateFilterSelector({super.key});

  @override
  State<DateFilterSelector> createState() => _DateFilterSelectorState();
}

class _DateFilterSelectorState extends State<DateFilterSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: DateFilterType.values.length,
              itemBuilder: (context, index) {
                final filter = DateFilterType.values[index];
                final isSelected = state.filterType == filter;
                return _FilterChipItem(
                  filter: filter,
                  isSelected: isSelected,
                  isDark: isDark,
                  theme: theme,
                  index: index,
                  onTap: () => _onFilterSelected(context, filter),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _onFilterSelected(BuildContext context, DateFilterType filter) {
    HapticFeedback.selectionClick();

    if (filter == DateFilterType.custom) {
      _showDateRangePicker(context);
    } else {
      context.read<HomeCubit>().changeFilter(filter);
    }
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );

    if (picked != null && context.mounted) {
      context.read<HomeCubit>().changeFilter(
            DateFilterType.custom,
            customRange: picked,
          );
    }
  }
}

class _FilterChipItem extends StatefulWidget {
  final DateFilterType filter;
  final bool isSelected;
  final bool isDark;
  final ThemeData theme;
  final int index;
  final VoidCallback onTap;

  const _FilterChipItem({
    required this.filter,
    required this.isSelected,
    required this.isDark,
    required this.theme,
    required this.index,
    required this.onTap,
  });

  @override
  State<_FilterChipItem> createState() => _FilterChipItemState();
}

class _FilterChipItemState extends State<_FilterChipItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 200 + (widget.index * 50)),
      vsync: this,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  IconData _getFilterIcon() {
    switch (widget.filter) {
      case DateFilterType.today:
        return Icons.today_rounded;
      case DateFilterType.week:
        return Icons.date_range_rounded;
      case DateFilterType.month:
        return Icons.calendar_month_rounded;
      case DateFilterType.year:
        return Icons.calendar_today_rounded;
      case DateFilterType.custom:
        return Icons.edit_calendar_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutBack,
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.theme.colorScheme.primary,
                          widget.theme.colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      )
                    : null,
                color: widget.isSelected
                    ? null
                    : widget.isDark
                        ? widget.theme.colorScheme.surface.withValues(alpha: 0.8)
                        : widget.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.isSelected
                      ? Colors.transparent
                      : widget.theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFilterIcon(),
                    size: 16,
                    color: widget.isSelected
                        ? Colors.white
                        : widget.theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.filter.labelKey.tr(),
                    style: TextStyle(
                      color: widget.isSelected
                          ? Colors.white
                          : widget.theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
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

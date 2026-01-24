import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DateRangeSelector extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final VoidCallback onThisMonth;
  final VoidCallback onLastMonth;
  final VoidCallback onThisYear;
  final ValueChanged<DateTimeRange> onCustomRange;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onThisMonth,
    required this.onLastMonth,
    required this.onThisYear,
    required this.onCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'export.select_range'.tr(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        // Quick select chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickChip(
              context,
              label: 'export.this_month'.tr(),
              onTap: onThisMonth,
              isSelected: _isThisMonth(),
            ),
            _buildQuickChip(
              context,
              label: 'export.last_month'.tr(),
              onTap: onLastMonth,
              isSelected: _isLastMonth(),
            ),
            _buildQuickChip(
              context,
              label: 'export.this_year'.tr(),
              onTap: onThisYear,
              isSelected: _isThisYear(),
            ),
            _buildQuickChip(
              context,
              label: 'export.custom'.tr(),
              onTap: () => _showDateRangePicker(context),
              isSelected: _isCustomRange(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Selected range display
        if (selectedRange != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${dateFormat.format(selectedRange!.start)} - ${dateFormat.format(selectedRange!.end)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickChip(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  bool _isThisMonth() {
    if (selectedRange == null) return false;
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);
    return selectedRange!.start.day == thisMonthStart.day &&
        selectedRange!.start.month == thisMonthStart.month &&
        selectedRange!.end.day == thisMonthEnd.day &&
        selectedRange!.end.month == thisMonthEnd.month;
  }

  bool _isLastMonth() {
    if (selectedRange == null) return false;
    final now = DateTime.now();
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = DateTime(now.year, now.month, 0);
    return selectedRange!.start.day == lastMonthStart.day &&
        selectedRange!.start.month == lastMonthStart.month &&
        selectedRange!.end.day == lastMonthEnd.day &&
        selectedRange!.end.month == lastMonthEnd.month;
  }

  bool _isThisYear() {
    if (selectedRange == null) return false;
    final now = DateTime.now();
    final thisYearStart = DateTime(now.year, 1, 1);
    final thisYearEnd = DateTime(now.year, 12, 31);
    return selectedRange!.start.day == thisYearStart.day &&
        selectedRange!.start.month == thisYearStart.month &&
        selectedRange!.end.day == thisYearEnd.day &&
        selectedRange!.end.month == thisYearEnd.month;
  }

  bool _isCustomRange() {
    return selectedRange != null &&
        !_isThisMonth() &&
        !_isLastMonth() &&
        !_isThisYear();
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final theme = Theme.of(context);
    final now = DateTime.now();

    // Adjust initialDateRange if end date is after today
    DateTimeRange? adjustedRange;
    if (selectedRange != null) {
      final adjustedEnd = selectedRange!.end.isAfter(now) ? now : selectedRange!.end;
      adjustedRange = DateTimeRange(start: selectedRange!.start, end: adjustedEnd);
    }

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: adjustedRange,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: theme.colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      onCustomRange(result);
    }
  }
}

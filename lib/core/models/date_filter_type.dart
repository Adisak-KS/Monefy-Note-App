import 'package:flutter/material.dart';

enum DateFilterType {
  today,
  week,
  month,
  year,
  custom;

  String get labelKey {
    switch (this) {
      case DateFilterType.today:
        return 'home.filter_today';
      case DateFilterType.week:
        return 'home.filter_week';
      case DateFilterType.month:
        return 'home.filter_month';
      case DateFilterType.year:
        return 'home.filter_year';
      case DateFilterType.custom:
        return 'home.filter_custom';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateFilterType.today:
        return DateTimeRange(start: today, end: today);
      case DateFilterType.week:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 6)),
          end: today,
        );
      case DateFilterType.month:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: today,
        );
      case DateFilterType.year:
        return DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: today,
        );
      case DateFilterType.custom:
        return DateTimeRange(start: today, end: today);
    }
  }
}

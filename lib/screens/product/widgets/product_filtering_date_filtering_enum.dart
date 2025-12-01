import 'package:flutter/material.dart';

enum DateFilterType {
  none,
  today,
  last7Days,
  last30Days,
  custom,
}
 
class DateFilter {
  final DateFilterType type;
  final DateTimeRange? customRange;

  const DateFilter(this.type, [this.customRange]);

  bool get isActive => type != DateFilterType.none;
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../constants/time_period.dart';


class PaymentsDataProcessor {
  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  }) processPaymentsData(
      List<dynamic> payments, TimePeriod period, String paymentType) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklyPayments(payments, paymentType);
      case TimePeriod.monthly:
        return _processMonthlyPayments(payments, paymentType);
    }
  }

  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  }) _processWeeklyPayments(List<dynamic> payments, String paymentType) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday;
    final daysToMonday = currentDayOfWeek - 1;
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: daysToMonday));
    final endOfWeek =
        startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfPreviousWeek = startOfWeek.subtract(const Duration(seconds: 1));

    final currentResult =
        _aggregatePayments(payments, startOfWeek, endOfWeek, isWeekly: true, paymentType: paymentType);
    final previousResult = _aggregatePayments(
        payments, startOfPreviousWeek, endOfPreviousWeek,
        isWeekly: true, paymentType: paymentType);

    const maxX = 8.0;
    final currentSpots = _fillMissingPoints(currentResult.spots, maxX, isWeekly: true);
    final previousSpots = _fillMissingPoints(previousResult.spots, maxX, isWeekly: true);
    final maxY = _calculateMaxY([...currentSpots, ...previousSpots]);
    const labels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    debugPrint('Weekly Current Spots: ${currentSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}');
    debugPrint('Weekly Previous Spots: ${previousSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}');
    return (
      currentSpots: currentSpots,
      previousSpots: previousSpots,
      maxY: maxY,
      labels: labels,
      errors: [...currentResult.errors, ...previousResult.errors],
    );
  }

  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  }) _processMonthlyPayments(List<dynamic> payments, String paymentType) {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month, lastDayOfMonth, 23, 59, 59);
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    final currentResult =
        _aggregatePayments(payments, startOfMonth, endOfMonth, paymentType: paymentType);
    final previousResult =
        _aggregatePayments(payments, startOfPreviousMonth, endOfPreviousMonth, paymentType: paymentType);

    final maxX = (lastDayOfMonth + 1).toDouble();
    final currentSpots = _fillMissingPoints(currentResult.spots, maxX);
    final previousSpots = _fillMissingPoints(previousResult.spots, maxX);
    final maxY = _calculateMaxY([...currentSpots, ...previousSpots]);
    final labels = List.generate(lastDayOfMonth, (index) => (index + 1).toString());

    debugPrint('Monthly Current Spots: ${currentSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}');
    debugPrint('Monthly Previous Spots: ${previousSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}');
    return (
      currentSpots: currentSpots,
      previousSpots: previousSpots,
      maxY: maxY,
      labels: labels,
      errors: [...currentResult.errors, ...previousResult.errors],
    );
  }

  static ({List<FlSpot> spots, List<String> errors}) _aggregatePayments(
    List<dynamic> payments,
    DateTime startDate,
    DateTime endDate, {
    bool isWeekly = false,
    required String paymentType,
  }) {
    final normalizedStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final daysInRange = normalizedEndDate.difference(normalizedStartDate).inDays + 1;
    final errors = <String>[];

    final Map<int, double> dailyPayments = isWeekly
        ? {for (int i = 1; i <= 7; i++) i: 0.0}
        : {for (int i = 1; i <= daysInRange; i++) i: 0.0};

    for (var payment in payments) {
      try {
        final paymentDate = DateFormat('dd MMM yyyy').parse(payment.date);
        final expenseDate = DateTime(paymentDate.year, paymentDate.month, paymentDate.day);
        if (expenseDate.isAtSameMomentAs(normalizedStartDate) ||
            (expenseDate.isAfter(normalizedStartDate) &&
                expenseDate.isBefore(normalizedEndDate.add(const Duration(seconds: 1))))) {
          final index = isWeekly
              ? expenseDate.weekday
              : expenseDate.difference(normalizedStartDate).inDays + 1;
          if (dailyPayments.containsKey(index)) {
            final amount = paymentType == 'Payment In'
                ? payment.receivedAmount
                : payment.paidAmount;
            dailyPayments[index] = (dailyPayments[index] ?? 0.0) + amount.clamp(0, double.infinity);
          } else {
            errors.add('Invalid index for payment: $index, Date: $paymentDate, Payment ID: ${payment.id}');
          }
        }
      } catch (e) {
        errors.add('Error processing payment date: ${payment.date}, error: $e, Payment ID: ${payment.id}');
        continue;
      }
    }

    return (
      spots: dailyPayments.entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value)).toList(),
      errors: errors,
    );
  }

  static double _calculateMaxY(List<FlSpot> allSpots) {
    if (allSpots.isEmpty) return 100.0;
    final maxAmount = allSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble().clamp(100.0, double.infinity);
  }

  static List<FlSpot> _fillMissingPoints(List<FlSpot> spots, double maxX, {bool isWeekly = false}) {
    final maxDay = maxX.toInt();
    final spotMap = {for (var spot in spots) spot.x.toInt(): spot};
    return List.generate(maxDay, (i) => (isWeekly || i > 0) ? (spotMap[i] ?? FlSpot(i.toDouble(), 0)) : null)
        .whereType<FlSpot>()
        .toList();
  }

  static String formatTooltip(int index, double value, TimePeriod period, bool isCurrentPeriod) {
    final labels = period == TimePeriod.weekly
        ? ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : List.generate(31, (i) => (i + 1).toString());
    final label = period == TimePeriod.monthly && index == 0
        ? 'Day 1'
        : (index < labels.length && index >= 0 ? labels[index] : 'Day ${index + 1}');
    final formattedValue = value.toStringAsFixed(2);
    final periodLabel = isCurrentPeriod ? 'Current' : 'Previous';
    return '$periodLabel $label\n₹$formattedValue';
  }
}
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:cream_ventory/db/models/expence/expence_model.dart';

import '../../../screen/reports/screens/constants/time_period.dart';


class ExpensesDataProcessor {
  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors, // Added to collect error messages
  })
  processExpensesData(List<ExpenseModel> expenses, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklyExpenses(expenses);
      case TimePeriod.monthly:
        return _processMonthlyExpenses(expenses);
    }
  }

  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  })
  _processWeeklyExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday;
    final daysToMonday = currentDayOfWeek - 1;
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysToMonday));
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));
    final endOfPreviousWeek = startOfWeek.subtract(const Duration(seconds: 1));

    final currentResult = _aggregateExpenses(
      expenses,
      startOfWeek,
      endOfWeek,
      isWeekly: true,
    );
    final previousResult = _aggregateExpenses(
      expenses,
      startOfPreviousWeek,
      endOfPreviousWeek,
      isWeekly: true,
    );

    const maxX = 8.0;
    final currentSpots = _fillMissingPoints(
      currentResult.spots,
      maxX,
      isWeekly: true,
    );
    final previousSpots = _fillMissingPoints(
      previousResult.spots,
      maxX,
      isWeekly: true,
    );
    final maxY = _calculateMaxY([...currentSpots, ...previousSpots]);
    const labels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    debugPrint(
      'Weekly Current Spots: ${currentSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}',
    );
    debugPrint(
      'Weekly Previous Spots: ${previousSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}',
    );
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
  })
  _processMonthlyExpenses(List<ExpenseModel> expenses) {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(
      now.year,
      now.month,
      lastDayOfMonth,
      23,
      59,
      59,
    );
    final startOfPreviousMonth = DateTime(now.year, now.month - 1, 1);
    final endOfPreviousMonth = DateTime(now.year, now.month, 0, 23, 59, 59);

    final currentResult = _aggregateExpenses(
      expenses,
      startOfMonth,
      endOfMonth,
    );
    final previousResult = _aggregateExpenses(
      expenses,
      startOfPreviousMonth,
      endOfPreviousMonth,
    );

    final maxX = (lastDayOfMonth + 1).toDouble();
    final currentSpots = _fillMissingPoints(currentResult.spots, maxX);
    final previousSpots = _fillMissingPoints(previousResult.spots, maxX);
    final maxY = _calculateMaxY([...currentSpots, ...previousSpots]);
    final labels = List.generate(
      lastDayOfMonth,
      (index) => (index + 1).toString(),
    );

    debugPrint(
      'Monthly Current Spots: ${currentSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}',
    );
    debugPrint(
      'Monthly Previous Spots: ${previousSpots.map((s) => '(${s.x}, ${s.y})').join(', ')}',
    );
    return (
      currentSpots: currentSpots,
      previousSpots: previousSpots,
      maxY: maxY,
      labels: labels,
      errors: [...currentResult.errors, ...previousResult.errors],
    );
  }

  static ({List<FlSpot> spots, List<String> errors}) _aggregateExpenses(
    List<ExpenseModel> expenses,
    DateTime startDate,
    DateTime endDate, {
    bool isWeekly = false,
  }) {
    final normalizedStartDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEndDate = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    final daysInRange =
        normalizedEndDate.difference(normalizedStartDate).inDays + 1;
    final errors = <String>[];

    final Map<int, double> dailyExpenses = isWeekly
        ? {for (int i = 1; i <= 7; i++) i: 0.0}
        : {for (int i = 1; i < daysInRange; i++) i: 0.0};

    for (var expense in expenses) {
      try {
        final expenseDate = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        if (expenseDate.isAtSameMomentAs(normalizedStartDate) ||
            (expenseDate.isAfter(normalizedStartDate) &&
                expenseDate.isBefore(
                  normalizedEndDate.add(const Duration(seconds: 1)),
                ))) {
          final index = isWeekly
              ? expenseDate.weekday
              : expenseDate.difference(normalizedStartDate).inDays + 1;
          if (dailyExpenses.containsKey(index)) {
            dailyExpenses[index] =
                (dailyExpenses[index] ?? 0.0) +
                expense.totalAmount.clamp(0, double.infinity);
          } else {
            errors.add(
              'Invalid index for expense: $index, Date: $expenseDate, Expense ID: ${expense.id}',
            );
          }
        }
      } catch (e) {
        errors.add(
          'Error processing expense date: ${expense.date}, error: $e, Expense ID: ${expense.id}',
        );
        continue;
      }
    }

    return (
      spots: dailyExpenses.entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList(),
      errors: errors,
    );
  }

  static double _calculateMaxY(List<FlSpot> allSpots) {
    if (allSpots.isEmpty) return 100.0; // Lower default for better scaling
    final maxAmount = allSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
    return (maxAmount * 1.2).ceilToDouble().clamp(100.0, double.infinity);
  }

  static List<FlSpot> _fillMissingPoints(List<FlSpot> spots, double maxX, {bool isWeekly = false}) {
    final maxDay = maxX.toInt();
    final spotMap = {for (var spot in spots) spot.x.toInt(): spot};
    // Start from 1 for monthly, 0 for weekly
    return List.generate(maxDay, (i) => (isWeekly || i > 0) ? (spotMap[i] ?? FlSpot(i.toDouble(), 0)) : null)
      .whereType<FlSpot>().toList();
  }

  // static String formatTooltip(
  //   int index,
  //   double value,
  //   TimePeriod period,
  //   bool isCurrentPeriod,
  // ) {   
  //   final labels = period == TimePeriod.weekly
  //       ? ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
  //       : List.generate(31, (i) => (i + 1).toString());
  //   final label = period == TimePeriod.monthly && index == 0
  //       ? 'Day 1' // Override Day 0 for monthly
  //       : (index < labels.length && index >= 0
  //             ? labels[index]
  //             : 'Day ${index + 1}');
  //   final formattedValue = value.toStringAsFixed(2);
  //   final periodLabel = isCurrentPeriod ? 'Current' : 'Previous';
  //   return '$periodLabel $label\n₹$formattedValue';
  // }

  static double calculateTotalExpenses(List<ExpenseModel> expenses) {
    return expenses.fold<double>(
      0.0,
      (sum, expense) => sum + (expense.totalAmount.clamp(0, double.infinity)),
    );
  }
}

import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum TimePeriod { weekly, monthly, yearly }

class ExpenseDataProcessor {
  static ({List<FlSpot> spots, double maxY, List<String> labels}) processExpenseData(
      List<ExpenseModel> expenses, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklyExpenses(expenses);
      case TimePeriod.monthly:
        return _processMonthlyExpenses(expenses);
      case TimePeriod.yearly:
        return _processYearlyExpenses(expenses);
    }
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processWeeklyExpenses(
      List<ExpenseModel> expenses) {
    final Map<int, double> expensesByWeekday = {for (int i = 0; i < 7; i++) i: 0.0};
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var expense in expenses) {
      try {
        // DateTime object, no parsing needed
        final weekdayIndex = expense.date.weekday - 1;
        expensesByWeekday[weekdayIndex] =                            
            (expensesByWeekday[weekdayIndex] ?? 0.0) + expense.totalAmount;
      } catch (e) {
        debugPrint("Error processing expense date: ${expense.date}, error: $e, ID: ${expense.id}");
        continue;
      }
    }

    final max = expensesByWeekday.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      7,
      (index) => FlSpot(index.toDouble(), (expensesByWeekday[index] ?? 0) * scale),
    );

    debugPrint("Weekly Expenses: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}");
    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processMonthlyExpenses(
      List<ExpenseModel> expenses) {
    final Map<int, double> expensesByDay = {for (int i = 1; i <= 31; i++) i: 0.0};
    final labels = List.generate(31, (index) => (index + 1).toString());

    for (var expense in expenses) {
      try {
        final day = expense.date.day;
        expensesByDay[day] = (expensesByDay[day] ?? 0.0) + expense.totalAmount;
      } catch (e) {
        debugPrint("Error processing expense date: ${expense.date}, error: $e, ID: ${expense.id}");
        continue;
      }
    }

    final max = expensesByDay.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      31,
      (index) => FlSpot(index.toDouble(), (expensesByDay[index + 1] ?? 0) * scale),
    );

    debugPrint("Monthly Expenses: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}");
    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processYearlyExpenses(
      List<ExpenseModel> expenses) {
    final Map<int, double> expensesByMonth = {for (int i = 0; i < 12; i++) i: 0.0};
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (var expense in expenses) {
      try {
        final monthIndex = expense.date.month - 1;
        expensesByMonth[monthIndex] = (expensesByMonth[monthIndex] ?? 0.0) + expense.totalAmount;
      } catch (e) {
        debugPrint("Error processing expense date: ${expense.date}, error: $e, ID: ${expense.id}");
        continue;
      }
    }

    final max = expensesByMonth.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), (expensesByMonth[index] ?? 0) * scale),
    );

    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static String formatTooltip(int index, double value, TimePeriod period, double totalExpenses) {
    final labels = period == TimePeriod.weekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : period == TimePeriod.monthly
            ? List.generate(31, (i) => (i + 1).toString())
            : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final label = labels[index];
    final actualValue = (value * (totalExpenses / 100)).toStringAsFixed(2);
    return '$label\n₹-$actualValue';
  }

  static double getTotalExpenses(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);
  }

  static List<ExpenseModel> filterByDateRange(List<ExpenseModel> expenses, DateTime start, DateTime end) {
    return expenses.where((expense) =>
        expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
        expense.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }
}
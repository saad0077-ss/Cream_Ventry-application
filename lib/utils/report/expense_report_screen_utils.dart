import 'package:cream_ventory/db/functions/expence_db.dart';
import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_screen_pdf.dart';
import 'package:cream_ventory/utils/report/graphs/expense_graph_processers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screen/reports/screens/constants/time_period.dart';

class ExpenseReportUtils {
  final ExpenseDB _db = ExpenseDB();
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // ──────────────────────────────────────────────────────────────
  // 1. Load chart data
  // ──────────────────────────────────────────────────────────────
  Future<ChartData> loadChartData({
    required String period,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final expenses = await _db.getAllExpenses();
    final filtered = _filterByDateRange(expenses, start, end);
    final timePeriod = period == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

    final processed = ExpensesDataProcessor.processExpensesData(
      filtered,
      timePeriod,
    );

    return ChartData(
      currentSpots: processed.currentSpots,
      previousSpots: processed.previousSpots,
      labels: processed.labels,
      maxY: processed.maxY,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Load list data
  // ──────────────────────────────────────────────────────────────
  Future<List<ExpenseModel>> loadExpenseList({
    required DateTime? start,
    required DateTime? end,
  }) async {
    final all = await _db.getAllExpenses();
    return _filterByDateRange(all, start, end);
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Date filter helper
  // ──────────────────────────────────────────────────────────────
  List<ExpenseModel> _filterByDateRange(
    List<ExpenseModel> expenses,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null || end == null) return expenses;

    return expenses
        .where((e) =>
            e.date.isAfter(start.subtract(const Duration(days: 1))) &&
            e.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ──────────────────────────────────────────────────────────────
  // 4. PDF export (thin wrapper)
  // ──────────────────────────────────────────────────────────────
  Future<void> exportToPdf({
    required BuildContext context,
    required String period,
    required DateTime? start,
    required DateTime? end,
    required List<ExpenseModel> items,
  }) async {
    await exportReportToPdf<ExpenseModel>( 
      context: context,
      title: 'Expenses Report',
      periodInfo: 
          ' From: ${_formatDate(start)} – To: ${_formatDate(end)}',
      headers: ['ID', 'Category', 'Date', 'Amount'],
      items: items,
      rowBuilder: (e) => [
        e.id.split('-').last,
        e.category,
        _dateFormatter.format(e.date),
        '₹${e.totalAmount.toStringAsFixed(2)}',
      ],
    );
  }

  String _formatDate(DateTime? d) => d == null ? '—' : _dateFormatter.format(d);
}

/// Simple DTO for chart data – makes the UI code readable.
class ChartData {
  final List<FlSpot> currentSpots;
  final List<FlSpot> previousSpots;
  final List<String> labels;
  final double maxY;

  ChartData({
    required this.currentSpots,
    required this.previousSpots,
    required this.labels,
    required this.maxY,
  });
}
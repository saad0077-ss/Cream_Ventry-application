// lib/utils/report/income_report_utils.dart
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_screen_pdf.dart';
import 'package:cream_ventory/core/utils/reports/graphs/income_graph_processer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeItem {
  final String id;
  final String type; // "Sale" or "Payment In"
  final DateTime date;
  final double amount;

  IncomeItem({
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
  });
}

class IncomeReportUtils {
  final _dateFormatter = DateFormat('dd MMM yyyy'); 
 
  // ──────────────────────────────────────────────────────────────
  // 1. Load chart data
  // ──────────────────────────────────────────────────────────────
  // lib/utils/report/income_report_utils.dart

  Future<ChartData> loadChartData({
    required String period,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final sales = await SaleDB.getSales();
    final payments = await PaymentInDb.getAllPayments();

    final timePeriod = period == 'Weekly'
        ? TimePeriod.weekly
        : TimePeriod.monthly;

    // ──────────────────────────────────────────────────────────────
    // Always use the *selected period* for chart structure
    // (Weekly = 7 days, Monthly = current month days)
    // ──────────────────────────────────────────────────────────────
    final now = DateTime.now();
    DateTime currentStart, currentEnd, previousStart, previousEnd;

    if (timePeriod == TimePeriod.weekly) {
      // Fixed: 7-day week (Mon–Sun) – always!
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      currentStart = DateTime(weekStart.year, weekStart.month, weekStart.day);
      currentEnd = currentStart.add(
        const Duration(days: 6, hours: 23, minutes: 59),
      );
      previousStart = currentStart.subtract(const Duration(days: 7));
      previousEnd = currentEnd.subtract(const Duration(days: 7));
    } else {
      // Fixed: Full current month
      currentStart = DateTime(now.year, now.month, 1);
      currentEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      previousStart = DateTime(now.year, now.month - 1, 1);
      previousEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
    }

    // ──────────────────────────────────────────────────────────────
    // But still filter data by custom date range (if provided)
    // ──────────────────────────────────────────────────────────────
    final List<SaleModel> filteredSales = sales.where((s) {
      final d = _safeParseDate(s.date);
      return d != null && _isInRange(d, start, end);
    }).toList();

    final List<PaymentInModel> filteredPayments = payments.where((p) {
      final d = _safeParseDate(p.date);
      return d != null && _isInRange(d, start, end);
    }).toList();

    final processed = IncomeDataProcessor.processIncomeData(
      sales: filteredSales,
      payments: filteredPayments,
      period: timePeriod,
      currentStart: currentStart,
      currentEnd: currentEnd,
      previousStart: previousStart,
      previousEnd: previousEnd,
    );

    return ChartData(
      currentSpots: processed.currentSpots,
      previousSpots: processed.previousSpots,
      labels: processed.labels,
      maxY: processed.maxY,
      errors: processed.errors,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Load list items (merged)
  // ──────────────────────────────────────────────────────────────
  Future<List<IncomeItem>> loadIncomeItems({
    required DateTime? start,
    required DateTime? end,
  }) async {
    final sales = await SaleDB.getSales();
    final payments = await PaymentInDb.getAllPayments();

    final List<IncomeItem> items = [];

    final dateParser = DateFormat('dd MMM yyyy');

    // Add Sales
    for (var sale in sales) {
      final date = dateParser.parse(sale.date);
      if (_isInRange(date, start, end)) {
        items.add(
          IncomeItem(
            id: sale.id.split('-').last,
            type: 'Sale',
            date: date,
            amount: sale.receivedAmount,
          ),
        );
      }
    }

    // Add Payments
    for (var payment in payments) {
      final date = dateParser.parse(payment.date);
      if (_isInRange(date, start, end)) {
        items.add(
          IncomeItem(
            id: payment.id.split('-').last,
            type: 'Payment In',
            date: date,
            amount: payment.receivedAmount,
          ),
        );
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  bool _isInRange(DateTime date, DateTime? start, DateTime? end) {
    if (start == null || end == null) return true;
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Calculate total income
  // ──────────────────────────────────────────────────────────────
  Future<double> calculateTotalIncome({
    required DateTime? start,
    required DateTime? end,
  }) async {
    try {
      final sales = await SaleDB.getSales();
      final payments = await PaymentInDb.getAllPayments();

      double total = 0.0;

      // ---- Sales ----------------------------------------------------
      for (final s in sales) {
        final date = _safeParseDate(s.date);
        if (date == null) continue; // skip bad dates
        if (!_isInRange(date, start, end)) continue; // skip out-of-range

        final amount = s.receivedAmount;
        total += amount;
      }

      // ---- Payments -------------------------------------------------
      for (final p in payments) {
        final date = _safeParseDate(p.date);
        if (date == null) continue;
        if (!_isInRange(date, start, end)) continue;

        final amount = p.receivedAmount;
        total += amount;
      }

      return total;
    } catch (e, stack) {
      debugPrint('calculateTotalIncome error: $e\n$stack');
      return 0.0; // never let the UI crash
    }
  }

  // -----------------------------------------------------------------
  // Helper: parse a date string safely
  // -----------------------------------------------------------------
 DateTime? _safeParseDate(String? raw) { 
  if (raw == null || raw.isEmpty) return null;
  try {
    return _dateFormatter.parseStrict(raw);  // Now uses 'dd MMM yyyy'
  } on FormatException catch (e) {
    debugPrint('Date parse error for "$raw": $e');
    return null;
  }   
}
  // ──────────────────────────────────────────────────────────────
  // 4. Export to PDF
  // ──────────────────────────────────────────────────────────────
   Future<void> exportToPdf({
    required BuildContext context,
    required String period,
    required DateTime? start,
    required DateTime? end,
    required List<IncomeItem> items,
  }) async {
    // Build professional period info string
    String periodInfo;
    if (start != null && end != null) {
      if (period == 'Weekly') {
        periodInfo = '${DateFormat('dd MMM yyyy ').format(start)} – ${DateFormat('dd MMM yyyy').format(end)}';
      } else if (period == 'Monthly') {
        periodInfo = DateFormat('MMMM yyyy').format(start);
      } else {
        // Custom date range
        periodInfo = '${_dateFormatter.format(start)} – ${_dateFormatter.format(end)}';
      }
    } else {
      periodInfo = 'All Time';
    }

    await exportReportToPdf<IncomeItem>(
      context: context,
      title: 'Income Report',
      periodInfo: periodInfo,
      companyName: 'Cream Ventory', // Your company/app name
      headers: ['Date', 'Type', 'ID', 'Amount'],
      items: items,
      rowBuilder: (item) => [
        _dateFormatter.format(item.date),
        item.type,
        item.id.split('-').last, // Short ID for cleaner look
        '₹${item.amount.toStringAsFixed(2)}',
      ],  
      amountColumnIndex: 3, // Amount column - enables automatic total calculation
      accentColor: Colors.blue, // Blue theme for income
    );
  }

}

 
class ChartData {
  final List<FlSpot> currentSpots;
  final List<FlSpot> previousSpots;
  final List<String> labels;
  final double maxY;
  final List<String> errors;

  ChartData({
    required this.currentSpots,
    required this.previousSpots,
    required this.labels,
    required this.maxY,
    this.errors = const [],
  });
}

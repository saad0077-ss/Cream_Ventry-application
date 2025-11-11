// utils/report/sales_report_screen_utils.dart
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_screen_pdf.dart';
import 'package:cream_ventory/core/utils/reports/graphs/sale_graph_processers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/time_period.dart';

/// ---------------------------------------------------------------
///  SalesReportUtils – thin UI-layer helper
/// ---------------------------------------------------------------
class SalesReportUtils {
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  // ──────────────────────────────────────────────────────────────
  // 1. Load chart data (weekly / monthly line chart)
  // ──────────────────────────────────────────────────────────────
  Future<ChartData> loadChartData({
    required String period,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final sales = await SaleDB.getSales(); // <-- same method you already use
    final filtered = _filterByDateRange(sales, start, end);

    final timePeriod = period == 'Weekly'
        ? TimePeriod.weekly
        : TimePeriod.monthly;

    final processed = SalesDataProcessor.processSalesData(filtered, timePeriod);

    return ChartData(
      currentSpots: processed.currentSpots,
      previousSpots: processed.previousSpots,
      labels: processed.labels,
      maxY: processed.maxY,
    );
  }

  // ──────────────────────────────────────────────────────────────
  // 2. Load list data (for the detailed list below the chart)
  // ──────────────────────────────────────────────────────────────
  Future<List<SaleModel>> loadSaleList({
    required DateTime? start,
    required DateTime? end,
  }) async {
    final all = await SaleDB.getSales();
    return _filterByDateRange(all, start, end);
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Date-range filter + sorting (newest first)
  // ──────────────────────────────────────────────────────────────
  List<SaleModel> _filterByDateRange(
    List<SaleModel> sales,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null || end == null) return sales;

    return sales
        .where(
          (s) {
              final saleDate = DateFormat('dd/MM/yyyy').parse(s.date);
              return saleDate.isAfter(start.subtract(const Duration(days: 1))) &&
              saleDate.isBefore(end.add(const Duration(days: 1)));}
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ──────────────────────────────────────────────────────────────
  // 4. PDF export (thin wrapper around the generic PDF helper)
  // ──────────────────────────────────────────────────────────────
  Future<void> exportToPdf({
    required BuildContext context, 
    required String period,
    required DateTime? start,
    required DateTime? end,
    required List<SaleModel> items,
  }) async {
    await exportReportToPdf<SaleModel>(
      context: context,
      title: 'Sales Report',
      periodInfo: 
          ' From: ${_formatDate(start)} – To: ${_formatDate(end)}',
      headers: [ 
        'ID',
        'Customer',
        'Date',
        'Amount',
      ], // <-- adjust if you want different columns
      items: items,
      rowBuilder: (s) => [
        s.id.split('-').last,
        s.customerName ?? '—', // <-- change to the field you prefer
        s.date,
        '₹${s.total.toStringAsFixed(2)}',
      ],
    );
  }

  String _formatDate(DateTime? d) => d == null ? '—' : _dateFormatter.format(d);
}

/// ---------------------------------------------------------------
///  DTO used by the UI – exactly the same shape as the expense version
/// ---------------------------------------------------------------
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
 
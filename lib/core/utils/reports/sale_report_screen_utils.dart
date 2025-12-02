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
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');
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
              final saleDate = DateFormat('dd MMM yyyy').parse(s.date);
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
    // Build professional period info string
    String periodInfo;
    if (start != null && end != null) {
      if (period == 'Weekly') {
        periodInfo = '${DateFormat('dd MMM yyyy').format(start)} – ${DateFormat('dd MMM yyyy').format(end)}'; 
      } else if (period == 'Monthly') {
        periodInfo = DateFormat('MMMM yyyy').format(start);
      } else {
        // Custom date range
        periodInfo = '${_dateFormatter.format(start)} – ${_dateFormatter.format(end)}';
      }
    } else {
      periodInfo = 'All Time';
    }

    await exportReportToPdf<SaleModel>(
      context: context,
      title: 'Sales Report',
      periodInfo: periodInfo,
      companyName: 'Cream Ventory', // Your company/app name
      headers: ['Date', 'Customer', 'Invoice No.', 'Amount'],
      items: items,
      rowBuilder: (sale) => [
        // Format date properly if it's a DateTime object
        sale.date is DateTime 
            ? _dateFormatter.format(sale.date as DateTime)   
            : _dateFormatter.format(DateFormat('dd MMM yyyy').parse(sale.date)), // Parse string and format
        sale.customerName ?? '—',
        sale.id.split('-').last, // Short ID for invoice number
        '₹${sale.total.toStringAsFixed(2)}',
      ],
      amountColumnIndex: 3, // Amount column - enables automatic total calculation
      accentColor: Colors.purple, // Purple theme for sales
    );
  }

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
 
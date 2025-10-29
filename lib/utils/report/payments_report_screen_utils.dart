// utils/report/payments_report_utils.dart
import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_screen_pdf.dart';
import 'package:cream_ventory/utils/report/graphs/payment_graph_processers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../screen/reports/screens/constants/time_period.dart';

/// ---------------------------------------------------------------
/// PaymentsReportUtils – thin UI-layer helper
/// ---------------------------------------------------------------
class PaymentsReportUtils {
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  // ──────────────────────────────────────────────────────────────
  // 1. Load chart data
  // ──────────────────────────────────────────────────────────────
  Future<ChartData> loadChartData({
    required String period,
    required String paymentType,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final List<dynamic> payments = paymentType == 'Payment In'
        ? await PaymentInDb.getAllPayments()
        : await PaymentOutDb.getAllPayments();

    final filtered = _filterByDateRange(payments, start, end);
    final timePeriod =
        period == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

    final processed = PaymentsDataProcessor.processPaymentsData(
      filtered,
      timePeriod,
      paymentType,
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
  Future<List<dynamic>> loadPaymentList({
    required String paymentType,
    required DateTime? start,
    required DateTime? end,
  }) async {
    final all = paymentType == 'Payment In'
        ? await PaymentInDb.getAllPayments()
        : await PaymentOutDb.getAllPayments();

    return _filterByDateRange(all, start, end);
  }

  // ──────────────────────────────────────────────────────────────
  // 3. Date-range filter + sorting (newest first) – SAFE
  // ──────────────────────────────────────────────────────────────
  List<dynamic> _filterByDateRange(
    List<dynamic> payments,
    DateTime? start,
    DateTime? end,
  ) {
    if (start == null || end == null) return payments;

    final startBound = start.subtract(const Duration(days: 1));
    final endBound = end.add(const Duration(days: 1));

    return payments
        .where((p) {
          final paymentDate = _dateFormatter.parse(p.date); // String → DateTime
          return paymentDate.isAfter(startBound) &&
                 paymentDate.isBefore(endBound);
        })
        .toList()
      ..sort((a, b) {
        final dateA = _dateFormatter.parse(a.date);
        final dateB = _dateFormatter.parse(b.date);
        return dateB.compareTo(dateA); // newest first  
      });
  }

  // ──────────────────────────────────────────────────────────────
  // 4. PDF export
  // ──────────────────────────────────────────────────────────────
  Future<void> exportToPdf({
    required BuildContext context,
    required String period,
    required String paymentType,
    required DateTime? start,
    required DateTime? end,
    required List<dynamic> items,
  }) async {
    final title = '$paymentType Report';
    final periodInfo =
        ' From: ${_formatDate(start)} – To: ${_formatDate(end)}';

    await exportListToPdf<dynamic>(
      context: context,
      title: title,
      periodInfo: periodInfo,
      headers: ['ID', 'Party', 'Date', 'Amount'],
      items: items,
      rowBuilder: (p) => [
        p.id.split('-').last, 
        p.party ?? '—',
        p.date, // already formatted
        '₹${p.amount.toStringAsFixed(2)}',
      ],
    );
  }

  String _formatDate(DateTime? d) =>
      d == null ? '—' : _dateFormatter.format(d);
}

/// ---------------------------------------------------------------
/// DTO for UI
/// ---------------------------------------------------------------
class ChartData {
  final List<FlSpot> currentSpots;
  final List<FlSpot> previousSpots;
  final List<String> labels;
  final double maxY;

  const ChartData({
    required this.currentSpots,
    required this.previousSpots,
    required this.labels,
    required this.maxY,
  });
}
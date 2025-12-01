// utils/report/payments_report_utils.dart
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_screen_pdf.dart';
import 'package:cream_ventory/core/utils/reports/graphs/payment_graph_processers.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/time_period.dart';

/// ---------------------------------------------------------------
/// PaymentsReportUtils – thin UI-layer helper
/// ---------------------------------------------------------------
class PaymentsReportUtils {
  final DateFormat _dateFormatter = DateFormat('dd MMM yyyy');

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

    return payments.where((p) {
      final paymentDate = _dateFormatter.parse(p.date); // String → DateTime
      return paymentDate.isAfter(startBound) && paymentDate.isBefore(endBound);
    }).toList()
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
    final dateFormat = DateFormat('dd MMM yyyy');

    await exportReportToPdf<dynamic>(
      context: context,
      title: '$paymentType Report',
      periodInfo: period == 'Weekly'
          ? '${start != null ? DateFormat('dd MMM').format(start) : ''} – ${end != null ? DateFormat('dd MMM').format(end) : ''}'
          : start != null
              ? DateFormat('MMM yyyy').format(start)
              : '',
      headers: ['Date', 'Party', 'Amount'],
      items: items,
      rowBuilder: (item) {
        if (item is PaymentInModel) {
          return [
            dateFormat.format(dateFormat.parse(item.date)),
            item.partyName ?? '—',
            '₹${item.receivedAmount.toStringAsFixed(2)}',
          ];
        } else if (item is PaymentOutModel) {
          return [
            dateFormat.format(dateFormat.parse(item.date)),
            item.partyName,
            '₹${item.paidAmount.toStringAsFixed(2)}',
          ];
        }
        return ['', '', ''];
      },
      amountColumnIndex: 2, // Amount is in last column
    );
  }
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

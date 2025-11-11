import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:intl/intl.dart';

class IncomeDataProcessor {
  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  }) processIncomeData({
    required List<SaleModel> sales,
    required List<PaymentInModel> payments,
    required TimePeriod period,
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklyIncome(
          sales: sales,
          payments: payments,
          currentStart: currentStart,
          currentEnd: currentEnd,
          previousStart: previousStart,
          previousEnd: previousEnd,
        );
      case TimePeriod.monthly:
        return _processMonthlyIncome(
          sales: sales,
          payments: payments,
          currentStart: currentStart,
          currentEnd: currentEnd,
          previousStart: previousStart,
          previousEnd: previousEnd,
        );
    }
  }

  static ({
    List<FlSpot> currentSpots,
    List<FlSpot> previousSpots,
    double maxY,
    List<String> labels,
    List<String> errors,
  }) _processWeeklyIncome({
    required List<SaleModel> sales,
    required List<PaymentInModel> payments,
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) {
    final currentResult = _aggregateIncome(
      sales: sales,
      payments: payments,
      startDate: currentStart,
      endDate: currentEnd,
      isWeekly: true,
    );
    final previousResult = _aggregateIncome(
      sales: sales,
      payments: payments,
      startDate: previousStart,
      endDate: previousEnd,
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
  }) _processMonthlyIncome({
    required List<SaleModel> sales,
    required List<PaymentInModel> payments,
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  }) {
    final lastDayOfMonth = currentEnd.day;
    final currentResult = _aggregateIncome(
      sales: sales,
      payments: payments,
      startDate: currentStart,
      endDate: currentEnd,
    );
    final previousResult = _aggregateIncome(
      sales: sales,
      payments: payments,
      startDate: previousStart,
      endDate: previousEnd,
    );

    final maxX = (lastDayOfMonth + 1).toDouble();
    final currentSpots = _fillMissingPoints(currentResult.spots, maxX);
    final previousSpots = _fillMissingPoints(previousResult.spots, maxX);
    final maxY = _calculateMaxY([...currentSpots, ...previousSpots]);
    final labels = [ ...List.generate(lastDayOfMonth, (index) => (index + 1).toString())];

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

  static ({List<FlSpot> spots, List<String> errors})_aggregateIncome({
    required List<SaleModel> sales,
    required List<PaymentInModel> payments,
    required DateTime startDate,
    required DateTime endDate,
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
    final daysInRange = normalizedEndDate.difference(normalizedStartDate).inDays + 1;
    final errors = <String>[];

    final Map<int, double> dailyIncome = isWeekly
        ? {for (int i = 1; i <= 7; i++) i: 0.0}
        : {for (int i = 1; i < daysInRange; i++) i: 0.0};

    // Process sales
    for (var sale in sales) {
      try {
        final saleDate = DateFormat('dd/MM/yyyy').parse(sale.date);

        final normalizedSaleDate = DateTime(
          saleDate.year,
          saleDate.month, 
          saleDate.day,  
        );
        if (normalizedSaleDate.isAtSameMomentAs(normalizedStartDate) ||
            (normalizedSaleDate.isAfter(normalizedStartDate) &&
                normalizedSaleDate.isBefore(
                  normalizedEndDate.add(const Duration(seconds: 1)),
                ))) {
          final index = isWeekly
              ? normalizedSaleDate.weekday
              : normalizedSaleDate.difference(normalizedStartDate).inDays + 1;
          if (dailyIncome.containsKey(index)) {
            dailyIncome[index] = (dailyIncome[index] ?? 0.0) + sale.receivedAmount.clamp(0, double.infinity);
          } else {
            errors.add(
              'Invalid index for sale: $index, Date: $saleDate, Sale ID: ${sale.id}',
            );
          }
        }
      } catch (e) {
        errors.add(
          'Error processing sale date: ${sale.date}, error: $e, Sale ID: ${sale.id}',
        );
        continue;
      }
    }

    // Process payments
    for (var payment in payments) {
      try {
        final paymentDate = DateFormat('dd/MM/yyyy').parse(payment.date);
        final normalizedPaymentDate = DateTime(
          paymentDate.year,
          paymentDate.month,
          paymentDate.day,
        );
        if (normalizedPaymentDate.isAtSameMomentAs(normalizedStartDate) ||
            (normalizedPaymentDate.isAfter(normalizedStartDate) && 
                normalizedPaymentDate.isBefore(
                  normalizedEndDate.add(const Duration(seconds: 1)),
                ))) {
          final index = isWeekly
              ? normalizedPaymentDate.weekday
              : normalizedPaymentDate.difference(normalizedStartDate).inDays + 1;
          if (dailyIncome.containsKey(index)) {
            dailyIncome[index] = (dailyIncome[index] ?? 0.0) + payment.receivedAmount.clamp(0, double.infinity);
          } else {
            errors.add(
              'Invalid index for payment: $index, Date: $paymentDate, Payment ID: ${payment.id}',
            );
          }
        }
      } catch (e) {
        errors.add(
          'Error processing payment date: ${payment.date}, error: $e, Payment ID: ${payment.id}',
        );
        continue;
      }
    }

    return (
      spots: dailyIncome.entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList(),
      errors: errors,
    );
  }

  static double _calculateMaxY(List<FlSpot> allSpots) {
    if (allSpots.isEmpty) return 100.0;
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
}
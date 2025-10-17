import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TimePeriod { weekly, monthly, yearly }

class PaymentOutDataProcessor {
  static ({List<FlSpot> spots, double maxY, List<String> labels}) processPaymentOutData(
      List<PaymentOutModel> paymentsOut, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklyPaymentsOut(paymentsOut);
      case TimePeriod.monthly:
        return _processMonthlyPaymentsOut(paymentsOut);
      case TimePeriod.yearly:
        return _processYearlyPaymentsOut(paymentsOut);
    }
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processWeeklyPaymentsOut(
      List<PaymentOutModel> paymentsOut) {
    final Map<int, double> paymentsByWeekday = {for (int i = 0; i < 7; i++) i: 0.0};
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var payment in paymentsOut) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(payment.date);
        final weekdayIndex = date.weekday - 1;
        paymentsByWeekday[weekdayIndex] = 
            (paymentsByWeekday[weekdayIndex] ?? 0.0) + payment.paidAmount;
      } catch (e) {
        debugPrint("Invalid date: ${payment.date}, error: $e, ID: ${payment.id}");
        continue;
      }
    }

    final max = paymentsByWeekday.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      7,
      (index) => FlSpot(index.toDouble(), (paymentsByWeekday[index] ?? 0) * scale),
    );

    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processMonthlyPaymentsOut(
      List<PaymentOutModel> paymentsOut) {
    final Map<int, double> paymentsByDay = {for (int i = 1; i <= 31; i++) i: 0.0};
    final labels = List.generate(31, (index) => (index + 1).toString());

    for (var payment in paymentsOut) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(payment.date);
        final day = date.day;
        paymentsByDay[day] = (paymentsByDay[day] ?? 0.0) + payment.paidAmount;
      } catch (e) {
        debugPrint("Invalid date: ${payment.date}, error: $e, ID: ${payment.id}");
        continue;
      }
    }

    final max = paymentsByDay.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      31,
      (index) => FlSpot(index.toDouble(), (paymentsByDay[index + 1] ?? 0) * scale),
    );

    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processYearlyPaymentsOut(
      List<PaymentOutModel> paymentsOut) {
    final Map<int, double> paymentsByMonth = {for (int i = 0; i < 12; i++) i: 0.0};
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    for (var payment in paymentsOut) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(payment.date);
        final monthIndex = date.month - 1;
        paymentsByMonth[monthIndex] = (paymentsByMonth[monthIndex] ?? 0.0) + payment.paidAmount;
      } catch (e) {
        debugPrint("Invalid date: ${payment.date}, error: $e, ID: ${payment.id}");
        continue;
      }
    }

    final max = paymentsByMonth.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), (paymentsByMonth[index] ?? 0) * scale),
    );

    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static String formatTooltip(int index, double value, TimePeriod period, double totalPayments) {
    final labels = period == TimePeriod.weekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : period == TimePeriod.monthly
            ? List.generate(31, (i) => (i + 1).toString())
            : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final label = labels[index];
    final actualValue = (value * (totalPayments / 100)).toStringAsFixed(2);
    return '$label\n₹-$actualValue';
  }

  static double getTotalPaymentsOut(List<PaymentOutModel> paymentsOut) {
    return paymentsOut.fold(0.0, (sum, payment) => sum + payment.paidAmount);
  } 

  static List<PaymentOutModel> filterByDateRange(List<PaymentOutModel> paymentsOut, DateTime start, DateTime end) {
    try {
      return paymentsOut.where((payment) {
        final date = DateFormat('dd/MM/yyyy').parseStrict(payment.date);
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
               date.isBefore(end.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
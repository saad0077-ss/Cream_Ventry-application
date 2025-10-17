import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/home/widgets/sale_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesDataProcessor {
  static ({List<FlSpot> spots, double maxY, List<String> labels}) processSalesData(
      List<SaleModel> sales, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return _processWeeklySales(sales);
      case TimePeriod.monthly:
        return _processMonthlySales(sales);
      case TimePeriod.yearly:
        return _processYearlySales(sales);
    }
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processWeeklySales(
      List<SaleModel> sales) {
    final Map<int, double> salesByWeekday = {for (int i = 0; i < 7; i++) i: 0.0};
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var sale in sales) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(sale.date);
        final weekdayIndex = date.weekday - 1;
        salesByWeekday[weekdayIndex] = (salesByWeekday[weekdayIndex] ?? 0.0) + sale.total;
      } catch (e) {
        debugPrint("Invalid date: ${sale.date}, error: $e, Sale ID: ${sale.id}");
        continue;
      }
    }

    final max = salesByWeekday.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      7,
      (index) => FlSpot(index.toDouble(), (salesByWeekday[index] ?? 0) * scale),
    );

    debugPrint("Weekly Sales FlSpots: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}");
    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processMonthlySales(
      List<SaleModel> sales) {
    final Map<int, double> salesByDay = {for (int i = 1; i <= 31; i++) i: 0.0};
    final labels = List.generate(31, (index) => (index + 1).toString());

    for (var sale in sales) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(sale.date);
        final day = date.day;
        salesByDay[day] = (salesByDay[day] ?? 0.0) + sale.total;
      } catch (e) {
        debugPrint("Invalid date: ${sale.date}, error: $e, Sale ID: ${sale.id}");
        continue;
      }
    }

    final max = salesByDay.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      31,
      (index) => FlSpot(index.toDouble(), (salesByDay[index + 1] ?? 0) * scale),
    );

    debugPrint("Monthly Sales FlSpots: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}");
    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static ({List<FlSpot> spots, double maxY, List<String> labels}) _processYearlySales(
      List<SaleModel> sales) {
    final Map<int, double> salesByMonth = {for (int i = 0; i < 12; i++) i: 0.0};
    final labels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    for (var sale in sales) {
      try {
        final date = DateFormat('dd/MM/yyyy').parseStrict(sale.date);
        final monthIndex = date.month - 1;
        salesByMonth[monthIndex] = (salesByMonth[monthIndex] ?? 0.0) + sale.total;
      } catch (e) {
        debugPrint("Invalid date: ${sale.date}, error: $e, Sale ID: ${sale.id}");
        continue;
      }
    }

    final max = salesByMonth.values.fold<double>(0.0, (a, b) => a > b ? a : b);
    final scale = max > 0 ? 100 / max : 1;
    final spots = List.generate(
      12,
      (index) => FlSpot(index.toDouble(), (salesByMonth[index] ?? 0) * scale),
    );

    debugPrint("Yearly Sales FlSpots: ${spots.map((s) => '(${s.x}, ${s.y})').join(', ')}");
    return (spots: spots, maxY: 100.0, labels: labels);
  }

  static String formatTooltip(int index, double value, TimePeriod period, double totalSales) {
    final labels = period == TimePeriod.weekly
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : period == TimePeriod.monthly
            ? List.generate(31, (i) => (i + 1).toString())
            : [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec'
              ];
    final label = labels[index];
    final actualValue = (value * (totalSales / 100)).toStringAsFixed(2);
    return '$label\n$actualValue';
  }
}
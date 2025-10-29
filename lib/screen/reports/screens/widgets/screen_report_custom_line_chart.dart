import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_custom_line_chart_details.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/time_period.dart';


class CustomLineChart extends StatelessWidget {
  final List<FlSpot> currentSpots;
  final List<FlSpot> previousSpots;
  final List<String> xAxisLabels;
  final double maxY;
  final TimePeriod period;
  final String Function(int, double, TimePeriod, bool)? tooltipFormatter;
  final Color cardBackgroundColor;
  final Color gridLineColor;
  final Color borderColor;
  final double elevation;

  const CustomLineChart({
    super.key,
    required this.currentSpots,
    required this.previousSpots,
    required this.xAxisLabels,
    required this.maxY,
    required this.period,
    this.tooltipFormatter,
    this.cardBackgroundColor = Colors.white,
    this.gridLineColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.elevation = 4.0,
  });

  // Default tooltip formatter
  String _defaultTooltipFormatter(int index, double value, TimePeriod period, bool isCurrentPeriod) {
    final labels = period == TimePeriod.weekly
        ? ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : List.generate(31, (i) => (i + 1).toString());
    final label = period == TimePeriod.monthly && index == 0
        ? 'Day 1'
        : (index < labels.length && index >= 0 ? labels[index] : 'Day ${index + 1}');
    final formattedValue = value.toStringAsFixed(2);
    final periodLabel = isCurrentPeriod ? 'Current' : 'Previous';
    return '$periodLabel $label\n₹$formattedValue';
  }  
  
  // Map TimePeriod enum to string for GraphLegend
  String _mapTimePeriodToString(TimePeriod period) {
    return period == TimePeriod.monthly ? 'Monthly' : 'Weekly';
  }

  @override
  Widget build(BuildContext context) {
    final verticalInterval = period == TimePeriod.monthly ? 5.0 : 1.0;

    return Card(
      elevation: elevation,
      color: cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor,width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Line Chart
            SizedBox(
              height: 200.h, // Adjustable height for the chart
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY / 4,
                    verticalInterval: verticalInterval,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: gridLineColor.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: gridLineColor.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: verticalInterval,
                        getTitlesWidget: (value, meta) {
                          final index = period == TimePeriod.weekly
                              ? value.toInt()
                              : value.toInt() - 1;
                          if (index < 0 || index >= xAxisLabels.length) {
                            return const Text('');
                          }
                          return Text(
                            xAxisLabels[index],
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${(value / 1000).toInt()}k',
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
                  ),
                  minX: period == TimePeriod.weekly ? 0 : 1,
                  maxX: period == TimePeriod.monthly ? xAxisLabels.length.toDouble() : 7,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: currentSpots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.blue,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: false),
                      preventCurveOverShooting: true,
                    ),
                    LineChartBarData(
                      spots: previousSpots,
                      isCurved: true,
                      curveSmoothness: 0.2,
                      color: Colors.red,
                      barWidth: 2,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.1),
                      ),
                      dotData: const FlDotData(show: false),
                      preventCurveOverShooting: true,
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = period == TimePeriod.weekly
                              ? spot.x.toInt()
                              : spot.x.toInt() - 1;
                          return LineTooltipItem(
                            tooltipFormatter?.call(index, spot.y, period, spot.bar.color == Colors.blue) ??
                                _defaultTooltipFormatter(index, spot.y, period, spot.bar.color == Colors.blue),
                            TextStyle(
                              color: spot.bar.color ?? Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
            // Graph Legend
            Padding(
              padding: EdgeInsets.only(top: 9.h),
              child: GraphLegend(
                selectedPeriod: _mapTimePeriodToString(period),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
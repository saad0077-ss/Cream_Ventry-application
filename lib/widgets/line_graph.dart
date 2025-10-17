import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final double maxY;
  final List<String> xAxisLabels;
  final String Function(int, double) tooltipFormatter;

  const LineChartWidget({
    super.key,
    required this.spots,
    required this.maxY,
    required this.xAxisLabels,
    required this.tooltipFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.black.withOpacity(0.4),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData( 
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 25,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                  ), 
                ),
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  return index >= 0 && index < xAxisLabels.length
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            xAxisLabels[index],
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        )
                      : const Text('');
                },
              ),
            ),
          ), 
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
          ),
          minX: 0,
          maxX: (xAxisLabels.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineBarsData: spots.isEmpty
              ? [] // Empty data when no sales
              : [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: Colors.blueAccent,
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.cyanAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.blueAccent,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.3),
                          Colors.cyanAccent.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 10,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {  
                  return LineTooltipItem(
                    tooltipFormatter(spot.x.toInt(), spot.y),
                    const TextStyle(color: Colors.white, fontSize: 12),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
} 
import 'package:cream_ventory/widgets/line_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  _SalesReportScreenState createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _selectedPeriod = 'Weekly';
  List<FlSpot> _salesSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 100;

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  void _updateChartData() {      
    setState(() {
      if (_selectedPeriod == 'Weekly') {
        _xAxisLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        _salesSpots = [
          FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 55), FlSpot(3, 70),
          FlSpot(4, 65), FlSpot(5, 80), FlSpot(6, 75),
        ];
        _maxY = 100;
      } else if (_selectedPeriod == 'Monthly') {
        _xAxisLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        _salesSpots = [
          FlSpot(0, 200), FlSpot(1, 250), FlSpot(2, 300), FlSpot(3, 280),
        ];
        _maxY = 350;
      }
    });
  }

  Widget _buildPeriodFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterButton('Weekly'),
        _buildFilterButton('Monthly'),
      ],
    );
  }

  Widget _buildFilterButton(String period) {
    bool isSelected = _selectedPeriod == period;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedPeriod = period;
          _updateChartData();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        period,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Report',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _buildPeriodFilter(),
          const SizedBox(height: 20),  
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),   
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChartWidget(
                  spots: _salesSpots,
                  maxY: _maxY,
                  xAxisLabels: _xAxisLabels,
                  tooltipFormatter: (x, y) =>
                      '$_selectedPeriod: ${y.toInt()} units',    
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
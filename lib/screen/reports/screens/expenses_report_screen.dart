import 'package:cream_ventory/widgets/line_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensesReportScreen extends StatefulWidget {
  const ExpensesReportScreen({super.key});

  @override
  _ExpensesReportScreenState createState() => _ExpensesReportScreenState();
}

class _ExpensesReportScreenState extends State<ExpensesReportScreen> {
  String _selectedPeriod = 'Weekly';
  List<FlSpot> _expensesSpots = [];
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
        _expensesSpots = [      
          FlSpot(0, 30), FlSpot(1, 35), FlSpot(2, 40), FlSpot(3, 45),
          FlSpot(4, 50), FlSpot(5, 55), FlSpot(6, 60),
        ];
        _maxY = 100;
      } else if (_selectedPeriod == 'Monthly') {
        _xAxisLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        _expensesSpots = [
          FlSpot(0, 150), FlSpot(1, 180), FlSpot(2, 200), FlSpot(3, 190),
        ];
        _maxY = 250;
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
        backgroundColor: isSelected ? Colors.redAccent : Colors.grey[300],
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
    return  Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Text(
              'Expenses Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            _buildPeriodFilter(),
            const SizedBox(height: 20),
            SizedBox(  // Changed SizedBox to Expanded for proper layout
              height: 300,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(      
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(   
                  padding: const EdgeInsets.all(16.0),
                  child: LineChartWidget(
                    spots: _expensesSpots,
                    maxY: _maxY,
                    xAxisLabels: _xAxisLabels,
                    tooltipFormatter: (x, y) =>
                        '$_selectedPeriod: \$${y.toInt()}',
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
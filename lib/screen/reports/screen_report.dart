// import 'package:cream_ventory/widgets/line_graph.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';

// class ScreenReport extends StatefulWidget {
//   final String reportTitle;

//   const ScreenReport({super.key, required this.reportTitle});

//   @override
//   _ScreenReportState createState() => _ScreenReportState();
// }

// class _ScreenReportState extends State<ScreenReport> {
//   String _selectedPeriod = 'Weekly'; // Default filter

//   // Placeholder data for sales, expenses, payment-in, and payment-out
//   List<FlSpot> _salesSpots = [];
//   List<FlSpot> _expensesSpots = [];
//   List<FlSpot> _paymentInSpots = [];
//   List<FlSpot> _paymentOutSpots = [];
//   List<String> _xAxisLabels = [];
//   double _maxY = 100;

//   @override
//   void initState() {
//     super.initState();
//     _updateChartData();
//   }

//   void _updateChartData() {
//     setState(() {
//       if (_selectedPeriod == 'Weekly') {
//         _xAxisLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//         _salesSpots = [
//           FlSpot(0, 50), FlSpot(1, 60), FlSpot(2, 55), FlSpot(3, 70),
//           FlSpot(4, 65), FlSpot(5, 80), FlSpot(6, 75),
//         ];
//         _expensesSpots = [
//           FlSpot(0, 30), FlSpot(1, 35), FlSpot(2, 40), FlSpot(3, 45),
//           FlSpot(4, 50), FlSpot(5, 55), FlSpot(6, 60),
//         ];
//         _paymentInSpots = [
//           FlSpot(0, 45), FlSpot(1, 55), FlSpot(2, 50), FlSpot(3, 65),
//           FlSpot(4, 60), FlSpot(5, 75), FlSpot(6, 70),
//         ];
//         _paymentOutSpots = [
//           FlSpot(0, 25), FlSpot(1, 30), FlSpot(2, 35), FlSpot(3, 40),
//           FlSpot(4, 45), FlSpot(5, 50), FlSpot(6, 55),
//         ];
//         _maxY = 100;
//       } else if (_selectedPeriod == 'Monthly') {
//         _xAxisLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
//         _salesSpots = [
//           FlSpot(0, 200), FlSpot(1, 250), FlSpot(2, 300), FlSpot(3, 280),
//         ];
//         _expensesSpots = [
//           FlSpot(0, 150), FlSpot(1, 180), FlSpot(2, 200), FlSpot(3, 190),
//         ];
//         _paymentInSpots = [
//           FlSpot(0, 180), FlSpot(1, 230), FlSpot(2, 270), FlSpot(3, 260),
//         ];
//         _paymentOutSpots = [
//           FlSpot(0, 130), FlSpot(1, 160), FlSpot(2, 180), FlSpot(3, 170),
//         ];
//         _maxY = 350;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: ' Reports',
//         fontSize: 24,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: AppTheme.appGradient,
//         ),
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Filter Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildFilterButton('Weekly'),
//                   _buildFilterButton('Monthly'),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               // Sales Graph
//               Text(
//                 'Sales',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: LineChartWidget(
//                     spots: _salesSpots,
//                     maxY: _maxY,
//                     xAxisLabels: _xAxisLabels,
//                     tooltipFormatter: (x, y) =>
//                         '$_selectedPeriod: ${y.toInt()} units',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Expenses Graph
//               Text(
//                 'Expenses',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: LineChartWidget(
//                     spots: _expensesSpots,
//                     maxY: _maxY,
//                     xAxisLabels: _xAxisLabels,
//                     tooltipFormatter: (x, y) =>
//                         '$_selectedPeriod: \$${y.toInt()}',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Payment - In Graph
//               Text(
//                 'Payment - In',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: LineChartWidget(
//                     spots: _paymentInSpots,
//                     maxY: _maxY,  
//                     xAxisLabels: _xAxisLabels,
//                     tooltipFormatter: (x, y) =>
//                         '$_selectedPeriod: \$${y.toInt()}',
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // Payment - Out Graph
//               Text(
//                 'Payment - Out',
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                       color: Colors.black87,
//                       fontWeight: FontWeight.bold,
//                     ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: LineChartWidget(
//                     spots: _paymentOutSpots,
//                     maxY: _maxY,
//                     xAxisLabels: _xAxisLabels,
//                     tooltipFormatter: (x, y) =>
//                         '$_selectedPeriod: \$${y.toInt()}',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterButton(String period) {
//     bool isSelected = _selectedPeriod == period;
//     return ElevatedButton(
//       onPressed: () {
//         setState(() {
//           _selectedPeriod = period;
//           _updateChartData();
//         });
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
//         foregroundColor: isSelected ? Colors.white : Colors.black87,
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//       ),
//       child: Text(
//         period,
//         style: TextStyle(
//           fontSize: 16,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//         ),
//       ),
//     );
//   }
// }   

import 'package:cream_ventory/screen/reports/screens/expenses_report_screen.dart';
import 'package:cream_ventory/screen/reports/screens/payments_report_screen.dart';
import 'package:cream_ventory/screen/reports/screens/sales_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';

class ScreenReport extends StatefulWidget {
  final String reportTitle;

  const ScreenReport({super.key, required this.reportTitle});

  @override
  _ScreenReportState createState() => _ScreenReportState();
}

class _ScreenReportState extends State<ScreenReport> {
  Widget _currentScreen = const SalesReportScreen();

  void _navigateToScreen(String screenName) {
    setState(() {
      switch (screenName) {
        case 'Sales':
          _currentScreen = const SalesReportScreen();
          break;
        case 'Expenses':
          _currentScreen = const ExpensesReportScreen();
          break;
        case 'Payments':
          _currentScreen = const PaymentsReportScreen();
          break;
      }
    });
  }

  Widget _buildNavigationButton(String tabName, IconData icon) {
    bool isSelected = _getCurrentScreenName() == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToScreen(tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                tabName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCurrentScreenName() {
    if (_currentScreen is SalesReportScreen) return 'Sales';
    if (_currentScreen is ExpensesReportScreen) return 'Expenses';
    if (_currentScreen is PaymentsReportScreen) return 'Payments';
    return 'Sales';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Reports',
        fontSize: 24,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appGradient,
        ),
        child: Column(
          children: [
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin: const EdgeInsets.all(16), 
              child: Row(
                children: [
                  _buildNavigationButton('Sales', Icons.trending_up),
                  SizedBox(width: 8),
                  _buildNavigationButton('Expenses', Icons.money_off),
                   SizedBox(width: 8),  
                  _buildNavigationButton('Payments', Icons.payment),
                ],
              ),
            ),
            // Current Screen
            Expanded(
              child: _currentScreen,
            ),
          ],
        ),
      ),
    );
  }
}
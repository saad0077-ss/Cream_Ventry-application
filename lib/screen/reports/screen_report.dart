import 'package:cream_ventory/screen/reports/screens/expenses_report_screen.dart';
import 'package:cream_ventory/screen/reports/screens/income_report_screen.dart';
import 'package:cream_ventory/screen/reports/screens/payments_report_screen.dart';
import 'package:cream_ventory/screen/reports/screens/sales_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScreenReport extends StatefulWidget {
  final String reportTitle;

  const ScreenReport({super.key, required this.reportTitle});

  @override
  _ScreenReportState createState() => _ScreenReportState();
}

class _ScreenReportState extends State<ScreenReport> {
  Widget _currentScreen = const IncomeReportScreen();
  double _scale = 1.0; // Add scale state for bounce animation

  void _navigateToScreen(String screenName) {
    setState(() { 
      switch (screenName) {
        case 'Sales':
          _currentScreen = const SalesReportScreen();
          break; 
        case 'Expense':
          _currentScreen = const ExpensesReportScreen();    
          break;
        case 'Payment':
          _currentScreen = const PaymentsReportScreen();
          break;
        case 'Income':
          _currentScreen = const IncomeReportScreen();
          break;
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.9; // Scale down on tap
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0; // Bounce back to normal
    });
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0; // Restore scale if tap canceled
    });
  }

  Widget _buildNavigationButton(String tabName, IconData icon) {

    final bool  isSMobile = MediaQuery.of(context).size.width < 375;

    bool isSelected = _getCurrentScreenName() == tabName;
    return Expanded(
      child: GestureDetector(
        onTapDown: _onTapDown, 
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () => _navigateToScreen(tabName),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceOut, // Bounce effect
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueGrey : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blueGrey : Colors.blueGrey,
                width: 2,
              ),
            ), 
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                 SizedBox(height: 4.h),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  style: TextStyle(
                    fontSize: isSMobile? 10 : 14.r,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.blueGrey,
                  ),
                  child: Text(tabName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentScreenName() {
    if (_currentScreen is SalesReportScreen) return 'Sales';
    if (_currentScreen is ExpensesReportScreen) return 'Expense';
    if (_currentScreen is PaymentsReportScreen) return 'Payment';
    if (_currentScreen is IncomeReportScreen) return 'Income'; 
    return 'Income';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Report', 
        fontSize: 24.r,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.appGradient,                                             
        ),
        child: Column(
          children: [  
            // Navigation Buttons
            Container(
              padding:  EdgeInsets.all(8.r), 
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin:  EdgeInsets.all(16.r), 
              child: Row(
                children: [ 
                  _buildNavigationButton('Income', FontAwesomeIcons.indianRupeeSign), 
                   SizedBox(width: 8.w,),
                  _buildNavigationButton('Sales', Icons.trending_up),
                   SizedBox(width: 8.w),  
                  _buildNavigationButton('Expense', FontAwesomeIcons.wallet),
                   SizedBox(width: 8.w),   
                  _buildNavigationButton('Payment', Icons.payment) 
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
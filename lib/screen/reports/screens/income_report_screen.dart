// import 'package:cream_ventory/db/functions/payment_db.dart';
// import 'package:cream_ventory/db/functions/sale/sale_db.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_custom_line_chart.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_montly_weekly_tap.dart';
// import 'package:cream_ventory/utils/report/graphs/income_graph_processer.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'constants/time_period.dart';

// class IncomeReportScreen extends StatefulWidget {
//   const IncomeReportScreen({super.key});

//   @override
//   _IncomeReportScreenState createState() => _IncomeReportScreenState();
// }

// class _IncomeReportScreenState extends State<IncomeReportScreen> {
//   String _selectedPeriod = 'Weekly';
//   List<FlSpot> _currentSpots = [];
//   List<FlSpot> _previousSpots = [];
//   List<String> _xAxisLabels = [];
//   double _maxY = 10000;
//   String? _errorMessage;
//   double _totalIncome = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     await _updateChartData();
//   }

//   Future<void> _updateChartData() async {
//     try {
//       final now = DateTime.now();
//       TimePeriod period = _selectedPeriod == 'Weekly'
//           ? TimePeriod.weekly
//           : TimePeriod.monthly;

//       DateTime currentStart, currentEnd, previousStart, previousEnd;

//       if (period == TimePeriod.weekly) {
//         // Current week: Monday to Sunday
//         final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
//         currentStart = DateTime(
//           currentWeekStart.year,
//           currentWeekStart.month,
//           currentWeekStart.day,
//         );
//         currentEnd = currentStart.add(
//           const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
//         );
//         // Previous week
//         previousStart = currentStart.subtract(const Duration(days: 7));
//         previousEnd = currentEnd.subtract(const Duration(days: 7));
//       } else {
//         // Current month
//         currentStart = DateTime(now.year, now.month, 1);
//         currentEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
//         // Previous month
//         previousStart = DateTime(now.year, now.month - 1, 1);
//         previousEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
//       }

//       // Fetch sales and payment-in data
//       final sales = await SaleDB.getSales();
//       final payments = await PaymentInDb.getAllPayments();

//       // Process data for the chart
//       final processedData = IncomeDataProcessor.processIncomeData(
//         sales: sales,
//         payments: payments,
//         period: period,
//         currentStart: currentStart,
//         currentEnd: currentEnd,
//         previousStart: previousStart,
//         previousEnd: previousEnd,
//       );

//       // Calculate total income for the current period
//       final totalIncome = await _calculateTotalIncome(
//         currentStart: currentStart,
//         currentEnd: currentEnd,
//       );

//       setState(() {
//         _currentSpots = processedData.currentSpots;
//         _previousSpots = processedData.previousSpots;
//         _xAxisLabels = processedData.labels;
//         _maxY = processedData.maxY;
//         _totalIncome = totalIncome;
//         _errorMessage = processedData.errors.isNotEmpty
//             ? 'Errors occurred: ${processedData.errors.join(', ')}'
//             : null;
//       });

//       if (_errorMessage != null && mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
//       }
//     } catch (e) {
//       debugPrint('Error updating income chart data: $e');
//       setState(() {
//         _errorMessage = 'Failed to load income data. Showing placeholder data.';
//         if (_selectedPeriod == 'Weekly') {
//           _xAxisLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//           _currentSpots = List.generate(
//             7,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _previousSpots = List.generate(
//             7,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _maxY = 10000;
//           _totalIncome = 0.0;
//         } else {
//           final now = DateTime.now();
//           final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
//           _xAxisLabels = [
//             '',
//             ...List.generate(lastDayOfMonth, (index) => (index + 1).toString()),
//           ];
//           _currentSpots = List.generate(
//             lastDayOfMonth,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _previousSpots = List.generate(
//             lastDayOfMonth,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _maxY = 10000;
//           _totalIncome = 0.0;
//         }
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
//       }
//     }
//   }

//   Future<double> _calculateTotalIncome({
//     required DateTime currentStart,
//     required DateTime currentEnd,
//   }) async {
//     try {
//       final sales = await SaleDB.getSales();
//       final payments = await PaymentInDb.getAllPayments();

//      final totalSales = sales
//     .where((sale) {
//       // Convert sale.date from String → DateTime
//       final saleDate = DateFormat('dd/MM/yyyy').parse(sale.date);

//       return saleDate.isAfter(currentStart.subtract(const Duration(days: 1))) &&
//           saleDate.isBefore(currentEnd.add(const Duration(days: 1)));
//     })
//     .fold<double>(0.0, (sum, sale) => sum + (sale.receivedAmount));

// final totalPayments = payments
//     .where((payment) {
//       // Convert payment.date from String → DateTime
//       final paymentDate = DateFormat('dd/MM/yyyy').parse(payment.date);

//       return paymentDate.isAfter(currentStart.subtract(const Duration(days: 1))) &&
//           paymentDate.isBefore(currentEnd.add(const Duration(days: 1)));
//     })
//     .fold<double>(0.0, (sum, payment) => sum + (payment.receivedAmount));

//       final total = totalSales + totalPayments;
//       debugPrint(
//         'Total income for period $currentStart to $currentEnd: $total',
//       );
//       return total;
//     } catch (e) {
//       debugPrint('Error calculating total income: $e');
//       return 0.0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final period = _selectedPeriod == 'Weekly'
//         ? TimePeriod.weekly
//         : TimePeriod.monthly;
//     // Get the current month name
//     // final now = DateTime.now();
//     // final monthName = DateFormat('MMMM').format(now); // e.g., "October"

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Income Report',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             PeriodFilter(
//               selectedPeriod: _selectedPeriod,
//               onPeriodChanged: (String period) {
//                 setState(() {
//                   _selectedPeriod = period;
//                   _updateChartData();
//                 });
//               },
//             ),
//             const SizedBox(height: 20),
//             if (_errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 10),
//                 child: Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.red, fontSize: 14),
//                 ),
//               ),
//             SizedBox(
//               height: 270.h,
//               child: CustomLineChart(
//                 currentSpots: _currentSpots,
//                 previousSpots: _previousSpots,
//                 xAxisLabels: _xAxisLabels,
//                 maxY: _maxY,
//                 period: period,
//                 cardBackgroundColor: Colors.transparent,
//                 gridLineColor: Colors.black38,
//                 borderColor: Colors.black12,
//                 elevation: 2.0,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               'Total Income: ₹${_totalIncome.toStringAsFixed(2)}',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Colors.green,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// lib/screen/reports/screens/income_report_screen.dart
import 'package:cream_ventory/screen/reports/screens/constants/time_period.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_custom_line_chart.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_date_picker_row.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_list_container.dart';
import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_montly_weekly_tap.dart';
import 'package:cream_ventory/utils/report/income_report_screen_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class IncomeReportScreen extends StatefulWidget {
  const IncomeReportScreen({super.key});

  @override
  State<IncomeReportScreen> createState() => _IncomeReportScreenState();
}

class _IncomeReportScreenState extends State<IncomeReportScreen> {
  // UI State
  String _selectedPeriod = 'Weekly';
  DateTime? _startDate;
  DateTime? _endDate;

  // Data State
  List<FlSpot> _currentSpots = [];
  List<FlSpot> _previousSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 10000;
  double _totalIncome = 0.0;
  List<IncomeItem> _incomeItems = [];
  String? _errorMessage;

  final _utils = IncomeReportUtils();
  final _dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate?.subtract(const Duration(days: 30));
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadChart(), _loadListAndTotal()]);
  }

  Future<void> _loadChart() async {
    try {
      final chart = await _utils.loadChartData(
        period: _selectedPeriod,
        start: _startDate,
        end: _endDate,
      );
      setState(() {
        _currentSpots = chart.currentSpots;
        _previousSpots = chart.previousSpots;
        _xAxisLabels = chart.labels;
        _maxY = chart.maxY;
        _errorMessage = chart.errors.isNotEmpty
            ? chart.errors.join(', ')
            : null;
      });
    } catch (e) {
      _setPlaceholderChart();
    }
  }

  Future<void> _loadListAndTotal() async {
    try {
      final items = await _utils.loadIncomeItems(
        start: _startDate,
        end: _endDate,
      );
      final total = items.fold(0.0, (sum, i) => sum + i.amount);
      setState(() {
        _incomeItems = items;
        _totalIncome = total;
      });
    } catch (e) {
      debugPrint('List error: $e');
      setState(() => _incomeItems = []);
    }
  }

  void _setPlaceholderChart() {
    setState(() {
      _errorMessage = 'Failed to load data.';
      if (_selectedPeriod == 'Weekly') {
        _xAxisLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        _currentSpots = List.generate(7, (i) => FlSpot((i + 1).toDouble(), 0));
        _previousSpots = List.generate(7, (i) => FlSpot((i + 1).toDouble(), 0));
      } else {
        final days = DateTime(
          DateTime.now().year,
          DateTime.now().month + 1,
          0,
        ).day;
        _xAxisLabels = List.generate(days + 1, (i) => i == 0 ? '' : '$i');
        _currentSpots = List.generate(
          days,
          (i) => FlSpot((i + 1).toDouble(), 0),
        );
        _previousSpots = List.generate(
          days,
          (i) => FlSpot((i + 1).toDouble(), 0),
        );
      }
      _maxY = 10000;
    });
  }

  // Date Picker
  Future<void> _pickDate(bool isStart) async {
    final init = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate = _startDate!.add(const Duration(days: 1));
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _endDate!.isBefore(_startDate!)) {
          _startDate = _endDate!.subtract(const Duration(days: 1));
        }
      }
    });
    _loadAll();
  }

  // Export Modal
  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Export Report',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  _utils.exportToPdf(
                    context: context,
                    period: _selectedPeriod,
                    start: _startDate,
                    end: _endDate,
                    items: _incomeItems,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final period = _selectedPeriod == 'Weekly'
        ? TimePeriod.weekly
        : TimePeriod.monthly;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Period Filter
            PeriodFilter(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (p) {
                setState(() => _selectedPeriod = p);
                _loadAll();
              },
            ),
            const SizedBox(height: 20),

            // Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Chart
            SizedBox(
              height: 270.h,
              child: CustomLineChart(
                currentSpots: _currentSpots,
                previousSpots: _previousSpots,
                xAxisLabels: _xAxisLabels,
                maxY: _maxY,
                period: period,
                cardBackgroundColor: Colors.transparent,
                gridLineColor: Colors.black38,
                borderColor: Colors.blueGrey,
                elevation: 2,
              ),
            ),
            const SizedBox(height: 10),

            // // Total Income
            // Text(
            //   'Total Income: ₹${_totalIncome.toStringAsFixed(2)}',
            //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //         color: Colors.green,
            //         fontWeight: FontWeight.w600,
            //       ),
            // ),
            // const SizedBox(height: 20),

            // Date Pickers
            DatePickerRow(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: () => _pickDate(true),
              onSelectEnd: () => _pickDate(false),
            ),
            SizedBox(height: 20.h),

            // List Container
            ReportListContainer<IncomeItem>(
              title: 'Income Details',
              items: _incomeItems,
              onExportPressed: _showExportOptions,
              itemBuilder: (_, item, __) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  leading: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _dateFormatter.format(item.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  title: Center(
                    child: Text(
                      item.id.split('-').last,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  trailing: Text(
                    '₹${item.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),  
                border: Border.all(color: Colors.blueGrey,width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Income',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '₹${_totalIncome.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

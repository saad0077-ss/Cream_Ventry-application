// import 'package:cream_ventory/db/functions/sale/sale_db.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_custom_line_chart.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_montly_weekly_tap.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:cream_ventory/utils/report/graphs/sale_graph_processers.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'constants/time_period.dart';

// class SalesReportScreen extends StatefulWidget {
//   const SalesReportScreen({super.key});

//   @override
//   _SalesReportScreenState createState() => _SalesReportScreenState();
// }

// class _SalesReportScreenState extends State<SalesReportScreen> {
//   String _selectedPeriod = 'Weekly';
//   List<FlSpot> _currentSpots = [];
//   List<FlSpot> _previousSpots = [];
//   List<String> _xAxisLabels = [];
//   double _maxY = 10000;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _updateChartData();
//   }

//   Future<void> _updateChartData() async {
//     try {
//       final sales = await SaleDB.getSales();
//       TimePeriod period = _selectedPeriod == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

//       final processedData = SalesDataProcessor.processSalesData(sales, period);

//       setState(() {
//         _currentSpots = processedData.currentSpots;
//         _previousSpots = processedData.previousSpots;
//         _xAxisLabels = processedData.labels;
//         _maxY = processedData.maxY;
//         _errorMessage = processedData.errors.isNotEmpty ? processedData.errors.join('\n') : null;
//       });
//     } catch (e) {
//       debugPrint('Error updating sales chart data: $e');
//       setState(() {
//         _errorMessage = 'Failed to load sales data. Showing placeholder data.';
//         if (_selectedPeriod == 'Weekly') {
//           _xAxisLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//           _currentSpots = List.generate(7, (index) => FlSpot((index + 1).toDouble(), 0));
//           _previousSpots = List.generate(7, (index) => FlSpot((index + 1).toDouble(), 0));
//           _maxY = 10000;
//         } else {
//           final now = DateTime.now();
//           final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
//           _xAxisLabels = List.generate(lastDayOfMonth, (index) => (index + 1).toString());
//           _currentSpots = List.generate(lastDayOfMonth, (index) => FlSpot((index + 1).toDouble(), 0));
//           _previousSpots = List.generate(lastDayOfMonth, (index) => FlSpot((index + 1).toDouble(), 0));
//           _maxY = 10000;
//         }
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(_errorMessage!)),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final period = _selectedPeriod == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Sales Report',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     color: Colors.black87,
//                     fontWeight: FontWeight.bold,
//                   ),
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
//               gridLineColor: Colors.black38,
//               borderColor: Colors.black12,
//               elevation: 2.0
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cream_ventory/models/sale_model.dart'; // <-- NEW
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_custom_line_chart.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_date_picker_row.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_list_container.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_montly_weekly_tap.dart';
import 'package:cream_ventory/core/utils/reports/sale_report_screen_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  // ───── UI state ─────
  String _selectedPeriod = 'Weekly';
  DateTime? _startDate;
  DateTime? _endDate;

  // ───── Data state ─────
  List<FlSpot> _currentSpots = [];
  List<FlSpot> _previousSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 10000;

  List<SaleModel> _sales = [];
  String? _errorMessage;

  final _utils = SalesReportUtils(); // <-- NEW
  // ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now().toUtc();
    _startDate = _endDate?.subtract(const Duration(days: 30));
    _loadAll();
  }

  // ──────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    await Future.wait([_loadChart(), _loadList()]);
  }

  double _getTotalSales() {
    if (_sales.isEmpty) return 0.0;
    return _sales.fold<double>(0.0, (sum, sale) => sum + (sale.total));
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
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Chart error: $e');
      _setPlaceholderChart();
    }
  }

  Future<void> _loadList() async {
    try {
      final list = await _utils.loadSaleList(start: _startDate, end: _endDate);
      setState(() => _sales = list);
    } catch (e) {
      debugPrint('List error: $e');
      setState(() => _sales = []);
    }
  }

  void _setPlaceholderChart() {
    setState(() {
      _errorMessage = 'Failed to load data. Showing placeholder.';
      if (_selectedPeriod == 'Weekly') {
        _xAxisLabels = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        _currentSpots = List.generate(7, (i) => FlSpot((i + 1).toDouble(), 0));
        _previousSpots = List.generate(7, (i) => FlSpot((i + 1).toDouble(), 0));
      } else {
        final now = DateTime.now();
        final days = DateTime(now.year, now.month + 1, 0).day;
        _xAxisLabels = List.generate(days, (i) => (i + 1).toString());
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
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage!)));
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Date picker
  // ──────────────────────────────────────────────────────────────
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

  // ──────────────────────────────────────────────────────────────
  // Export modal
  // ──────────────────────────────────────────────────────────────
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
                    items: _sales,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // UI
  // ──────────────────────────────────────────────────────────────
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
            // ── Title ──
            Text(
              'Sales Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // ── Period filter ──
            PeriodFilter(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (p) {
                setState(() => _selectedPeriod = p);
                _loadAll();
              },
            ),
            const SizedBox(height: 20),

            // ── Error ──
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ), 

            // ── Chart ──
            SizedBox(
              height: 280.h,
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
            const SizedBox(height: 20),

            // ── Date pickers ──
            DatePickerRow(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: () => _pickDate(true),
              onSelectEnd: () => _pickDate(false),
            ),
            const SizedBox(height: 20),

            // ── Sales list ──
            ReportListContainer<SaleModel>(
              title: 'Sale Details',
              items: _sales,
              onExportPressed: _showExportOptions,
              itemBuilder: (_, s, __) => Card(
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
                      // Replace `customerName` with the field you want to show
                      Text(
                        s.customerName ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        s.date,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  title: Center(
                    child: Text(
                      s.id.split('-').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  trailing: Text(
                    '₹${s.total.toStringAsFixed(2)}',
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
                    'Total Sales',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),   
                  Text(
                    '₹${_getTotalSales().toStringAsFixed(2)}',
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

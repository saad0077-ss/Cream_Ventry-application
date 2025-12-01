

// lib/screen/reports/screens/income_report_screen.dart
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_custom_line_chart.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_date_picker_row.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_list_container.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_montly_weekly_tap.dart';
import 'package:cream_ventory/core/utils/reports/income_report_screen_utils.dart';
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
  final _dateFormatter = DateFormat('dd MMM yyyy');

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
      padding:  EdgeInsets.all(16.r),
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
             SizedBox(height: 10.h),

            // Period Filter
            PeriodFilter(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (p) {
                setState(() => _selectedPeriod = p);
                _loadAll();
              },
            ),
             SizedBox(height: 20.h),

            // Error
            if (_errorMessage != null)
              Padding(
                padding:  EdgeInsets.only(bottom: 10.r),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Chart
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
             SizedBox(height: 10.h),
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
                        style:  TextStyle(
                          fontSize: 18.r,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _dateFormatter.format(item.date),
                        style: TextStyle(fontSize: 12.r, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  title: Center(
                    child: Text(
                      item.id.split('-').last,
                      style:  TextStyle(
                        fontSize: 12.r,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  trailing: Text(
                    '₹${item.amount.toStringAsFixed(2)}',
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.r,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
             SizedBox(height: 20.h),
            Container(
              padding:  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8.r),  
                border: Border.all(color: Colors.blueGrey,width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Total Income',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.r),
                  ),
                  Text(
                    '₹${_totalIncome.toStringAsFixed(2)}',
                    style:  TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.r,
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

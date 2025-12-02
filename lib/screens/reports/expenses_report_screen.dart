import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:cream_ventory/screens/reports/widgets/report_screen_custom_total_section.dart';
import 'package:cream_ventory/screens/reports/widgets/report_screen_transaction_card.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_custom_line_chart.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_date_picker_row.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_list_container.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_montly_weekly_tap.dart';
import 'package:cream_ventory/core/utils/reports/expense_report_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensesReportScreen extends StatefulWidget {
  const ExpensesReportScreen({super.key});

  @override
  State<ExpensesReportScreen> createState() => _ExpensesReportScreenState();
}

class _ExpensesReportScreenState extends State<ExpensesReportScreen> {
  // ───── UI state ─────
  String _selectedPeriod = 'Weekly';
  DateTime? _startDate;
  DateTime? _endDate;

  // ───── Data state ─────
  List<FlSpot> _currentSpots = [];
  List<FlSpot> _previousSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 10000;

  List<ExpenseModel> _expenses = [];
  String? _errorMessage;

  final _utils = ExpenseReportUtils();

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

  double _getTotalExpenses() {
    if (_expenses.isEmpty) return 0.0;
    return _expenses.fold<double>(
      0.0,
      (sum, exp) => sum + (exp.totalAmount),
    );
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
      final list = await _utils.loadExpenseList(
        start: _startDate,
        end: _endDate,
      );
      setState(() => _expenses = list);
    } catch (e) {
      debugPrint('List error: $e');
      setState(() => _expenses = []);
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
  }

  // ──────────────────────────────────────────────────────────────
  // Date picker
  // ──────────────────────────────────────────────────────────────
  Future<void> _pickDate(bool isStart) async {
    final init =
        isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());

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
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Export Report',
                style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () async {
                  Navigator.pop(context); // Close modal immediately

                  // Show tiny spinner while generating
                  final overlay = OverlayEntry(
                    builder: (_) => const Center(
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                  Overlay.of(context).insert(overlay);

                  try {
                    await _utils.exportToPdf(
                      context: context,
                      period: _selectedPeriod,
                      start: _startDate,
                      end: _endDate,
                      items: _expenses,
                    );
                  } finally {
                    overlay.remove(); // Always remove spinner
                  }
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
    final period =
        _selectedPeriod == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Expense Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 10.h),

            // Period filter
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
                padding: EdgeInsets.only(bottom: 10.r),
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
            SizedBox(height: 20.h),

            // Date pickers (re-using the new widget)
            DatePickerRow(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: () => _pickDate(true),
              onSelectEnd: () => _pickDate(false),
            ),
            SizedBox(height: 20.h),

            // List container
            ReportListContainer<ExpenseModel>(
                title: 'Expense Details',
                items: _expenses,
                onExportPressed: _showExportOptions,
                itemBuilder: (_, e, __) => TransactionCard(
                      title: e.category,
                      subtitle: DateFormat('dd MMM yyyy').format(e.date),
                      id: e.id,
                      amount: e.totalAmount,
                      icon: Icons.shopping_cart_outlined,
                      iconColor: Colors.red,
                      iconBackgroundColor: Colors.red.withOpacity(0.1),
                      amountColor: Colors.red[700],
                    )),
            SizedBox(height: 20.h),

            StatsCard(
              title: 'Total Expenses',
              amount: '₹${_getTotalExpenses().toStringAsFixed(2)}',
              icon: Icons.trending_down_rounded,
              primaryColor: const Color(0xFFEF4444), // Red for expenses
              secondaryColor: const Color(0xFFDC2626),
              count: _expenses.length,
              countLabel: 'Expenses',
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

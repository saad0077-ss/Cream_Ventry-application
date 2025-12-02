import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/core/constants/time_period.dart';
import 'package:cream_ventory/screens/reports/widgets/report_screen_custom_total_section.dart';
import 'package:cream_ventory/screens/reports/widgets/report_screen_transaction_card.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_custom_line_chart.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_date_picker_row.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_list_container.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_montly_weekly_tap.dart';
import 'package:cream_ventory/screens/reports/widgets/screen_report_payment_in_out_tap.dart';
import 'package:cream_ventory/core/utils/reports/payments_report_screen_utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PaymentsReportScreen extends StatefulWidget {
  const PaymentsReportScreen({super.key});

  @override
  State<PaymentsReportScreen> createState() => _PaymentsReportScreenState();
}

class _PaymentsReportScreenState extends State<PaymentsReportScreen> {
  // ───── UI state ─────
  String _selectedPeriod = 'Weekly';
  String _selectedPaymentType = 'Payment In';
  DateTime? _startDate;
  DateTime? _endDate;

  // ───── Data state ─────
  List<FlSpot> _currentSpots = [];
  List<FlSpot> _previousSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 10000;

  List<dynamic> _payments =
      []; // dynamic → works for both PaymentInModel & PaymentOutModel
  String? _errorMessage;

  final _utils = PaymentsReportUtils();
  final _dateFormatter = DateFormat('dd MMM yyyy');

  // -----------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now().toUtc();
    _startDate = _endDate?.subtract(const Duration(days: 30));
    _loadAll();
    _setupListeners();
  }

  double _getTotalAmount() {
    if (_payments.isEmpty) return 0.0;

    return _payments.fold<double>(0.0, (sum, p) {
      // PaymentInModel → receivedAmount
      // PaymentOutModel → paidAmount
      final amount = (p is PaymentInModel) ? p.receivedAmount : p.paidAmount;
      return sum + (amount ?? 0.0);
    });
  }

  // -----------------------------------------------------------------------
  void _setupListeners() {
    PaymentInDb.paymentInNotifier.addListener(_onDataChanged);
    PaymentOutDb.paymentOutNotifier.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) _loadAll();
  }

  // -----------------------------------------------------------------------
  Future<void> _loadAll() async {
    await Future.wait([_loadChart(), _loadList()]);
  }

  // -----------------------------------------------------------------------
  Future<void> _loadChart() async {
    try {
      final chart = await _utils.loadChartData(
        period: _selectedPeriod,
        paymentType: _selectedPaymentType,
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

  // -----------------------------------------------------------------------
  Future<void> _loadList() async {
    try {
      final list = await _utils.loadPaymentList(
        paymentType: _selectedPaymentType,
        start: _startDate,
        end: _endDate,
      );
      setState(() => _payments = list);
    } catch (e) {
      debugPrint('List error: $e');
      setState(() => _payments = []);
    }
  }

  // -----------------------------------------------------------------------
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

  // -----------------------------------------------------------------------
  // Date picker
  // -----------------------------------------------------------------------
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

  // -----------------------------------------------------------------------
  // Export modal
  // -----------------------------------------------------------------------
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
                    paymentType: _selectedPaymentType,
                    start: _startDate,
                    end: _endDate,
                    items: _payments,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // UI
  // -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final period =
        _selectedPeriod == 'Weekly' ? TimePeriod.weekly : TimePeriod.monthly;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Payments Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),

            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PeriodFilter(
                  selectedPeriod: _selectedPeriod,
                  onPeriodChanged: (p) {
                    setState(() => _selectedPeriod = p);
                    _loadAll();
                  },
                ),
                const SizedBox(width: 10),
                PaymentTypeFilter(
                  selectedPaymentType: _selectedPaymentType,
                  onPaymentTypeChanged: (t) {
                    setState(() => _selectedPaymentType = t);
                    _loadAll();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment type subtitle
            Text(
              _selectedPaymentType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),

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

            // Date pickers
            DatePickerRow(
              startDate: _startDate,
              endDate: _endDate,
              onSelectStart: () => _pickDate(true),
              onSelectEnd: () => _pickDate(false),
            ),
            const SizedBox(height: 20),

            // List container – works for both PaymentIn & PaymentOut
            ReportListContainer<dynamic>(
              title: 'Payment Details',
              items: _payments,
              onExportPressed: _showExportOptions,
              itemBuilder: (_, p, __) => TransactionCard(
                title: p is PaymentInModel ? (p.partyName ?? '—') : p.partyName,
                subtitle: _dateFormatter.format(_dateFormatter.parse(p.date)),
                id: p.id,
                amount: p is PaymentInModel ? p.receivedAmount : p.paidAmount,
                icon: _selectedPaymentType == 'Payment In'
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                iconColor: _selectedPaymentType == 'Payment In'
                    ? Colors.green
                    : Colors.orange,
                iconBackgroundColor: _selectedPaymentType == 'Payment In'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                amountColor: _selectedPaymentType == 'Payment In'
                    ? Colors.green[700]
                    : Colors.orange[700],
              ),
            ),
            const SizedBox(height: 20),
            StatsCard(
              title: _selectedPaymentType == 'Payment In'
                  ? 'Total Received Amount'
                  : 'Total Paid Amount',
              amount: '₹${_getTotalAmount().toStringAsFixed(2)}',
              icon: _selectedPaymentType == 'Payment In'
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              primaryColor: _selectedPaymentType == 'Payment In'
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              secondaryColor: _selectedPaymentType == 'Payment In'
                  ? const Color(0xFF059669)
                  : const Color(0xFFDC2626),
              count: _payments.length,
              countLabel: _selectedPaymentType == 'Payment In'
                  ? 'Payments In'
                  : 'Payments Out',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  @override
  void dispose() {
    PaymentInDb.paymentInNotifier.removeListener(_onDataChanged);
    PaymentOutDb.paymentOutNotifier.removeListener(_onDataChanged);
    super.dispose();
  }
}

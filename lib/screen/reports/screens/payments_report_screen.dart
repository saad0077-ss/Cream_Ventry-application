import 'package:cream_ventory/widgets/line_graph.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cream_ventory/db/functions/payment_db.dart';


class PaymentsReportScreen extends StatefulWidget {
  const PaymentsReportScreen({super.key});

  @override
  _PaymentsReportScreenState createState() => _PaymentsReportScreenState();
}

class _PaymentsReportScreenState extends State<PaymentsReportScreen> {
  String _selectedPeriod = 'Weekly';
  String _selectedPaymentType = 'Payment In'; // 'Payment In' or 'Payment Out'
  List<FlSpot> _paymentSpots = [];
  List<String> _xAxisLabels = [];
  double _maxY = 100;
  
  bool _isLoading = true;
  VoidCallback? _paymentInListener;
  VoidCallback? _paymentOutListener;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Initialize both payment DBs
      await PaymentInDb.init();
      await PaymentOutDb.init();
      
      // Set up listeners for real-time updates
      _setupListeners();
      
      // Refresh payments to ensure latest data
      await PaymentInDb.refreshPayments();
      await PaymentOutDb.refreshPayments();
      
      // Initial data load
      await _updateChartData();
    } catch (e) {
      debugPrint('Error initializing payment data: $e');
      _showEmptyState();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _setupListeners() {
    // Create listener functions
    _paymentInListener = _onPaymentsChanged;
    _paymentOutListener = _onPaymentsChanged;
    
    // Listen to Payment In changes
    PaymentInDb.paymentInNotifier.addListener(_paymentInListener!);
    
    // Listen to Payment Out changes
    PaymentOutDb.paymentOutNotifier.addListener(_paymentOutListener!);
  }

  void _onPaymentsChanged() {
    if (mounted && !_isLoading) {
      debugPrint('Payments changed, updating chart...');
      _updateChartData();
    }
  }

  Future<void> _updateChartData() async {
    if (_isLoading) return;
    
    try {
      setState(() => _isLoading = true);
      
      DateTime now = DateTime.now();
      List<FlSpot> spots = [];
      List<String> labels = [];
      double maxYValue = 0;
      
      if (_selectedPeriod == 'Weekly') {
        await _loadWeeklyData(now, spots, labels, maxYValue);
      } else if (_selectedPeriod == 'Monthly') {
        await _loadMonthlyData(now, spots, labels, maxYValue);
      }
      
      if (mounted) {
        setState(() {
          _paymentSpots = spots;
          _xAxisLabels = labels;
          _maxY = maxYValue > 0 ? maxYValue * 1.2 : 100;
        });
      }
    } catch (e) {
      debugPrint('Error updating chart data: $e');
      _showEmptyState();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadWeeklyData(
    DateTime now, 
    List<FlSpot> spots, 
    List<String> labels, 
    double maxYValue
  ) async {
    labels.addAll(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']);
    
    // Get start of current week (Monday)
    DateTime today = DateTime.now();
    int daysToMonday = today.weekday - DateTime.monday;
    DateTime monday = today.subtract(Duration(days: daysToMonday));
    
    for (int i = 0; i < 7; i++) {
      DateTime day = monday.add(Duration(days: i));
      DateTime startOfDay = DateTime(day.year, day.month, day.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));
      
      double totalAmount = await _getTotalAmountForDateRange(startOfDay, endOfDay);
      spots.add(FlSpot(i.toDouble(), totalAmount));
      maxYValue = maxYValue > totalAmount ? maxYValue : totalAmount;
    }
  }

  Future<void> _loadMonthlyData(
    DateTime now, 
    List<FlSpot> spots, 
    List<String> labels, 
    double maxYValue
  ) async {
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    
    for (int week = 0; week < 4; week++) {
      DateTime weekStart = firstDayOfMonth.add(Duration(days: week * 7));
      DateTime weekEnd = weekStart.add(const Duration(days: 7));
      
      double totalAmount = await _getTotalAmountForDateRange(weekStart, weekEnd);
      spots.add(FlSpot(week.toDouble(), totalAmount));
      labels.add('Week ${week + 1}');
      maxYValue = maxYValue > totalAmount ? maxYValue : totalAmount;
    }
  }

  Future<double> _getTotalAmountForDateRange(DateTime start, DateTime end) async {
    try {
      double total = 0;
      
      if (_selectedPaymentType == 'Payment In') {
        // Use notifier for better performance
        final payments = PaymentInDb.paymentInNotifier.value;
        final filteredPayments = payments.where((payment) {
          try {
            final paymentDate = _parseDateString(payment.date);
            if (paymentDate == null) return false;
            
            return paymentDate.isAfter(start.subtract(const Duration(days: 1))) &&
                   paymentDate.isBefore(end.add(const Duration(days: 1)));
          } catch (e) {
            debugPrint('Error parsing date for payment ${payment.id}: ${payment.date}');
            return false;
          }
        }).toList();
        
        total = filteredPayments.fold<double>(
          0, 
          (sum, payment) => sum + payment.receivedAmount
        );
      } else {
        // For Payment Out - assuming similar structure
        final payments = PaymentOutDb.paymentOutNotifier.value;
        final filteredPayments = payments.where((payment) {
          try {
            // Adjust this based on your PaymentOutModel date field
            final paymentDate = _parseDateString(payment.date); // or payment.dateString, etc.
            if (paymentDate == null) return false;
            
            return paymentDate.isAfter(start.subtract(const Duration(days: 1))) &&
                   paymentDate.isBefore(end.add(const Duration(days: 1)));
          } catch (e) {
            debugPrint('Error parsing date for payment out: $e');
            return false;
          }
        }).toList();
        
        total = filteredPayments.fold<double>(
          0, 
          (sum, payment) {
            // Adjust field name based on your PaymentOutModel
            // This assumes you have a 'paidAmount' field
            final amount = payment.paidAmount ; // Adjust field name
            return sum + amount;
          }
        );
      }
      
      debugPrint('Total $_selectedPaymentType for ${start.toString().substring(0,10)} to ${end.toString().substring(0,10)}: $total');
      return total;
    } catch (e) {
      debugPrint('Error calculating total for date range: $e');
      return 0;
    }
  }

  /// Helper method to parse date string to DateTime
  DateTime? _parseDateString(String dateString) {
    try {
      // Try parsing as ISO 8601 format first
      DateTime? parsedDate = DateTime.tryParse(dateString);
      if (parsedDate != null) {
        return parsedDate;
      }
      
      // Try common formats
      final formats = [
        'dd/MM/yyyy',      // 15/01/2024
        'yyyy-MM-dd',      // 2024-01-15
        'dd-MM-yyyy',      // 15-01-2024
        'yyyy/MM/dd',      // 2024/01/15
        'dd/MM/yyyy HH:mm', // 15/01/2024 10:30
        'yyyy-MM-dd HH:mm:ss', // 2024-01-15 10:30:00
      ];
      
      for (String format in formats) {
        try {   
          final formatter = DateFormat(format);
          parsedDate = formatter.parseLoose(dateString);
          return parsedDate;
                } catch (e) {
          // Continue to next format
          continue;
        }
      }
      
      // Try regex extraction for yyyy-MM-dd pattern
      final regex = RegExp(r'(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
      final match = regex.firstMatch(dateString);
      if (match != null) {
        return DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
      }
      
      debugPrint('Could not parse date: "$dateString"');
      return null;
    } catch (e) {
      debugPrint('Error parsing date string "$dateString": $e');
      return null;
    }
  }

  void _showEmptyState() {
    if (mounted) {
      setState(() {
        _paymentSpots = [];
        _xAxisLabels = _selectedPeriod == 'Weekly' 
            ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
            : ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
        _maxY = 100;
      });
    }
  }

  Widget _buildFilters() {
    return Column(
      children: [
        // Payment Type Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterButton('Payment In', 'type'),
            _buildFilterButton('Payment Out', 'type'),
          ],
        ),
        const SizedBox(height: 10),
        // Period Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterButton('Weekly', 'period'),
            _buildFilterButton('Monthly', 'period'),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFilterButton(String label, String filterType) {
    bool isSelected = (filterType == 'period' && _selectedPeriod == label) ||
                      (filterType == 'type' && _selectedPaymentType == label);
    
    Color buttonColor = filterType == 'period' 
        ? (isSelected ? Colors.green : Colors.grey[300]!)
        : (isSelected ? Colors.blueAccent : Colors.grey[300]!);

    return ElevatedButton(
      onPressed: _isLoading ? null : () async {
        setState(() {
          if (filterType == 'period') {
            _selectedPeriod = label;
          } else {
            _selectedPaymentType = label;
          }
        });
        await _updateChartData();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
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
            'Payments Report',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          _buildFilters(),
          const SizedBox(height: 20),
          Text(
            '$_selectedPaymentType${_isLoading ? ' (Loading...)' : ''}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 300,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(  
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _paymentSpots.isEmpty || 
                      (_paymentSpots.length > 0 && _paymentSpots.every((spot) => spot.y == 0))
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _selectedPaymentType == 'Payment In' 
                                    ? Icons.account_balance_wallet 
                                    : Icons.payment_outlined,
                                  size: 48, 
                                  color: Colors.grey[400]
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No $_selectedPaymentType data available\nfor $_selectedPeriod',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : LineChartWidget(
                            spots: _paymentSpots,
                            maxY: _maxY,
                            xAxisLabels: _xAxisLabels,
                            tooltipFormatter: (x, y) {
                              if (x >= 0 && x < _xAxisLabels.length && y > 0) {
                                String periodLabel = _xAxisLabels[x.toInt()];
                                NumberFormat currencyFormat = NumberFormat.currency(
                                  locale: 'en_US',
                                  symbol: '\$',
                                  decimalDigits: 0,
                                );
                                return '$periodLabel: ${currencyFormat.format(y.toInt())}';
                              }
                              return 'No data';
                            }
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Remove listeners to prevent memory leaks
    if (_paymentInListener != null) {
      PaymentInDb.paymentInNotifier.removeListener(_paymentInListener!);
    }
    if (_paymentOutListener != null) {
      PaymentOutDb.paymentOutNotifier.removeListener(_paymentOutListener!);
    }
    super.dispose();
  }
}
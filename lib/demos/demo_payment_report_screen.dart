// import 'package:cream_ventory/db/functions/payment_db.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_custom_line_chart.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_montly_weekly_tap.dart';
// import 'package:cream_ventory/screen/reports/screens/widgets/screen_report_payment_in_out_tap.dart';
// import 'package:cream_ventory/utils/report/graphs/payment_graph_processers.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'constants/time_period.dart';

// class PaymentsReportScreen extends StatefulWidget {
//   const PaymentsReportScreen({super.key});

//   @override
//   _PaymentsReportScreenState createState() => _PaymentsReportScreenState();
// }

// class _PaymentsReportScreenState extends State<PaymentsReportScreen> {
//   String _selectedPeriod = 'Weekly';
//   String _selectedPaymentType = 'Payment In';
//   List<FlSpot> _currentSpots = [];
//   List<FlSpot> _previousSpots = [];
//   List<String> _xAxisLabels = [];
//   double _maxY = 100;
//   String? _errorMessage;
//   VoidCallback? _paymentInListener;
//   VoidCallback? _paymentOutListener;

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     try {
//       await PaymentInDb.init();
//       await PaymentOutDb.init();
//       _setupListeners();
//       await PaymentInDb.refreshPayments();
//       await PaymentOutDb.refreshPayments();
//       await _updateChartData();
//     } catch (e) {
//       debugPrint('Error initializing payment data: $e');
//       _showEmptyState();
//     }
//   }

//   void _setupListeners() {
//     _paymentInListener = _onPaymentsChanged;
//     _paymentOutListener = _onPaymentsChanged;
//     PaymentInDb.paymentInNotifier.addListener(_paymentInListener!);
//     PaymentOutDb.paymentOutNotifier.addListener(_paymentOutListener!);
//   }

//   void _onPaymentsChanged() {
//     if (mounted) {
//       debugPrint('Payments changed, updating chart...');
//       _updateChartData();
//     }
//   }

//   Future<void> _updateChartData() async {
//     try {
//       final payments = _selectedPaymentType == 'Payment In'
//           ? await PaymentInDb.getAllPayments()
//           : await PaymentOutDb.getAllPayments();
//       final period = _selectedPeriod == 'Weekly'
//           ? TimePeriod.weekly
//           : TimePeriod.monthly;

//       final processedData = PaymentsDataProcessor.processPaymentsData(
//         payments,
//         period,
//         _selectedPaymentType,
//       );

//       if (mounted) {
//         setState(() {
//           _currentSpots = processedData.currentSpots;
//           _previousSpots = processedData.previousSpots;
//           _xAxisLabels = processedData.labels;
//           _maxY = processedData.maxY;
//           _errorMessage = processedData.errors.isNotEmpty
//               ? processedData.errors.join('\n')
//               : null;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error updating payments chart data: $e');
//       _showEmptyState();
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_errorMessage ?? 'Failed to load payments data.'),
//           ),
//         );
//       }
//     }
//   }

//   void _showEmptyState() {
//     if (mounted) {
//       setState(() {
//         _errorMessage =
//             'Failed to load payments data. Showing placeholder data.';
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
//           _maxY = 100;
//         } else {
//           final now = DateTime.now();
//           final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
//           _xAxisLabels = List.generate(
//             lastDayOfMonth,
//             (index) => (index + 1).toString(),
//           );
//           _currentSpots = List.generate(
//             lastDayOfMonth,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _previousSpots = List.generate(
//             lastDayOfMonth,
//             (index) => FlSpot((index + 1).toDouble(), 0),
//           );
//           _maxY = 100;
//         }
//       });
//     }
//   }
// Widget _buildFilters() {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       PeriodFilter(
//         selectedPeriod: _selectedPeriod,
//         onPeriodChanged: (period) async {
//           setState(() {
//             _selectedPeriod = period;
//           });
//           await _updateChartData();
//         },
//       ),
//       const SizedBox(width: 10),
//       PaymentTypeFilter(
//         selectedPaymentType: _selectedPaymentType,
//         onPaymentTypeChanged: (paymentType) async {
//           setState(() {
//             _selectedPaymentType = paymentType;
//           });
//           await _updateChartData();
//         },
//       ),
//     ],
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     final period = _selectedPeriod == 'Weekly'
//         ? TimePeriod.weekly
//         : TimePeriod.monthly;

//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Payments Report',
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 10),
//             _buildFilters(),
//             const SizedBox(height: 20),
//             Text(
//               _selectedPaymentType,
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 color: Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(height: 10),
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
//                 // Omit tooltipFormatter to use default
//              cardBackgroundColor: Colors.transparent,
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

//   @override
//   void dispose() {
//     if (_paymentInListener != null) {
//       PaymentInDb.paymentInNotifier.removeListener(_paymentInListener!);
//     }
//     if (_paymentOutListener != null) {
//       PaymentOutDb.paymentOutNotifier.removeListener(_paymentOutListener!);
//     }
//     super.dispose();
//   }
// }

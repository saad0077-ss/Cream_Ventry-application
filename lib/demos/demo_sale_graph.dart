// import 'package:cream_ventory/db/functions/sale/sale_db.dart';
// import 'package:cream_ventory/db/models/sale/sale_model.dart';
// import 'package:cream_ventory/utils/graphs/sale_graph_processers.dart';
// import 'package:cream_ventory/widgets/line_graph.dart';
// import 'package:flutter/material.dart';


// class SalesGraph extends StatefulWidget {
//   const SalesGraph({super.key});

//   @override
//   _SalesGraphState createState() => _SalesGraphState();
// }

// class _SalesGraphState extends State<SalesGraph> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     SaleDB.saleNotifier.addListener(_onSaleNotifierChanged);
//     _loadInitialData();
//   }

//   void _onSaleNotifierChanged() {
//     debugPrint("saleNotifier changed: ${SaleDB.saleNotifier.value.length} sales");
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   void dispose() {
//     SaleDB.saleNotifier.removeListener(_onSaleNotifierChanged);
//     super.dispose();
//   }

//   Future<void> _loadInitialData() async {
//     try {
//       await SaleDB.init();
//       await Future.delayed(const Duration(milliseconds: 100));
//       debugPrint("Sales after init: ${SaleDB.saleNotifier.value.length}");
//       setState(() => _isLoading = false);
//     } catch (e) {
//       debugPrint("Initialization error: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: Colors.black.withOpacity(0.3), width: 1),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(16.0),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(16.0),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title
//             Center(
//               child: Text(
//                 'Weekly Sales Overview',
//                 style: theme.textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                   fontFamily: 'ABeeZee',
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             // Graph or Loading Indicator
//             Expanded(
//               child: _isLoading
//                   ? _buildLoadingIndicator(theme)
//                   : _buildSalesGraph(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator(ThemeData theme) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
//           ),
//           const SizedBox(height: 16.0),
//           Text(
//             'Loading Sales Data...',
//             style: theme.textTheme.bodyMedium?.copyWith(
//               color: theme.colorScheme.onSurface.withOpacity(0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSalesGraph() {
//     return ValueListenableBuilder<List<SaleModel>>(
//       valueListenable: SaleDB.saleNotifier,
//       builder: (context, sales, _) {
//         debugPrint("ValueListenableBuilder rebuilt with ${sales.length} sales");
//         final data = SalesDataProcessor.processSalesData(
//           sales,
//           TimePeriod.weekly, // Fixed to weekly
//         );
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           child: LineChartWidget(
//             spots: data.currentSpots, // Use currentSpots for weekly data
//             maxY: data.maxY,
//             xAxisLabels: data.labels,
//             tooltipFormatter: (index, value) => SalesDataProcessor.formatTooltip(
//               index,
//               value,
//               TimePeriod.weekly,
//               true, // Current period
//             ),
//             previousSpots: data.previousSpots, // Include previousSpots for comparison
//           ),
//         );
//       },
//     );
//   }
// }

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${substring(1)}";
//   }
// }
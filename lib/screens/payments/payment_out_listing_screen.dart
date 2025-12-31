import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/screens/payments/payment_out_add_screen.dart';
import 'package:cream_ventory/screens/payments/payment_out_listing_screen_list.dart';
import 'package:cream_ventory/widgets/listing_screen_summary_card.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/utils/expence/date_amount_format.dart';
import 'package:cream_ventory/widgets/app_bar.dart' show CustomAppBar;
import 'package:cream_ventory/widgets/data_Range_Selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyOfPaymentOut extends StatelessWidget {
  final List<PaymentOutModel> payments;
  final double totalPayment;
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;
 
  const BodyOfPaymentOut({
    super.key,
    required this.payments,
    required this.totalPayment,
    this.onDateRangeChanged, 
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 700;

    return CustomScrollView(
      slivers: [
        // Date range selector - scrolls normally
        SliverToBoxAdapter(
          child: DateRangeSelector(
            onDateRangeChanged: onDateRangeChanged,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 10),
        ),

        // Summary Cards - becomes sticky when scrolled up
        SliverPersistentHeader(
          pinned: true,
          delegate: _PaymentOutSummaryDelegate(
            payments: payments,
            totalPayment: totalPayment,
            isTablet: isTablet,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 10),
        ),

        // Payment List - now converted to sliver
        PaymentOutListSliver(payments: payments),
      ],
    );
  }
}

class _PaymentOutSummaryDelegate extends SliverPersistentHeaderDelegate {
  final List<PaymentOutModel> payments;
  final double totalPayment;
  final bool isTablet;

  _PaymentOutSummaryDelegate({
    required this.payments,
    required this.totalPayment,
    required this.isTablet,
  });

  @override
  double get minExtent => isTablet ? 200 : 160;
 
  @override
  double get maxExtent => isTablet ? 200 : 160;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0), 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SummaryCard(
              key: ValueKey('txn_count_${payments.length}'),
              title: "No Of Payments",
              value: payments.length.toString(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              key: ValueKey('total_payment_$totalPayment'),
              title: "Total PaymentOut",
              value: FormatUtils.formatAmount(totalPayment),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_PaymentOutSummaryDelegate oldDelegate) {
    return payments.length != oldDelegate.payments.length ||
        totalPayment != oldDelegate.totalPayment ||
        isTablet != oldDelegate.isTablet;
  }
}

class PaymentOutTransaction extends StatefulWidget {
  const PaymentOutTransaction({super.key});

  @override
  State<PaymentOutTransaction> createState() => _PaymentOutTransactionState();
}

class _PaymentOutTransactionState extends State<PaymentOutTransaction> {
  DateTime? startDate;
  DateTime? endDate;
  String? userId;

  @override
  void initState() {
    super.initState();
    PaymentOutDb.init().then((_) {
      debugPrint('PaymentOutDb initialized');
    });
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final currentUser = await UserDB.getCurrentUser();
    setState(() {
      userId = currentUser.id;
    });
  }

  List<PaymentOutModel> _filterPayments(List<PaymentOutModel> payments) {
  debugPrint('Total payments before filter: ${payments.length}');
  debugPrint('Start date: $startDate, End date: $endDate');
  
  if (startDate == null || endDate == null) {
    debugPrint('No date filter applied');
    return payments;
  }

  final dateFormat = DateFormat('dd MMM yyyy');
  final filtered = payments.where((payment) {
    try {
      debugPrint('Parsing date: ${payment.date}');
      final paymentDate = dateFormat.parse(payment.date);
      final isInRange = paymentDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
             paymentDate.isBefore(endDate!.add(const Duration(days: 1)));
      debugPrint('Payment date: $paymentDate, In range: $isInRange');
      return isInRange;
    } catch (e) {
      debugPrint('Error parsing date for payment ${payment.receiptNo}: $e');
      debugPrint('Date string was: ${payment.date}'); 
      return false;
    }
  }).toList();
  
  debugPrint('Filtered payments count: ${filtered.length}');
  return filtered; 
}

  void _onDateRangeChanged(DateTime newStartDate, DateTime newEndDate) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        startDate = newStartDate;
        endDate = newEndDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Payment-Out Transaction', fontSize: 17),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: ValueListenableBuilder<List<PaymentOutModel>>(
          valueListenable: PaymentOutDb.paymentOutNotifier,
          builder: (context, allPayments, _) {
            final filteredPayments = _filterPayments(allPayments);
            final totalPayment = filteredPayments.fold<double>(
              0.0,
              (sum, payment) => sum + payment.paidAmount,
            );

            return BodyOfPaymentOut(
              payments: filteredPayments,
              totalPayment: totalPayment,
              onDateRangeChanged: _onDateRangeChanged,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey ,
        elevation: 6,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentOutScreen()),
          );
          if (result == true) {
            debugPrint('Refresh triggered from PaymentOutScreen');
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
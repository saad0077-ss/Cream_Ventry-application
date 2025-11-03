import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/screen/adding/payments/payment-out/payment_out_add_screen.dart';
import 'package:cream_ventory/screen/listing/payment_out/screen/payment_out_listing_screen_list.dart';
import 'package:cream_ventory/widgets/listing_screen_summary_card.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/utils/adding/expence/date_amount_format.dart';
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
    return Column(
      children: [
        DateRangeSelector(
          onDateRangeChanged: onDateRangeChanged,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SummaryCard(
                key: ValueKey('txn_count_${payments.length}'),
                title: "No Of Payments",
                value: payments.length.toString(),
              ),
              SummaryCard(
                key: ValueKey('total_payment_$totalPayment'), 
                title: "Total PaymentOut",
                value: FormatUtils.formatAmount(totalPayment),
              ),
            ],
          ),  
        ),
        const SizedBox(height: 10), 
        PaymentOutList(payments: payments),
      ],
    );
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
    if (startDate == null || endDate == null) return payments;

    final dateFormat = DateFormat('dd/MM/yyyy');
    return payments.where((payment) {
      try {
        final paymentDate = dateFormat.parse(payment.date);
        return paymentDate.isAfter(startDate!.subtract(const Duration(days: 1))) &&
               paymentDate.isBefore(endDate!.add(const Duration(days: 1)));
      } catch (e) {
        debugPrint('Error parsing date for payment ${payment.receiptNo}: $e');
        return false;
      }
    }).toList();
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
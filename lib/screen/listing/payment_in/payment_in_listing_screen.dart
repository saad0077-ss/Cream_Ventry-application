import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/db/models/payment/payment_in_model.dart';
import 'package:cream_ventory/screen/adding/payments/payment-in/payment_in_add_screen.dart';
import 'package:cream_ventory/screen/listing/payment_in/screen/payment_in_listing_screen_list.dart';
import 'package:cream_ventory/widgets/listing_screen_summary_card.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/utils/adding/expence/date_amount_format.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/data_Range_Selector.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyOfPaymentIn extends StatelessWidget {
  final List<PaymentInModel> payments;
  final double totalPayment;
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const BodyOfPaymentIn({
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
                title: "Total Payment In",
                value: FormatUtils.formatAmount(totalPayment),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        PaymentInList(payments: payments),
      ],
    );
  }
}

class PaymentInTransaction extends StatefulWidget {
  const PaymentInTransaction({super.key});


  @override
  State<PaymentInTransaction> createState() => _PaymentInTransactionState();
}

class _PaymentInTransactionState extends State<PaymentInTransaction> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    PaymentInDb.init().then((_) {
      debugPrint('PaymentInDb initialized');
    });
  }

  List<PaymentInModel> _filterPayments(List<PaymentInModel> payments) {
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
      appBar: CustomAppBar(title: 'Payment In Transactions', fontSize: 20),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: ValueListenableBuilder<List<PaymentInModel>>(
          valueListenable: PaymentInDb.paymentInNotifier,
          builder: (context, allPayments, _) {
            final filteredPayments = _filterPayments(allPayments);
            final totalPayment = filteredPayments.fold<double>(
              0.0,
              (sum, payment) => sum + payment.receivedAmount,
            );

            return BodyOfPaymentIn(
              payments: filteredPayments,
              totalPayment: totalPayment,
              onDateRangeChanged: _onDateRangeChanged,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton( 
        backgroundColor: Colors.blueGrey,
        elevation: 6,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentInScreen()),
          );
          if (result == true) {
            debugPrint('Refresh triggered from PaymentInScreen');
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
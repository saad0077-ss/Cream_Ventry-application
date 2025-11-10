import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/screen/adding/payments/payment-out/payment_out_add_screen.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/adding/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class PaymentOutList extends StatelessWidget {
  final List<PaymentOutModel> payments;

  const PaymentOutList({super.key, required this.payments});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktop(context);

    return Expanded(
      child: Stack(
        children: [
          // Empty State
          if (payments.isEmpty)
            Center(
              child: Text(
                'No payments to display.',
                style: AppTextStyles.emptyListText, 
                textAlign: TextAlign.center,
              ),     
            )
          // List or Grid
          else
            isDesktop
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 170,  
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ReportLists(
                        onTap: () => _navigateToDetail(context, payment),
                        name: payment.partyName,
                        amount: FormatUtils.formatAmount(payment.paidAmount),
                        date: FormatUtils.formatDate(payment.date),
                        saleId: payment.receiptNo,
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ReportLists(
                        onTap: () => _navigateToDetail(context, payment),
                        name: payment.partyName,
                        amount: FormatUtils.formatAmount(payment.paidAmount),
                        date: FormatUtils.formatDate(payment.date),
                        saleId: payment.receiptNo,
                      );
                    },
                  ),

          // OVERLAYS GO HERE
          // Example: FAB
          // Positioned(
          //   bottom: 20,
          //   right: 20,
          //   child: FloatingActionButton(
          //     onPressed: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const PaymentOutAddScreen()),
          //     ),
          //     child: const Icon(Icons.add),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, PaymentOutModel payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentOutScreen(payment: payment),
      ),
    ).then((result) {
      if (result == true) {
        debugPrint('Refresh triggered from PaymentOutScreen');
      }
    });
  }
}
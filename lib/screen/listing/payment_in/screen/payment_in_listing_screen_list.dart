import 'package:cream_ventory/db/models/payment/payment_in_model.dart';
import 'package:cream_ventory/screen/adding/payments/payment-in/payment_in_add_screen.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/adding/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class PaymentInList extends StatelessWidget {
  final List<PaymentInModel> payments;

  const PaymentInList({super.key, required this.payments});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = _isDesktop(context);

    return Expanded(
      child: Stack(
        children: [
          if (payments.isEmpty)
            Center(
              child: Text(
                'No payments to display.',
                style: AppTextStyles.emptyListText,
                textAlign: TextAlign.center,
              ),
            )
          else
            isDesktop
                ? GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 5 / 0.8, 
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ReportLists(
                        onTap: () => _navigateToDetail(context, payment),
                        name: payment.partyName ?? '',
                        amount: FormatUtils.formatAmount(
                          payment.receivedAmount,
                        ),
                        date: FormatUtils.formatDate(payment.date),
                        saleId: payment.receiptNo,
                      );
                    },
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return ReportLists(
                        onTap: () => _navigateToDetail(context, payment),
                        name: payment.partyName ?? '',
                        amount: FormatUtils.formatAmount(
                          payment.receivedAmount,
                        ),
                        date: FormatUtils.formatDate(payment.date),
                        saleId: payment.receiptNo,
                      );
                    },
                  ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, PaymentInModel payment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentInScreen(payment: payment),
      ),
    );
  }
}

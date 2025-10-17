import 'package:cream_ventory/db/models/payment/payment_in_model.dart';
import 'package:cream_ventory/screen/adding/payment-in/payment_in.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class PaymentInList extends StatelessWidget {
  final List<PaymentInModel> payments;

  const PaymentInList({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
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
            ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                return ReportLists(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentInScreen(payment: payment),
                      ),
                    );
                  },
                  name: payment.partyName ?? '',
                  amount: FormatUtils.formatAmount(payment.receivedAmount),
                  date: payment.date,
                  saleId: payment.receiptNo,
                );
              },
            ),
        ],
      ), 
    );
  }
}
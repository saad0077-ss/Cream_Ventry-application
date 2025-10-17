
import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/screen/adding/payment-out/payment_out.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class PaymentOutList extends StatelessWidget {
  final List<PaymentOutModel> payments;
  

  const PaymentOutList({super.key, required this.payments});

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
                        builder: (context) => PaymentOutScreen(payment: payment),
                      ),
                    ).then((result) {
                      if (result == true) {    
                        // Refresh handled by notifier, but keep as fallback
                        debugPrint('Refresh triggered from PaymentOutScreen');
                      }
                    });
                  },
                  name: payment.partyName,
                  amount: FormatUtils.formatAmount(payment.paidAmount),
                  date: FormatUtils.formatDate(payment.date),
                  saleId: payment.receiptNo,
                );
              },
            ),
        ],
      ), 
    );
  }
}
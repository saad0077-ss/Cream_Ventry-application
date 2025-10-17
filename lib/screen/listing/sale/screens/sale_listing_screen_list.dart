import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/add_sale.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class SaleList extends StatelessWidget {
  final List<SaleModel> sales;


  const SaleList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
   
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 8, vertical: 8),
        child: Stack(
          children: [
            if (sales.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Text(
                    'No sales to display.',
                    style: AppTextStyles.emptyListText.copyWith(
                      fontSize: isTablet ? 18 : 16,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ), 
              )
            else
              ListView.builder(
                padding: EdgeInsets.only(bottom: isTablet ? 80 : 60),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ReportLists(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SaleScreen( 
                            sale: sale,
                            transactionType: TransactionType.sale,
                          ),
                        ),
                      );
                    },
                    name: sale.customerName ?? 'No Customer',
                    amount: '₹${FormatUtils.formatAmount(sale.total)}',
                    date: sale.date,
                    saleId: sale.invoiceNumber,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
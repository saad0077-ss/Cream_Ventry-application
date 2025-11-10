import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/adding/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class SaleList extends StatelessWidget {
  final List<SaleModel> sales;

  const SaleList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) { 
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
 
    // Responsive values (same as PaymentInList)
    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 16.0 : 8.0;
    final bottomPadding = isDesktop ? 100.0 : 60.0;
    final emptyTextSize = isDesktop ? 20.0 : 16.0;

    final gridCrossAxisCount = isDesktop ? 2 : 1;

    return Expanded(  
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
        child: Stack(
          children: [
            // ----- Empty State -----
            if (sales.isEmpty) 
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 32 : 16),
                  child: Text(
                    'No sales to display.',
                    style: AppTextStyles.emptyListText.copyWith(
                      fontSize: emptyTextSize,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (isDesktop)
              GridView.builder(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  top: verticalPadding,
                  bottom: bottomPadding,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCrossAxisCount,
                  mainAxisExtent: 170,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 16,
                ),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ReportLists(
                    onTap: () => _navigateToDetail(context, sale),
                    name: sale.customerName ?? 'No Customer',
                    amount: '₹${FormatUtils.formatAmount(sale.total)}',
                    date: FormatUtils.formatDate(sale.date),
                    saleId: sale.invoiceNumber,
                  );
                },
              )
            else
              ListView.builder(
                padding: EdgeInsets.only(
                  left: horizontalPadding, 
                  right: horizontalPadding,
                  top: verticalPadding,
                  bottom: bottomPadding,
                ),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return ReportLists(
                    onTap: () => _navigateToDetail(context, sale),
                    name: sale.customerName ?? 'No Customer',
                    amount: '₹${FormatUtils.formatAmount(sale.total)}',
                    date: FormatUtils.formatDate(sale.date),
                    saleId: sale.invoiceNumber,
                  );
                },
              ), 
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, SaleModel sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleScreen(
          sale: sale,
          transactionType: TransactionType.sale,
        ),
      ),
    );
  }
} 
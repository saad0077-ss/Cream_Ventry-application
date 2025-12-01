import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/sale/sale_add_screen.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_listing_screen_sale_card.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/core/utils/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class SaleList extends StatelessWidget {
  final List<SaleModel> sales;

  const SaleList({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {  
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
 
    // Responsive values
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
                  mainAxisExtent: 220, // Increased height for status badge
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: sales.length,
                itemBuilder: (context, index) {
                  final sale = sales[index];
                  return SaleCard(
                    onTap: () => _navigateToDetail(context, sale),
                    customerName: sale.customerName ?? 'No Customer',
                    amount: FormatUtils.formatAmount(sale.total),
                    date: FormatUtils.formatDate(sale.date),
                    invoiceNumber: sale.invoiceNumber,
                    transactionType: sale.transactionType ?? TransactionType.sale,
                    status: sale.status,
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SaleCard(
                      onTap: () => _navigateToDetail(context, sale),
                      customerName: sale.customerName ?? 'No Customer',
                      amount: FormatUtils.formatAmount(sale.total), 
                      date: FormatUtils.formatDate(sale.date),
                      invoiceNumber: sale.invoiceNumber,
                      transactionType: sale.transactionType ?? TransactionType.sale,
                      status: sale.status,
                    ),
                  );
                },
              ), 
          ],
        ),
      ),
    );
  }
 
  void _navigateToDetail(BuildContext context, SaleModel sale) {
     final transactionType = sale.transactionType ?? TransactionType.sale;    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleScreen(
          sale: sale,
          transactionType: transactionType,
        ),
      ),
    );
  }
}
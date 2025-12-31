import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/sale/sale_add_screen.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_listing_screen_sale_card.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';

class SaleListSliver extends StatelessWidget {
  final List<SaleModel> sales;

  const SaleListSliver({super.key, required this.sales});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    final horizontalPadding = isDesktop ? 32.0 : 16.0;
    final verticalPadding = isDesktop ? 16.0 : 8.0;
    final bottomPadding = isDesktop ? 100.0 : 60.0;
    final emptyTextSize = isDesktop ? 20.0 : 16.0;

    final gridCrossAxisCount = isDesktop ? 2 : 1;

    // Empty State
    if (sales.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
        ),
      );
    }
 
    // ✅ ADD: Listen to party changes to rebuild cards
    return ValueListenableBuilder<List<PartyModel>>(
      valueListenable: PartyDb.partyNotifier,
      builder: (context, parties, child) {
        // Desktop Grid View
        if (isDesktop) {
          return SliverPadding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: verticalPadding,
              bottom: bottomPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCrossAxisCount,
                mainAxisExtent: 300,
                mainAxisSpacing: 17,
                crossAxisSpacing: 17,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sale = sales[index];
                  // ✅ Use factory constructor to pass customerId
                  return SaleCard.fromSaleModel(
                    sale: sale,
                    onTap: () => _navigateToDetail(context, sale),
                  );
                },
                childCount: sales.length,
              ),
            ),
          );
        }

        // Mobile List View
        return SliverPadding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            top: verticalPadding,
            bottom: bottomPadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final sale = sales[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  // ✅ Use factory constructor to pass customerId
                  child: SaleCard.fromSaleModel(
                    sale: sale, 
                    onTap: () => _navigateToDetail(context, sale),
                  ),
                );
              },
              childCount: sales.length,
            ),
          ),
        );
      },
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
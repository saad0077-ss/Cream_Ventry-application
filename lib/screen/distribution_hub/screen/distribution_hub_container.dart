import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/payments/payment-in/payment_in_add_screen.dart';
import 'package:cream_ventory/screen/adding/sale/sale_add_screen.dart';
import 'package:cream_ventory/screen/distribution_hub/screen/distribution_hub_parties_tap.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_balance_card.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_bottom_sheet.dart';
import 'package:cream_ventory/screen/distribution_hub/widget/distribution_hub_flotting_buttons.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DistributionHubContainer extends StatelessWidget {
  final BoxConstraints constraints;
  final bool isSmallScreen;
  final double totalYoullGet;
  final double totalYoullGive;
  final String? currentFilter;
  final VoidCallback onFilterYoullGet;
  final VoidCallback onFilterYoullGive;
  final VoidCallback onLoadTotalBalance;

  const DistributionHubContainer({
    super.key,
    required this.constraints,
    required this.isSmallScreen,
    required this.totalYoullGet,
    required this.totalYoullGive,
    this.currentFilter,
    required this.onFilterYoullGet,
    required this.onFilterYoullGive,
    required this.onLoadTotalBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.appGradient),
      height: constraints.maxHeight,
      child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 16),
                    buildSummaryCard(
                      onTap: onFilterYoullGet,
                      icon: Icons.arrow_downward_rounded,
                      iconColor: Colors.green,
                      title: "You'll Get",
                      value: NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 2,
                      ).format(totalYoullGet),
                      valueColor: Colors.green.shade400,
                      isSmallScreen: isSmallScreen,
                      currentFilter: currentFilter,
                    ),
                    const SizedBox(width: 16),
                    buildSummaryCard(
                      onTap: onFilterYoullGive,
                      icon: Icons.arrow_upward_rounded,
                      iconColor: Colors.red,
                      title: "You'll Give",
                      value: NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                        decimalDigits: 2,
                      ).format(totalYoullGive),
                      valueColor: Colors.red.shade400,
                      isSmallScreen: isSmallScreen,
                      currentFilter: currentFilter,
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: const PartiesTap()),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                right: isSmallScreen ? 2 : 12, // Fixed pixel values (0.05 * 400 ≈ 2, 0.3 * 400 ≈ 12)
                bottom: 24, // Fixed pixel value (3% of typical 800px height ≈ 24)
              ),
              child: ActionButtons(
                onTakePayment: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (_) => PaymentInScreen(),
                        ),
                      )
                      .then((result) {
                        if (result == true) {
                          onLoadTotalBalance();
                        }
                      });
                },
                onAddAction: () {
                  TransactionBottomSheet().show(context);
                },
                onAddSale: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SaleScreen( 
                        transactionType: TransactionType.sale,
                      ),
                    ),
                  );    
                  if (result == true) {
                    onLoadTotalBalance();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
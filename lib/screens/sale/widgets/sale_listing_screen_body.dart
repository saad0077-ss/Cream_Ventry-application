import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_listing_screen_list.dart';
import 'package:cream_ventory/widgets/listing_screen_summary_card.dart';
import 'package:cream_ventory/widgets/data_range_selector.dart';
import 'package:flutter/material.dart';

class BodyOfSale extends StatelessWidget {
  final List<SaleModel> sales;
  final double totalSale;
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const BodyOfSale({
    super.key,
    required this.sales,
    required this.totalSale,
    this.onDateRangeChanged,

  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Column(
      children: [
        // Date range selector for filtering sales
        Padding(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          child: DateRangeSelector(
            onDateRangeChanged: onDateRangeChanged,
          ),
        ),

        // Summary Cards
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SummaryCard(
                key: ValueKey('txn_count_${sales.length}'), 
                title: "No. of Sales",
                value: sales.length.toString(),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              SummaryCard(
                key: ValueKey('total_sale_$totalSale'),
                title: "Total Sale",
                value: '₹${totalSale.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),

        // Sale List
        SaleList(sales: sales),
      ],
    );
  }
}
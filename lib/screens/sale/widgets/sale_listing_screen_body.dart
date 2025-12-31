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
    final isTablet = MediaQuery.of(context).size.width > 700;

    return CustomScrollView(
      slivers: [
        // Date range selector - scrolls normally
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 12 : 2),
            child: DateRangeSelector(
              onDateRangeChanged: onDateRangeChanged,
            ),
          ),
        ),

        // Summary Cards - becomes sticky when scrolled up
        SliverPersistentHeader(
          pinned: true,
          delegate: _SummaryCardDelegate(
            sales: sales,
            totalSale: totalSale,
            isTablet: isTablet,
          ),
        ),

        // Sale List - now converted to sliver
        SaleListSliver(sales: sales),
      ],
    );
  }
}

class _SummaryCardDelegate extends SliverPersistentHeaderDelegate {
  final List<SaleModel> sales;
  final double totalSale;
  final bool isTablet;

  _SummaryCardDelegate({
    required this.sales,
    required this.totalSale,
    required this.isTablet,
  });

  @override
  double get minExtent => isTablet ? 200 : 160; // Increased height

  @override
  double get maxExtent => isTablet ? 200 : 160; // Increased height

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material( 
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = isTablet ? 16.0 : 10.0;          
          return Padding(
            padding: const EdgeInsets.all(16.0), 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SummaryCard(
                    key: ValueKey('txn_count_${sales.length}'),
                    title: "No. of Sales",
                    value: sales.length.toString(),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: SummaryCard(
                    key: ValueKey('total_sale_$totalSale'),
                    title: "Total Sale",
                    value: '₹${totalSale.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ); 
  }

  @override
  bool shouldRebuild(_SummaryCardDelegate oldDelegate) {
    return sales.length != oldDelegate.sales.length ||
        totalSale != oldDelegate.totalSale ||
        isTablet != oldDelegate.isTablet;
  }
}
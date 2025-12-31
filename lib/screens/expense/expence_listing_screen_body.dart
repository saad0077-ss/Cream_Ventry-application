import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/screens/expense/expence_listing_screen_list.dart';
import 'package:cream_ventory/widgets/listing_screen_summary_card.dart';
import 'package:cream_ventory/widgets/data_Range_Selector.dart';
import 'package:flutter/material.dart';

class BodyOfExpense extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final double totalExpense;
  final void Function(DateTime startDate, DateTime endDate)? onDateRangeChanged;

  const BodyOfExpense({
    super.key,
    required this.expenses,
    required this.totalExpense,
    this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 700;

    return CustomScrollView(
      slivers: [
        // Date range selector - scrolls normally
        SliverToBoxAdapter(
          child: DateRangeSelector(
            onDateRangeChanged: onDateRangeChanged,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 10),
        ),

        // Summary Cards - becomes sticky when scrolled up
        SliverPersistentHeader(
          pinned: true,
          delegate: _ExpenseSummaryDelegate(
            expenses: expenses,
            totalExpense: totalExpense,
            isTablet: isTablet,
          ),
        ),

        SliverToBoxAdapter(
          child: const SizedBox(height: 10),
        ),

        // Expense List - now converted to sliver
        ExpenseListSliver(expenses: expenses),
      ],
    );
  }
}

class _ExpenseSummaryDelegate extends SliverPersistentHeaderDelegate {
  final List<ExpenseModel> expenses;
  final double totalExpense;
  final bool isTablet;

  _ExpenseSummaryDelegate({
    required this.expenses,
    required this.totalExpense,
    required this.isTablet,
  });

  @override
  double get minExtent => isTablet ? 200 : 160; 

  @override
  double get maxExtent => isTablet ? 200 : 160;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SummaryCard(
              key: ValueKey('txn_count_${expenses.length}'),
              title: "No Of Expense",
              value: expenses.length.toString(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              key: ValueKey('total_expense_$totalExpense'),
              title: "Total Expense",
              value: '₹${totalExpense.toStringAsFixed(2)}',
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_ExpenseSummaryDelegate oldDelegate) {
    return expenses.length != oldDelegate.expenses.length ||
        totalExpense != oldDelegate.totalExpense ||
        isTablet != oldDelegate.isTablet;
  }
}
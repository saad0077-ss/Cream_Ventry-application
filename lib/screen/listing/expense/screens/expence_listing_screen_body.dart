import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:cream_ventory/screen/listing/expense/screens/expence_listing_screen_list.dart';
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
    return Column(
      children: [
        // Only notify parent of date changes
        DateRangeSelector(
          onDateRangeChanged: onDateRangeChanged,
        ),

        const SizedBox(height: 10),

        // Summary Cards
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [   
              SummaryCard(
                key: ValueKey('txn_count_${expenses.length}'),
                title: "No Of Expense",
                value: expenses.length.toString(),
              ),
              SummaryCard(
                key: ValueKey('total_expense_$totalExpense'),
                title: "Total Expense", 
                value: '₹${totalExpense.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Expense List
        ExpenseList(expenses: expenses),
      ],
    );
  }
}

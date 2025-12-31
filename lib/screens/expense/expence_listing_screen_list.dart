import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/screens/expense/add_expense_screen.dart';
import 'package:cream_ventory/screens/expense/widgets/expense_card.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';

class ExpenseListSliver extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const ExpenseListSliver({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // Empty State
    if (expenses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No expenses to display.',
            style: AppTextStyles.emptyListText,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Expense List
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final expense = expenses[index];
          return ExpenseCard(
            expense: expense,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddExpensePage(existingExpense: expense),
                ),
              );
            },
          );
        },
        childCount: expenses.length,
      ),
    );
  }
}
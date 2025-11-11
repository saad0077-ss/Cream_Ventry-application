
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/screens/expense/add_expense_screen.dart';
import 'package:cream_ventory/widgets/listing_screen_list.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/core/utils/expence/date_amount_format.dart';
import 'package:flutter/material.dart';

class ExpenseList extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const ExpenseList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(    
        children: [
          if (expenses.isEmpty)
             Center(   
              child: Text(
                'No expenses to display.',
                style: AppTextStyles.emptyListText,
                textAlign: TextAlign.center,
              ),
            )
          else
            ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ReportLists(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddExpensePage(existingExpense: expense),
                      ),
                    );
                  },
                  name: expense.category,
                  amount:
                      '₹${FormatUtils.formatAmount(expense.totalAmount)}',
                  date: FormatUtils.formatDate(expense.date),
                  saleId: expense.invoiceNo.toString(),
                );
              }, 
            ),
        ],
      ),
    );
  }
}

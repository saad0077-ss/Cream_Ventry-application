import 'package:cream_ventory/database/functions/expense_category_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_acition_button.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_category_dropdown.dart';
import 'package:cream_ventory/screens/expense/widgets/add_category_date_row.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_sub_category_items_list.dart' show AddItemButtonWidget, ItemsListWidget;
import 'package:cream_ventory/screens/expense/widgets/add_category_total_amount.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/core/utils/expence/add_expence_logics.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  final ExpenseModel? existingExpense;
  const AddExpensePage({super.key, this.existingExpense});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}
                         
class _AddExpensePageState extends State<AddExpensePage> {
  late bool isEditing;
  late AddExpenseLogic logic;
  Future<List<ExpenseCategoryModel>>? categoryListFuture; // Fixed type

  @override
  void initState() {
    super.initState();
    isEditing = widget.existingExpense != null;
    logic = AddExpenseLogic(expense: widget.existingExpense);
    categoryListFuture = ExpenseCategoryDB.getCategories(); // Direct call with correct type
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: isEditing ? 'Edit Expense' : 'Add Expense',
        fontSize: 25,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.appGradient),
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              DateRowWidget(
                logic: logic,
                onDateSelected: setState, // Pass setState callback
              ),
              const SizedBox(height: 15),
              CategoryDropdownWidget(
                logic: logic,
                categoryListFuture: categoryListFuture,
                onCategoriesUpdated: (updatedFuture) {
                  setState(() {
                    categoryListFuture = updatedFuture;
                  });
                },
              ),
              const SizedBox(height: 15),
              Text('BILLED ITEMS', style: AppTextStyles.textBold),
              ItemsListWidget(
                logic: logic,
                onChanged: setState,
              ),
              AddItemButtonWidget(
                logic: logic,
                onPressed: setState,
              ),
              const SizedBox(height: 10),
              TotalAmountWidget(logic: logic),
              const SizedBox(height: 20),
              ActionButtonsWidget(
                logic: logic,
                isEditing: isEditing,
                existingExpense: widget.existingExpense,
                onSaveAndNew: setState, // Pass setState for Save & New
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cream_ventory/database/functions/expense_category_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_acition_button.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_category_dropdown.dart';
import 'package:cream_ventory/screens/expense/widgets/add_category_date_row.dart';
import 'package:cream_ventory/screens/expense/widgets/add_expense_sub_category_items_list.dart' show AddItemButtonWidget, ItemsListWidget;
import 'package:cream_ventory/screens/expense/widgets/add_category_total_expense.dart';
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
  Future<List<ExpenseCategoryModel>>? categoryListFuture;

  @override   
  void initState() {
    super.initState();
    isEditing = widget.existingExpense != null;
    logic = AddExpenseLogic(expense: widget.existingExpense);
    categoryListFuture = ExpenseCategoryDB.getCategories();
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  // ✅ Add this wrapper method for synchronous updates
  void _updateState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // ✅ Add this wrapper for async operations
  Future<void> updateStateAsync(Future<void> Function() asyncFn) async {
    await asyncFn();
    if (mounted) {
      setState(() {});
    }
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
        padding: const EdgeInsets.all(18.0),
        child: SingleChildScrollView(  
          child: Column( 
            children: [
              const SizedBox(height: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DateRowWidget(   
                          logic: logic,
                          onDateSelected: _updateState, // ✅ Use wrapper
                        ),
                        const SizedBox(height: 15),
                        Text('EXPENSE CATEGORY', style: AppTextStyles.textBold), 
                        SizedBox(height: 10),
                        CategoryDropdownWidget(
                          logic: logic,
                          categoryListFuture: categoryListFuture,
                          onCategoriesUpdated: (updatedFuture) {
                            setState(() {
                              categoryListFuture = updatedFuture; 
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  ItemsListWidget(
                    logic: logic, 
                    onChanged: _updateState, 
                  ),
                  AddItemButtonWidget(
                    logic: logic,
                    onPressed: _updateState, 
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TotalAmountWidget(logic: logic),
              const SizedBox(height: 20),
              ActionButtonsWidget(
                logic: logic,
                isEditing: isEditing,
                existingExpense: widget.existingExpense,
                onSaveAndNew: _updateState, 
              ),
            ],
          ),
        ),
      ),
    );
  }
}
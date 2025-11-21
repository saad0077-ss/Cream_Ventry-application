import 'package:cream_ventory/database/functions/expence_db.dart';
import 'package:cream_ventory/database/functions/expense_category_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddExpenseLogic {
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController(
    text: '₹0.00',
  );
  String selectedCategory = 'EXPENSE CATEGORY';
  DateTime selectedDate = DateTime.now();
  ExpenseModel? existingExpense;

  List<Map<String, Object>> billedItems = [
    <String, Object>{
      'id': UniqueKey().toString(),
      'name': '',
      'qty': 0,
      'rate': 0.0,
      'amount': 0.0,
      'nameController': TextEditingController(),
      'qtyController': TextEditingController(),
      'rateController': TextEditingController(),
    },
  ];

  AddExpenseLogic({ExpenseModel? expense}) {
    if (expense != null) {
      loadExpense(expense);
    } else {
      _setAutoInvoiceNumber();
    }
  }

  Future<void> initializeUserAndData(
    BuildContext context,
    Function setState,
  ) async {
    if (existingExpense == null) {
      await _setAutoInvoiceNumber();
    }
  }

  void dispose() {
    for (var item in billedItems) {
      (item['nameController'] as TextEditingController?)?.dispose();
      (item['qtyController'] as TextEditingController?)?.dispose();
      (item['rateController'] as TextEditingController?)?.dispose();
    }
    invoiceController.dispose();
    totalAmountController.dispose();
  }

  Future<void> _setAutoInvoiceNumber() async {
    if (existingExpense != null) return;
    final db = ExpenseDB();
    final nextInvoice = await db.getNextInvoiceNumber();
    invoiceController.text = nextInvoice;
  }

  Future<void> selectDate(BuildContext context, Function setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void addNewItem(Function setState) {
    debugPrint('Before adding: ${billedItems.length} items');
    setState(() {
      billedItems.add(<String, Object>{
        'id': UniqueKey().toString(),
        'name': '',
        'qty': 0,
        'rate': 0.0,
        'amount': 0.0,
        'nameController': TextEditingController(),
        'qtyController': TextEditingController(),
        'rateController': TextEditingController(),
      });
      debugPrint('After adding: ${billedItems.length} items');
      calculateTotal();
    });
  }

  void removeItem(int index, Function setState, BuildContext context) {
    setState(() {
      if (billedItems.length > 1) {
        (billedItems[index]['nameController'] as TextEditingController?)
            ?.dispose();
        (billedItems[index]['qtyController'] as TextEditingController?)
            ?.dispose();
        (billedItems[index]['rateController'] as TextEditingController?)
            ?.dispose();
        billedItems.removeAt(index);
        calculateTotal();
        
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: 'Item removed successfully',
          ),
        );
      } else {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message: 'At least one item is required',
          ),
        );
      }
    });
  }

  void calculateTotal() {
    double total = 0.0;
    for (var item in billedItems) {
      final qtyText = (item['qtyController'] as TextEditingController).text;
      final rateText = (item['rateController'] as TextEditingController).text;
      final qty = int.tryParse(qtyText) ?? 0;
      final rate = double.tryParse(rateText) ?? 0.0;
      item['amount'] = qty * rate;
      total += (item['amount'] as double);
    }
    totalAmountController.text = '₹${total.toStringAsFixed(2)}';
  }

  Future<void> saveAndNew(Function setState, BuildContext context) async {
    if (!_validateFields(context)) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(
          message: 'Please fill in all required fields correctly',
        ),
      );
      return;
    }

    await save(context, shouldPop: false);

    setState(() {
      for (var item in billedItems) {
        (item['nameController'] as TextEditingController?)?.dispose();
        (item['qtyController'] as TextEditingController?)?.dispose();
        (item['rateController'] as TextEditingController?)?.dispose();
      }
      invoiceController.clear();
      totalAmountController.text = '₹0.00';
      selectedCategory = 'EXPENSE CATEGORY';
      selectedDate = DateTime.now();
      existingExpense = null;
      billedItems = [
        <String, Object>{
          'id': UniqueKey().toString(),
          'name': '',
          'qty': 0,
          'rate': 0.0,
          'amount': 0.0,
          'nameController': TextEditingController(),
          'qtyController': TextEditingController(),
          'rateController': TextEditingController(),
        },
      ];
    });

    showTopSnackBar(
      Overlay.of(context),
      const CustomSnackBar.success(
        message: '✓ Saved successfully! Ready for new entry',
      ),
    );

    await _setAutoInvoiceNumber();
  }

  Future<void> save(BuildContext context, {bool shouldPop = true}) async {
    if (!_validateFields(context)) return;
    
    final user = await UserDB.getCurrentUser();
    final expense = ExpenseModel(
      id:
          existingExpense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNo: invoiceController.text,
      category: selectedCategory,
      date: selectedDate,
      userId: user.id,
      billedItems: billedItems.map((item) {
        final qtyText = (item['qtyController'] as TextEditingController).text;
        final rateText = (item['rateController'] as TextEditingController).text;

        return BilledItem(
          userId: user.id,
          name: (item['nameController'] as TextEditingController).text,
          quantity: int.parse(qtyText),
          rate: double.parse(rateText),
        );
      }).toList(),
    );

    final expenseDB = ExpenseDB();

    try {
      if (existingExpense != null) {
        await expenseDB.updateExpense(expense);
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: '✓ Expense updated successfully!',
          ),
        );
      } else {
        await expenseDB.addExpense(expense);
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: '✓ Expense saved successfully!',
          ),
        );
      }

      if (shouldPop) {
        Navigator.of(context).pop(expense);
      }
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Error saving expense: $e',
        ),
      );
    }   
  }

  void loadExpense(ExpenseModel expense) {
    existingExpense = expense;
    invoiceController.text = expense.invoiceNo;
    selectedDate = expense.date;
    selectedCategory = expense.category;

    billedItems = expense.billedItems.map((item) {
      final nameController = TextEditingController(text: item.name);
      final qtyController = TextEditingController(
        text: item.quantity.toString(),
      );
      final rateController = TextEditingController(text: item.rate.toString());
      return <String, Object>{
        'id': UniqueKey().toString(),
        'name': item.name,
        'qty': item.quantity,
        'rate': item.rate,
        'amount': item.quantity * item.rate,
        'nameController': nameController, 
        'qtyController': qtyController,
        'rateController': rateController, 
      };
    }).toList();

    calculateTotal();
  }

  Future<List<ExpenseCategoryModel>> loadCategories() async {
    return await ExpenseCategoryDB.getCategories();
  }

  TextStyle get textBoldStyle => AppTextStyles.textBold;

  Future<List<ExpenseCategoryModel>> fetchExpenseCategories() async {
    final categories = await ExpenseCategoryDB.getCategories();
    categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return categories;
  }

  Future<void> addNewCategory(String categoryName) async {
    await ExpenseCategoryDB.addCategory(categoryName);
  }

  bool _validateFields(BuildContext context) {
    if (invoiceController.text.isEmpty ||
        selectedCategory == 'EXPENSE CATEGORY' ||
        billedItems.isEmpty ||
        billedItems.any((item) {
          final name = (item['nameController'] as TextEditingController).text;
          final qtyText = (item['qtyController'] as TextEditingController).text;
          final rateText =
              (item['rateController'] as TextEditingController).text;
          final qty = int.tryParse(qtyText);
          final rate = double.tryParse(rateText);
          return name.isEmpty ||
              qtyText.isEmpty ||
              rateText.isEmpty ||
              qty == null ||
              rate == null ||
              qty <= 0 ||
              rate <= 0;
        })) {
      return false;
    }
    return true;
  }

  Future<void> updateExpense(
    ExpenseModel oldExpense,
    BuildContext context,
  ) async {
    if (!_validateFields(context)) return;

    final updatedExpense = ExpenseModel(
      id: oldExpense.id,
      invoiceNo: invoiceController.text,
      date: selectedDate,
      category: selectedCategory,
      billedItems: billedItems.map((item) {
        final qtyText = (item['qtyController'] as TextEditingController).text;
        final rateText = (item['rateController'] as TextEditingController).text;
        return BilledItem(
          name: (item['nameController'] as TextEditingController).text,
          quantity: int.parse(qtyText),
          rate: double.parse(rateText),
          userId: oldExpense.userId,
        );
      }).toList(),
      userId: oldExpense.userId,
    );

    try {
      await ExpenseDB().updateExpense(updatedExpense);
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: '✓ Expense updated successfully',
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Error updating expense: $e',
        ),
      );
    }
  }

  Future<void> deleteExpense(BuildContext context, String expenseId) async {
    try {
      await ExpenseDB().deleteExpense(expenseId);
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: '✓ Expense deleted successfully!',
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: 'Error deleting expense: $e',
        ),
      );
    }
  }
}   
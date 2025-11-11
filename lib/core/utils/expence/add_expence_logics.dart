import 'package:cream_ventory/database/functions/expence_db.dart';
import 'package:cream_ventory/database/functions/expense_category_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';

class AddExpenseLogic {
  final TextEditingController invoiceController = TextEditingController();
  final TextEditingController totalAmountController = TextEditingController(
    text: '₹',
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

  // If an expense is provided, it loads the expense for editing.
  // Otherwise, it generates a new invoice number automatically.
  AddExpenseLogic({ExpenseModel? expense}) {
    if (expense != null) {
      loadExpense(expense);
    } else {
      _setAutoInvoiceNumber();
    }
  }

  // Initialize data
  Future<void> initializeUserAndData(
    BuildContext context,
    Function setState,
  ) async {
    if (existingExpense == null) {
      await _setAutoInvoiceNumber();
    }
  }

  // Disposes TextEditingControllers to prevent memory leaks when the widget is destroyed.
  void dispose() {
    for (var item in billedItems) {
      (item['nameController'] as TextEditingController?)?.dispose();
      (item['qtyController'] as TextEditingController?)?.dispose();
      (item['rateController'] as TextEditingController?)?.dispose();
    }
    invoiceController.dispose();
    totalAmountController.dispose();
  }

  // Automatically generates a new invoice number when adding, not updating.
  Future<void> _setAutoInvoiceNumber() async {
    if (existingExpense != null) return;
    final db = ExpenseDB();
    final nextInvoice = await db.getNextInvoiceNumber();
    invoiceController.text = nextInvoice;
  }

  // Opens a date picker dialog for selecting a date.
  Future<void> selectDate(BuildContext context, Function setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Adds a new item to billedItems with a unique ID and empty controllers.
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

  // Removes an item at the specified index, ensuring at least one item remains.
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('At least one item is required'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  // Calculates each item's amount (qty * rate) and updates the total.
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

  // Saves the expense and resets the form for a new entry.
  Future<void> saveAndNew(Function setState, BuildContext context) async {
    if (!_validateFields(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
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
      totalAmountController.text = '₹';
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
          'qtyController': TextEditingController(text: '0'),
          'rateController': TextEditingController(text: '0.0'),
        },
      ];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved and ready for new entry!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    await _setAutoInvoiceNumber();
  }

  // Saves the expense to the database (add or update).
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
      } else {
        await expenseDB.addExpense(expense);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingExpense != null
                ? 'Expense updated successfully!'
                : 'Expense saved successfully!',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      if (shouldPop) {
        Navigator.of(context).pop(expense);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving expense: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Loads an existing expense from the database model.
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

  // Add this method to AddExpenseLogic class
Future<List<ExpenseCategoryModel>> loadCategories() async {
  return await ExpenseCategoryDB.getCategories();
}

// Add textBoldStyle getter if not exists
TextStyle get textBoldStyle => AppTextStyles.textBold;

  Future<List<ExpenseCategoryModel>> fetchExpenseCategories() async {
  final categories = await ExpenseCategoryDB.getCategories();
  categories.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return categories;
}

Future<void> addNewCategory(String categoryName) async {
  await ExpenseCategoryDB.addCategory(categoryName);
}

  // Validates form fields, ensuring all required inputs are correct.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // Updates an existing expense in the database.
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense updated successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating expense: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),       
      );
    }
  }

  // Deletes an expense from the database.
  Future<void> deleteExpense(BuildContext context, String expenseId) async {
    try {
      await ExpenseDB().deleteExpense(expenseId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense deleted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting expense: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExpenseDB {
  static const String _boxName = 'expenseBox';

  // Full expenses notifier (complete list)
  final ValueNotifier<List<ExpenseModel>> allExpensesNotifier = ValueNotifier([]);
  
  // Keep the original for backward compatibility if needed
  final ValueNotifier<List<ExpenseModel>> expensesNotifier = ValueNotifier([]);

  ExpenseDB._internal();
  static final ExpenseDB _instance = ExpenseDB._internal();
  factory ExpenseDB() => _instance;

  

  // Initialize and load all expenses
  Future<void> initialize() async {
    await _loadAllExpenses();
  }

  // Load ALL expenses for the current user
  Future<void> _loadAllExpenses() async {
    try {
      final user = await UserDB.getCurrentUser();
      final box = await Hive.openBox<ExpenseModel>(_boxName);
      final allExpenses = box.values   
          .where((expense) => expense.userId == user.id)
          .toList();
      
      allExpensesNotifier.value = allExpenses;
      expensesNotifier.value = allExpenses; // Keep backward compatibility
      
      debugPrint('Loaded ${allExpenses.length} expenses for user ${user.id}');
    } catch (e) {
      debugPrint('Error loading all expenses: $e');
      allExpensesNotifier.value = [];
      expensesNotifier.value = [];
    }
  }

  // Add a new expense
  Future<void> addExpense(ExpenseModel expense) async {
    final box = await Hive.openBox<ExpenseModel>(_boxName);
    debugPrint('Saving Expense: ${expense.toString()}');                    
    await box.put(expense.id, expense);
    debugPrint('Expense saved');
    await _loadAllExpenses(); // Reload full list
  }

  // Get ALL expenses (for listing screens)
  Future<List<ExpenseModel>> getAllExpenses() async {
    await _loadAllExpenses(); // Ensure it's up to date
    return allExpensesNotifier.value;
  }

  // Get filtered expenses by date range (for specific queries)
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allExpenses = await getAllExpenses();
    final filtered = allExpenses.where((expense) {
      final expenseDate = expense.date;
      return expenseDate.isAfter(start.subtract(const Duration(days: 1))) &&
          expenseDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
    
    // DON'T update notifier here - return filtered result only
    return filtered..sort((a, b) => b.date.compareTo(a.date));
  }

   // Generate the next invoice number
  Future<String> getNextInvoiceNumber() async {
    try {
      final box = await Hive.openBox<ExpenseModel>(_boxName);
      final user = await UserDB.getCurrentUser();
      final expenses = box.values
          .where((expense) => expense.userId == user.id)   
          .toList();
      expensesNotifier.value = expenses; // Update notifier
      final lastInvoice = expenses
          .map(
            (e) =>
                int.tryParse(e.invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) ??
                0,
          )
          .fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
      final nextInvoiceNumber = lastInvoice + 1;
      return nextInvoiceNumber.toString().padLeft(5, '0');
    } catch (e) {
      debugPrint('Error generating next invoice number: $e');
      return '00001';
    }
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    final box = await Hive.openBox<ExpenseModel>(_boxName);
    await box.delete(id);
    debugPrint('Expense with ID $id deleted');
    await _loadAllExpenses(); // Reload full list
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      final box = await Hive.openBox<ExpenseModel>(_boxName);
      await box.put(expense.id, expense);
      debugPrint('Expense updated: ID=${expense.id}');
      await _loadAllExpenses(); // Reload full list
    } catch (e) {
      debugPrint('Error updating expense: $e');
    }
  }

  

}
 
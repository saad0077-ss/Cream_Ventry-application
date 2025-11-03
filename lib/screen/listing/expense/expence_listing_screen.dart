import 'package:cream_ventory/db/functions/expence_db.dart';
import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:cream_ventory/screen/adding/expense/add_expense_screen.dart';
import 'package:cream_ventory/screen/listing/expense/screens/expence_listing_screen_body.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:flutter/material.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  DateTime? startDate;
  DateTime? endDate;
  final ExpenseDB _expenseDB = ExpenseDB();

  @override
  void initState() {
    super.initState();
    // Initialize and load expenses when screen starts
    _initializeExpenses();
  }

  // Initialize expenses and ensure data is loaded
  Future<void> _initializeExpenses() async {
    try {
      await _expenseDB.initialize();
    } catch (e) {
      debugPrint('Error initializing expenses: $e');
    }
  }

  // Refresh expenses manually
  Future<void> _refreshExpenses() async {
    await _initializeExpenses();
  }

  List<ExpenseModel> _filterExpenses(List<ExpenseModel> expenses) {
    if (startDate == null || endDate == null) {
      return expenses;
    }
    return expenses.where((expense) {
      try {
        // Ensure date comparison works correctly
        final expenseDate = expense.date;
        return expenseDate.isAfter(
              startDate!.subtract(const Duration(days: 1)),
            ) &&
            expenseDate.isBefore(endDate!.add(const Duration(days: 1)));
      } catch (e) {
        debugPrint('Error filtering expense date: $e');
        return false;
      }
    }).toList();
  }

  void _onDateRangeChanged(DateTime newStartDate, DateTime newEndDate) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        startDate = newStartDate;
        endDate = newEndDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(title: 'Expense Transactions', fontSize: 20),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: ValueListenableBuilder<List<ExpenseModel>>(
          valueListenable: _expenseDB.allExpensesNotifier,
          builder: (context, allExpenses, _) {
            debugPrint('All expenses count: ${allExpenses.length}');

            final filteredExpenses = _filterExpenses(allExpenses);
            final totalExpense = filteredExpenses.fold<double>(
              0.0,
              (sum, expense) => sum + expense.totalAmount,
            );

            debugPrint(
              'Filtered expenses: ${filteredExpenses.length}, Total: $totalExpense',
            );

            return BodyOfExpense(
              expenses: filteredExpenses,
              totalExpense: totalExpense,
              onDateRangeChanged: _onDateRangeChanged,
            );
          },
        ),
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        elevation: 6,
        onPressed: () async { 
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpensePage()),
          );
          // Refresh expenses after returning
          if (result == true || result != null) {
            debugPrint('Refresh triggered from AddExpensePage');
            await _refreshExpenses();
          }
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Optional: customize position
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
 
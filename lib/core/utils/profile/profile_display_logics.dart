import 'dart:async';
import 'package:cream_ventory/core/utils/profile/profile_financial_utils.dart';
import 'package:cream_ventory/database/functions/expence_db.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/screens/auth/sign_in_screen.dart';
import 'package:cream_ventory/screens/settings/user_password_change.dart';
import 'package:cream_ventory/screens/profile/user_profile_editing_screen.dart';
import 'package:cream_ventory/widgets/snack_bar.dart';
import 'package:flutter/material.dart';

class ProfileDisplayLogic {
  final BuildContext context;

  // -----------------------------------------------------------------
  // 1. Total-expense notifier – UI just reads this
  // -----------------------------------------------------------------
  final ValueNotifier<double> totalExpenseNotifier = ValueNotifier(0.0);
  final totalIncomeNotifier = ValueNotifier<double>(0.0);
  final totalYouWillGetNotifier = ValueNotifier<double>(0.0);
  final totalYouWillGiveNotifier = ValueNotifier<double>(0.0);

  // Keep a reference to the Hive notifier so we can react to changes
  late final ValueNotifier<List<ExpenseModel>> _hiveListener;

  ProfileDisplayLogic(this.context) {
    // Initialise DB (idempotent)
    ExpenseDB().initialize();

    // Grab Hive's list notifier
    _hiveListener = ExpenseDB().allExpensesNotifier;

    // Compute initial value
    _recalculateTotal();
    _recalculateIncome(); 
    _initializePartyFinancials();
                
    // Listen for any future changes
    _hiveListener.addListener(_recalculateTotal);
  }

  Future<void> refreshFinancialSummaries() async {
   try {
      final totalYouWillGet = await PartyDb.calculateTotalYoullGet();   
      final totalYouWillGive = await PartyDb.calculateTotalYoullGive();

      totalYouWillGetNotifier.value = totalYouWillGet;
      totalYouWillGiveNotifier.value = totalYouWillGive;

      // Also update income/expense if you have those DBs
      // totalIncomeNotifier.value = await IncomeDb.getTotalIncome();
      // totalExpenseNotifier.value = await ExpenseDb.getTotalExpense();
    } catch (e) {
      debugPrint('Error refreshing financial summary: $e');
    }
  }
  Future<void> _initializePartyFinancials() async {
    try {
      // This triggers full recalculation of all party balances
      await PartyDb.loadParties();

      // Now update the profile notifiers
      await refreshFinancialSummaries();

      debugPrint('Party financials loaded successfully');
    } catch (e) {
      debugPrint('Failed to load party financials: $e');
    }
  }

  // -----------------------------------------------------------------
  // 2. Recalculate total expense from the current list
  // -----------------------------------------------------------------
  void _recalculateTotal() {
    final expenses = _hiveListener.value;
    final sum = expenses.fold<double>(0.0, (prev, e) => prev + (e.totalAmount));
    totalExpenseNotifier.value = sum;
  }

  Future<void> _recalculateIncome() async {
    final income = await ProfileFinancialUtils.calculateTotalIncome();
    totalIncomeNotifier.value = income;
  }

  // -----------------------------------------------------------------
  // -----------------------------------------------------------------
  // 3. Clean-up when the object is no longer needed
  // -----------------------------------------------------------------
  void dispose() {
    _hiveListener.removeListener(_recalculateTotal);
    totalExpenseNotifier.dispose();
    totalIncomeNotifier.dispose();
  }

  // -----------------------------------------------------------------
  // 4. Navigation helpers
  // -----------------------------------------------------------------
  void navigateBack() => Navigator.of(context).pop();

  void navigateToChangePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePassword()));
  }

  void navigateToEditProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const EditProfilePage()));
  }

  Future<void> logout() async {
    try {
      await UserDB.logoutUser();

      CustomSnackbar.show(
        context: context,
        message: 'Logged out successfully!',
        backgroundColor: Colors.green,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ScreenSignIn()),
        (route) => false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context: context,
        message: 'Error logging out. Please try again.',
        backgroundColor: Colors.red,
      );
      debugPrint('Logout error: $e');
    }
  }
}

import 'dart:async';
import 'package:cream_ventory/core/utils/profile/profile_financial_utils.dart';
import 'package:cream_ventory/database/functions/expence_db.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/screens/auth/sign_in_screen.dart';
import 'package:cream_ventory/screens/settings/user_password_change.dart';
import 'package:cream_ventory/screens/profile/user_profile_editing_screen.dart';
import 'package:flutter/material.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProfileDisplayLogic {
  final BuildContext context;

  // Financial Notifiers 
  final ValueNotifier<double> totalExpenseNotifier = ValueNotifier(0.0);
  final totalIncomeNotifier = ValueNotifier<double>(0.0);
  final totalYouWillGetNotifier = ValueNotifier<double>(0.0);
  final totalYouWillGiveNotifier = ValueNotifier<double>(0.0);

  late final ValueNotifier<List<ExpenseModel>> _hiveListener;

  ProfileDisplayLogic(this.context) {
    ExpenseDB().initialize();
    _hiveListener = ExpenseDB().allExpensesNotifier;

    _recalculateTotal();
    _recalculateIncome();
    _initializePartyFinancials();

    _hiveListener.addListener(_recalculateTotal);
  }

  Future<void> refreshFinancialSummaries() async {
    try {
      final totalYouWillGet = await PartyDb.calculateTotalYoullGet();
      final totalYouWillGive = await PartyDb.calculateTotalYoullGive();

      totalYouWillGetNotifier.value = totalYouWillGet;
      totalYouWillGiveNotifier.value = totalYouWillGive;
    } catch (e) {
      debugPrint('Error refreshing financial summary: $e');
    }
  }

  Future<void> _initializePartyFinancials() async {
    try {
      await PartyDb.loadParties();
      await refreshFinancialSummaries();
      debugPrint('Party financials loaded successfully');
    } catch (e) {
      debugPrint('Failed to load party financials: $e');
    }
  }

  void _recalculateTotal() {
    final expenses = _hiveListener.value;
    final sum = expenses.fold<double>(0.0, (prev, e) => prev + e.totalAmount);
    totalExpenseNotifier.value = sum;
  }

  Future<void> _recalculateIncome() async {
    final income = await ProfileFinancialUtils.calculateTotalIncome();
    totalIncomeNotifier.value = income;
  }

  // Cleanup
  void dispose() {
    _hiveListener.removeListener(_recalculateTotal);
    totalExpenseNotifier.dispose();
    totalIncomeNotifier.dispose();
    totalYouWillGetNotifier.dispose();
    totalYouWillGiveNotifier.dispose();
  }

  // Navigation Helpers
  void navigateBack() => Navigator.of(context).pop();

  void navigateToChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePassword()),
    );
  }

  void navigateToEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  // LOGOUT with top_snackbar_flutter
  Future<void> logout() async {
    try {
      await UserDB.logoutUser();

      // Success Top Snackbar
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(
          message: "Logged out successfully!",
          icon: Icon(Icons.logout, color: Colors.white, size: 40),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to Sign In
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ScreenSignIn()),
          (route) => false,
        );
      }
    } catch (e) {
      // Error Top Snackbar
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Error logging out. Please try again.",
          backgroundColor: Colors.red.shade600,
        ),
      );
      debugPrint('Logout error: $e');
    }
  }
}
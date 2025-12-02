// lib/utils/report_data_manager.dart
import 'package:cream_ventory/database/functions/expence_db.dart';
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:cream_ventory/database/functions/user_db.dart'; // Import for UserDB

class ReportDataManager {
  static Future<void> selectDate({
    required BuildContext context,
    required bool isFrom,
    required DateTime? startDate,
    required DateTime? endDate,
    required Function(DateTime?, DateTime?) onDatesSelected,
  }) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      DateTime? newStartDate = startDate;
      DateTime? newEndDate = endDate;

      if (isFrom && picked != startDate) {
        newStartDate = picked;
      } else if (!isFrom && picked != endDate) {
        newEndDate = picked;
      }

      onDatesSelected(newStartDate, newEndDate);
    }
  }

  static Future<double> getTotalAmountByDateRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final payments = await PaymentInDb.getAllPayments();
      final total = payments
          .where((payment) {
            // If either date is null, include all payments for the user
            if (startDate == null || endDate == null) {
              return payment.userId == userId;
            }
 
            final paymentDate = DateFormat('dd MMM yyyy').parse(payment.date);
            final normalizedPaymentDate = DateTime.utc(
              paymentDate.year,
              paymentDate.month,
              paymentDate.day,
            );
            final normalizedStart = DateTime.utc(
              startDate.year,
              startDate.month,
              startDate.day,
            );
            final normalizedEnd = DateTime.utc(
              endDate.year,
              endDate.month,
              endDate.day,
            );

            // Inclusive range check
            return payment.userId == userId &&
                (normalizedPaymentDate.isAfter(normalizedStart) ||
                    normalizedPaymentDate.isAtSameMomentAs(normalizedStart)) &&
                (normalizedPaymentDate.isBefore(normalizedEnd) ||
                    normalizedPaymentDate.isAtSameMomentAs(normalizedEnd));
          })
          .fold(0.0, (sum, payment) => sum + payment.receivedAmount);
      debugPrint('Total payment amount from $startDate to $endDate: $total');
      return total;
    } catch (e) {
      debugPrint(
        'Error getting total payment amount for range $startDate to $endDate: $e',
      );
      return 0.0;
    }
  }

  static Future<double> getTotalReceivedAmountByDateRange({
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final sales = await SaleDB.getSales();
      final total = sales
          .where((sale) {
            // If either date is null, include all sales for the user
            if (startDate == null || endDate == null) {
              return sale.userId == userId;
            }

            final saleDate = DateFormat('dd MMM yyyy').parse(sale.date);
            final normalizedSaleDate = DateTime.utc(
              saleDate.year,
              saleDate.month,
              saleDate.day,
            );
            final normalizedStart = DateTime.utc(
              startDate.year,
              startDate.month,
              startDate.day,
            );
            final normalizedEnd = DateTime.utc(
              endDate.year,
              endDate.month,
              endDate.day,
            );

            // Inclusive range check
            return sale.userId == userId &&
                (normalizedSaleDate.isAfter(normalizedStart) ||
                    normalizedSaleDate.isAtSameMomentAs(normalizedStart)) &&
                (normalizedSaleDate.isBefore(normalizedEnd) ||
                    normalizedSaleDate.isAtSameMomentAs(normalizedEnd));
          })
          .fold(0.0, (sum, sale) => sum + sale.receivedAmount);
      debugPrint('Total received amount from $startDate to $endDate: $total');
      return total;
    } catch (e) {
      debugPrint(
        'Error getting total received amount for range $startDate to $endDate: $e',
      );
      return 0.0;
    }
  }

  static Future<double> getTotalSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      final box = Hive.box<SaleModel>(SaleDB.boxName);
      // Filter sales by userId and date range
      final sales = box.values.where((sale) {
        final saleDate = DateFormat('dd MMM yyyy').parse(sale.date);
        final normalizedSaleDate = DateTime.utc(
          saleDate.year,
          saleDate.month,
          saleDate.day,
        );
        final normalizedStart = DateTime.utc(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final normalizedEnd = DateTime.utc(
          endDate.year,
          endDate.month,
          endDate.day,
        );

        // Inclusive range check
        return sale.userId == userId &&
            (normalizedSaleDate.isAfter(normalizedStart) ||
                normalizedSaleDate.isAtSameMomentAs(normalizedStart)) &&
            (normalizedSaleDate.isBefore(normalizedEnd) ||
                normalizedSaleDate.isAtSameMomentAs(normalizedEnd));
      }).toList();

      // Calculate total sales amount
      double totalSales = 0.0;
      for (var sale in sales) {
        // Use totalAmount if available, otherwise calculate from items
        totalSales += sale.total;
      }

      debugPrint(
        'Total sales from ${DateFormat('yyyy-MM-dd').format(startDate)} to '
        '${DateFormat('yyyy-MM-dd').format(endDate)}: $totalSales',
      );
      return totalSales;
    } catch (e) {
      debugPrint('Error calculating total sales: $e');
      throw Exception('Failed to calculate total sales: $e');
    }
  }

  static Future<double> getTotalExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      await ExpenseDB().initialize(); // Ensure the Hive box is initialized  

      final box = Hive.box<ExpenseModel>('expenseBox');
      // Filter expenses by userId and date range
      final expenses = box.values
          .where((expense) {
            final expenseDate = expense.date;
            final normalizedExpenseDate = DateTime.utc(expenseDate.year, expenseDate.month, expenseDate.day);
            final normalizedStart = DateTime.utc(startDate.year, startDate.month, startDate.day);
            final normalizedEnd = DateTime.utc(endDate.year, endDate.month, endDate.day);

            // Inclusive range check
            return expense.userId == userId &&
                   (normalizedExpenseDate.isAfter(normalizedStart) ||
                    normalizedExpenseDate.isAtSameMomentAs(normalizedStart)) &&
                   (normalizedExpenseDate.isBefore(normalizedEnd) ||
                    normalizedExpenseDate.isAtSameMomentAs(normalizedEnd));
          })
          .toList();

      // Calculate total expenses amount
      double totalExpenses = expenses.fold(
        0.0,
        (sum, expense) => sum + expense.totalAmount,
      );

      debugPrint(
        'Total expenses from ${DateFormat('yyyy-MM-dd').format(startDate)} to '
        '${DateFormat('yyyy-MM-dd').format(endDate)}: $totalExpenses',
      );
      return totalExpenses;
    } catch (e) {
      debugPrint('Error calculating total expenses: $e');
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  static Future<double> getTotalPaymentOutByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      await PaymentOutDb.init(); // Ensure the Hive box is initialized

      final box = Hive.box<PaymentOutModel>(PaymentOutDb.boxName);
      // Filter payments by userId and date range
      final payments = box.values
          .where((payment) {
            // Assuming date is a string in dd/MM/yyyy format, consistent with other methods
            final paymentDate = DateFormat('dd MMM yyyy').parse(payment.date);
            final normalizedPaymentDate = DateTime.utc(paymentDate.year, paymentDate.month, paymentDate.day);
            final normalizedStart = DateTime.utc(startDate.year, startDate.month, startDate.day);
            final normalizedEnd = DateTime.utc(endDate.year, endDate.month, endDate.day);    

            // Inclusive range check
            return payment.userId == userId &&
                   (normalizedPaymentDate.isAfter(normalizedStart) ||
                    normalizedPaymentDate.isAtSameMomentAs(normalizedStart)) &&
                   (normalizedPaymentDate.isBefore(normalizedEnd) ||
                    normalizedPaymentDate.isAtSameMomentAs(normalizedEnd));
          })
          .toList();

      // Calculate total payment out amount
      double totalPayments = payments.fold(
        0.0, 
        (sum, payment) => sum + payment.paidAmount,
      );

      debugPrint(
        'Total payment out from ${DateFormat('yyyy-MM-dd').format(startDate)} to '
        '${DateFormat('yyyy-MM-dd').format(endDate)}: $totalPayments',
      );
      return totalPayments;
    } catch (e) {
      debugPrint('Error calculating total payment out: $e');
      throw Exception('Failed to calculate total payment out: $e');
    }
  }
}

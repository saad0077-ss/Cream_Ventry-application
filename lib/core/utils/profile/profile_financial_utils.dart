import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:flutter/foundation.dart';

/// Simple, reliable total income calculator
class ProfileFinancialUtils {
  ProfileFinancialUtils._(); // Static class

  /// Calculates **Total Income** = Sales + Payments (All Time)
  static Future<double> calculateTotalIncome() async {
    try {
      // Ensure DBs are initialized
      await SaleDB.init();
      await PaymentInDb.init();

      final sales = await SaleDB.getSales();
      final payments = await PaymentInDb.getAllPayments();

      double total = 0.0;

      // ---- SALES ----
      for (final s in sales) {
        final amount = s.receivedAmount ; 
        total += amount;
        debugPrint('Sale: ${s.id} → +₹$amount');
      }

      // ---- PAYMENTS ----
      for (final p in payments) {
        final amount = p.receivedAmount ;
        total += amount;
        debugPrint('Payment: ${p.id} → +₹$amount');
      }

      debugPrint('TOTAL INCOME: ₹$total');
      return total;

    } catch (e, stack) {
      debugPrint('calculateTotalIncome ERROR: $e');
      debugPrintStack(stackTrace: stack);
      return 0.0; // Only on real crash
    }
  }
}
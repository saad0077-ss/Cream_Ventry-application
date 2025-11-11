import 'package:intl/intl.dart';

class FormatUtils {
  // Helper function to safely format date
  static String formatDate(dynamic date) {
    if (date == null) return 'Unknown Date';
    try {
      final parsedDate = date is DateTime
          ? date
          : DateTime.tryParse(date.toString());
      if (parsedDate != null) {
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      }
    } catch (e) {
      print('Error formatting date: $e');
    }
    return 'Invalid Date';
  }

  // Helper function to safely format total amount
  static String formatAmount(dynamic amount) {
    if (amount == null) return '0.00'; // Fallback if null
    try {
      if (amount is double) {
        return amount.toStringAsFixed(2); // If it's already a double, format it
      } else if (amount is String) {
        // Try parsing string into double
        return double.tryParse(amount) != null
            ? double.tryParse(amount)!.toStringAsFixed(2)
            : '0.00';
      }
    } catch (e) {
      print('Error formatting amount: $e');
    }
    return '0.00'; // Fallback if invalid
  }
}
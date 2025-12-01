import 'package:intl/intl.dart';

class FormatUtils {
  // Helper function to safely format date
  static String formatDate(dynamic date) {
    if (date == null) return 'Unknown Date';
    try {
      DateTime? parsedDate;
      
      if (date is DateTime) {
        parsedDate = date;
      } else if (date is String) {
        // Try multiple date formats
        parsedDate = DateTime.tryParse(date); // ISO format
        
        if (parsedDate == null) {
          // Try 'dd MMM yyyy' format
          try {
            parsedDate = DateFormat('dd MMM yyyy').parse(date);
          } catch (_) {}
        }
        
        if (parsedDate == null) {
          // Try 'dd/MM/yyyy' format
          try {  
            parsedDate = DateFormat('dd/MM/yyyy').parse(date);
          } catch (_) {}
        }
      }
      
      if (parsedDate != null) {
        return DateFormat('dd MMM yyyy').format(parsedDate);
      }
    } catch (e) {
      print('Error formatting date: $e - Date value: $date');
    }
    return 'Invalid Date';
  }

  // Helper function to safely format total amount
  static String formatAmount(dynamic amount) {
    if (amount == null) return '₹ 0.00'; // Add currency symbol
    try {
      if (amount is double) {
        return '₹ ${amount.toStringAsFixed(2)}';
      } else if (amount is int) {
        return '₹ ${amount.toDouble().toStringAsFixed(2)}';
      } else if (amount is String) {
        final parsed = double.tryParse(amount);
        return parsed != null ? '₹ ${parsed.toStringAsFixed(2)}' : '₹ 0.00';
      }
    } catch (e) {
      print('Error formatting amount: $e - Amount value: $amount');
    }
    return '₹ 0.00';
  }
}
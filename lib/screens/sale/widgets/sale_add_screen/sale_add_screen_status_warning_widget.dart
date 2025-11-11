// sale_status_warning_widget.dart
import 'package:flutter/material.dart';

class SaleStatusWarningWidget {
  /// Builds the status warning for cancelled or closed sales
  static Widget buildStatusWarning({
    required bool isCancelled,
    required bool isClosed,
    required String transactionType,
  }) {
    if (transactionType.toLowerCase() != 'sale' &&isCancelled || isClosed ) {       
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'This sale order is ${isCancelled ? "cancelled" : "closed"} and cannot be edited.',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,   
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
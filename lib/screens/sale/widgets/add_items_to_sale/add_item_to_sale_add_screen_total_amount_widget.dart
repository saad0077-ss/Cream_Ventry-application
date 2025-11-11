// add_item_total_amount_widget.dart
import 'package:flutter/material.dart';

class AddItemTotalAmountWidget {
  /// Builds the total amount field
  static Widget buildTotalAmount({
    required TextEditingController totalAmountController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          const Text(
            'Total Amount :',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: totalAmountController,
              readOnly: true,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
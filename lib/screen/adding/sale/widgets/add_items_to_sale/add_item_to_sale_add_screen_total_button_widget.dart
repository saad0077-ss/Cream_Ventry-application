// add_item_total_button_widget.dart
import 'package:flutter/material.dart';

class AddItemTotalButtonWidget {
  /// Builds the total calculation button
  static Widget buildTotalButton({
    required VoidCallback onPressed,
  }) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          'Total',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
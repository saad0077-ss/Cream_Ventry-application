import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onTakePayment;
  final VoidCallback onAddAction;
  final VoidCallback onAddSale;

  const ActionButtons({
    super.key,
    required this.onTakePayment,
    required this.onAddAction,
    required this.onAddSale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8, // Fixed pixel value
        vertical: 4, // Fixed pixel value
      ), 
      child: Row( 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CustomActionButton(
              label: 'Take Payment',
              backgroundColor: const Color.fromARGB(255, 80, 82, 84),
              onPressed: onTakePayment,
            ),
          ),
          const SizedBox(width: 4), // Fixed pixel value
          FloatingActionButton(
            onPressed: onAddAction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24), // Fixed pixel value
            ),
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 4), // Fixed pixel value
          Expanded(
            child: CustomActionButton(
              label: 'Add Sale',
              backgroundColor: const Color.fromARGB(255, 180, 189, 5),
              onPressed: onAddSale,
            ),
          ),
        ],
      ),
    );
  }
}
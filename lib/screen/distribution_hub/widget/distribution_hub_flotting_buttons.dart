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
        horizontal: 8, 
        vertical: 4,
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
          const SizedBox(width: 4), 
          FloatingActionButton(
            backgroundColor: Colors.blueGrey,
            onPressed: onAddAction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.blueGrey)
            ),
             
            child: const Icon(Icons.add,color: Colors.white,),
          ),
          const SizedBox(width: 4), 
          Expanded(
            child: CustomActionButton(
              label: 'Add Sale',
              backgroundColor: const Color.fromARGB(255, 85, 172, 213),
              onPressed: onAddSale,
            ),
          ),
        ],
      ),
    );
  }
}
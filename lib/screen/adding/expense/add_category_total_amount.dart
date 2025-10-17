import 'package:cream_ventory/utils/expence/add_expence_logics.dart';
import 'package:flutter/material.dart';

class TotalAmountWidget extends StatelessWidget {
  final AddExpenseLogic logic;

  const TotalAmountWidget({super.key, required this.logic});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(6)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('TOTAL AMOUNT', style: logic.textBoldStyle),
          SizedBox(
            width: screenWidth * 0.4,
            child: TextField(
              controller: logic.totalAmountController,
              readOnly: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }
}
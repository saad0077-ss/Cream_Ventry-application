import 'package:cream_ventory/utils/responsive_util.dart';
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
    SizeConfig.init(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 2,
        vertical: SizeConfig.blockHeight * 0.5,
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
          SizedBox(width: SizeConfig.blockWidth * 1),
          FloatingActionButton(
            onPressed: onAddAction,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 6),
            ),
            child: const Icon(Icons.add),
          ),
          SizedBox(width: SizeConfig.blockWidth * 1),
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

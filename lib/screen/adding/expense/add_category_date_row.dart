import 'package:cream_ventory/utils/adding/expence/add_expence_logics.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRowWidget extends StatelessWidget {
  final AddExpenseLogic logic;
  final void Function(VoidCallback) onDateSelected; // Added callback
  
  const DateRowWidget({
    super.key, 
    required this.logic,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            controller: logic.invoiceController,
            hintText: 'Invoice No',
            labelText: 'Invoice No',
            readOnly: true,
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => logic.selectDate(context, onDateSelected),
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: DateFormat('dd/MM/yyyy').format(logic.selectedDate),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
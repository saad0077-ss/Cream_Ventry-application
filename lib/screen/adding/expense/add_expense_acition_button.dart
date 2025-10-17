import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:cream_ventory/utils/expence/add_expence_logics.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class ActionButtonsWidget extends StatelessWidget {
  final AddExpenseLogic logic;
  final bool isEditing;
  final ExpenseModel? existingExpense;
  final void Function(VoidCallback)? onSaveAndNew; // Added callback

  const ActionButtonsWidget({
    super.key,
    required this.logic,
    required this.isEditing,
    this.existingExpense,
    this.onSaveAndNew,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        isEditing
          ? CustomActionButton(
              onPressed: () => logic.deleteExpense(context, existingExpense!.id),
              backgroundColor: Colors.red,
              label: 'Delete',
            )
          : CustomActionButton(
              onPressed: () => logic.saveAndNew(onSaveAndNew ?? (()=>{}), context),
              backgroundColor: Colors.red,
              label: 'Save & New',
            ),
        CustomActionButton(
          onPressed: isEditing && existingExpense != null
            ? () => logic.updateExpense(existingExpense!, context)
            : () => logic.save(context),
          backgroundColor: Colors.black,
          label: isEditing ? 'Update' : 'Save',
        ),
      ],
    );
  }
}
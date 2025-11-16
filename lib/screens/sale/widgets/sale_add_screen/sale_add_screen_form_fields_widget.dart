// sale_form_fields_widget.dart
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/core/constants/sale_add_screen_constant.dart';
import 'package:cream_ventory/screens/sale/widgets/sale_add_screen/sale_add_screen_customer_dropdown_widget.dart';
import 'package:flutter/material.dart';

class SaleFormFieldsWidget {
  /// Builds a gorgeous, Material-3 styled form card.
  static Widget buildFormFields({
    required TextEditingController invoiceController,
    required TextEditingController dateController,
    required TextEditingController customerController,
    required TextEditingController dueDateController,
    required bool isEditable,
    required TransactionType transactionType,
    required VoidCallback? onDateTap,
    required VoidCallback? onDueDateTap,
    required ValueChanged<PartyModel?>? onCustomerChanged,
  }) {
    // Common styling
    const double kFieldRadius = 10.0;
    const EdgeInsets kFieldPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    final InputBorder enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kFieldRadius),
      borderSide: BorderSide(color: Colors.grey.shade300),
    );
    final InputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(kFieldRadius),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Invoice + Date ----------
            Row(
              children: [
                Expanded(
                  child: _StyledTextField(
                    controller: invoiceController,
                    label: AppConstants.invoiceNoLabel,
                    readOnly: true,
                    enabledBorder: enabledBorder,
                    focusedBorder: focusedBorder,
                    padding: kFieldPadding,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StyledTextField(
                    controller: dateController,
                    label: AppConstants.dateLabel,
                    readOnly: true,
                    onTap: isEditable ? onDateTap : null,
                    suffixIcon: const Icon(Icons.calendar_today, size: 20),
                    enabledBorder: enabledBorder,
                    focusedBorder: focusedBorder,
                    padding: kFieldPadding,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---------- Customer Dropdown ----------
            SaleCustomerDropdownWidget.buildCustomerDropdown(
              customerController: customerController,
              isEditable: isEditable,
              onChanged: onCustomerChanged,
            ),
            const SizedBox(height: 20),

            // ---------- Due Date (only for SaleOrder) ----------
            if (transactionType == TransactionType.saleOrder)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _StyledTextField(
                  controller: dueDateController,
                  label: AppConstants.dueDateLabel,
                  readOnly: true,
                  onTap: isEditable ? onDueDateTap : null,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20),
                  enabledBorder: enabledBorder,
                  focusedBorder: focusedBorder,
                  padding: kFieldPadding,
                ),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Re-usable styled TextField – keeps the code DRY.
class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    required this.enabledBorder,
    required this.focusedBorder,
    required this.padding,
  });

  final TextEditingController controller;
  final String label;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final InputBorder enabledBorder;
  final InputBorder focusedBorder;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        contentPadding: padding,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(maxHeight: 36),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
      ),
    );
  }
}
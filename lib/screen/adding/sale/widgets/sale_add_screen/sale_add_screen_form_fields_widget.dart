// sale_form_fields_widget.dart
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/screen/adding/sale/constant/sale_add_screen_constant.dart';
import 'package:cream_ventory/screen/adding/sale/widgets/sale_add_screen/sale_add_screen_customer_dropdown_widget.dart';
import 'package:flutter/material.dart';

class SaleFormFieldsWidget {
  /// Builds the form fields section (invoice, date, customer, due date)
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextField(
                controller: invoiceController,
                decoration: const InputDecoration(
                  labelText: AppConstants.invoiceNoLabel,
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: dateController,
                readOnly: true,
                onTap: isEditable ? onDateTap : null,
                decoration: const InputDecoration(
                  labelText: AppConstants.dateLabel,
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SaleCustomerDropdownWidget.buildCustomerDropdown(
          customerController: customerController,
          isEditable: isEditable,
          onChanged: onCustomerChanged,
        ),
        if (transactionType == TransactionType.saleOrder) ...[
          const SizedBox(height: 20),
          TextField(
            controller: dueDateController,
            readOnly: true,
            onTap: isEditable ? onDueDateTap : null,
            decoration: const InputDecoration(
              labelText: AppConstants.dueDateLabel,
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
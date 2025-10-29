// sale_customer_dropdown_widget.dart
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:flutter/material.dart';

import '../../constant/sale_add_screen_constant.dart';

class SaleCustomerDropdownWidget {
  /// Builds the customer dropdown or text field if no customers are available
  static Widget buildCustomerDropdown({
    required TextEditingController customerController,
    required bool isEditable,
    required ValueChanged<PartyModel?>? onChanged,
  }) {
    return ValueListenableBuilder<List<PartyModel>>(
      valueListenable: PartyDb.partyNotifier,
      builder: (context, parties, _) {
        if (parties.isEmpty) {
          return TextField(
            controller: customerController,
            decoration: const InputDecoration(
              labelText: AppConstants.customerLabel,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
              hintText: AppConstants.noCustomersHint,
            ),
            readOnly: true,
          );
        }
        PartyModel? selectedParty;
        if (customerController.text.isNotEmpty) {
          selectedParty = parties.firstWhere(
            (party) => party.name == customerController.text,
            orElse: () => parties[0],
          );
        }
        return DropdownButtonFormField<PartyModel>(
          value: selectedParty,
          hint: const Text(AppConstants.selectCustomerHint),
          items: parties.map((party) {
            return DropdownMenuItem<PartyModel>(
              value: party,
              child: Text(party.name),
            );
          }).toList(),
          onChanged: isEditable ? onChanged : null,
          decoration: const InputDecoration(
            labelText: AppConstants.customerLabel,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          isExpanded: true,
          validator: (value) {
            if (value == null && customerController.text.isEmpty) {
              return AppConstants.selectCustomerError;
            }
            return null;
          },
        );
      },
    );
  }
}
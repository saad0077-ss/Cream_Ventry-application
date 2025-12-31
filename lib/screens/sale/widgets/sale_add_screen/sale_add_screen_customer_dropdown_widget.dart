// sale_customer_dropdown_widget.dart
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/sale_add_screen_constant.dart';
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
            decoration: InputDecoration(
              labelText: AppConstants.customerLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), 
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.person,
                color: Colors.grey.shade600,
              ),
              hintText: AppConstants.noCustomersHint,
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            readOnly: true,
          );
        }

        // ✅ Find party by ID if available, fallback to name
        PartyModel? selectedParty;
        if (customerController.text.isNotEmpty) {
          try {
            selectedParty = parties.firstWhere(
              (party) => party.name == customerController.text,
            );
          } catch (e) {
            debugPrint('Party not found: ${customerController.text}');
          }
        }

        return DropdownButtonFormField<String>(  // ← Use String (party ID)
          value: selectedParty?.id,  // ← Use party ID
          hint: Text(
            AppConstants.selectCustomerHint,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          items: parties.map((party) {
            return DropdownMenuItem<String>(  // ← Use String
              value: party.id,  // ← Use party ID as value
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Text(
                        party.name.isNotEmpty ? party.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        party.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (BuildContext context) {
            return parties.map<Widget>((PartyModel party) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  party.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          onChanged: isEditable 
              ? (String? partyId) {  // ← Receive party ID
                  if (partyId != null && onChanged != null) {
                    final party = parties.firstWhere((p) => p.id == partyId);
                    onChanged(party);  // ← Pass full party object
                  }
                }
              : null,
          decoration: InputDecoration(
            labelText: AppConstants.customerLabel,
            labelStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), 
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),     
            prefixIcon: Icon(
              Icons.person,
              color: isEditable ? Theme.of(context).primaryColor : Colors.grey.shade400,
            ),
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isEditable ? Theme.of(context).primaryColor : Colors.grey.shade400,
          ), 
          dropdownColor: Colors.white,
          menuMaxHeight: 300,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
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
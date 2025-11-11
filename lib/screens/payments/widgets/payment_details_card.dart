import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';

class PaymentDetailsCard extends StatelessWidget {
  final TextEditingController receiptController;
  final TextEditingController dateController;
  final TextEditingController phoneNumberController;
  final PartyModel? selectedParty;
  final ValueChanged<PartyModel?> onPartyChanged;
  final VoidCallback onDateTap;

  const PaymentDetailsCard({
    super.key,
    required this.receiptController,
    required this.dateController,
    required this.phoneNumberController,
    required this.selectedParty,
    required this.onPartyChanged,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white.withOpacity(0.95),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: receiptController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Receipt No',
                      labelStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: onDateTap,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        color: Colors.black54,
                        size: 20,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PartyModel>(
              value: selectedParty,
              decoration: InputDecoration(
                labelText: 'Party Name',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              items: PartyDb.partyNotifier.value.map((PartyModel party) {
                return DropdownMenuItem<PartyModel>(
                  value: party,
                  child: Text(
                    party.name,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: onPartyChanged,
              hint: const Text(
                'Select Party',
                style: TextStyle(color: Colors.black54),
              ),
              validator: (value) => value == null ? 'Please select a party' : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: const TextStyle(color: Colors.black54),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.phone,
                  color: Colors.black54,
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
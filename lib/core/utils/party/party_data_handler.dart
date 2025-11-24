import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class PartyDataHandler {
  final _uuid = const Uuid();

  Future<void> saveParty({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required PartyModel? party,
    required String partyName,
    required String contactNumber,
    required String openingBalance,
    required String paymentType,
    required DateTime? selectedDate,
    required String billingAddress,
    required String email,
    required Uint8List? imageBytes,
    required String imagePath,
    required bool clearFields,
    required VoidCallback clearForm,
  }) async {
    if (!formKey.currentState!.validate()) return;

    if (partyName.isEmpty || contactNumber.isEmpty) {
      _showSnackBar(context, "Party Name and Contact Number are required!", Colors.red);
      return;
    }

    // Handle optional opening balance - default to 0.0 if empty
    double parsedBalance = 0.0;
    if (openingBalance.trim().isNotEmpty) {
      parsedBalance = double.tryParse(openingBalance) ?? 0.0;
    }
    
    double finalOpeningBalance =
        paymentType == "You'll Give" ? -parsedBalance.abs() : parsedBalance.abs();

    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    String finalImagePath = '';
    if (kIsWeb && imageBytes != null) {
      finalImagePath = base64Encode(imageBytes); // Store as base64 for web
    } else {
      finalImagePath = imagePath.isNotEmpty ? imagePath : (party?.imagePath ?? '');
    }

    final newParty = PartyModel(
      id: party?.id ?? _uuid.v4(),
      name: partyName,
      contactNumber: contactNumber,
      openingBalance: finalOpeningBalance,
      asOfDate: selectedDate ?? DateTime.now(),
      billingAddress: billingAddress,
      email: email,
      paymentType: paymentType,
      imagePath: finalImagePath,
      partyBalance: 0.0,
      userId: userId,
    );

    try {
      if (party != null) {
        bool success = await PartyDb.updatePartyBasic(newParty);
        if (success) {
          _showSnackBar(context, "Party updated successfully!", Colors.green);
        } else {
          throw Exception("Failed to update party: Not found");
        }
      } else {
        await PartyDb.addParty(newParty);
        _showSnackBar(context, "Party added successfully!", Colors.green);
      }

      if (clearFields) {
        clearForm();
      } else {
        Navigator.of(context).pop(newParty);
      }
    } catch (e) {
      _showSnackBar(context, "Failed to save party: $e", Colors.red);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( 
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
import 'dart:convert';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      _showError(context, "Party Name and Contact Number are required!");
      return;
    }

    // Parse opening balance safely
    double parsedBalance = 0.0;
    if (openingBalance.trim().isNotEmpty) {
      parsedBalance = double.tryParse(openingBalance) ?? 0.0;
    }

    // Determine sign based on payment type
    double finalOpeningBalance =
        paymentType == "You'll Give" ? -parsedBalance.abs() : parsedBalance.abs();

    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    // Handle image path (Web vs Native)
    String finalImagePath = '';
    if (kIsWeb && imageBytes != null) {
      finalImagePath = base64Encode(imageBytes);
    } else {
      finalImagePath = imagePath.isNotEmpty ? imagePath : (party?.imagePath ?? '');
    }



    final newParty = PartyModel(
      id: party?.id ?? _uuid.v4(),
      name: partyName,
      contactNumber: contactNumber,
      openingBalance: finalOpeningBalance,
      asOfDate: (selectedDate ?? DateTime.now()).toIso8601String(),
      billingAddress: billingAddress,
      email: email,
      paymentType: paymentType,
      imagePath: finalImagePath,
      partyBalance: 0.0,
      userId: userId,
    );

    try {
      if (party != null) {
        // Update existing party
        bool success = await PartyDb.updatePartyBasic(newParty);
        if (success) {
          _showSuccess(context, "Party updated successfully!");
        } else {
          throw Exception("Failed to update party: Not found");
        }
      } else {
        // Add new party
        await PartyDb.addParty(newParty);
        _showSuccess(context, "Party added successfully!");
      }

      // Navigate or clear form
      if (clearFields) {
        clearForm();
      } else {
        if (context.mounted) {
          Navigator.of(context).pop(newParty);
        }
      }
    } catch (e) {
      debugPrint("Error saving party: $e");
      _showError(context, "Failed to save party. Please try again.");
    }
  }

  // Success feedback
  void _showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  // Error feedback
  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
        backgroundColor: Colors.red.shade600,
      ),
    );
  } 
}
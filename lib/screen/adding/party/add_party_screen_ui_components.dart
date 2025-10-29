import 'dart:convert';
import 'package:cream_ventory/utils/adding/party/party_form_feild_validation.dart';
import 'package:cream_ventory/utils/adding/party/party_image_handler.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class PartyUIComponents {
  static Widget buildImagePicker({
    required double screenWidth,
    required Uint8List? imageBytes,
    required String imagePath,
    required PartyModel? party,
    required Function(Uint8List?, String) onPick,
  }) {
    ImageProvider? backgroundImage;
    if (imageBytes != null) {
      backgroundImage = MemoryImage(imageBytes);
    } else if (!kIsWeb && imagePath.isNotEmpty) {
      backgroundImage = FileImage(File(imagePath));
    } else if (party?.imagePath.isNotEmpty ?? false) {
      if (kIsWeb) {
        // Assume imagePath is base64 on web
        try {
          backgroundImage = MemoryImage(base64Decode(party!.imagePath));
        } catch (_) {
          backgroundImage = null;
        }
      } else {
        backgroundImage = FileImage(File(party!.imagePath));
      }
    }

    return GestureDetector(
      onTap: () async {
        final handler = PartyImageHandler();
        final result = await handler.pickImage();
        if (result != null) {
          onPick(result['bytes'], result['path'] ?? '');
        }
      },
      child: CircleAvatar(
        radius: screenWidth * 0.15,
        backgroundColor: Colors.grey[300],
        backgroundImage: backgroundImage,
        child: backgroundImage == null
            ? Icon(
                Icons.person,
                size: screenWidth * 0.15,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  static Widget buildPartyNameField(TextEditingController controller) {
    return CustomTextField(
      labelText: 'Party Name',
      controller: controller,
      validator: PartyValidations.validatePartyName,
      keyboardType: TextInputType.text,
    );
  }

  static Widget buildContactNumberField(TextEditingController controller) {
    return CustomTextField(
      labelText: 'Contact Number',
      controller: controller,
      validator: PartyValidations.validateContactNumber,
      keyboardType: TextInputType.phone,
    );
  }

  static Widget buildBalanceAndDateRow({
    required double screenWidth,
    required double screenHeight,
    required TextEditingController openingBalanceController,
    required DateTime? selectedDate,
    required bool isEditMode,
    required Future<void> Function(BuildContext) pickDate,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            labelText: 'Opening Bal',
            controller: openingBalanceController,
            keyboardType: TextInputType.number,
            readOnly: isEditMode,
            validator: PartyValidations.validateOpeningBalance,
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        Expanded(
          child: GestureDetector(
            onTap: () => pickDate(context),
            child: AbsorbPointer(
              child: CustomTextField(
                labelText: 'As Of Date',
                controller: TextEditingController(
                  text: selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : '',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildPaymentTypeSelector(String paymentType, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Radio(
              value: "You'll Get",
              groupValue: paymentType,
              onChanged: onChanged,
            ),
            const Text('To Receive'),
          ],
        ),
        Row(
          children: [
            Radio(
              value: "You'll Give",
              groupValue: paymentType,
              onChanged: onChanged,
            ),
            const Text('To Pay'),
          ],
        ),
      ],
    );
  }

  static Widget buildBillingAddressField(TextEditingController controller) {
    return CustomTextField(
      labelText: 'Billing Address',
      controller: controller,
      validator: PartyValidations.validateBillingAddress,
    );
  }

  static Widget buildEmailField(TextEditingController controller) {
    return CustomTextField(
      labelText: 'Email',
      controller: controller,
      focusColor: Colors.blue,
      validator: PartyValidations.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }

  static Widget buildActionButtons({
    required double screenWidth,
    required double screenHeight,
    required PartyModel? party,
    required VoidCallback onSaveAndNew,
    required VoidCallback onSave,
  }) {
    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomActionButton(
            label: 'Save & New',
            backgroundColor: Colors.black,
            onPressed: onSaveAndNew,
            width: screenWidth * 0.4,
            padding: EdgeInsets.symmetric( 
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.015,
            ),
          ),
          CustomActionButton(
            label: party != null ? 'Edit Party' : 'Save Party',
            backgroundColor: Colors.red,
            onPressed: onSave,
            width: screenWidth * 0.4,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.06,
              vertical: screenHeight * 0.016,
            ),
          ),
        ],
      ),
    );
  }
}
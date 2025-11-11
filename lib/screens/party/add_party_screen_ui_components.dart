import 'dart:convert';
import 'package:cream_ventory/core/utils/party/party_form_feild_validation.dart';
import 'package:cream_ventory/core/utils/party/party_image_handler.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:cream_ventory/widgets/text_field.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    
    // Priority 1: If we have bytes from picker, use them
    if (imageBytes != null) {
      backgroundImage = MemoryImage(imageBytes);
    } 
    // Priority 2: If we have a path and not on web, use file
    else if (!kIsWeb && imagePath.isNotEmpty) {
      final file = File(imagePath);
      if (file.existsSync()) {
        backgroundImage = FileImage(file);
      }
    } 
    // Priority 3: If party has an existing image
    else if (party?.imagePath.isNotEmpty ?? false) {
      final partyImagePath = party!.imagePath;
      
      if (kIsWeb) {
        // On web, try to decode base64
        try {
          // Check if it has the data:image prefix
          if (partyImagePath.startsWith('data:image')) {
            final base64Data = partyImagePath.split(',').last;
            backgroundImage = MemoryImage(base64Decode(base64Data));
          } else {
            // Try direct base64 decode
            backgroundImage = MemoryImage(base64Decode(partyImagePath));
          }
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          backgroundImage = null;
        }
      } else {
        // On mobile, use file path
        final file = File(partyImagePath);
        if (file.existsSync()) {
          backgroundImage = FileImage(file);
        }
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
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 60.r,
          backgroundColor: Colors.grey[300],
          backgroundImage: backgroundImage,
          child: backgroundImage == null
              ? Icon(
                  Icons.add_a_photo,
                  size: 60.r,
                  color: Colors.grey[600],
                )
              : null,
        ),
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
          Expanded(
            child: CustomActionButton(
              label: 'Save & New',
              backgroundColor: Color.fromARGB(255, 80, 82, 84),
              onPressed: onSaveAndNew,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.013,
              ), 
            ),                     
          ),
          SizedBox(width: 10),
          Expanded(
            child: CustomActionButton(
              label: party != null ? 'Edit Party' : 'Save Party',
              backgroundColor: Color.fromARGB(255, 85, 172, 213),
              onPressed: onSave,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.013,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
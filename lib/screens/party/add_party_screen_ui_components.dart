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
  // Helper: Check if opening balance is non-empty and non-zero
  static bool _hasOpeningBalance(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return false;
    final value = double.tryParse(text);
    return value != null && value != 0;
  }

  static Future<void> showBeautifulInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String buttonText = "Got it",
    IconData icon = Icons.info,
    Color iconColor = const Color(0xFF4A90E2),
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.98),
                  Colors.white.withOpacity(0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: Offset(0, 10), 
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 30,
                  offset: Offset(0, 15),
                  spreadRadius: -10,
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient circle
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.2),
                        iconColor.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: iconColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(icon, size: 36 , color: iconColor),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Content with bullet points
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 15 ,
                      color: Colors.black.withOpacity(0.78),
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 28.h),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom( 
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      shadowColor: iconColor.withOpacity(0.4),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),  
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
      final file = File(imagePath);
      if (file.existsSync()) {
        backgroundImage = FileImage(file);
      }
    } else if (party?.imagePath.isNotEmpty ?? false) {
      final partyImagePath = party!.imagePath;

      if (kIsWeb) {
        try {
          if (partyImagePath.startsWith('data:image')) {
            final base64Data = partyImagePath.split(',').last;
            backgroundImage = MemoryImage(base64Decode(base64Data));
          } else {
            backgroundImage = MemoryImage(base64Decode(partyImagePath));
          }
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          backgroundImage = null;
        }
      } else {
        final file = File(partyImagePath);
        if (file.existsSync()) {
          backgroundImage = FileImage(file);
        }
      }
    }

    return Column(
      children: [
        GestureDetector(
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
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 65.r,
              backgroundColor: Colors.white.withOpacity(0.9),
              backgroundImage: backgroundImage,
              child: backgroundImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 40.r,
                          color: Colors.grey[600],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(height: screenWidth * 0.03),
      ],
    );
  }

  static Widget buildPartyNameField(TextEditingController controller) {
    return _buildFieldWithLabel(
      label: 'Party Name',
      child: CustomTextField(
        hintText: 'Party Name',
        showInfoIcon: true,
        infoMessage: 'Enter the full name of the party.',
        controller: controller,
        validator: PartyValidations.validatePartyName,
        keyboardType: TextInputType.text,
      ),
    );
  }

  static Widget buildContactNumberField(TextEditingController controller) {
    return _buildFieldWithLabel(
      label: 'Contact Number',
      child: CustomTextField(
        hintText: 'Contact Number',
        showInfoIcon: true,
        infoMessage: 'Enter a valid contact number',
        controller: controller,
        validator: PartyValidations.validateContactNumber,
        keyboardType: TextInputType.phone,
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                'Financial Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  PartyUIComponents.showBeautifulInfoDialog(
                    context: context,
                    title: "Financial Information",
                    icon: Icons.account_balance,
                    iconColor: const Color(0xFF50A684),
                    content:
                        "• Opening Balance: Any previous due amount when you start tracking this party.\n\n"
                        "• Positive value → Party owes you (To Receive)\n"
                        "• Negative value → You owe party (To Pay)\n\n"
                        "• Leave blank or 0 if no prior balance",
                  );
                },
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Colors.black.withOpacity(0.7),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Opening Balance',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            PartyUIComponents.showBeautifulInfoDialog(
                              context: context,
                              title: "Opening Balance",
                              icon: Icons.account_balance_wallet,
                              iconColor: const Color(0xFF4A90E2),
                              content:
                                  "• Enter amount party owed you (or you owed them) before using this app.\n\n"
                                  "• Use +5000 → Party owes you\n"
                                  "• Use -2500 → You owe party\n\n"
                                  "• Optional: Leave empty if starting fresh",
                              buttonText: "Understood",
                            );
                          },
                          child: Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    CustomTextField(
                      hintText: 'e.g. 5000 or -2500',
                      controller: openingBalanceController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      readOnly: isEditMode,
                      // Optional field → no required validation
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final num = double.tryParse(value.trim());
                        if (num == null) return 'Enter a valid number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black.withOpacity(0.7),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'As Of Date',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => pickDate(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          hintText: 'Select Date',
                          controller: TextEditingController(
                            text: selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(selectedDate)
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Updated: Payment Type shown only if opening balance > 0
  static Widget buildPaymentTypeSelector({
    required String paymentType,
    required Function(String?) onChanged,
    required TextEditingController openingBalanceController,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: openingBalanceController,
      builder: (context, value, child) {
        final showPaymentType = _hasOpeningBalance(openingBalanceController);

        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: showPaymentType
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: _buildPaymentTypeWidget(
            paymentType: paymentType,
            onChanged: onChanged,
          ),
          alignment: Alignment.topCenter,
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
        );
      },
    );
  }

  // Extracted original payment type UI (no changes)
  static Widget _buildPaymentTypeWidget({
    required String paymentType,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Payment Type',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildRadioOption(
                  value: "You'll Get",
                  groupValue: paymentType,
                  label: 'To Receive',
                  icon: Icons.arrow_downward,
                  iconColor: Colors.green,
                  onChanged: onChanged,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _buildRadioOption(
                  value: "You'll Give",
                  groupValue: paymentType,
                  label: 'To Pay',
                  icon: Icons.arrow_upward,
                  iconColor: Colors.red,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Function(String?) onChanged,
  }) {
    bool isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black12 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.blueGrey,
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white12 : Colors.white10,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? Colors.blueGrey : Colors.grey,
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildBillingAddressField(TextEditingController controller) {
    return _buildFieldWithLabel(
      label: 'Billing Address',
      child: CustomTextField(
        hintText: 'Billing Address',
        showInfoIcon: true,
        infoMessage: 'Enter the full billing address of the party.',
        controller: controller,
        validator: PartyValidations.validateBillingAddress,
      ),
    );
  }

  static Widget buildEmailField(TextEditingController controller) {
    return _buildFieldWithLabel(
      label: 'Email Address',
      child: CustomTextField(
        hintText: 'Email Address',
        showInfoIcon: true,
        infoMessage: 'Enter a valid email address.',
        controller: controller,
        focusColor: Colors.black38,
        validator: PartyValidations.validateEmail,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  static Widget _buildFieldWithLabel({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
        ),
        child,
      ],
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

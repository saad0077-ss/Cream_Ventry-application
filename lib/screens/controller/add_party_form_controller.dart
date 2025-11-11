import 'package:cream_ventory/core/utils/party/party_data_handler.dart';
import 'package:cream_ventory/core/utils/party/party_image_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cream_ventory/models/party_model.dart';


class PartyFormController {
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController openingBalanceController = TextEditingController();
  final TextEditingController billingAddressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String paymentType = "You'll Give";
  DateTime? selectedDate;
  Uint8List? imageBytes; // For web image display
  String imagePath = ''; // For native image path

  final PartyImageHandler _imageHandler = PartyImageHandler();
  final PartyDataHandler _dataHandler = PartyDataHandler();
  final PartyModel? party;
  final VoidCallback onStateChanged; // Callback to trigger setState in widget

  PartyFormController(this.party, this.onStateChanged);

  void initializeForm() {
    if (party != null) {
      partyNameController.text = party!.name;
      contactNumberController.text = party!.contactNumber;
      openingBalanceController.text = party!.openingBalance.toString();
      billingAddressController.text = party!.billingAddress;
      emailController.text = party!.email;
      paymentType = party!.paymentType;
      selectedDate = party!.asOfDate;
      if (party!.imagePath.isNotEmpty && !kIsWeb) {
        imagePath = party!.imagePath;
      }
      // Note: For web, if imagePath is base64, load into imageBytes if needed
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      onStateChanged();
    }
  }

  Future<void> pickImage() async {
    final result = await _imageHandler.pickImage();
    if (result != null) {
      imageBytes = result['bytes'];
      imagePath = result['path'] ?? '';
      onStateChanged(); // Trigger widget rebuild
    }
  }

  Future<void> saveParty(BuildContext context, {bool clearFields = false}) async {
    await _dataHandler.saveParty(
      context: context,
      formKey: formKey,
      party: party,
      partyName: partyNameController.text,
      contactNumber: contactNumberController.text,
      openingBalance: openingBalanceController.text,
      paymentType: paymentType,
      selectedDate: selectedDate,
      billingAddress: billingAddressController.text,
      email: emailController.text,
      imageBytes: imageBytes,
      imagePath: imagePath,
      clearFields: clearFields,
      clearForm: _clearForm,
    );
  }

  void _clearForm() {
    partyNameController.clear();
    contactNumberController.clear();
    openingBalanceController.clear();
    billingAddressController.clear();
    emailController.clear();
    selectedDate = null;
    paymentType = "You'll Give";
    imageBytes = null;
    imagePath = '';
    onStateChanged();
  }
}
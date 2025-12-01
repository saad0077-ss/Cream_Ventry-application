import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PaymentInUtils {
  static final _uuid = Uuid();
  static final _picker = ImagePicker();

  // Generate receipt number
  static Future<void> generateReceiptNumber(
    TextEditingController receiptController,
    Function setState,
  ) async {
    try {
      final payments = await PaymentInDb.getAllPayments();
      int maxNumber = 0;
      for (var payment in payments) {
        final number = int.tryParse(payment.receiptNo) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
      setState(() {
        receiptController.text = (maxNumber + 1).toString().padLeft(4, '0');
      });
    } catch (e) {
      debugPrint('Error generating receipt number: $e');
      setState(() {
        receiptController.text =
            DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      });
    }
  }

  // Date picker
  static Future<void> selectDate(
    BuildContext context,
    TextEditingController dateController,
    Function setState,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  // Pick image (Web + Mobile)
  static Future<void> pickImage(
    BuildContext context,
    Function(String?) setImagePathCallback,
    Function(Uint8List?) setImageBytesCallback,
  ) async {
    try {
      String? imagePath;
      Uint8List? imageBytes;
      FilePickerResult? result;

      if (kIsWeb) {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes!;
          imagePath = base64Encode(imageBytes);
          setImageBytesCallback(imageBytes);
          setImagePathCallback(imagePath);

          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Image attached successfully!",
              icon: Icon(Icons.image, color: Colors.white, size: 40),
            ),
          );
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          final permanentPath =
              await _saveImagePermanently(File(pickedFile.path));
          imagePath = permanentPath;
          setImagePathCallback(imagePath);
          setImageBytesCallback(null);

          showTopSnackBar(
            Overlay.of(context),
            const CustomSnackBar.success(
              message: "Image attached!",
              icon: Icon(Icons.check_circle, color: Colors.white, size: 40),
            ),
          );
        }
      }

      if (imagePath == null &&
          (result == null || result.files.single.bytes == null)) {
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.info(
            message: "No image selected",
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to attach image",
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  static Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final permanentPath = '${directory.path}/payment_images/$fileName';
    await Directory('${directory.path}/payment_images').create(recursive: true);
    final savedImage = await image.copy(permanentPath);
    return savedImage.path;
  }

  // Save payment
  static Future<void> savePayment({
    required BuildContext context,
    required bool saveAndNew,
    required bool isEditMode,
    required PaymentInModel? existingPayment,
    required PartyModel? selectedParty,
    required String receivedAmount,
    required TextEditingController receiptController,
    required TextEditingController dateController,
    required TextEditingController phoneNumberController,
    required TextEditingController noteController,
    required TextEditingController receivedAmountController,
    required TextEditingController partyNameController,
    required String selectedPaymentType,
    required String? imagePath,
    required Function setState,
    required Function popNavigator,
  }) async {
    // Validation
    if (selectedParty == null) {
      showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.error(message: "Please select a party"));
      return;
    }
    if (phoneNumberController.text.trim().isEmpty) {
      showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.error(message: "Please enter a phone number"));
      return;
    }
    if (receivedAmount.isEmpty || receivedAmount == '0.00') {
      showTopSnackBar(Overlay.of(context),
          const CustomSnackBar.error(message: "Please enter a valid amount"));
      return;
    }

    final user = await UserDB.getCurrentUser();
    final double parsedAmount = double.parse(receivedAmount);
    final formattedAmount = parsedAmount.toStringAsFixed(2);

    final payment = PaymentInModel(
      id: isEditMode ? existingPayment!.id : _uuid.v4(),
      receiptNo: receiptController.text,
      date: dateController.text,
      partyName: selectedParty.name,
      phoneNumber: phoneNumberController.text.trim(),
      receivedAmount: double.parse(formattedAmount),
      paymentType: selectedPaymentType,
      note: noteController.text.trim().isEmpty
          ? null
          : noteController.text.trim(),
      imagePath: imagePath,
      userId: user.id,
    );

    try {
      if (isEditMode && existingPayment != null) {
        // UPDATE existing
        await PaymentInDb.updatePayment(payment);
      } else {
        // INSERT new 
        await PaymentInDb.savePayment(payment); // this will generate new ID
      } 
      await PartyDb.updateBalanceAfterPayment(
        payment.partyName!,
        payment.receivedAmount,
        true,
      );

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: isEditMode
              ? "Payment updated successfully"
              : "Payment saved successfully",
          icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
        ),
      );

      if (saveAndNew) {
        setState(() {
          partyNameController.clear();
          phoneNumberController.clear();
          noteController.clear();
          receivedAmountController.text = '0.00';
          imagePath = null;
        });
        await generateReceiptNumber(receiptController, setState);
      } else {
        popNavigator();
      }
    } catch (e) {
      debugPrint('Error saving payment: $e');
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to save payment",
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  // Delete payment with confirmation
  static void deletePayment({
    required BuildContext context,
    required bool isEditMode,
    required PaymentInModel? payment,
  }) {
    if (!isEditMode || payment == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this payment?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await PaymentInDb.deletePayment(payment.id);
                await PartyDb.updateBalanceAfterPayment(
                  payment.partyName!,
                  payment.receivedAmount,
                  false,
                );

                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen

                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.success(
                    message: "Payment deleted successfully!",
                    icon: Icon(Icons.delete_forever,
                        color: Colors.white, size: 40),
                  ),
                );
              } catch (e) {
                debugPrint('Error deleting payment: $e');
                showTopSnackBar(
                  Overlay.of(context),
                  CustomSnackBar.error(
                    message: "Failed to delete payment",
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PaymentOutUtils {
  static final _uuid = Uuid();
  static final _picker = ImagePicker();

  static Future<void> generateReceiptNumber(
    TextEditingController receiptController,
    Function setState,
  ) async {
    try {
      final payments = await PaymentOutDb.getAllPayments();
      int maxNumber = 0;
      for (var payment in payments) {
        String receiptNo = payment.receiptNo;
        final number = int.tryParse(receiptNo) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
      setState(() {
        receiptController.text = (maxNumber + 1).toString().padLeft(4, '0');
      });
    } catch (e) {
      debugPrint('Error generating receipt number: $e');
      setState(() {
        receiptController.text = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      });
    }
  }

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
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  static Future<void> pickImage(
    BuildContext context,
    Function(String?) setImagePathCallback, // Changed to String? for path
    Function(Uint8List?) setImageBytesCallback, // For web image bytes
  ) async {
    try {
      String? imagePath;
      Uint8List? imageBytes;

      if (kIsWeb) {
        // Web: Use file_picker for reliability
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.bytes != null) {
          imageBytes = result.files.single.bytes!;
          imagePath = base64Encode(imageBytes); // Store as base64 string
          setImageBytesCallback(imageBytes);
          setImagePathCallback(imagePath);
        }
      } else {
        // Native: Use image_picker
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          final permanentPath = await _saveImagePermanently(File(pickedFile.path));
          imagePath = permanentPath;
          setImagePathCallback(imagePath);
          setImageBytesCallback(null); // Clear bytes for native
        }
      }

      if (imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No image selected'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static Future<String> _saveImagePermanently(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final permanentPath = '${directory.path}/$fileName';
    final savedImage = await image.copy(permanentPath);
    return savedImage.path;
  }

  static Future<void> savePayment({
    required BuildContext context,
    required bool saveAndNew,
    required bool isEditMode,
    required PaymentOutModel? existingPayment,
    required PartyModel? selectedParty,
    required String paidAmount,
    required TextEditingController receiptController,
    required TextEditingController dateController,
    required TextEditingController phoneNumberController,
    required TextEditingController noteController,
    required TextEditingController paidAmountController,
    required TextEditingController partyNameController,
    required String selectedPaymentType,
    required String? imagePath, // Changed to String?
    required Function setState,
    required Function popNavigator,
  }) async {
    if (selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a party'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a phone number'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (paidAmount.isEmpty || paidAmount == '0.00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid paid amount'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    final double parsedAmount = double.parse(paidAmount);
    final formattedAmount = parsedAmount.toStringAsFixed(2);

    final payment = PaymentOutModel(
      id: isEditMode ? existingPayment!.id.toString() : '0',
      receiptNo: receiptController.text,
      date: dateController.text,
      partyName: selectedParty.name,
      phoneNumber: phoneNumberController.text.trim(),
      paidAmount: double.parse(formattedAmount),
      paymentType: selectedPaymentType,
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      imagePath: imagePath, // Use the string path
      userId: userId,
    );

    try {
      await PaymentOutDb.savePayment(payment);
      await PartyDb.updateBalanceAfterPayment(payment.partyName, payment.paidAmount, false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditMode ? 'Payment updated successfully' : 'Payment saved successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      if (saveAndNew) {
        setState(() {
          partyNameController.clear();
          phoneNumberController.clear();
          noteController.clear();
          paidAmountController.text = '0.00';
          imagePath = null;
        });
        await generateReceiptNumber(receiptController, setState);
      } else {
        popNavigator();
      }
    } catch (e) {
      debugPrint('Error saving payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save payment: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void deletePayment({
    required BuildContext context,
    required bool isEditMode,
    required PaymentOutModel? payment,
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
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await PaymentOutDb.deletePayment(payment.id);
                await PartyDb.updateBalanceAfterPayment(payment.partyName, payment.paidAmount, true);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment deleted successfully!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint('Error deleting payment: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete payment: $e'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
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
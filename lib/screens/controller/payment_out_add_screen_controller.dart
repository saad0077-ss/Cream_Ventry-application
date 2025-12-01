import 'dart:convert';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/screens/payments/widgets/note_and_image_card.dart';
import 'package:cream_ventory/screens/payments/widgets/payment_details_card.dart';
import 'package:cream_ventory/screens/payments/widgets/payments_add_bottom_buttons.dart';
import 'package:cream_ventory/screens/payments/widgets/transaction_details_card.dart';
import 'package:cream_ventory/core/utils/payments/payment_out_add_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentOutScreenState extends StatefulWidget {
  final PaymentOutModel? payment;
  const PaymentOutScreenState({super.key, this.payment});

  @override
  _PaymentOutScreenState createState() => _PaymentOutScreenState();
}

class _PaymentOutScreenState extends State<PaymentOutScreenState> {
  String _paidAmount = '';
  String _selectedPaymentType = 'Cash';
  String? _partyName;
  PartyModel? _selectedParty;
  String? _imagePath; // Store image path (file path or base64)
  Uint8List? _imageBytes; // For web image display
  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.payment != null;
    initializeForm();
    PartyDb.partyNotifier.addListener(_updatePartyList);
    _loadParties();
  }

  Future<void> _loadParties() async {
    await PartyDb.loadParties();
  }

  void _updatePartyList() {
    setState(() {});
  }

  Future<void> initializeForm() async {
    try {   
      if (_isEditMode) {
        final payment = widget.payment!;
        _receiptController.text = payment.receiptNo;
        _dateController.text = payment.date;
        _phoneNumberController.text = payment.phoneNumber;
        _noteController.text = payment.note ?? '';
        _paidAmount = payment.paidAmount.toStringAsFixed(2);
        _paidAmountController.text = _paidAmount;
        _selectedPaymentType = payment.paymentType;
        if (payment.imagePath != null && payment.imagePath!.isNotEmpty) {
          setState(() {
            _imagePath = payment.imagePath; // Set the image path
            if (kIsWeb) {
              try {
                _imageBytes = base64Decode(
                  payment.imagePath!,
                ); // Decode for web
              } catch (e) {
                debugPrint('Error decoding base64 image: $e');
                _imageBytes = null;
              }
            }
          });
        }

        _partyName = payment.partyName;
        _partyNameController.text = payment.partyName;
        final party = await PartyDb.getPartyByIdFromName(payment.partyName);
        if (party != null) {
          setState(() {
            _selectedParty = party;
            _phoneNumberController.text = party.contactNumber;
          });
        }
      } else {
        _dateController.text = DateFormat('dd MMM yyyy').format(DateTime.now());
        _paidAmountController.text = _paidAmount;
        await PaymentOutUtils.generateReceiptNumber(
          _receiptController,
          setState,
        );
      }
    } catch (e) {
      debugPrint('Error initializing form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize form: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    await PaymentOutUtils.pickImage(
      context,
      (String? newPath) {
        setState(() {
          _imagePath = newPath; // Update image path
        });
      },
      (Uint8List? newBytes) {
        setState(() {
          _imageBytes = newBytes; // Update image bytes for web
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PaymentDetailsCard(
                  receiptController: _receiptController,
                  dateController: _dateController,
                  phoneNumberController: _phoneNumberController,
                  selectedParty: _selectedParty,
                  onPartyChanged: (PartyModel? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedParty = newValue;
                        _partyName = newValue.name;
                        _phoneNumberController.text = newValue.contactNumber;
                        debugPrint(
                          'Selected Party: $_partyName, Phone: ${_phoneNumberController.text}',
                        );
                      });
                    }
                  },
                  onDateTap: () => PaymentOutUtils.selectDate(
                    context,
                    _dateController,
                    setState,
                  ),
                ),
                const SizedBox(height: 16),
                TransactionDetailsCard(
                  isPaymentIn: false,
                  amount: _paidAmount,
                  selectedPaymentType: _selectedPaymentType,
                  onAmountChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        try {

                          _paidAmount = value;
                          _paidAmountController.text = value;

                        } catch (e) {
                          _paidAmount = '';
                          _paidAmountController.text = '';
                        }   
                      } else {
                        _paidAmount = '';
                         _paidAmountController.text = '';
                      } 
                    });
                  },
                  onPaymentTypeChanged: (String? newValue) {   
                    if (newValue != null) {
                      setState(() {
                        _selectedPaymentType = newValue;
                      });
                      debugPrint(
                        'Selected Payment Type: $_selectedPaymentType',
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                NoteAndImageCard(
                  noteController: _noteController,
                  imagePath: _imagePath, // Pass image path
                  imageBytes: _imageBytes, // Pass image bytes for web
                  onImageTap: _pickImage,
                ),
              ],
            ),
          ),
        ),
        BottomButtons(
          isEditMode: _isEditMode,
          onSave: () => PaymentOutUtils.savePayment(
            context: context,
            saveAndNew: false,
            isEditMode: _isEditMode,
            existingPayment: widget.payment,
            selectedParty: _selectedParty,
            paidAmount: _paidAmount,
            receiptController: _receiptController,
            dateController: _dateController,
            phoneNumberController: _phoneNumberController,
            noteController: _noteController,
            paidAmountController: _paidAmountController,
            partyNameController: _partyNameController,
            selectedPaymentType: _selectedPaymentType,
            imagePath: _imagePath, // Pass image path
            setState: setState,
            popNavigator: () => Navigator.of(context).pop(true),
          ),
          onSaveAndNewOrDelete: () => _isEditMode
              ? PaymentOutUtils.deletePayment(
                  context: context,
                  isEditMode: _isEditMode,
                  payment: widget.payment,
                )
              : PaymentOutUtils.savePayment(
                  context: context,
                  saveAndNew: true,
                  isEditMode: _isEditMode,
                  existingPayment: widget.payment,
                  selectedParty: _selectedParty,
                  paidAmount: _paidAmount,
                  receiptController: _receiptController,
                  dateController: _dateController,
                  phoneNumberController: _phoneNumberController,
                  noteController: _noteController,
                  paidAmountController: _paidAmountController,
                  partyNameController: _partyNameController,
                  selectedPaymentType: _selectedPaymentType,
                  imagePath: _imagePath, // Pass image path
                  setState: setState,
                  popNavigator: () => Navigator.of(context).pop(true),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _receiptController.dispose();
    _dateController.dispose();
    _phoneNumberController.dispose();
    _noteController.dispose();
    _paidAmountController.dispose();
    _partyNameController.dispose();
    PartyDb.partyNotifier.removeListener(_updatePartyList);
    super.dispose();
  }
}

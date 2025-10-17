import 'dart:io';
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/screen/adding/expense/adding_expense_screen_dotted_fields.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/widgets/app_bar.dart';
import 'package:cream_ventory/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PaymentOutScreen extends StatefulWidget {
  final PaymentOutModel? payment;
  const PaymentOutScreen({super.key, this.payment});

  @override
  _PaymentOutScreenState createState() => _PaymentOutScreenState();
}

class _PaymentOutScreenState extends State<PaymentOutScreen> {
  String _paidAmount = '';
  String _selectedPaymentType = 'Cash';
  PartyModel? _selectedParty;
  File? _selectedImage;
  final TextEditingController _receiptController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _paidAmountController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.payment != null;

    initializeForm();
  }

  void initializeForm() {
  if (_isEditMode) {
    // Pre-fill fields for editing
    final payment = widget.payment!;
    _receiptController.text = payment.receiptNo; 
    _dateController.text = payment.date;
    _phoneNumberController.text = payment.phoneNumber ; // Handle null
    _noteController.text = payment.note ?? '';
    _paidAmount = payment.paidAmount.toStringAsFixed(2);
    _paidAmountController.text = _paidAmount;
    _selectedPaymentType = payment.paymentType;
    if (payment.imagePath != null && File(payment.imagePath!).existsSync()) {
      _selectedImage = File(payment.imagePath!);
    }
    Future.microtask(() async {
      try {
        await PartyDb.loadParties();
        final party = await PartyDb.getPartyByIdFromName(payment.partyName); 
        setState(() {
          _selectedParty = party; // Set to matched party or null
          debugPrint('Selected Party in edit mode: ${_selectedParty?.name}, Payment PartyName: ${payment.partyName}');
        });
            } catch (e) {
        debugPrint('Error loading parties in edit mode: $e');
        setState(() {
          _selectedParty = null; // Fallback to null on error
        });
      }
    });
  } else {
    // Initialize for new payment
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());      
    _paidAmountController.text = _paidAmount;
    Future.microtask(() async {
      try {
        await PartyDb.loadParties();
        await _generateReceiptNumber();
      } catch (e) {
        debugPrint('Error initializing new payment: $e');
      }
    });
  }
}

  Future<void> _generateReceiptNumber() async {
    try {
      final payments = await PaymentOutDb.getAllPayments();
      debugPrint(
        'Payments for receipt generation: ${payments.length} payments',
      );
      int maxNumber = 0;
      for (var payment in payments) {
        final number = int.tryParse(payment.receiptNo) ?? 0;
        if (number > maxNumber) maxNumber = number;
      }
      final newNumber = maxNumber + 1;
      setState(() {
        _receiptController.text = newNumber.toString().padLeft(4, '0');
      });
    } catch (e) {
      debugPrint('Error generating receipt number: $e');
      setState(() {
        _receiptController.text = '1';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }

  Future<void> _savePayment({bool saveAndNew = false}) async {
    if (_selectedParty == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a Party')));
      return;
    }
    if (_phoneNumberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Phone Number')),
      );
      return;
    }
    if (_paidAmount.isEmpty || _paidAmount == '0.00') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Paid Amount')),
      );
      return;
    }
    double? amount;
    try {
      amount = double.parse(_paidAmount);
      if (amount <= 0) {
        throw const FormatException('Amount must be greater than 0');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Paid Amount format')),
      );
      return;
    }

    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    final payment = PaymentOutModel(
      id: _isEditMode ? widget.payment!.id.toString() : '0',
      receiptNo: _receiptController.text,
      date: _dateController.text,
      partyName: _selectedParty!.name,
      phoneNumber: _phoneNumberController.text.trim(),
      paidAmount: amount,
      paymentType: _selectedPaymentType,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      imagePath: _selectedImage?.path,
      userId: userId
    );

    debugPrint('Saving payment: $payment');

    try {   
      await PaymentOutDb.savePayment(payment);
      await PartyDb.updateBalanceAfterPayment(
        payment.partyName,
        payment.paidAmount,   
        false,
      );
      await PartyDb.loadParties();
      debugPrint('Payment saved successfully');
      final allPayments = await PaymentOutDb.getAllPayments();
      debugPrint('Payments after save: ${allPayments.length} payments');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment saved successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      if (saveAndNew) {
        setState(() {
          _phoneNumberController.clear();
          _noteController.clear();
          _paidAmount = '0.00';
          _paidAmountController.text = '0.00';
          _selectedPaymentType = 'Cash';
          _selectedImage = null;
          _selectedParty = null;
          _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        });
        await _generateReceiptNumber();
      } else {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving payment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save payment')));
    }
  }

  void _deletePayment() {
    if (!_isEditMode) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this Payment Out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              PaymentOutDb.deletePayment(widget.payment!.id).then((_) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment deleted successfully!'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
              });
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditMode ? 'Edit Payment-Out' : 'Payment-Out',
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _receiptController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Receipt No',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _dateController,
                                    readOnly: true,
                                    onTap: () => _selectDate(context),
                                    decoration: const InputDecoration(
                                      labelText: 'Date',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ValueListenableBuilder<List<PartyModel>>(
                              valueListenable: PartyDb.partyNotifier,
                              builder: (context, parties, child) {
                                return DropdownButtonFormField<PartyModel>(
                                  initialValue: _selectedParty,
                                  decoration: const InputDecoration(
                                    labelText: 'Party Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  hint: parties.isEmpty
                                      ? const Text('No Parties Available')
                                      : const Text('Select Party'),
                                  items: parties.isEmpty
                                      ? null
                                      : parties.map((PartyModel party) {
                                          return DropdownMenuItem<PartyModel>(
                                            value: party,
                                            child: Text(party.name),
                                          );
                                        }).toList(),
                                  onChanged: parties.isEmpty
                                      ? null
                                      : (PartyModel? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              _selectedParty = newValue;
                                              _phoneNumberController.text =
                                                  newValue.contactNumber;
                                            });
                                            debugPrint(
                                              'Selected Party: ${newValue.name}, Phone: ${newValue.contactNumber}',
                                            );
                                          }
                                        },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _phoneNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Paid'),
                                const SizedBox(width: 160),
                                Expanded(
                                  child: DottedTextField(
                                    hintText: '0.00',
                                    controller: _paidAmountController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        if (value.isNotEmpty) {
                                          try {
                                            final parsed = double.parse(value);
                                            _paidAmount = parsed
                                                .toStringAsFixed(2);
                                          } catch (e) {
                                            _paidAmount = '0.00';
                                          }
                                        } else {
                                          _paidAmount = '0.00';
                                        }
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Payment Type'),
                                const SizedBox(width: 150),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedPaymentType,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 2,
                                      ),
                                    ),
                                    items: ['Cash', 'GPay', 'PhonePe'].map((
                                      String paymentType,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: paymentType,
                                        child: Text(paymentType),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              decoration: const InputDecoration(
                                labelText: 'Add Note',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black54),
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: _pickImage,
                                child: _selectedImage == null
                                    ? IconButton(
                                        icon: const Icon(Icons.image),
                                        onPressed: _pickImage,
                                      )
                                    : Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: ValueListenableBuilder<List<PartyModel>>(
                valueListenable: PartyDb.partyNotifier,
                builder: (context, parties, child) {
                  final isSaveEnabled = parties.isNotEmpty;
                  return Row(
                    children: [
                      Expanded(
                        child: CustomActionButton(
                          label: _isEditMode ? 'DELETE' : 'SAVE & NEW',
                          backgroundColor: isSaveEnabled
                              ? Colors.red
                              : Colors.grey,
                          onPressed: _isEditMode
                              ? _deletePayment
                              : () => _savePayment(saveAndNew: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomActionButton(
                          label: _isEditMode ? 'UPDATE' : 'SAVE',
                          backgroundColor: isSaveEnabled
                              ? Colors.black
                              : Colors.grey,
                          onPressed: () => _savePayment(saveAndNew: false),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _receiptController.dispose();
    _dateController.dispose();
    _phoneNumberController.dispose();
    _noteController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }
}
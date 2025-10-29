// import 'dart:io';
// import 'package:cream_ventory/db/functions/party_db.dart';
// import 'package:cream_ventory/db/functions/payment_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/parties/party_model.dart';
// import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
// import 'package:cream_ventory/screen/adding/expense/adding_expense_screen_dotted_fields.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';
// import 'package:cream_ventory/widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';

// class PaymentOutScreen extends StatefulWidget {
//   final PaymentOutModel? payment;
//   const PaymentOutScreen({super.key, this.payment});

//   @override
//   _PaymentOutScreenState createState() => _PaymentOutScreenState();
// }

// class _PaymentOutScreenState extends State<PaymentOutScreen> {
//   String _paidAmount = '';
//   String _selectedPaymentType = 'Cash';
//   PartyModel? _selectedParty;
//   File? _selectedImage;
//   final TextEditingController _receiptController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   final TextEditingController _paidAmountController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();
//   bool _isEditMode = false;

//   @override
//   void initState() {
//     super.initState();
//     _isEditMode = widget.payment != null;

//     initializeForm();
//   }

//   void initializeForm() {
//     if (_isEditMode) {
//       // Pre-fill fields for editing
//       final payment = widget.payment!;
//       _receiptController.text = payment.receiptNo;
//       _dateController.text = payment.date;
//       _phoneNumberController.text = payment.phoneNumber; // Handle null
//       _noteController.text = payment.note ?? '';
//       _paidAmount = payment.paidAmount.toStringAsFixed(2);
//       _paidAmountController.text = _paidAmount;
//       _selectedPaymentType = payment.paymentType;
//       if (payment.imagePath != null && File(payment.imagePath!).existsSync()) {
//         _selectedImage = File(payment.imagePath!);
//       }
//       Future.microtask(() async {
//         try {
//           await PartyDb.loadParties();
//           final party = await PartyDb.getPartyByIdFromName(payment.partyName);
//           setState(() {
//             _selectedParty = party; // Set to matched party or null
//             debugPrint(
//               'Selected Party in edit mode: ${_selectedParty?.name}, Payment PartyName: ${payment.partyName}',
//             );
//           });
//         } catch (e) {
//           debugPrint('Error loading parties in edit mode: $e');
//           setState(() {
//             _selectedParty = null; // Fallback to null on error
//           });
//         }
//       });
//     } else {
//       // Initialize for new payment
//       _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
//       _paidAmountController.text = _paidAmount;
//       Future.microtask(() async {
//         try {
//           await PartyDb.loadParties();
//           await _generateReceiptNumber();
//         } catch (e) {
//           debugPrint('Error initializing new payment: $e');
//         }
//       });
//     }
//   }

//   Future<void> _generateReceiptNumber() async {
//     try {
//       final payments = await PaymentOutDb.getAllPayments();
//       debugPrint(
//         'Payments for receipt generation: ${payments.length} payments',
//       );
//       int maxNumber = 0;
//       for (var payment in payments) {
//         final number = int.tryParse(payment.receiptNo) ?? 0;
//         if (number > maxNumber) maxNumber = number;
//       }
//       final newNumber = maxNumber + 1;
//       setState(() {
//         _receiptController.text = newNumber.toString().padLeft(4, '0');
//       });
//     } catch (e) {
//       debugPrint('Error generating receipt number: $e');
//       setState(() {
//         _receiptController.text = '1';
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 800,
//         maxHeight: 800,
//       );
//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//         });
//       }
//     } catch (e) {
//       debugPrint('Error picking image: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
//     }
//   }

//   Future<void> _savePayment({bool saveAndNew = false}) async {
//     if (_selectedParty == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Please select a Party')));
//       return;
//     }
//     if (_phoneNumberController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a Phone Number')),
//       );
//       return;
//     }
//     if (_paidAmount.isEmpty || _paidAmount == '0.00') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a valid Paid Amount')),
//       );
//       return;
//     }
//     double? amount;
//     try {
//       amount = double.parse(_paidAmount);
//       if (amount <= 0) {
//         throw const FormatException('Amount must be greater than 0');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid Paid Amount format')),
//       );
//       return;
//     }

//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;

//     final payment = PaymentOutModel(
//       id: _isEditMode ? widget.payment!.id.toString() : '0',
//       receiptNo: _receiptController.text,
//       date: _dateController.text,
//       partyName: _selectedParty!.name,
//       phoneNumber: _phoneNumberController.text.trim(),
//       paidAmount: amount,
//       paymentType: _selectedPaymentType,
//       note: _noteController.text.trim().isEmpty
//           ? null
//           : _noteController.text.trim(),
//       imagePath: _selectedImage?.path,
//       userId: userId,
//     );

//     debugPrint('Saving payment: $payment');

//     try {
//       await PaymentOutDb.savePayment(payment);
//       await PartyDb.updateBalanceAfterPayment(
//         payment.partyName,
//         payment.paidAmount,
//         false,
//       );
//       await PartyDb.loadParties();
//       debugPrint('Payment saved successfully');
//       final allPayments = await PaymentOutDb.getAllPayments();
//       debugPrint('Payments after save: ${allPayments.length} payments');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Payment saved successfully'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.green,
//         ),
//       );

//       if (saveAndNew) {
//         setState(() {
//           _phoneNumberController.clear();
//           _noteController.clear();
//           _paidAmount = '0.00';
//           _paidAmountController.text = '0.00';
//           _selectedPaymentType = 'Cash';
//           _selectedImage = null;
//           _selectedParty = null;
//           _dateController.text = DateFormat(
//             'dd/MM/yyyy',
//           ).format(DateTime.now());
//         });
//         await _generateReceiptNumber();
//       } else {
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       debugPrint('Error saving payment: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Failed to save payment')));
//     }
//   }

//   void _deletePayment() {
//     if (!_isEditMode) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Confirm Delete'),
//         content: Text('Are you sure you want to delete this Payment Out?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               PaymentOutDb.deletePayment(widget.payment!.id).then((_) {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Payment deleted successfully!'),
//                     behavior: SnackBarBehavior.floating,
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               });
//             },
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: _isEditMode ? 'Edit Payment-Out' : 'Payment-Out',
//       ),
//       backgroundColor: Colors.transparent,
//       body: Container(
//         decoration: const BoxDecoration(gradient: AppTheme.appGradient),
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Section 1: Receipt and Date
//                     ValueListenableBuilder<List<PartyModel>>(
//                       valueListenable: PartyDb.partyNotifier,
//                       builder: (context, parties, child) {
//                         return Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           color: Colors.white.withOpacity(0.95),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Payment Details',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: TextField(
//                                         controller: _receiptController,
//                                         readOnly: true,
//                                         decoration: InputDecoration(
//                                           labelText: 'Receipt No',
//                                           labelStyle: const TextStyle(color: Colors.black54),
//                                           filled: true,
//                                           fillColor: Colors.grey[100],
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           contentPadding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 16,
//                                           ),
//                                         ),
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: TextField(
//                                         controller: _dateController,
//                                         readOnly: true,
//                                         onTap: () => _selectDate(context),
//                                         decoration: InputDecoration(
//                                           labelText: 'Date',
//                                           labelStyle: const TextStyle(color: Colors.black54),
//                                           filled: true,
//                                           fillColor: Colors.grey[100],
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           suffixIcon: const Icon(
//                                             Icons.calendar_today,
//                                             color: Colors.black54,
//                                             size: 20,
//                                           ),
//                                           contentPadding: const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 16,
//                                           ),
//                                         ),
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 DropdownButtonFormField<PartyModel>(
//                                   value: _selectedParty,
//                                   decoration: InputDecoration(
//                                     labelText: 'Party Name',
//                                     labelStyle: const TextStyle(color: Colors.black54),
//                                     filled: true,
//                                     fillColor: Colors.grey[100],
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                   items: parties.isEmpty
//                                       ? null
//                                       : parties.map((PartyModel party) {
//                                           return DropdownMenuItem<PartyModel>(
//                                             value: party,
//                                             child: Text(
//                                               party.name,
//                                               style: const TextStyle(fontSize: 16),
//                                             ),
//                                           );
//                                         }).toList(),
//                                   onChanged: parties.isEmpty
//                                       ? null
//                                       : (PartyModel? newValue) {
//                                           if (newValue != null) {
//                                             setState(() {
//                                               _selectedParty = newValue;
//                                               _phoneNumberController.text =
//                                                   newValue.contactNumber;
//                                             });
//                                             debugPrint(
//                                               'Selected Party: ${newValue.name}, Phone: ${newValue.contactNumber}',
//                                             );
//                                           }
//                                         },
//                                   hint: parties.isEmpty
//                                       ? const Text('No Parties Available')
//                                       : const Text(
//                                           'Select Party',
//                                           style: TextStyle(color: Colors.black54),
//                                         ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 TextField(
//                                   controller: _phoneNumberController,
//                                   decoration: InputDecoration(
//                                     labelText: 'Phone Number',
//                                     labelStyle: const TextStyle(color: Colors.black54),
//                                     filled: true,
//                                     fillColor: Colors.grey[100],
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     prefixIcon: const Icon(
//                                       Icons.phone,
//                                       color: Colors.black54,
//                                       size: 20,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                   keyboardType: TextInputType.phone,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     // Section 2: Amount and Payment Type
//                     ValueListenableBuilder<List<PartyModel>>(
//                       valueListenable: PartyDb.partyNotifier,
//                       builder: (context, parties, child) {
//                         return Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           color: Colors.grey[200]?.withOpacity(0.95),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Transaction Details',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     const Text(
//                                       'Paid',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: DottedTextField(
//                                         hintText: '0.00',
//                                         controller: _paidAmountController,
//                                         keyboardType:
//                                             const TextInputType.numberWithOptions(
//                                           decimal: true,
//                                         ),
//                                         inputFormatters: [
//                                           FilteringTextInputFormatter.allow(
//                                             RegExp(r'^\d*\.?\d{0,2}'),
//                                           ), // Allow decimal numbers (e.g., 12.34)
//                                         ],
//                                         onChanged: (value) {         
//                                           setState(() {
//                                             if (value.isNotEmpty) {
//                                               try {
//                                                 final parsed = double.parse(value);
//                                                 _paidAmount = parsed
//                                                     .toStringAsFixed(2);
//                                               } catch (e) {
//                                                 _paidAmount = '0.00';
//                                               }
//                                             } else {
//                                               _paidAmount = '0.00';
//                                             }
//                                           });
//                                         },
//                                         decoration: InputDecoration(
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(8),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 16,
//                                           ),
//                                           hintText:
//                                               '0.00', // Optional: hintText can be set via decoration or widget parameter
//                                           hintStyle: const TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 16,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   children: [
//                                     const Text(
//                                       'Payment Type',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     Expanded(
//                                       child: DropdownButtonFormField<String>(
//                                         value: _selectedPaymentType,
//                                         decoration: InputDecoration(
//                                           labelText: 'Select Payment Type',
//                                           labelStyle: const TextStyle(
//                                             color: Colors.black54,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                           filled: true,
//                                           fillColor: Colors.white,
//                                           border: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: const BorderSide(
//                                               color: Colors.grey,
//                                               width: 1.5,
//                                             ),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: const BorderSide(
//                                               color: Colors.grey,
//                                               width: 1.5,
//                                             ),
//                                           ),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius: BorderRadius.circular(12),
//                                             borderSide: const BorderSide(
//                                               color: Colors.black12,
//                                               width: 2,
//                                             ),
//                                           ),
//                                           contentPadding: const EdgeInsets.symmetric(
//                                             horizontal: 16 ,
//                                             vertical: 16,
//                                           ),
//                                           suffixIcon: const Icon(
//                                             Icons.arrow_drop_down,
//                                             color: Colors.black54,
//                                             size: 24,
//                                           ),
//                                         ),
//                                         icon: const SizedBox.shrink(), // Hide default icon
//                                         items: ['Cash', 'GPay', 'PhonePe'].map((String paymentType) {
//                                           return DropdownMenuItem<String>(
//                                             value: paymentType, 
//                                             child: Row(  
//                                               children: [
//                                                 Icon(
//                                                   paymentType == 'Cash'   
//                                                       ? Icons.money
//                                                       : Icons.payment, 
//                                                   color: Colors.black54,
//                                                   size: 20,
//                                                 ),
//                                                 const SizedBox(width: 8),
//                                                 Text(
//                                                   paymentType,
//                                                   style: const TextStyle(
//                                                     fontSize: 16, 
//                                                     color: Colors.black87,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           );
//                                         }).toList(),
//                                         onChanged: (String? newValue) {
//                                           if (newValue != null) {
//                                             setState(() {
//                                               _selectedPaymentType = newValue;
//                                             });
//                                             debugPrint('Selected Payment Type: $_selectedPaymentType');
//                                           }
//                                         },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     // Section 3: Note and Image
//                     Card(
//                       elevation: 4,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       color: Colors.white.withOpacity(0.95),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: _noteController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Add Note',
//                                   labelStyle: const TextStyle(color: Colors.black54),
//                                   filled: true,
//                                   fillColor: Colors.grey[100],
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 16,
//                                   ),
//                                 ),
//                                 maxLines: 3,
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Container(
//                               width: 80,
//                               height: 80,
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.black26, width: 1.5),
//                                 color: Colors.grey[200],
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 4,
//                                     offset: const Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(12),
//                                 child: InkWell(
//                                   onTap: _pickImage,
//                                   child: _selectedImage == null
//                                       ? Center(
//                                           child: Icon(
//                                             Icons.image,
//                                             color: Colors.black54,
//                                             size: 32,
//                                           ),
//                                         )
//                                       : Image.file(
//                                           _selectedImage!,
//                                           fit: BoxFit.cover,
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // Bottom Buttons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//               child: ValueListenableBuilder<List<PartyModel>>(
//                 valueListenable: PartyDb.partyNotifier,
//                 builder: (context, parties, child) { 
//                   final isSaveEnabled = parties.isNotEmpty;
//                   return Row(
//                     children: [
//                       Expanded(
//                         child: CustomActionButton(
//                           label: _isEditMode ? 'DELETE' : 'SAVE & NEW',
//                           backgroundColor: isSaveEnabled
//                               ? Colors.red.shade400
//                               : Colors.grey,
//                           onPressed:()=> isSaveEnabled
//                               ? (_isEditMode
//                                   ? _deletePayment
//                                   : () => _savePayment(saveAndNew: true))
//                               : null,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: CustomActionButton(
//                           label: _isEditMode ? 'UPDATE' : 'SAVE',
//                           backgroundColor: isSaveEnabled
//                               ? Colors.black87
//                               : Colors.grey,
//                           onPressed:()=> isSaveEnabled
//                               ? () => _savePayment(saveAndNew: false)
//                               : null,
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _receiptController.dispose();
//     _dateController.dispose();
//     _phoneNumberController.dispose();
//     _noteController.dispose();
//     _paidAmountController.dispose();
//     super.dispose();
//   }
// }
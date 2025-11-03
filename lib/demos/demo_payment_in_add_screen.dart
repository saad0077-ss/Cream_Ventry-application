// import 'dart:io';
// import 'package:cream_ventory/db/functions/party_db.dart';
// import 'package:cream_ventory/db/functions/payment_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/parties/party_model.dart';
// import 'package:cream_ventory/db/models/payment/payment_in_model.dart';
// import 'package:cream_ventory/screen/adding/expense/adding_expense_screen_dotted_fields.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';
// import 'package:cream_ventory/widgets/custom_button.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
  
// class PaymentInScreen extends StatefulWidget {
//   final PaymentInModel? payment;
//   const PaymentInScreen({super.key, this.payment});

//   @override
//   _PaymentInScreenState createState() => _PaymentInScreenState();
// }

// class _PaymentInScreenState extends State<PaymentInScreen> {
//   String _receivedAmount = '';
//   String _selectedPaymentType = 'Cash';
//   String? _partyName;
//   PartyModel? _selectedParty;
//   File? _selectedImage;    
//   final TextEditingController _receiptController = TextEditingController();
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _phoneNumberController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   final TextEditingController _receivedAmountController = TextEditingController();
//   final TextEditingController _partyNameController = TextEditingController();
//   final ImagePicker _picker = ImagePicker();
//   bool _isEditMode = false;

//   @override                  
//   void initState() {
//     super.initState();
//     _isEditMode = widget.payment != null;
//     initializeForm();
//     // Listen to party changes
//     PartyDb.partyNotifier.addListener(_updatePartyList);
//     // Load parties initially
//     _loadParties();
//   }

//   Future<void> _loadParties() async {
//     await PartyDb.loadParties();
//   }

//   void _updatePartyList() {
//     setState(() {});
//   }

//   Future<void> initializeForm() async {
//     try {
//       if (_isEditMode) {
//         final payment = widget.payment!;
//         _receiptController.text = payment.receiptNo;
//         _dateController.text = payment.date;
//         _phoneNumberController.text = payment.phoneNumber ?? '';
//         _noteController.text = payment.note ?? '';
//         _receivedAmount = payment.receivedAmount.toStringAsFixed(2);
//         _receivedAmountController.text = _receivedAmount;
//         _selectedPaymentType = payment.paymentType;
//         if (payment.imagePath != null && File(payment.imagePath!).existsSync()) {
//           _selectedImage = File(payment.imagePath!);
//         }
//         if (payment.partyName != null) {
//           _partyName = payment.partyName;
//           _partyNameController.text = payment.partyName!;
//           // Find the party by name and set _selectedParty
//           final party = await PartyDb.getPartyByIdFromName(payment.partyName!);
//           if (party != null) {
//             setState(() {
//               _selectedParty = party;
//               _phoneNumberController.text = party.contactNumber;
//             });
//           }
//         }
//       } else {
//         _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
//         _receivedAmountController.text = _receivedAmount;
//         await _generateReceiptNumber();
//       }
//     } catch (e) {
//       debugPrint('Error initializing form: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to initialize form: $e'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _generateReceiptNumber() async {
//     try {
//       final payments = await PaymentInDb.getAllPayments();
//       int maxNumber = 0;
//       for (var payment in payments) {
//         String receiptNo = payment.receiptNo;
//         final number = int.tryParse(receiptNo) ?? 0;
//         if (number > maxNumber) maxNumber = number;
//       }
//       setState(() {
//         _receiptController.text = (maxNumber + 1).toString().padLeft(4, '0');
//       });
//     } catch (e) {
//       debugPrint('Error generating receipt number: $e');
//       setState(() {
//         _receiptController.text = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
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
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to pick image'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _savePayment({required bool saveAndNew}) async {
//     if (_selectedParty == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a party'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (_phoneNumberController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a phone number'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     if (_receivedAmount.isEmpty || _receivedAmount == '0.00') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a valid received amount'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     double? amount;
//     try {
//       amount = double.parse(_receivedAmount);
//       if (amount <= 0) {
//         throw const FormatException('Amount must be greater than 0');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Invalid received amount format'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;

//     final payment = PaymentInModel(
//       id: _isEditMode ? widget.payment!.id.toString() : '0',
//       receiptNo: _receiptController.text,
//       date: _dateController.text,
//       partyName: _selectedParty!.name,
//       phoneNumber: _phoneNumberController.text.trim(),   
//       receivedAmount: amount,
//       paymentType: _selectedPaymentType,
//       note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
//       imagePath: _selectedImage?.path,
//       userId: userId,
//     );

//     try {
//       await PaymentInDb.savePayment(payment);
//       await PartyDb.updateBalanceAfterPayment(
//         payment.partyName!,
//         payment.receivedAmount,
//         true,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(_isEditMode ? 'Payment updated successfully' : 'Payment saved successfully'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.green,
//         ),
//       );

//       if (saveAndNew) {
//         setState(() {
//           _partyNameController.clear();
//           _phoneNumberController.clear();
//           _noteController.clear();
//           _receivedAmount = '0.00';
//           _receivedAmountController.text = '0.00';
//           _selectedPaymentType = 'Cash';
//           _selectedImage = null;
//           _partyName = null;
//           _selectedParty = null;
//           _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
//         });
//         await _generateReceiptNumber();
//       } else {
//         Navigator.of(context).pop(true);
//       }
//     } catch (e) {
//       debugPrint('Error saving payment: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save payment: $e'),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _deletePayment() {
//     if (!_isEditMode) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Delete'),
//         content: const Text('Are you sure you want to delete this payment?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () async {
//               try {
//                 await PaymentInDb.deletePayment(widget.payment!.id);
//                 await PartyDb.updateBalanceAfterPayment(
//                   widget.payment!.partyName!,
//                   widget.payment!.receivedAmount,
//                   false,
//                 );
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Payment deleted successfully!'),
//                     behavior: SnackBarBehavior.floating,
//                     backgroundColor: Colors.green,
//                   ),
//                 );
//               } catch (e) {
//                 debugPrint('Error deleting payment: $e');
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Failed to delete payment: $e'),
//                     behavior: SnackBarBehavior.floating,
//                     backgroundColor: Colors.red,
//                   ), 
//                 );
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],      
//       ),
//     );
//   }

//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: CustomAppBar(
//       title: _isEditMode ? 'Edit Payment-In' : 'Payment-In',

//     ),
//     backgroundColor: Colors.transparent,
//     body: Container(
//       decoration: const BoxDecoration(gradient: AppTheme.appGradient),
//       child: Column(
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Section 1: Receipt and Date
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     color: Colors.white.withOpacity(0.95),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [ 
//                           const Text(
//                             'Payment Details',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: _receiptController,
//                                   readOnly: true,
//                                   decoration: InputDecoration(
//                                     labelText: 'Receipt No',
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
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: TextField(
//                                   controller: _dateController,
//                                   readOnly: true,
//                                   onTap: () => _selectDate(context),
//                                   decoration: InputDecoration(
//                                     labelText: 'Date',
//                                     labelStyle: const TextStyle(color: Colors.black54),
//                                     filled: true,
//                                     fillColor: Colors.grey[100],
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     suffixIcon: const Icon(
//                                       Icons.calendar_today,
//                                       color: Colors.black54,
//                                       size: 20,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           DropdownButtonFormField<PartyModel>(
//                             value: _selectedParty,
//                             decoration: InputDecoration(
//                               labelText: 'Party Name',
//                               labelStyle: const TextStyle(color: Colors.black54),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 16,
//                               ),
//                             ),
//                             items: PartyDb.partyNotifier.value.map((PartyModel party) {
//                               return DropdownMenuItem<PartyModel>(
//                                 value: party,
//                                 child: Text(
//                                   party.name,
//                                   style: const TextStyle(fontSize: 16),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (PartyModel? newValue) {
//                               if (newValue != null) {
//                                 setState(() {
//                                   _selectedParty = newValue;
//                                   _partyName = newValue.name;
//                                   _phoneNumberController.text = newValue.contactNumber;
//                                   debugPrint('Selected Party: $_partyName, Phone: ${_phoneNumberController.text}');
//                                 });
//                               }
//                             },
//                             hint: const Text(
//                               'Select Party',
//                               style: TextStyle(color: Colors.black54),
//                             ),
//                             validator: (value) => value == null ? 'Please select a party' : null,
//                           ),
//                           const SizedBox(height: 16),
//                           TextField(
//                             controller: _phoneNumberController,
//                             decoration: InputDecoration(
//                               labelText: 'Phone Number',
//                               labelStyle: const TextStyle(color: Colors.black54),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide: BorderSide.none,
//                               ),
//                               prefixIcon: const Icon(
//                                 Icons.phone,
//                                 color: Colors.black54,
//                                 size: 20,
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 16,
//                               ),
//                             ),
//                             keyboardType: TextInputType.phone,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Section 2: Amount and Payment Type
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     color: Colors.grey[200]?.withOpacity(0.95),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Transaction Details',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 'Received',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: DottedTextField(
//                                   hintText: '0.00',
//                                   controller: _receivedAmountController,
//                                   keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                                   inputFormatters: [
//                                     FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
//                                   ],
//                                   onChanged: (value) {
//                                     setState(() {
//                                       if (value.isNotEmpty) {
//                                         try {
//                                           final parsed = double.parse(value);
//                                           _receivedAmount = parsed.toStringAsFixed(2);
//                                         } catch (e) {
//                                           _receivedAmount = '0.00';
//                                         } 
//                                       } else {
//                                         _receivedAmount = '0.00';
//                                       }
//                                     });
//                                   },
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor: Colors.white24,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               const Text(
//                                 'Payment Type',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: DropdownButtonFormField<String>(
//                                   value: _selectedPaymentType,
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor: Colors.white24,
//                                     border: OutlineInputBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                       vertical: 16,
//                                     ),
//                                   ),
//                                   items: ['Cash', 'GPay', 'PhonePe'].map((String paymentType) {
//                                     return DropdownMenuItem<String>(
//                                       value: paymentType,
//                                       child: Text(
//                                         paymentType,
//                                         style: const TextStyle(fontSize: 16),
//                                       ),
//                                     );
//                                   }).toList(),
//                                   onChanged: (String? newValue) {
//                                     if (newValue != null) {
//                                       setState(() {
//                                         _selectedPaymentType = newValue;
//                                       });
//                                       debugPrint('Selected Payment Type: $_selectedPaymentType');
//                                     }
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   // Section 3: Note and Image
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     color: Colors.white.withOpacity(0.95),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _noteController,
//                               decoration: InputDecoration(
//                                 labelText: 'Add Note',
//                                 labelStyle: const TextStyle(color: Colors.black54),
//                                 filled: true,
//                                 fillColor: Colors.grey[100],
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 16,
//                                 ),
//                               ),
//                               maxLines: 3,
//                               style: const TextStyle(fontSize: 16),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Container(
//                             width: 80,
//                             height: 80,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.black26, width: 1.5),
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: InkWell(
//                                 onTap: _pickImage,
//                                 child: _selectedImage == null
//                                     ? Center(
//                                         child: Icon(
//                                           Icons.image,
//                                           color: Colors.black54,
//                                           size: 32,
//                                         ),
//                                       )
//                                     : Image.file(
//                                         _selectedImage!,
//                                         fit: BoxFit.cover,
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // Bottom Buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: CustomActionButton(
//                     label: _isEditMode ? 'DELETE' : 'SAVE & NEW',
//                     backgroundColor: Colors.red.shade400,
//                     onPressed: _isEditMode ? _deletePayment : () => _savePayment(saveAndNew: true),
                   
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: CustomActionButton(
//                     label: _isEditMode ? 'UPDATE' : 'SAVE',
//                     backgroundColor: Colors.black87,
//                     onPressed: () => _savePayment(saveAndNew: false),
          
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     ),
//   );
// }

//   @override
//   void dispose() {
//     _receiptController.dispose();
//     _dateController.dispose();
//     _phoneNumberController.dispose();
//     _noteController.dispose();
//     _receivedAmountController.dispose();
//     _partyNameController.dispose();
//     PartyDb.partyNotifier.removeListener(_updatePartyList);
//     super.dispose();
//   }
// }
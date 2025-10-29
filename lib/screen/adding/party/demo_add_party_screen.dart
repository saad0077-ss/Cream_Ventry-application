// import 'package:cream_ventory/db/functions/party_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/parties/party_model.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/utils/party/party_form_feild_validation.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';
// import 'package:cream_ventory/widgets/custom_button.dart';
// import 'package:cream_ventory/widgets/text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class AddParty extends StatefulWidget {
//   final PartyModel? party;
//   const AddParty({super.key, this.party});

//   @override
//   State<AddParty> createState() => _AddPartyState();
// }

// class _AddPartyState extends State<AddParty> {
//   final TextEditingController partyNameController = TextEditingController();
//   final TextEditingController contactNumberController = TextEditingController();
//   final TextEditingController openingBalanceController =
//       TextEditingController();
//   final TextEditingController billingAddressController =
//       TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   String paymentType = "You'll Give";
//   DateTime? selectedDate;
//   File? _selectedImage;
//   final ImagePicker _picker = ImagePicker();
//   final _uuid = Uuid();

//   @override
//   void initState() {
//     super.initState();
//     initializeForm();
//   }

//   void initializeForm() {
//     if (widget.party != null) {
//       final party = widget.party!;
//       partyNameController.text = party.name;
//       contactNumberController.text = party.contactNumber;
//       openingBalanceController.text = party.openingBalance.toString();
//       billingAddressController.text = party.billingAddress;
//       emailController.text = party.email;
//       paymentType = party.paymentType;
//       selectedDate = party.asOfDate;
//       if (party.imagePath.isNotEmpty) {
//         _selectedImage = File(party.imagePath);
//       }
//     }
//   }

//   Future<void> pickDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: selectedDate ?? DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//     );

//     if (pickedDate != null) {
//       setState(() {
//         selectedDate = pickedDate;
//       });
//     }
//   }

//   Future<void> pickImage() async {
//     try {
//       final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         final permanentPath = await _saveImagePermanently(File(image.path));
//         setState(() {
//           _selectedImage = File(permanentPath);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to pick image: $e"),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<String> _saveImagePermanently(File image) async {
//     final directory = await getApplicationDocumentsDirectory();
//     final fileName = '${_uuid.v4()}.jpg';
//     final permanentPath = '${directory.path}/$fileName';
//     final savedImage = await image.copy(permanentPath);
//     return savedImage.path;
//   }

//   Future<void> saveParty({bool clearFields = false}) async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//     if (partyNameController.text.isEmpty ||
//         contactNumberController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Party Name and Contact Number are required!"),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     double parsedBalance =
//         double.tryParse(openingBalanceController.text) ?? 0.0;
//     double finalOpeningBalance = paymentType == "You'll Give"
//         ? -parsedBalance.abs()
//         : parsedBalance.abs();

//         final user = await UserDB.getCurrentUser();
//         final userId = user.id;

//     final party = PartyModel(
//       id: widget.party?.id ?? _uuid.v4(),
//       name: partyNameController.text,
//       contactNumber: contactNumberController.text,
//       openingBalance: finalOpeningBalance,
//       asOfDate: selectedDate ?? DateTime.now(),
//       billingAddress: billingAddressController.text,
//       email: emailController.text,
//       paymentType: paymentType,
//       imagePath: _selectedImage?.path ?? widget.party?.imagePath ?? '',
//       partyBalance: 0.0,
//       userId: userId
//     );

//     try {
//       if (widget.party != null) {
//         bool success = await PartyDb.updatePartyBasic(party);
//         if (success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Party updated successfully!"),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else {
//           throw Exception("Failed to update party: Not found");
//         }
//       } else {
//         await PartyDb.addParty(party);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Party added successfully!"),
//             behavior: SnackBarBehavior.floating,
//             backgroundColor: Colors.green,
//           ),
//         );
//       }

//       if (clearFields) {
//         clearForm();
//       } else {
//         Navigator.of(context).pop(party);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to save party: $e"),
//           behavior: SnackBarBehavior.floating,
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void clearForm() {
//     partyNameController.clear();
//     contactNumberController.clear();
//     openingBalanceController.clear();
//     billingAddressController.clear();
//     emailController.clear();
//     setState(() {
//       selectedDate = null;
//       paymentType = "You'll Give";
//       _selectedImage = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: widget.party != null ? 'Edit Party' : 'Add Party',
//         fontSize: 30,
//       ),
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         decoration: BoxDecoration(gradient: AppTheme.appGradient),
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(screenWidth * 0.05),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(height: screenHeight * 0.05),
//                 GestureDetector(
//                   onTap: pickImage,
//                   child: CircleAvatar(
//                     radius: screenWidth * 0.15,
//                     backgroundColor: Colors.grey[300],
//                     backgroundImage: _selectedImage != null
//                         ? FileImage(_selectedImage!)
//                         : widget.party?.imagePath.isNotEmpty ?? false
//                             ? FileImage(File(widget.party!.imagePath))
//                             : null,
//                     child: _selectedImage == null &&
//                             (widget.party?.imagePath.isEmpty ?? true)
//                         ? Icon(
//                             Icons.person,
//                             size: screenWidth * 0.15,
//                             color: Colors.grey[600],
//                           )
//                         : null,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 CustomTextField(
//                   labelText: 'Party Name',
//                   controller: partyNameController,
//                   validator: PartyValidations.validatePartyName,
//                   keyboardType: TextInputType.text,
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 CustomTextField(
//                   labelText: 'Contact Number',
//                   controller: contactNumberController,
//                   validator: PartyValidations.validateContactNumber,
//                   keyboardType: TextInputType.phone,
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         labelText: 'Opening Bal',
//                         controller: openingBalanceController,
//                         keyboardType: TextInputType.number,
//                         readOnly: widget.party != null,
//                         validator: PartyValidations.validateOpeningBalance,
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.05),
//                     Expanded(
//                       child: GestureDetector(
//                         onTap: () => pickDate(context),
//                         child: AbsorbPointer(
//                           child: CustomTextField(
//                             labelText: 'As Of Date',
//                             controller: TextEditingController(
//                               text: selectedDate != null
//                                   ? DateFormat('dd/MM/yyyy').format(selectedDate!)
//                                   : '',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Row(
//                       children: [
//                         Radio(
//                           value: "You'll Get",
//                           groupValue: paymentType,
//                           onChanged: (value) {
//                             setState(() {
//                               paymentType = value.toString();
//                             });
//                           },
//                         ),
//                         const Text('To Receive'),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Radio(
//                           value: "You'll Give",
//                           groupValue: paymentType,
//                           onChanged: (value) {
//                             setState(() {
//                               paymentType = value.toString();
//                             });
//                           },
//                         ),
//                         const Text('To Pay'),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const Padding(
//                   padding: EdgeInsets.only(bottom: 8.0),
//                   child: Text(
//                     'Address',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 CustomTextField(
//                   labelText: 'Billing Address',
//                   controller: billingAddressController,
//                   validator: PartyValidations.validateBillingAddress,
//                 ),
//                 SizedBox(height: screenHeight * 0.02),
//                 CustomTextField(
//                   labelText: 'Email',
//                   controller: emailController,
//                   focusColor: Colors.blue,
//                   validator: PartyValidations.validateEmail,
//                   keyboardType: TextInputType.emailAddress,
//                 ),
//                 SizedBox(height: screenHeight * 0.05),
//                 SizedBox(
//                   height: 150,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       CustomActionButton(
//                         label: 'Save & New',
//                         backgroundColor: Colors.black,
//                         onPressed: () => saveParty(clearFields: true),
//                         width: screenWidth * 0.4,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.05,
//                           vertical: screenHeight * 0.015,
//                         ),
//                       ),
//                       CustomActionButton(
//                         label: widget.party != null ? 'Edit Party' : 'Save Party',
//                         backgroundColor: Colors.red,
//                         onPressed: () => saveParty(),
//                         width: screenWidth * 0.4,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * 0.06,
//                           vertical: screenHeight * 0.016,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
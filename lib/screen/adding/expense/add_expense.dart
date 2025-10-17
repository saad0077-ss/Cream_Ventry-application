// import 'package:cream_ventory/db/functions/expense_category_db.dart';
// import 'package:cream_ventory/db/models/expence/expence_model.dart';
// import 'package:cream_ventory/db/models/expence/expense_category_model.dart';
// import 'package:cream_ventory/screen/listing/expense/screens/widgets/dotted_fields.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/themes/font_helper/font_helper.dart';
// import 'package:cream_ventory/utils/expence/add_expence_logics.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';
// import 'package:cream_ventory/widgets/custom_button.dart';
// import 'package:cream_ventory/widgets/text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';

// class AddExpensePage extends StatefulWidget {
//   final ExpenseModel? existingExpense;

//   const AddExpensePage({super.key, this.existingExpense});

//   @override
//   _AddExpensePageState createState() => _AddExpensePageState();
// }

// class _AddExpensePageState extends State<AddExpensePage> {
//   late bool isEditing;   
//   late AddExpenseLogic logic;
//   Future<List<ExpenseCategoryModel>>? categoryListFuture;

//   @override
//   void initState() {
//     super.initState();
//     isEditing = widget.existingExpense != null;
//     logic = AddExpenseLogic(expense: widget.existingExpense);
//     categoryListFuture = ExpenseCategoryDB.getCategories();
//   }


//   @override
//   void dispose() {
//     logic.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: CustomAppBar(
//         title: isEditing ? 'Edit Expense' : 'Add Expense',
//         fontSize: 25,
//       ),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: BoxDecoration(gradient: AppTheme.appGradient),
//         padding: const EdgeInsets.all(10.0),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   Expanded(
//                     child: CustomTextField(
//                       controller: logic.invoiceController,
//                       hintText: 'Invoice No',
//                       labelText: 'Invoice No',
//                       readOnly: true,
//                       onChanged: (_) {},
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => logic.selectDate(context, setState),
//                       child: AbsorbPointer(
//                         child: TextField(
//                           decoration: InputDecoration(
//                             labelText: DateFormat(
//                               'dd/MM/yyyy',
//                             ).format(logic.selectedDate),
//                             border: const OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 15),

//               // Category Dropdown
//               FutureBuilder<List<ExpenseCategoryModel>>(
//                 future: categoryListFuture,
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return const CircularProgressIndicator();
//                   }

//                   final categories =
//                       snapshot.data!..sort(
//                         (a, b) => a.name.toLowerCase().compareTo(
//                           b.name.toLowerCase(),
//                         ),
//                       );
//                   final List<String> categoryNames =
//                       categories.map((e) => e.name).toList();
//                   final allItems = [
//                     'EXPENSE CATEGORY',
//                     ...categoryNames,
//                     '➕ Add New Category', 
//                   ];

//                   // Ensure selectedCategory is valid
//                   if (!allItems.contains(logic.selectedCategory)) {
//                     logic.selectedCategory = 'EXPENSE CATEGORY';
//                   }

//                   return DropdownButtonFormField<String>(
//                     initialValue: logic.selectedCategory,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Expense Category',
//                     ),
//                     items:
//                         allItems.toSet().map((value) {
//                           return DropdownMenuItem<String>(
//                             value: value,
//                             child: Text(value),
//                           );
//                         }).toList(),
//                     onChanged: (value) async {
//                       if (value == '➕ Add New Category') {
//                         final newCategoryName = await _showAddCategoryDialog(
//                           context,
//                         );
//                         if (newCategoryName != null &&
//                             newCategoryName.trim().isNotEmpty) {
//                           final trimmedName = newCategoryName.trim();
//                           await ExpenseCategoryDB.addCategory(trimmedName);

//                           // Refresh category list
//                           final updatedList =
//                               await ExpenseCategoryDB.getCategories();
//                           updatedList.sort(
//                             (a, b) => a.name.toLowerCase().compareTo(
//                               b.name.toLowerCase(),
//                             ),
//                           );
//                           setState(() {
//                             categoryListFuture = Future.value(updatedList);
//                             logic.selectedCategory = trimmedName;
//                           });
//                         }
//                       } else {
//                         setState(() {
//                           logic.selectedCategory = value!;
//                         });
//                       }
//                     },
//                     validator: (value) {
//                       if (value == null ||
//                           value == 'EXPENSE CATEGORY' ||
//                           value == '➕ Add New Category') {
//                         return 'Please select a category';
//                       }
//                       return null;
//                     },
//                   );
//                 },
//               ),

//               const SizedBox(height: 15),
//                Text(
//                 'BILLED ITEMS',
//                 style: AppTextStyles.textBold,
//               ),

//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: logic.billedItems.length,
//                 itemBuilder: (context, index) {
//                   var item = logic.billedItems[index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       key: ValueKey(item['id']),
//                       children: [
//                         Expanded(
//                           child: DottedTextField(
//                             key: ValueKey('${item['id']}_name'),
//                             hintText: 'Name',
//                             controller:
//                                 item['nameController'] as TextEditingController,
//                             onChanged: (value) {
//                               setState(() {
//                                 item['name'] = value;
//                               });
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: DottedTextField(
//                             key: ValueKey('${item['id']}_qty'),
//                             hintText: 'Qty',
//                             controller:
//                                 item['qtyController'] as TextEditingController,
//                             keyboardType: TextInputType.number,
//                             inputFormatters: [
//                               FilteringTextInputFormatter.digitsOnly,
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 item['qty'] = int.tryParse(value) ?? 0;
//                                 logic.calculateTotal();
//                               });
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: DottedTextField(
//                             key: ValueKey('${item['id']}_rate'),
//                             hintText: 'Rate',
//                             controller:
//                                 item['rateController'] as TextEditingController,
//                             keyboardType: const TextInputType.numberWithOptions(
//                               decimal: true,
//                             ),
//                             inputFormatters: [
//                               FilteringTextInputFormatter.allow(
//                                 RegExp(r'^\d*\.?\d{0,2}'),
//                               ),
//                             ],
//                             onChanged: (value) {
//                               setState(() {
//                                 item['rate'] = double.tryParse(value) ?? 0.0;
//                                 logic.calculateTotal();
//                               });
//                             },
//                           ),
//                         ),
//                         const SizedBox(width: 5),
//                         Expanded(
//                           child: Center(
//                             child: Text(
//                               '₹${((item['qty'] as int) * (item['rate'] as double)).toStringAsFixed(2)}',
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           key: ValueKey('${item['id']}_remove'),
//                           icon: const Icon(
//                             Icons.remove_circle,
//                             color: Colors.red,
//                           ),
//                           onPressed:
//                               () => logic.removeItem(index, setState, context),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),

//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: TextButton(
//                   onPressed: () => logic.addNewItem(setState),
//                   child: const Text('+ Add Item'),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               // Total Amount
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                      Text(
//                       'TOTAL AMOUNT',
//                       style:AppTextStyles.textBold,
//                     ),
//                     SizedBox(
//                       width: screenWidth * 0.4,
//                       child: TextField(
//                         controller: logic.totalAmountController,
//                         readOnly: true,
//                         decoration: const InputDecoration(
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Buttons
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   if (!isEditing)
//                     CustomActionButton(
//                       onPressed: () => logic.saveAndNew(setState, context),
//                       backgroundColor: Colors.red,
//                       label: 'Save & New',
//                     )
//                   else
//                     CustomActionButton(
//                       onPressed:
//                           () => logic.deleteExpense(
//                             context,
//                             widget.existingExpense!.id,
//                           ),
//                       backgroundColor: Colors.red,
//                       label: 'Delete',
//                     ),
//                   CustomActionButton(
//                     onPressed: () {
//                       if (isEditing && widget.existingExpense != null) {
//                         logic.updateExpense(widget.existingExpense!, context);
//                       } else {
//                         logic.save(context);
//                       }
//                     },
//                     backgroundColor: Colors.black,
//                     label: isEditing ? 'Update' : 'Save',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<String?> _showAddCategoryDialog(BuildContext context) async {
//     return showDialog<String>(
//       context: context,
//       builder: (context) {
//         final controller = TextEditingController();
//         return AlertDialog(
//           title: const Text('Add New Category'),
//           content: TextField(
//             controller: controller,
//             decoration: const InputDecoration(hintText: 'Category Name'),
//             autofocus: true,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(controller.text);
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }  
// }

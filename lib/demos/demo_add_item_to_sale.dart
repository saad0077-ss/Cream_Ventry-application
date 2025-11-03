// import 'package:cream_ventory/db/functions/category_db.dart';
// import 'package:cream_ventory/db/functions/product_db.dart';
// import 'package:cream_ventory/db/functions/sale/sale_item_db.dart';
// import 'package:cream_ventory/db/functions/stock_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/items/category/category_model.dart';
// import 'package:cream_ventory/db/models/items/products/product_model.dart';
// import 'package:cream_ventory/db/models/sale/sale_item_model.dart';
// import 'package:cream_ventory/themes/app_theme/theme.dart';
// import 'package:cream_ventory/widgets/app_bar.dart';
// import 'package:flutter/material.dart';

// class AddItemToSale extends StatefulWidget {
//   final SaleItemModel? saleItem; // Optional sale item for editing
//   final int? index; // Index of the item in the list for updating

//   const AddItemToSale({super.key, this.saleItem, this.index});

//   @override
//   _AddItemToSaleState createState() => _AddItemToSaleState();
// }

// class _AddItemToSaleState extends State<AddItemToSale> {
//   final TextEditingController quantityController = TextEditingController();
//   final TextEditingController rateController = TextEditingController();
//   final TextEditingController totalAmountController = TextEditingController();
//   String? selectedCategoryId;
//   String? selectedProductId;
//   String? selectedCategoryName;
//   List<ProductModel> products = [];
//   bool isEditMode = false;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize databases
//     CategoryDB.loadSampleCategories();
//     ProductDB.initialize();
//     SaleItemDB.init();

//     initializeForm();
//     // Add listeners to update total
//     rateController.addListener(calculateTotal);
//     quantityController.addListener(calculateTotal);
//   }

//   void initializeForm() {
//     // Check if editing an existing item
//     isEditMode = widget.saleItem != null;
//     if (isEditMode) {
//       final saleItem = widget.saleItem!;
//       selectedProductId = saleItem.id;
//       selectedCategoryName = saleItem.categoryName;
//       quantityController.text = saleItem.quantity.toString();
//       rateController.text = saleItem.rate.toStringAsFixed(2);
//       totalAmountController.text = saleItem.subtotal.toStringAsFixed(2);
//       // Load category ID from product
//       ProductDB.getProductById(saleItem.id).then((product) {
//         if (product != null) {
//           setState(() {
//             selectedCategoryId = product.category.id;
//             loadProductsByCategory(product.category.id);
//           });
//         }
//       });
//     }
//   }

//   void calculateTotal() {
//     double qty = double.tryParse(quantityController.text) ?? 0;
//     double rate = double.tryParse(rateController.text) ?? 0;
//     totalAmountController.text = (qty * rate).toStringAsFixed(2);
//   }

//   Future<void> loadProductsByCategory(String categoryId) async {
//     final productList = await ProductDB.getProductsByCategory(categoryId);
//     final category = await CategoryDB.getCategoryById(categoryId);
//     setState(() {
//       products = productList;
//       selectedCategoryName = category?.name ?? '';
//       if (!isEditMode) {
//         selectedProductId = null;
//         rateController.clear();
//       }
//     });
//   }

//   void saveSaleItem({required bool saveAndNew}) async {
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     if (selectedProductId != null &&
//         selectedCategoryName != null &&
//         quantityController.text.isNotEmpty &&
//         rateController.text.isNotEmpty) {
//       final product = products.firstWhere((p) => p.id == selectedProductId!);
//       final quantity = int.tryParse(quantityController.text) ?? 0;
//       if (quantity <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please enter a valid quantity'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       int originalQuantity = isEditMode ? widget.saleItem!.quantity : 0;
//       int quantityDifference = quantity - originalQuantity;
//       if (quantityDifference > 0 && product.stock < quantityDifference) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Insufficient stock for ${product.name}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }
//       try {
//         if (isEditMode) {
//           await StockDB.restockProduct(widget.saleItem!.id, originalQuantity);
//         }
//         final saleItem = SaleItemModel(
//           id: selectedProductId!,
//           productName: product.name,
//           quantity: quantity,
//           rate: double.parse(rateController.text),
//           subtotal: double.parse(totalAmountController.text),
//           categoryName: selectedCategoryName!,
//           index: isEditMode
//               ? widget.saleItem!.index
//               : (await SaleItemDB.getSaleItems(userId: userId)).length + 1,
//           imagePath: product.imagePath,
//           userId: userId,
//         );
//         if (isEditMode) {
//           await SaleItemDB.updateSaleItem(saleItem.id, saleItem);
//         } else {
//           await SaleItemDB.addSaleItem(saleItem);
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               isEditMode
//                   ? 'Sale item updated successfully'
//                   : 'Sale item saved successfully',
//             ),
//             backgroundColor: Colors.green,
//           ),
//         );
//         if (saveAndNew) {
//           quantityController.clear();
//           rateController.clear();
//           totalAmountController.clear();
//           setState(() {
//             selectedCategoryId = null;
//             selectedProductId = null;
//             products = [];
//           });
//         } else {
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving sale item: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please fill all fields'),
//           backgroundColor: Colors.red,
//         ),             
//       );
//     }
//   }

//   @override
//   void dispose() {
//     quantityController.dispose();
//     rateController.dispose();
//     totalAmountController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: isEditMode ? 'Edit Item' : 'Add Item to Sale',
//       ),
//       body: Container(
//         decoration: const BoxDecoration(gradient: AppTheme.appGradient),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
//           child: ConstrainedBox(
//             constraints: BoxConstraints(
//               minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Category and Product Selection
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: ValueListenableBuilder<List<CategoryModel>>(
//                     valueListenable: CategoryDB.categoryNotifier,
//                     builder: (context, categories, _) {
//                       return Column(
//                         children: [
//                           // Category Dropdown
//                           DropdownButtonFormField<String>(
//                             decoration: const InputDecoration(
//                               labelText: 'Item Category',
//                               border: OutlineInputBorder(),
//                             ),
//                             value: selectedCategoryId,
//                             items: categories
//                                 .map(
//                                   (category) => DropdownMenuItem(
//                                     value: category.id,
//                                     child: Text(category.name),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedCategoryId = value;
//                               });
//                               if (value != null) {
//                                 loadProductsByCategory(value);
//                               }
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           // Product Dropdown
//                           DropdownButtonFormField<String>(
//                             decoration: const InputDecoration(
//                               labelText: 'Item Name',
//                               border: OutlineInputBorder(),
//                             ),
//                             value: selectedProductId,
//                             items: products
//                                 .map(
//                                   (product) => DropdownMenuItem(
//                                     value: product.id,
//                                     child: Text(product.name),
//                                   ),
//                                 )
//                                 .toList(),
//                             onChanged: (value) async {
//                               if (value == null) return;
//                               final user = await UserDB.getCurrentUser();
//                               final userId = user.id;
//                               final selectedProduct = products.firstWhere(
//                                 (product) => product.id == value,
//                                 orElse: () => ProductModel(
//                                   name: '',
//                                   stock: 0,
//                                   salePrice: 0,
//                                   purchasePrice: 0,
//                                   category: CategoryModel(
//                                     id: '',
//                                     name: '',
//                                     imagePath: '',
//                                     discription: '',
//                                     userId: '',
//                                   ),
//                                   imagePath: '',
//                                   id: '',
//                                   creationDate: DateTime.now().toIso8601String(),
//                                   isAsset: false,
//                                   userId: userId,
//                                 ),
//                               );
//                               setState(() {
//                                 selectedProductId = value;
//                                 rateController.text = selectedProduct.salePrice.toStringAsFixed(2);
//                               });
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: TextField(
//                                   controller: quantityController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Quantity',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: TextField(
//                                   controller: rateController,
//                                   keyboardType: TextInputType.number,
//                                   decoration: const InputDecoration(
//                                     labelText: 'Rate(Price)',
//                                     border: OutlineInputBorder(),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       side: const BorderSide(),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: calculateTotal,
//                     child: const Text(
//                       'Total',
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                   child: Row(
//                     children: [
//                       const Text(
//                         'Total Amount :',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: TextField(
//                           controller: totalAmountController,
//                           readOnly: true,
//                           decoration: const InputDecoration(
//                             prefixText: '₹ ',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           onPressed: () => saveSaleItem(saveAndNew: true),
//                           child: const Text(
//                             'Save & New',
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                           ),
//                           onPressed: () => saveSaleItem(saveAndNew: false),
//                           child: Text(   
//                             isEditMode ? 'Update' : 'Save',
//                             style: const TextStyle(color: Colors.white),
//                           ),
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
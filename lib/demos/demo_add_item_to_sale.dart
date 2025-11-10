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
















// -------------------------------------------------------------------------p---------------------------

// import 'package:cream_ventory/db/functions/sale/sale_db.dart';
// import 'package:cream_ventory/db/functions/stock_db.dart';
// import 'package:cream_ventory/db/functions/user_db.dart';
// import 'package:cream_ventory/db/models/items/products/product_model.dart';
// import 'package:cream_ventory/db/models/items/products/stock_model.dart';
// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// class ProductDB {
//   static const String _productBoxName = 'productBox';
//   static ValueNotifier<List<ProductModel>> productNotifier = ValueNotifier([]);
//   static Box<ProductModel>? _productBox;

//   static Future<void> initialize() async {
//     try {
//       await _openProductBox(); 
//       debugPrint(
//         'ProductDB initialized with ${_productBox?.values.length} products',
//       );
//     } catch (e) {
//       debugPrint('Error initializing ProductDB: $e');
//       throw Exception('Failed to initialize ProductDB: $e');
//     }
//   }

//   static Future<Box<ProductModel>> _openProductBox() async {
//     if (_productBox == null || !_productBox!.isOpen) {
//       _productBox = await Hive.openBox<ProductModel>(_productBoxName);
//     }
//     return _productBox!;
//   }

//   static Future<void> refreshProducts() async {
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     try {
//       final productBox = await _openProductBox();
//       var products = productBox.values
//           .where((product) => product.userId == userId)
//           .toList();
//       productNotifier.value = products; 
//       debugPrint('Refreshed products: ${products.length}');
//     } catch (e) {
//       debugPrint('Error refreshing products: $e');
//       productNotifier.value = [];
//       throw Exception('Failed to refresh products: $e');
//     }
//   }

//   static Future<void> addProduct(ProductModel product) async {
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     try {
//       if (product.stock < 0 || product.purchasePrice < 0) {
//         throw Exception('Invalid stock or purchase price');
//       }

//       final productBox = await _openProductBox();
//       await productBox.put(product.id, product);
//       debugPrint('Saved Product: ID=${product.id}, Name=${product.name}');
//       if (product.stock > 0) {
//         final openingStock = StockModel(
//           id: const Uuid().v4(),
//           productId: product.id,
//           type: 'Opening Stock',
//           date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
//           quantity: product.stock,
//           total: product.stock * product.purchasePrice,
//           userId: userId,
//         );
//         await StockDB.addStock(openingStock);
//         debugPrint(
//           'Created Stock: StockID=${openingStock.id}, ProductID=${openingStock.productId}, Type=${openingStock.type}, Quantity=${openingStock.quantity}, Total=${openingStock.total}, ',
//         );
//       } else {
//         debugPrint(
//           'No stock entry created for Product ID=${product.id} (stock=0)',
//         );
//       }
//       await refreshProducts();
//     } catch (e) {
//       debugPrint('Error adding product: $e');
//       throw Exception('Failed to add product: $e');
//     }
//   }

//   static Future<bool> deleteProduct(String id) async {
//     try {
//       final productBox = await _openProductBox();
//       final product = productBox.get(id);
//       if (product == null) {
//         debugPrint('Product ID $id not found');
//         return false;
//       }
//       final isInSales = await SaleDB.isProductInSales(id);
//       if (isInSales) {
//         debugPrint('Cannot delete product ID $id: Referenced in sales');
//         throw Exception(
//           'Cannot delete product because it is part of existing sales',
//         );
//       }
//       await productBox.delete(id);
//       await refreshProducts();
//       debugPrint('Product deleted: ID $id');
//       return true;
//     } catch (e) {
//       debugPrint('Error deleting product: $e');
//       throw Exception('Failed to delete product: $e');
//     }
//   }

//   static Future<bool> updateProduct(
//     String id,
//     ProductModel updatedProduct, {
//     bool createStockTransaction = true,
//   }) async {
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     try {
//       final productBox = await _openProductBox();
//       final oldProduct = productBox.get(id);
//       if (oldProduct == null) {
//         debugPrint('ID not found for update: $id');
//         return false;
//       }
//       final stockChange = updatedProduct.stock - oldProduct.stock;
//       await productBox.put(id, updatedProduct);
//       if (createStockTransaction && stockChange != 0) {
//         final stockingType = stockChange > 0 ? 'Stock Added' : 'Stock Removed';
//         final stockAdjustment = StockModel(
//           id: const Uuid().v4(),
//           productId: updatedProduct.id,
//           type: stockingType,
//           date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
//           quantity: stockChange.abs().toInt(),
//           total: stockChange.abs() * updatedProduct.purchasePrice,
//           userId: userId,
//         );
//         await StockDB.addStock(stockAdjustment);
//         debugPrint(
//           'Stock Transaction Created: ProductID=${updatedProduct.id}, Type=$stockingType, Quantity=${stockAdjustment.quantity}, Total=${stockAdjustment.total}',
//         );
//       } else {
//         debugPrint(
//           'Product Updated (No Stock Change): ID=${updatedProduct.id}, Name=${updatedProduct.name}',
//         );
//       }
//       await refreshProducts();
//       return true;
//     } catch (e) {
//       debugPrint('Error updating product: $e');
//       throw Exception('Failed to update product: $e');
//     }
//   }

//   static Future<List<ProductModel>> getProductsByCategory(
//     String categoryId,
//   ) async {
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     try {
//       final productBox = await _openProductBox();
//       var products = productBox.values
//           .where(
//             (product) =>
//                 product.category.id == categoryId && product.userId == userId,
//           )
//           .toList();
//       debugPrint(
//         'Fetched ${products.length} products for category $categoryId',
//       );
//       return products;
//     } catch (e) {
//       debugPrint('Error fetching products by category: $e');
//       return [];
//     }
//   }

//   static Future<void> clearAllProducts() async {
//     try {
//       final productBox = await _openProductBox();
//       await productBox.clear();
//       debugPrint('Cleared all products');
//       await refreshProducts();
//     } catch (e) {
//       debugPrint('Error clearing products: $e');
//       throw Exception('Failed to clear products: $e');
//     }
//   }

//   static Future<List<ProductModel>> getProducts() async {
//     try {
//       final box = await _openProductBox();
//       final user = await UserDB.getCurrentUser();
//       final userId = user.id;
//       var products = box.values
//           .where((product) => product.userId == userId)
//           .toList();
//       debugPrint('Fetched ${products.length} products in userId $userId ');
//       return products;
//     } catch (e) {
//       debugPrint('Error fetching products: $e');
//       return [];
//     }
//   }

//   static Future<ProductModel?> getProductById(String id) async {
//     final products = await getProducts();
//     final user = await UserDB.getCurrentUser();
//     final userId = user.id;
//     try {
//       return products.firstWhere((product) => product.id == id && product.userId == userId);
//     } catch (e) {
//       return null;
//     }
//   }

//   static Future<ProductModel?> getProduct(String productId) async {
//     try {
//       final box = await _openProductBox();
//       final product = box.get(productId);
//       if (product == null) {
//         debugPrint('Product not found: ID $productId');
//         return null;
//       }
//       debugPrint('Fetched product: ID $productId');
//       return product;
//     } catch (e) {
//       debugPrint('Error fetching product: $e');
//       return null;
//     }
//   }
// }


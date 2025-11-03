// import 'dart:io';
// import 'package:cream_ventory/db/functions/product_db.dart';
// import 'package:cream_ventory/db/models/items/products/product_model.dart';
// import 'package:cream_ventory/screen/adding/product/show_product_add_bottom_sheet.dart';
// import 'package:cream_ventory/screen/detailing/product/product_detailing_screen.dart';
// import 'package:flutter/material.dart';

// class ItemCard extends StatelessWidget {
//   final ProductModel product;
//   final String index;

//   const ItemCard({super.key, required this.product, required this.index});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailsPage(product: product),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 5,
//         shadowColor: Colors.grey.withOpacity(0.3),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         child: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.white, Colors.grey.shade50],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image section
//                 Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.file(
//                       File(product.imagePath),
//                       height: 80,
//                       width: 80,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) => Container(
//                         height: 80,
//                         width: 80,
//                         color: Colors.grey.shade200,
//                         child: const Icon(
//                           Icons.broken_image,
//                           size: 40,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 // Details section
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product.name,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black87,
//                           letterSpacing: 0.5,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'Stock: ${product.stock}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: Colors.blue.shade200),
//                             ),
//                             child: Text(
//                               product.category.name,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.blue.shade700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Sale Price',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               Text(
//                                 '₹${product.salePrice}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Purchase Price',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               Text(
//                                 '₹${product.purchasePrice}',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Popup Menu
//                 PopupMenuButton<String>(
//                   icon: Icon(
//                     Icons.more_vert,
//                     color: Colors.grey.shade600,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 8,
//                   onSelected: (value) async {
//                     if (value == 'edit') {
//                       showAddProductBottomSheet(
//                         context,
//                         existingProduct: product,
//                         productKey: index,
//                       );
//                     } else if (value == 'delete') {
//                       final confirm = await showDialog<bool>(
//                         context: context,
//                         builder: (context) => AlertDialog(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),  
//                           title: const Text(    
//                             'Delete Product',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           content: const Text(
//                             'Are you sure you want to delete this product?',
//                             style: TextStyle(color: Colors.black54),
//                           ), 
//                           actions: [
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(false),
//                               child: const Text(
//                                 'Cancel',
//                                 style: TextStyle(color: Colors.grey),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () => Navigator.of(context).pop(true),
//                               child: const Text(
//                                 'Delete',
//                                 style: TextStyle(color: Colors.red),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                       if (confirm == true) {
//                         try {
//                           await ProductDB.deleteProduct(index);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: const Text(
//                                 'Product deleted successfully!',
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                               backgroundColor: Colors.green,
//                               behavior: SnackBarBehavior.floating,
//                               margin: const EdgeInsets.all(20),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                           );
//                         } catch (e) {
//                           final errorMessage = e.toString();
//                           if (errorMessage.contains(
//                               'Cannot delete product because it is part of existing sales')) {
//                             await showDialog(
//                               context: context,
//                               builder: (context) => AlertDialog(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 title: const Text(
//                                   'Cannot Delete Product',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.w700,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 content: const Text(
//                                   'This product cannot be deleted because it is part of existing sales records.',
//                                   style: TextStyle(color: Colors.black54),
//                                 ),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(),
//                                     child: const Text(
//                                       'OK',
//                                       style: TextStyle(color: Colors.blue),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'Failed to delete product: $errorMessage',
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                                 backgroundColor: Colors.red,
//                                 behavior: SnackBarBehavior.floating,
//                                 margin: const EdgeInsets.all(20),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                               ),
//                             );
//                           }
//                         }
//                       }
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'edit',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.edit, size: 20, color: Colors.blue),
//                           SizedBox(width: 8),
//                           Text('Edit'),
//                         ],
//                       ),
//                     ),
//                     PopupMenuItem(
//                       value: 'delete',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.delete, size: 20, color: Colors.red),
//                           SizedBox(width: 8),
//                           Text('Delete'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }                           

import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/listing/items/widgets/cards/widgets/product_listing_screen_card_product_actions_menu.dart';
import 'package:cream_ventory/screen/listing/items/widgets/cards/widgets/product_listing_screen_card_product_details.dart';
import 'package:cream_ventory/screen/listing/items/widgets/cards/widgets/product_listing_screen_card_product_image.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/screen/detailing/product/product_detailing_screen.dart';
   
class ItemCard extends StatelessWidget {
  final ProductModel product;
  final String index;


  const ItemCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsPage(product: product),
        ),
      ),
      child: Card(
        elevation: 5,
        shadowColor: Colors.grey.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductImage(imagePath: product.imagePath),
                const SizedBox(width: 16),
                Expanded(child: ProductDetails(product: product)),
                ProductActionsMenu(product: product, index: index),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
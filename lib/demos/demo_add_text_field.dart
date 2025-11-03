
// import 'package:cream_ventery/screen/items/screen/products/widgets/category_dropdown.dart';
// import 'package:cream_ventery/utils/product/add_product_logics.dart';
// import 'package:cream_ventery/widgets/text_field.dart';
// import 'package:flutter/material.dart';

// class TextFields extends StatelessWidget {
//   const TextFields({
//     super.key,
//     required this.logic,
//   });

//   final AddProductLogic logic;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(height: 20),
//         DropDown(),
//         SizedBox(height: 20),
//         CustomTextField(
//           labelText: 'Product Name',
//           controller:  logic.nameController,
//           errorText:  logic.nameError,
//         ),
//         SizedBox(height: 20),
//         CustomTextField(
//           labelText: 'Stock',
//           controller: logic.stockController,
//           keyboardType:TextInputType.number,
//           errorText: logic.stockError,
//         ),
//         SizedBox(height: 20),
//         CustomTextField(
//           labelText: 'Sale Price',
//           controller: logic.salePriceController,
//           keyboardType:TextInputType.number,
//           errorText: logic.salePriceError,
//         ),
//         SizedBox(height: 20),
//         CustomTextField(
//           labelText: 'Purchase Price',
//           controller: logic.purchasePriceController,
//           keyboardType:TextInputType.number,
//           errorText: logic.purchasePriceError,
//         ),
//       ],
//     );
//   }
// }
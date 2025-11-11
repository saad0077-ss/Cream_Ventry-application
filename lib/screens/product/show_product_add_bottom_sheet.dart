import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/product/product_add_bottom_sheet.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:flutter/material.dart';

void showAddProductBottomSheet(
  BuildContext context, {
  ProductModel? existingProduct,
  String? productKey,
}) {
  showModalBottomSheet(
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    context: context,
    builder: (context) => Container(
      decoration: BoxDecoration(
        gradient: AppTheme.appGradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: AddProductBottomSheet(
        existingProduct: existingProduct,
        productKey: productKey,
      ),
    ),
  );
}
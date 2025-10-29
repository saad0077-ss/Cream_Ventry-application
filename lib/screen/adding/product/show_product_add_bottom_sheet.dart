import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/adding/product/product_add_bottom_sheet.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
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
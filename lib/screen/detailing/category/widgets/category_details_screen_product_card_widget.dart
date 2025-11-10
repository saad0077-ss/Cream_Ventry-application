// lib/screens/category/widgets/product_card_widget.dart
import 'package:cream_ventory/screen/detailing/category/widgets/category_details_screen_product_image.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductModel product;
  final double screenWidth;
  const ProductCardWidget({super.key, required this.product, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:  EdgeInsets.only(bottom: 16.h),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding:  EdgeInsets.all(16.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageWidget(product: product),
             SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,   
                children: [
                  Text(product.name, style: AppTextStyles.bold18.copyWith(fontSize: 18, color: Colors.black87)),
                   SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _info('Stock', product.stock.toString(), Colors.green[700]!),
                      _info('Sale Price', '₹${product.salePrice.toStringAsFixed(2)}', Colors.blue[700]!),
                    ],
                  ),
                   SizedBox(height: 8.h),
                  _info('Purchase Price', '₹${product.purchasePrice.toStringAsFixed(2)}', Colors.black87),
                ],
              ),
            ),
          ],
        ),
      ), 
    );
  }

  Widget _info(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.textBold.copyWith(fontSize: 16, color: color)),
      ],
    );
  }
}
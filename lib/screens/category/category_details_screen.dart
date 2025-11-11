// lib/screens/category/category_details_page.dart
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/screens/category/widgets/category_detailing_screen_image_widget.dart';
import 'package:cream_ventory/screens/category/widgets/category_details_screen_info_box_widget.dart';
import 'package:cream_ventory/screens/category/widgets/category_details_screen_product_card_widget.dart';
import 'package:cream_ventory/core/theme/theme.dart';
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/core/utils/category/category_details_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CategoryDetailsPage extends StatefulWidget {
  final CategoryModel category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  final utils = CategoryDetailsUtils();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: utils.buildAppBar(context, widget.category, _handleMenuAction),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Column(
          children: [
            _buildCategoryCard(screenWidth),
             SizedBox(height: 8.h),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value) {
    utils.handleMenuAction(context, widget.category, value);
  }

  Widget _buildCategoryCard(double screenWidth) {
    return Card(
      margin:  EdgeInsets.all(16.r),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding:  EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryImageWidget(category: widget.category),
                 SizedBox(width: 20.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description:', style: AppTextStyles.bold18.copyWith(fontSize: 18, color: Colors.black87)),
                       SizedBox(height: 4.h),
                      Text(
                        widget.category.discription.isEmpty ? 'No description available' : widget.category.discription,
                        style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
             SizedBox(height: 20.h),
            ValueListenableBuilder<List<ProductModel>>(
              valueListenable: ProductDB.productNotifier,
              builder: (context, productList, _) {
                final categoryProducts = productList.where((p) => p.category.id == widget.category.id).toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InfoBoxWidget(label: 'Category Name', value: widget.category.name, screenWidth: screenWidth),
                    InfoBoxWidget(label: 'No. of Products', value: categoryProducts.length.toString(), screenWidth: screenWidth),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() { 
    return Expanded(
      child: ValueListenableBuilder<List<ProductModel>>(
        valueListenable: ProductDB.productNotifier,
        builder: (context, productList, _) {
          final categoryProducts = productList.where((p) => p.category.id == widget.category.id).toList();
          if (categoryProducts.isEmpty) {
            return Center(
              child: Text("No products in this category.", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600])),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              return ProductCardWidget(product: categoryProducts[index], screenWidth: MediaQuery.of(context).size.width);
            },
          );
        },
      ),
    );
  }
}
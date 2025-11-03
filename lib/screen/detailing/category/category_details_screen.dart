// lib/screens/category/category_details_page.dart
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/detailing/category/widgets/category_detailing_screen_image_widget.dart';
import 'package:cream_ventory/screen/detailing/category/widgets/category_details_screen_info_box_widget.dart';
import 'package:cream_ventory/screen/detailing/category/widgets/category_details_screen_product_card_widget.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:cream_ventory/utils/detailing/category_details_screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
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
            const SizedBox(height: 8),
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
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [Colors.white, Colors.grey[50]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryImageWidget(category: widget.category),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description:', style: AppTextStyles.bold18.copyWith(fontSize: 18, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(
                        widget.category.discription.isEmpty ? 'No description available' : widget.category.discription,
                        style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
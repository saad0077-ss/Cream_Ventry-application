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
  bool _isDescriptionExpanded = false;

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
      margin: EdgeInsets.all(16.r),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CategoryImageWidget(category: widget.category),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 20.r,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Description',
                            style: AppTextStyles.bold18.copyWith(
                              fontSize: 18,
                              color: Colors.blue.shade700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedCrossFade(
                            firstChild: Text(
                              widget.category.discription.isEmpty
                                  ? 'No description available'
                                  : widget.category.discription,
                              style: AppTextStyles.w500.copyWith(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            secondChild: Text(
                              widget.category.discription.isEmpty
                                  ? 'No description available'
                                  : widget.category.discription,
                              style: AppTextStyles.w500.copyWith(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            crossFadeState: _isDescriptionExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                          if (widget.category.discription.length > 100)
                            GestureDetector(
                              onTap: () => setState(() =>
                                  _isDescriptionExpanded =
                                      !_isDescriptionExpanded),
                              child: Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isDescriptionExpanded
                                          ? 'Show less'
                                          : 'Read more',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      _isDescriptionExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: Colors.blue.shade700,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.shade300,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            ValueListenableBuilder<List<ProductModel>>(
              valueListenable: ProductDB.productNotifier,
              builder: (context, productList, _) {
                final categoryProducts = productList
                    .where((p) => p.category.id == widget.category.id)
                    .toList();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: InfoBoxWidget(
                        label: 'Category Name',
                        value: widget.category.name,
                        screenWidth: screenWidth,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: InfoBoxWidget(
                        label: 'No. of Products',
                        value: categoryProducts.length.toString(),
                        screenWidth: screenWidth,
                      ),
                    ),
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
          final categoryProducts = productList
              .where((p) => p.category.id == widget.category.id)
              .toList();
          if (categoryProducts.isEmpty) {
            return Center(
              child: Text(
                "No products in this category.",
                style: AppTextStyles.w500.copyWith(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: categoryProducts.length,
            itemBuilder: (context, index) {
              return ProductCardWidget(
                product: categoryProducts[index],
                screenWidth: MediaQuery.of(context).size.width,
              );
            },
          );    
        },
      ),
    );
  }
}

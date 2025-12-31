// lib/screens/category/category_details_page.dart
// ignore_for_file: deprecated_member_use

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
  final ScrollController _scrollController = ScrollController();
  bool _showStickyHeader = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show sticky header when scrolled past 200 pixels
    if (_scrollController.offset > 200 && !_showStickyHeader) {
      setState(() => _showStickyHeader = true); 
    } else if (_scrollController.offset <= 200 && _showStickyHeader) {
      setState(() => _showStickyHeader = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: utils.buildAppBar(context, widget.category, _handleMenuAction),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Stack(
          children: [
            ValueListenableBuilder<List<ProductModel>>(
              valueListenable: ProductDB.productNotifier,
              builder: (context, productList, _) {
                final categoryProducts = productList
                    .where((p) => p.category.id == widget.category.id)
                    .toList();

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildCategoryCard(screenWidth, categoryProducts),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 8.h),
                    ),
                    categoryProducts.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: Text(
                                "No products in this category.",
                                style: AppTextStyles.w500.copyWith(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return ProductCardWidget(
                                    product: categoryProducts[index],
                                    screenWidth: screenWidth,
                                  );
                                },
                                childCount: categoryProducts.length,
                              ),
                            ),
                          ),
                  ],
                );
              },
            ),
            // Sticky Header
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showStickyHeader ? 0 : -100,
              left: 0,
              right: 0,
              child: _buildStickyHeader(screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String value) {
    utils.handleMenuAction(context, widget.category, value);
  }

  Widget _buildStickyHeader(double screenWidth) {

    final bool isDesktop = screenWidth >= 1024;
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: ProductDB.productNotifier,
      builder: (context, productList, _) {
        final categoryProducts = productList
            .where((p) => p.category.id == widget.category.id)
            .toList();

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.blue.shade50.withOpacity(0.5),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.blue.shade100.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              // Animated Image Container with Glow Effect
              Container( 
                width: isDesktop ? 80 : 60,  
                height: isDesktop ? 60.h : 56.h, 
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r), 
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400.withOpacity(0.3),
                      Colors.purple.shade300.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(3.r),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13.r),
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11.r),
                    child: CategoryImageWidget(category: widget.category),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // Content with Enhanced Styling
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.category.name,
                            style: AppTextStyles.bold18.copyWith(
                              fontSize: 17,
                              color: Colors.black87,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 14.r,
                          color: Colors.blue.shade600,
                        ), 
                        SizedBox(width: 5.w),
                        Text(
                          categoryProducts.length <= 1 ? 'Product' : 'Products',
                          style: AppTextStyles.w500.copyWith(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration( 
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.blue.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),  
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '${categoryProducts.length}',
                            style: AppTextStyles.bold18.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Optional: Add a subtle indicator
              Container(
                width: isDesktop ? 7 : 4.w, 
                height: isDesktop ? 60 : 40.h,
                decoration: BoxDecoration( 
                  gradient: LinearGradient( 
                    colors: [
                      Colors.blue.shade400,
                      Colors.purple.shade300,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
      double screenWidth, List<ProductModel> categoryProducts) {
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
            Row(
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
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/category/sample_category.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/screen/adding/category/add_category_bottom_sheet.dart';
import 'package:cream_ventory/themes/app_theme/theme.dart';
import 'package:cream_ventory/themes/font_helper/font_helper.dart';
import 'package:flutter/material.dart';

class CategoryDetailsPage extends StatefulWidget {
  final CategoryModel category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  // Check if the category is a sample by comparing its ID with SampleCategories
  bool _isSampleCategory() {
    return SampleCategories.samples.any((sample) => sample.id == widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;             
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.name.toUpperCase(),
          style: AppTextStyles.bold20.copyWith(
            fontSize: 24,
            color: Colors.black87,
            letterSpacing: 0.5,
            fontFamily: 'Audiowide',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87, size: 28),
            onSelected: (value) {
              if (_isSampleCategory()) {
                _showSampleCategoryAlert(context, value);
                return;
              }
              if (value == 'edit') {
                _editCategory(context);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit', style: AppTextStyles.w500.copyWith(fontSize: 16)),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: AppTextStyles.w500.copyWith(color: Colors.red[400], fontSize: 16)),
              ),
            ],
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFD6E6F2), // Soft blue-gray (matches ScreenHome)
                Color(0xFF7BE7F0), // Subtle cyan (matches ScreenHome)
              ],
              stops: [0.0, 1.0], // Smooth transition for app bar
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.appGradient),
        child: Column(
          children: [
            // Category Details Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 6,
              shadowColor: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.category.isAsset
                                ? Image.asset(
                                    widget.category.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                                  )
                                : File(widget.category.imagePath).existsSync()
                                    ? Image.file(
                                        File(widget.category.imagePath),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                                      )
                                    : _buildErrorIcon(),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description:',
                                style: AppTextStyles.bold18.copyWith(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.category.discription.isEmpty
                                    ? 'No description available'
                                    : widget.category.discription,
                                style: AppTextStyles.w500.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Info Boxes
                    ValueListenableBuilder<List<ProductModel>>(
                      valueListenable: ProductDB.productNotifier,
                      builder: (context, productList, _) {
                        final categoryProducts = productList
                            .where((product) => product.category.id == widget.category.id)
                            .toList();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoBox('Category Name', widget.category.name, screenWidth),
                            _infoBox('No. of Products', categoryProducts.length.toString(), screenWidth),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product List
            Expanded(
              child: ValueListenableBuilder<List<ProductModel>>(
                valueListenable: ProductDB.productNotifier,
                builder: (context, productList, _) {
                  final categoryProducts = productList
                      .where((product) => product.category.id == widget.category.id)
                      .toList();
                  if (categoryProducts.isEmpty) {
                    return Center(
                      child: Text(
                        "No products in this category.",
                        style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600]),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: categoryProducts.length,
                    itemBuilder: (context, index) {
                      final product = categoryProducts[index];
                      return _buildItemCard(product, screenWidth);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.w500.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: screenWidth * 0.4,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            value,
            style: AppTextStyles.bold13.copyWith(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ProductModel product, double screenWidth) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.isAsset
                    ? Image.asset(
                        product.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                      )
                    : File(product.imagePath).existsSync()
                        ? Image.file(
                            File(product.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
                          )
                        : _buildErrorIcon(),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.bold18.copyWith(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildProductInfo('Stock', product.stock.toString(), Colors.green[700]!),
                      _buildProductInfo('Sale Price', '₹${product.salePrice.toStringAsFixed(2)}', Colors.blue[700]!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildProductInfo('Purchase Price', '₹${product.purchasePrice.toStringAsFixed(2)}', Colors.black87),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfo(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.w500.copyWith(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.textBold.copyWith(
            fontSize: 16,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          size: 40,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _showSampleCategoryAlert(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Cannot $action Sample Category",
            style: AppTextStyles.bold18.copyWith(color: Colors.black87),
          ),
          content: Text(
            "Sample categories cannot be ${action == 'edit' ? 'edited' : 'deleted'}.",
            style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "OK",
                style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.blue[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editCategory(BuildContext context) {
    AddCategoryBottomSheet.show(
      context,
      categoryToEdit: widget.category,
      isEditing: true,
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final categoryName = widget.category.name;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Delete Category",
            style: AppTextStyles.bold18.copyWith(color: Colors.black87),
          ),
          content: Text(
            "Are you sure you want to delete the category '$categoryName'?",
            style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteCategory(context);
              },
              child: Text(
                "Delete",
                style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.red[400]),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCategory(BuildContext context) async {
    // Check if the category is a sample
    if (_isSampleCategory()) {
      _showSampleCategoryAlert(context, 'delete');
      return;
    }

    // Check if the category key is null
    if (widget.category.key == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error: Unable to delete category due to invalid key.",
            style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      await CategoryDB.deleteCategory(widget.category.key!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Category deleted successfully",
            style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error deleting category: $e",
            style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ), 
      );
    }
  }
}
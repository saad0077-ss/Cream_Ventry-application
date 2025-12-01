// lib/screens/category/utils/category_details_utils.dart
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/sample_category.dart';
import 'package:cream_ventory/screens/category/add_category_bottom_sheet.dart';
import 'package:cream_ventory/screens/category/widgets/category_custom_dialog_box.dart'; // Your dialogs
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CategoryDetailsUtils {
  bool _isSampleCategory(CategoryModel category) {
    final sampleNames = SampleCategories.samples.map((s) => s.name.toLowerCase()).toSet();
    final isNameMatch = sampleNames.contains(category.name.toLowerCase());
    final isIdMatch = SampleCategories.samples.any((s) => s.id == category.id);
    return isNameMatch || isIdMatch;
  }

  AppBar buildAppBar(BuildContext context, CategoryModel category, Function(String) onMenuSelected) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        category.name.toUpperCase(),
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
        // PREMIUM POPUP MENU BUTTON
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: PopupMenuButton<String>(
            // Beautiful gradient icon
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6EE2F5), Color(0xFF6454F0)],
                ),
                borderRadius: BorderRadius.circular(10 ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 26),
            ),
            offset: const Offset(0, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 20,
            shadowColor: Colors.black.withOpacity(0.25),
            color: Colors.white.withOpacity(0.97),
            surfaceTintColor: Colors.transparent,

            itemBuilder: (context) => [
              // Edit Item
              PopupMenuItem(
                value: 'edit',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Edit Category',
                      style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Delete Item
              PopupMenuItem(
                value: 'delete',
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Delete Category',
                      style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ],

            onSelected: (value) {
              // Early protection for sample categories
              if (_isSampleCategory(category)) {
                CategoryDialogs.showSampleCategoryAlert(context: context, action: value);
                return;
              }
              onMenuSelected(value);
            },
          ),
        ),
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD6E6F2), Color(0xFF7BE7F0)],
          ),
        ),
      ),
    );
  }

  void handleMenuAction(BuildContext context, CategoryModel category, String value) {
    // This is now only called for non-sample categories
    if (value == 'edit') {
      _editCategory(context, category);
    } else if (value == 'delete') {
      CategoryDialogs.showDeleteConfirmationDialog(
        context: context,
        categoryName: category.name,
        onConfirm: () => _deleteCategory(context, category),
      );
    }
  }

  void _editCategory(BuildContext context, CategoryModel category) {
    AddCategoryBottomSheet.show(context, categoryToEdit: category, isEditing: true);
  }

  Future<void> _deleteCategory(BuildContext context, CategoryModel category) async {
    if (category.key == null) {
      _showError(context, "Invalid category key");
      return;
    }

    // Check if category has products
    final products = await ProductDB.getProductsByCategory(category.key!);
    if (products.isNotEmpty) {
      CategoryDialogs.showCategoryHasProductsAlert(context: context, categoryName: category.name);
      return;
    }

    try {
      await CategoryDB.deleteCategory(category.key!);
      _showSuccess(context, "Category '${category.name}' deleted successfully");
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error deleting category: $e");
      _showError(context, "Failed to delete category");
    }
  }

  // Snackbar Helpers 
  void _showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
        backgroundColor: Colors.red.shade600,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
      ),
    );
  }
}
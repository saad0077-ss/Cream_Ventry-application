// lib/screens/category/utils/category_details_utils.dart
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/sample_category.dart';
import 'package:cream_ventory/screens/category/add_category_bottom_sheet.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CategoryDetailsUtils {
  bool _isSampleCategory(CategoryModel category) {
    return SampleCategories.samples.any((sample) => sample.id == category.id);
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
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black87, size: 28),
          onSelected: (value) => onMenuSelected(value),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit', style: AppTextStyles.w500.copyWith(fontSize: 16))),
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
            colors: [Color(0xFFD6E6F2), Color(0xFF7BE7F0)],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  void handleMenuAction(BuildContext context, CategoryModel category, String value) {
    if (_isSampleCategory(category)) {
      _showSampleCategoryAlert(context, value);
      return;
    }
    if (value == 'edit') {
      _editCategory(context, category);
    } else if (value == 'delete') {
      _showDeleteConfirmationDialog(context, category);
    }
  }

  void _showSampleCategoryAlert(BuildContext context, String action) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF9E6), Color(0xFFFFE5B4)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with circular background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 48,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                "Cannot ${action == 'edit' ? 'Edit' : 'Delete'}",
                textAlign: TextAlign.center,
                style: AppTextStyles.bold18.copyWith(
                  fontSize: 22,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Content
              Text(
                "Sample categories are protected and cannot be ${action == 'edit' ? 'edited' : 'deleted'}.",
                textAlign: TextAlign.center,
                style: AppTextStyles.w500.copyWith(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.orange.withOpacity(0.5),
                  ),
                  child: Text(
                    "Got It",
                    style: AppTextStyles.w500.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editCategory(BuildContext context, CategoryModel category) {
    AddCategoryBottomSheet.show(context, categoryToEdit: category, isEditing: true);
  }

  void _showDeleteConfirmationDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 10,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with circular background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 48,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                "Delete Category",
                textAlign: TextAlign.center,
                style: AppTextStyles.bold18.copyWith(
                  fontSize: 22,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              // Content
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.w500.copyWith(
                    fontSize: 15,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: "Are you sure you want to delete "),
                    TextSpan(
                      text: "'${category.name}'",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const TextSpan(text: "? This action cannot be undone."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                      ),
                      child: Text(
                        "Cancel",
                        style: AppTextStyles.w500.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteCategory(context, category);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: Colors.red.withOpacity(0.5),
                      ),
                      child: Text(
                        "Delete",
                        style: AppTextStyles.w500.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, CategoryModel category) async {
    if (_isSampleCategory(category)) {
      _showSampleCategoryAlert(context, 'delete');
      return;
    }

    if (category.key == null) { 
      _showError(context, "Error: Unable to delete category due to invalid key.");
      return;
    }

    try {
      await CategoryDB.deleteCategory(category.key!);
      _showSuccess(context, "Category deleted successfully");

      if (context.mounted) {
        Navigator.pop(context); // Go back to category list
      }
    } catch (e) {
      debugPrint("Error deleting category: $e");
      _showError(context, "Failed to delete category");
    }
  }

  // Reusable Top Snackbar Helpers
  void _showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 40),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 40),
        backgroundColor: Colors.red.shade600,
      ),
    );
  } 
}
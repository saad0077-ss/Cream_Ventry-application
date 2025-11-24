// lib/screens/category/utils/category_details_utils.dart
import 'package:cream_ventory/core/constants/font_helper.dart';
import 'package:flutter/material.dart';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/sample_category.dart';
import 'package:cream_ventory/screens/category/add_category_bottom_sheet.dart';

class CategoryDetailsUtils {
  bool _isSampleCategory(CategoryModel category) {
    return SampleCategories.samples.any((sample) => sample.id == category.id);
  }

  AppBar buildAppBar(BuildContext context, CategoryModel category, Function(String) onMenuSelected) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 24), onPressed: () => Navigator.pop(context)),
      title: Text(
        category.name.toUpperCase(),
        style: AppTextStyles.bold20.copyWith(fontSize: 24, color: Colors.black87, letterSpacing: 0.5, fontFamily: 'Audiowide'),
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
            PopupMenuItem(value: 'delete', child: Text('Delete', style: AppTextStyles.w500.copyWith(color: Colors.red[400], fontSize: 16))),
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Cannot $action Sample Category", style: AppTextStyles.bold18.copyWith(color: Colors.black87)),
        content: Text("Sample categories cannot be ${action == 'edit' ? 'edited' : 'deleted'}.", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("OK", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.blue[600]))),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context, CategoryModel category) {
    AddCategoryBottomSheet.show(context, categoryToEdit: category, isEditing: true);
  }

  void _showDeleteConfirmationDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Category", style: AppTextStyles.bold18.copyWith(color: Colors.black87)),
        content: Text("Are you sure you want to delete the category '${category.name}'?", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.grey[600]))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCategory(context, category);
            },
            child: Text("Delete", style: AppTextStyles.w500.copyWith(fontSize: 16, color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, CategoryModel category) async {
    if (_isSampleCategory(category)) {
      _showSampleCategoryAlert(context, 'delete');
      return;
    }
    if (category.key == null) {
      _showSnackBar(context, "Error: Unable to delete category due to invalid key.", Colors.red[600]!);
      return;
    }
    try {
      await CategoryDB.deleteCategory(category.key!);
      _showSnackBar(context, "Category deleted successfully", Colors.green[600]!);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar(context, "Error deleting category: $e", Colors.red[600]!);
    }
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.w500.copyWith(fontSize: 14, color: Colors.white)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
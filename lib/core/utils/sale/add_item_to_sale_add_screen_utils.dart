// add_item_to_sale_utils.dart
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/sale_item_model.dart';
import 'package:flutter/material.dart';

// Import top_snackbar_flutter
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class AddItemToSaleUtils {
  /// Initializes the form for creating or editing a sale item
  static Future<void> initializeForm({
    required SaleItemModel? saleItem,
    required bool isEditMode,
    required TextEditingController quantityController,
    required TextEditingController rateController,
    required TextEditingController totalAmountController,
    required Function(String) onFormInitialized,
  }) async {
    try {
      await CategoryDB.loadSampleCategories();
      await ProductDB.initialize();
      await SaleItemDB.init();

      if (isEditMode && saleItem != null) {
        quantityController.text = saleItem.quantity.toString();
        rateController.text = saleItem.rate.toStringAsFixed(2);
        totalAmountController.text = saleItem.subtotal.toStringAsFixed(2);

        final product = await ProductDB.getProductById(saleItem.id);
        if (product != null) {
          onFormInitialized(product.category.id);
        }
      }
    } catch (error) {
      throw Exception('Failed to initialize form: $error');
    }
  }

  /// Calculates the total amount based on quantity and rate
  static void calculateTotal({
    required TextEditingController quantityController,
    required TextEditingController rateController,
    required TextEditingController totalAmountController,
  }) {
    double qty = double.tryParse(quantityController.text) ?? 0;
    double rate = double.tryParse(rateController.text) ?? 0;
    totalAmountController.text = (qty * rate).toStringAsFixed(2);
  }

  /// Loads products by category ID
  static Future<void> loadProductsByCategory({
    required String categoryId,
    required Function(List<ProductModel>, String) onProductsLoaded,
    required bool isEditMode,
    required TextEditingController rateController,
  }) async {
    try {
      final productList = await ProductDB.getProductsByCategory(categoryId);
      final category = await CategoryDB.getCategoryById(categoryId);
      onProductsLoaded(productList, category?.name ?? '');
      if (!isEditMode) {
        rateController.clear();
      }
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  /// Saves or updates a sale item
  static Future<void> saveSaleItem({
    required BuildContext context,
    required String? selectedProductId,
    required String? selectedCategoryName,
    required TextEditingController quantityController,
    required TextEditingController rateController,
    required TextEditingController totalAmountController,
    required List<ProductModel> products,
    required bool isEditMode,
    required SaleItemModel? saleItem,
    required bool saveAndNew,
    required VoidCallback clearForm,
    required VoidCallback popScreen,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    if (selectedProductId == null ||
        selectedCategoryName == null ||
        quantityController.text.isEmpty ||
        rateController.text.isEmpty) {
      _showError(context, 'Please fill all required fields');
      return;
    }

    final product = products.firstWhere((p) => p.id == selectedProductId);
    final quantity = int.tryParse(quantityController.text) ?? 0;

    if (quantity <= 0) {
      _showError(context, 'Please enter a valid quantity');
      return;
    }

    int originalQuantity = isEditMode ? saleItem!.quantity : 0;
    int quantityDifference = quantity - originalQuantity;

    if (quantityDifference > 0 && product.stock < quantityDifference) {
      _showError(context, 'Insufficient stock for ${product.name}');
      return;
    }

    try {
      // Restore stock if editing
      if (isEditMode) {
        await ProductDB.restockProduct(saleItem!.id, originalQuantity);
      }

      final newSaleItem = SaleItemModel(
        id: selectedProductId,
        productName: product.name,
        quantity: quantity,
        rate: double.parse(rateController.text),
        subtotal: double.parse(totalAmountController.text),
        categoryName: selectedCategoryName,
        index: isEditMode
            ? saleItem!.index
            : (await SaleItemDB.getSaleItems(userId: userId)).length + 1,
        imagePath: product.imagePath,
        userId: userId,
      );

      if (isEditMode) {
        await SaleItemDB.updateSaleItem(newSaleItem.id, newSaleItem);
      } else {
        await SaleItemDB.addSaleItem(newSaleItem);
      }

      _showSuccess(
        context,
        isEditMode
            ? 'Sale item updated successfully'
            : 'Sale item added successfully',
      );

      if (saveAndNew) {
        clearForm();
      } else {
        if (context.mounted) popScreen();
      }
    } catch (e) {
      debugPrint('Error saving sale item: $e');
      _showError(context, 'Failed to save item. Please try again.');
    }
  }

  // Success Toast
  static void _showSuccess(BuildContext context, String message) {
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

  // Error Toast
  static void _showError(BuildContext context, String message) {
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
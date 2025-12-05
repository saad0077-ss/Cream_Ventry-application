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
    required Function(String) onCategorySelected,
    required Function(String) onProductSelected,
  }) async {
    if (!isEditMode || saleItem == null) return;

    // Fill text fields
    quantityController.text = saleItem.quantity.toString();
    rateController.text = saleItem.rate.toStringAsFixed(2);
    totalAmountController.text = saleItem.subtotal.toStringAsFixed(2);

    final product = await ProductDB.getProductById(saleItem.id);
    if (product == null) return;

    // Step 1: Select category → triggers product loading
    onCategorySelected(product.category.id);

    // Step 2: Wait for products to load, THEN select product
    // This is the magic fix
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Small delay to ensure products are loaded
      await Future.delayed(const Duration(milliseconds: 100));

      // Now safely select the product
      onProductSelected(saleItem.id);
    });
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
      final category = CategoryDB.getCategoryById(categoryId);
      onProductsLoaded(productList, category?.name ?? '');
      if (!isEditMode) {
        rateController.clear();
      }
    } catch (error) {
      throw Exception('Failed to load products: $error');
    }
  }

  static Future<void> saveSaleItem({
    required BuildContext context,
    required String? selectedProductId,
    required String? selectedCategoryName,
    required TextEditingController quantityController,
    required TextEditingController rateController,
    required TextEditingController totalAmountController,
    required List<ProductModel> products,
    required bool isEditMode,
    required SaleItemModel? saleItem, // ← existing item when editing
    required int? editIndex, // ← NEW: pass the index from the list
    required bool saveAndNew,
    required VoidCallback clearForm,
    required VoidCallback popScreen,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    // Validation
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

    try {
      int stockDifference = quantity;

      if (isEditMode && saleItem != null) {
        // If editing: only check if the ADDITIONAL units are available
        stockDifference = quantity - saleItem.quantity;
      }

      if (stockDifference > 0 && product.stock < stockDifference) {
        _showError(
          context,
          'Insufficient stock for ${product.name}. Available: ${product.stock}, Required: $stockDifference more',
        );
        return;
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
        // Edit mode: adjust stock by the difference
        if (stockDifference > 0) {
          // Increasing quantity: deduct more stock
          await ProductDB.deductStock(selectedProductId, stockDifference);
          debugPrint('Edit: Deducted $stockDifference from ${product.name}');    
        } else if (stockDifference < 0) {
          // Decreasing quantity: restore stock
          await ProductDB.restockProduct(selectedProductId, -stockDifference);
          debugPrint('Edit: Restored ${-stockDifference} to ${product.name}');
        }
        // If stockDifference == 0, no stock change needed

        await SaleItemDB.updateItemAt(editIndex!, newSaleItem);
      } else {

        await SaleItemDB.addSaleItem(newSaleItem);
      }
      if (context.mounted) {
        _showSuccess(
          context,
          isEditMode ? 'Item updated successfully' : 'Item added successfully',
        );
      }

      if (saveAndNew) {
        clearForm();
      } else {
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      debugPrint('Save error: $e');
      _showError(context, 'Failed to save item: $e');
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

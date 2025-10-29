// add_item_to_sale_utils.dart
import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/sale/sale_item_model.dart';
import 'package:flutter/material.dart';

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

      if (isEditMode) {
        final item = saleItem!;
        quantityController.text = item.quantity.toString();
        rateController.text = item.rate.toStringAsFixed(2);
        totalAmountController.text = item.subtotal.toStringAsFixed(2);
        final product = await ProductDB.getProductById(item.id);
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

    if (selectedProductId != null &&
        selectedCategoryName != null &&
        quantityController.text.isNotEmpty &&
        rateController.text.isNotEmpty) {
      final product = products.firstWhere((p) => p.id == selectedProductId);
      final quantity = int.tryParse(quantityController.text) ?? 0;

      if (quantity <= 0) {
        _showSnackBar(context, 'Please enter a valid quantity', Colors.red);
        return;
      }

      int originalQuantity = isEditMode ? saleItem!.quantity : 0;
      int quantityDifference = quantity - originalQuantity;

      if (quantityDifference > 0 && product.stock < quantityDifference) {
        _showSnackBar(context, 'Insufficient stock for ${product.name}', Colors.red);
        return;
      }

      try {
        if (isEditMode) {
          await StockDB.restockProduct(saleItem!.id, originalQuantity);
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

        _showSnackBar(
          context,
          isEditMode ? 'Sale item updated successfully' : 'Sale item saved successfully',
          Colors.green,
        );

        if (saveAndNew) {
          clearForm();
        } else {
          popScreen();
        }
      } catch (e) {
        _showSnackBar(context, 'Error saving sale item: $e', Colors.red);
      }
    } else {
      _showSnackBar(context, 'Please fill all fields', Colors.red);
    }
  }

  /// Shows a snackbar with the specified message and color
  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
      ),
    );
  }
}
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProductDB {
  static const String _productBoxName = 'productBox';
  static ValueNotifier<List<ProductModel>> productNotifier = ValueNotifier([]);
  static Box<ProductModel>? _productBox;

  static Future<void> initialize() async {
    try {
      await _openProductBox();
      debugPrint(
        'ProductDB initialized with ${_productBox?.values.length} products',
      );
    } catch (e) {
      debugPrint('Error initializing ProductDB: $e');
      throw Exception('Failed to initialize ProductDB: $e');
    }
  }

  static Future<Box<ProductModel>> _openProductBox() async {
    if (_productBox == null || !_productBox!.isOpen) {
      _productBox = await Hive.openBox<ProductModel>(_productBoxName);
    }
    return _productBox!;
  }

  static Future<void> refreshProducts() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final productBox = await _openProductBox();
      var products = productBox.values
          .where((product) => product.userId == userId)
          .toList();
      productNotifier.value = products; 
      debugPrint('Refreshed products: ${products.length}');
    } catch (e) {
      debugPrint('Error refreshing products: $e');
      productNotifier.value = [];
      throw Exception('Failed to refresh products: $e');
    }
  }

  static Future<void> addProduct(ProductModel product) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      if (product.stock < 0 || product.purchasePrice < 0) {
        throw Exception('Invalid stock or purchase price');
      }

      final productBox = await _openProductBox();
      await productBox.put(product.id, product);
      debugPrint('Saved Product: ID=${product.id}, Name=${product.name}');
      if (product.stock > 0) {
        final openingStock = StockModel(
          id: const Uuid().v4(),
          productId: product.id,
          type: 'Opening Stock',
          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          quantity: product.stock,
          total: product.stock * product.purchasePrice,
          userId: userId,
        );
        await StockDB.addStock(openingStock);
        debugPrint(
          'Created Stock: StockID=${openingStock.id}, ProductID=${openingStock.productId}, Type=${openingStock.type}, Quantity=${openingStock.quantity}, Total=${openingStock.total}, ',
        );
      } else {
        debugPrint(
          'No stock entry created for Product ID=${product.id} (stock=0)',
        );
      }
      await refreshProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  static Future<bool> deleteProduct(String id) async {
    try {
      final productBox = await _openProductBox();
      final product = productBox.get(id);
      if (product == null) {
        debugPrint('Product ID $id not found');
        return false;
      }
      final isInSales = await SaleDB.isProductInSales(id);
      if (isInSales) {
        debugPrint('Cannot delete product ID $id: Referenced in sales');
        throw Exception(
          'Cannot delete product because it is part of existing sales',
        );
      }
      await productBox.delete(id);
      await refreshProducts();
      debugPrint('Product deleted: ID $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  static Future<bool> updateProduct(
    String id,
    ProductModel updatedProduct, {
    bool createStockTransaction = true,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final productBox = await _openProductBox();
      final oldProduct = productBox.get(id);
      if (oldProduct == null) {
        debugPrint('ID not found for update: $id');
        return false;
      }
      final stockChange = updatedProduct.stock - oldProduct.stock;
      await productBox.put(id, updatedProduct);
      if (createStockTransaction && stockChange != 0) {
        final stockingType = stockChange > 0 ? 'Stock Added' : 'Stock Removed';
        final stockAdjustment = StockModel(
          id: const Uuid().v4(),
          productId: updatedProduct.id,
          type: stockingType,
          date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          quantity: stockChange.abs().toInt(),
          total: stockChange.abs() * updatedProduct.purchasePrice,
          userId: userId,
        );
        await StockDB.addStock(stockAdjustment);
        debugPrint(
          'Stock Transaction Created: ProductID=${updatedProduct.id}, Type=$stockingType, Quantity=${stockAdjustment.quantity}, Total=${stockAdjustment.total}',
        );
      } else {
        debugPrint(
          'Product Updated (No Stock Change): ID=${updatedProduct.id}, Name=${updatedProduct.name}',
        );
      }
      await refreshProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  static Future<List<ProductModel>> getProductsByCategory(
    String categoryId,
  ) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final productBox = await _openProductBox();
      var products = productBox.values
          .where(
            (product) =>
                product.category.id == categoryId && product.userId == userId,
          )
          .toList();
      debugPrint(
        'Fetched ${products.length} products for category $categoryId',
      );
      return products;
    } catch (e) {
      debugPrint('Error fetching products by category: $e');
      return [];
    }
  }

  static Future<void> clearAllProducts() async {
    try {
      final productBox = await _openProductBox();
      await productBox.clear();
      debugPrint('Cleared all products');
      await refreshProducts();
    } catch (e) {
      debugPrint('Error clearing products: $e');
      throw Exception('Failed to clear products: $e');
    }
  }

  static Future<List<ProductModel>> getProducts() async {
    try {
      final box = await _openProductBox();
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      var products = box.values
          .where((product) => product.userId == userId)
          .toList();
      debugPrint('Fetched ${products.length} products in userId $userId ');
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  static Future<ProductModel?> getProductById(String id) async {
    final products = await getProducts();
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      return products.firstWhere((product) => product.id == id && product.userId == userId);
    } catch (e) {
      return null;
    }
  }

  static Future<ProductModel?> getProduct(String productId) async {
    try {
      final box = await _openProductBox();
      final product = box.get(productId);
      if (product == null) {
        debugPrint('Product not found: ID $productId');
        return null;
      }
      debugPrint('Fetched product: ID $productId');
      return product;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      return null;
    }
  }
}
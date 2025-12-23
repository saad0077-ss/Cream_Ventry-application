import 'package:cream_ventory/core/notification/app_notification_service.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/database/functions/stock_transaction_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/stock_transaction_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProductDB {
  static const String _productBoxName = 'productBox';

  static ValueNotifier<List<ProductModel>> productNotifier = ValueNotifier([]);
  static ValueNotifier<List<ProductModel>> lowStockNotifier = ValueNotifier([]);

  static Box<ProductModel>? _productBox;

  // ============================================
  // INITIALIZATION
  // ============================================

  static Future<void> initialize() async {
    try {
      await _openProductBox();
      _productBox?.listenable().addListener(_onProductBoxChange);

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

  static void _onProductBoxChange() {
    refreshProducts();
    _updateLowStockNotifier();
  }

  static void _updateLowStockNotifier() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    final productBox = await _openProductBox();

    final lowStockProducts = productBox.values
        .where((product) => product.userId == userId && product.stock < 5)
        .toList();

    if (!listEquals(lowStockNotifier.value, lowStockProducts)) {
      lowStockNotifier.value = lowStockProducts;
      debugPrint(
        'Low stock notifier updated with ${lowStockProducts.length} products',
      );

      // 🔔 Send notifications
      if (lowStockProducts.isNotEmpty) {
        await InventoryNotificationService.checkAndNotifyLowStock(
          lowStockProducts,
        );
      }
    }
  }

// Add these new methods at the end
  static Future<void> checkAndNotifyLowStock() async {
    final lowStockProducts = lowStockNotifier.value;
    if (lowStockProducts.isNotEmpty) {
      await InventoryNotificationService.checkAndNotifyLowStock(
        lowStockProducts,
      );
    }
  }

  static Future<void> showInventorySummary() async {
    final lowStockProducts = lowStockNotifier.value;
    if (lowStockProducts.isNotEmpty) {
      await InventoryNotificationService.showLowStockSummary(
        lowStockProducts,
      );
    }
  }

  // In product_db.dart - replace the existing deductStock method
  static Future<void> deductStock(
    String productId,
    int quantity, {
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw Exception('Deduct quantity must be a positive number');
    }

    // Use adjustStock with negative value
    await adjustStock(
      productId,
      -quantity, // Negative for deduction
      notes: notes ?? 'Stock deducted for sale',
    );
  }

  // ============================================
  // PRODUCT CRUD OPERATIONS
  // ============================================

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
      debugPrint(
        'Saved Product: ID=${product.id}, Name=${product.name}, Stock=${product.stock}',
      );

      // Create opening stock transaction if stock > 0
      if (product.stock > 0) {
        final openingStockTransaction = StockTransactionModel(
          id: const Uuid().v4(),
          productId: product.id,
          productName: product.name,
          type: StockTransactionType.openingStock,
          quantity: product.stock,
          pricePerUnit: product.purchasePrice,
          totalValue: product.stock * product.purchasePrice,
          date: DateFormat('dd MMM yyyy').format(DateTime.now()),
          userId: userId,
          notes: 'Initial stock for new product',
          stockAfterTransaction: product.stock,
        );

        await StockTransactionDB.addTransaction(openingStockTransaction);
        debugPrint('Opening stock transaction created for ${product.name}');
      }

      await refreshProducts();
    } catch (e) {
      debugPrint('Error adding product: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  static Future<bool> updateProduct(
    String id,
    ProductModel updatedProduct,
  ) async {
    try {
      final productBox = await _openProductBox();
      final oldProduct = productBox.get(id);
      if (oldProduct == null) {
        debugPrint('ID not found for update: $id');
        return false;
      }

      await productBox.put(id, updatedProduct);
      debugPrint(
        'Product Updated: ID=${updatedProduct.id}, Name=${updatedProduct.name}, Stock=${updatedProduct.stock}',
      );

      await refreshProducts();
      return true;
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw Exception('Failed to update product: $e');
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

  // ============================================
  // PRODUCT RETRIEVAL
  // ============================================

  static Future<List<ProductModel>> getProducts() async {
    try {
      final box = await _openProductBox();
      final user = await UserDB.getCurrentUser();
      final userId = user.id;
      var products =
          box.values.where((product) => product.userId == userId).toList();
      debugPrint('Fetched ${products.length} products in userId $userId');
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
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

  static Future<ProductModel?> getProductById(String id) async {
    final products = await getProducts();
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      return products.firstWhere(
        (product) => product.id == id && product.userId == userId,
      );
    } catch (e) {
      return null;
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

  // ============================================
  // STOCK MANAGEMENT OPERATIONS
  // ============================================

  static Future<void> reduceStockForSale(
    String productId,
    int quantitySold,
    TransactionType transactionType, {
    String? saleId,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    if (quantitySold <= 0) {
      throw Exception('Quantity sold must be a positive number');
    }

    try {
      final productBox = await _openProductBox();
      final product = productBox.get(productId);

      if (product == null) {
        debugPrint('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }

      if (product.stock < quantitySold) {
        debugPrint(
          'Insufficient stock for product $productId: ${product.stock} available, $quantitySold requested',
        );
        throw Exception('Insufficient stock for product $productId');
      }

      final newStock = product.stock - quantitySold;

      // Update product stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: newStock,
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId,
      );

      await productBox.put(productId, updatedProduct);

      // Create stock transaction
      final stockTransaction = StockTransactionModel(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.name,
        type: transactionType == TransactionType.sale
            ? StockTransactionType.sale
            : StockTransactionType.saleOrder,
        quantity: quantitySold,
        pricePerUnit: product.salePrice,
        totalValue: quantitySold * product.salePrice,
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        userId: userId,
        referenceId: saleId,
        stockAfterTransaction: newStock,
      );

      await StockTransactionDB.addTransaction(stockTransaction);

      final transactionTypeName =
          transactionType == TransactionType.sale ? 'Sale' : 'Sale Order';
      debugPrint(
        '$transactionTypeName completed for product $productId: Quantity $quantitySold, New Stock: $newStock',
      );

      await refreshProducts();
    } catch (e) {
      debugPrint('Error reducing stock for sale: $e');
      throw Exception('Failed to reduce stock for product $productId: $e');
    }
  }

  static Future<void> restockProduct(
    String productId,
    int quantity, {
    double? purchasePrice,
    String? notes,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    if (quantity <= 0) {
      throw Exception('Restock quantity must be a positive number');
    }

    try {
      final productBox = await _openProductBox();
      final product = productBox.get(productId);

      if (product == null) {
        debugPrint('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }

      final newStock = product.stock + quantity;
      final priceToUse = purchasePrice ?? product.purchasePrice;

      // Update product stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: newStock,
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId,
      );

      await productBox.put(productId, updatedProduct);

      // Create stock transaction
      final stockTransaction = StockTransactionModel(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.name,
        type: StockTransactionType.restock,
        quantity: quantity,
        pricePerUnit: priceToUse,
        totalValue: quantity * priceToUse,
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        userId: userId,
        notes: notes,
        stockAfterTransaction: newStock,
      );

      await StockTransactionDB.addTransaction(stockTransaction);

      if (newStock >= 5) {
        await InventoryNotificationService.clearProductNotification(productId);
        debugPrint(
            '🔔 Notification cleared for ${product.name} (stock now: $newStock)');
      }

      debugPrint(
        'Restock completed for product $productId: Quantity $quantity, New Stock: $newStock',
      );

      await refreshProducts();
    } catch (e) {
      debugPrint('Error restocking product: $e');
      throw Exception('Failed to restock product $productId: $e');
    }
  }

  static Future<void> cancelSale(
    String productId,
    int quantityToRestore, {
    String? saleId,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    if (quantityToRestore <= 0) {
      throw Exception('Quantity to restore must be a positive number');
    }

    try {
      final productBox = await _openProductBox();
      final product = productBox.get(productId);

      if (product == null) {
        debugPrint('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }

      final newStock = product.stock + quantityToRestore;

      // Restore product stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: newStock,
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId,
      );

      await productBox.put(productId, updatedProduct);

      // Create stock transaction for sale return
      final stockTransaction = StockTransactionModel(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.name,
        type: StockTransactionType.cancelled,
        quantity: quantityToRestore,
        pricePerUnit: product.salePrice,
        totalValue: quantityToRestore * product.salePrice,
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        userId: userId,
        referenceId: saleId,
        notes: 'Sale cancelled/returned',
        stockAfterTransaction: newStock,
      );

      await StockTransactionDB.addTransaction(stockTransaction);

      debugPrint(
        'Sale cancelled for product $productId: Quantity restored $quantityToRestore, New Stock: $newStock',
      );

      await refreshProducts();
    } catch (e) {
      debugPrint('Error cancelling sale: $e');
      throw Exception('Failed to cancel sale for product $productId: $e');
    }
  }

  // ============================================
  // LOW STOCK ALERTS
  // ============================================

  static Future<List<ProductModel>> getLowStockAlert({
    double threshold = 5.0,
    String? sortBy, // 'quantity' or 'date'
    String? category, // Optional category filter
    int? limit, // Optional limit for results
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    try {
      final productBox = await _openProductBox();
      var lowStockList = productBox.values
          .where(
            (product) => product.userId == userId && product.stock < threshold,
          )
          .toList();

      if (category != null && category.isNotEmpty) {
        lowStockList = lowStockList
            .where((product) => product.category.id == category)
            .toList();
      }

      if (sortBy != null) {
        if (sortBy == 'quantity') {
          lowStockList.sort((a, b) => a.stock.compareTo(b.stock));
        } else if (sortBy == 'date') {
          lowStockList.sort(
            (a, b) => DateFormat('dd MMM yyyy')
                .parse(a.creationDate)
                .compareTo(DateFormat('dd MMM yyyy').parse(b.creationDate)),
          );
        }
      }

      if (limit != null && limit > 0 && lowStockList.length > limit) {
        lowStockList = lowStockList.sublist(0, limit);
      }

      debugPrint(
        'Fetched ${lowStockList.length} low stock items (threshold: $threshold, sortBy: $sortBy, category: $category, limit: $limit)',
      );
      return lowStockList;
    } catch (e) {
      debugPrint('Error fetching low stock alert: $e');
      throw Exception('Failed to fetch low stock alert: $e');
    }
  }

  static Future<void> adjustStock(
    String productId,
    int quantityChange, {
    // positive for increase, negative for decrease
    double? pricePerUnit,
    String? notes,
  }) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    if (quantityChange == 0) {
      throw Exception('Quantity change cannot be zero');
    }

    try {
      final productBox = await _openProductBox();
      final product = productBox.get(productId);

      if (product == null) {
        debugPrint('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }

      // Calculate new stock
      final newStock = product.stock + quantityChange;

      if (newStock < 0) {
        debugPrint(
          'Adjustment would result in negative stock: ${product.stock} + $quantityChange = $newStock',
        );
        throw Exception('Insufficient stock for this adjustment');
      }

      // Update product stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: newStock,
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId,
      );

      await productBox.put(productId, updatedProduct);

      // Create stock transaction
      final priceToUse = pricePerUnit ??
          (quantityChange > 0 ? product.purchasePrice : product.salePrice);

      final stockTransaction = StockTransactionModel(
        id: const Uuid().v4(),
        productId: product.id,
        productName: product.name,
        type: StockTransactionType.adjustment,
        quantity: quantityChange.abs(),
        pricePerUnit: priceToUse,
        totalValue: quantityChange.abs() * priceToUse,
        date: DateFormat('dd MMM yyyy').format(DateTime.now()),
        userId: userId,
        notes: notes ??
            (quantityChange > 0
                ? 'Stock adjustment: Added ${quantityChange.abs()} units'
                : 'Stock adjustment: Removed ${quantityChange.abs()} units'),
        stockAfterTransaction: newStock,
      );

      await StockTransactionDB.addTransaction(stockTransaction);

      debugPrint(
        'Stock adjustment completed for product $productId: '
        'Change: $quantityChange, New Stock: $newStock',
      );

      await refreshProducts();
    } catch (e) {
      debugPrint('Error adjusting stock: $e');
      throw Exception('Failed to adjust stock for product $productId: $e');
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  static void dispose() {
    _productBox?.listenable().removeListener(_onProductBoxChange);
    _productBox?.close();
    _productBox = null;
    productNotifier.dispose();
    lowStockNotifier.dispose();
    debugPrint('ProductDB disposed');
  }

  static Future<void> forceCheckLowStock() async {
  final user = await UserDB.getCurrentUser();
  final userId = user.id;
  final productBox = await _openProductBox();

  final lowStockProducts = productBox.values
      .where((product) => product.userId == userId && product.stock < 5)
      .toList();

  debugPrint('🔍 Force check - Low stock products: ${lowStockProducts.length}');
  
  for (var product in lowStockProducts) {
    debugPrint('  - ${product.name}: ${product.stock} units');
  }

  lowStockNotifier.value = lowStockProducts;
  
  return;
}

/// Get low stock count without triggering notifications
static int getLowStockCount() {
  final count = lowStockNotifier.value.length;
  debugPrint('📊 Current low stock count: $count');
  return count;
}

/// Print all products with their stock levels
static Future<void> debugPrintAllProducts() async {
  final user = await UserDB.getCurrentUser();
  final userId = user.id;
  final productBox = await _openProductBox();
  
  final products = productBox.values
      .where((product) => product.userId == userId)
      .toList();

  debugPrint('📦 All Products (Total: ${products.length}):');
  for (var product in products) {
    final status = product.stock == 0 
        ? '🚨 OUT OF STOCK' 
        : product.stock < 5 
            ? '⚠️ LOW STOCK' 
            : '✅ OK';
    debugPrint('  $status ${product.name}: ${product.stock} units');
  }
}

/// Reset notification tracking (useful for testing)
static void resetNotificationTracking() {
  InventoryNotificationService.resetNotifiedProducts();
  debugPrint('🔄 Notification tracking reset');
}
}

import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class StockDB {
  static const String _stockBoxName = 'stockBox';
  static Box<StockModel>? _stockBox;
  static final ValueNotifier<List<StockModel>> stockListNotifier = ValueNotifier<List<StockModel>>([]);
  static final ValueNotifier<List<StockModel>> lowStockNotifier = ValueNotifier<List<StockModel>>([]);

  static Future<void> initialize() async {
    try {
      await _openStockBox();
      stockListNotifier.value = _stockBox?.values.toList() ?? [];
      _stockBox?.listenable().addListener(_onBoxChange);
      _log('StockDB initialized with ${_stockBox?.values.length} stocks');
    } catch (e) {
      _log('Error initializing StockDB: $e');
      throw Exception('Failed to initialize StockDB: $e');
    }
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  static void _onBoxChange() {
    final newList = _stockBox?.values.toList() ?? [];
    if (!listEquals(stockListNotifier.value, newList)) {
      stockListNotifier.value = newList;
      _updateLowStockNotifier();
      _log('Stock box changed, notifier updated with ${newList.length} items');
    }
  }

  static void _updateLowStockNotifier() async {
  final user = await UserDB.getCurrentUser();
  final userId = user.id;
  final stockBox = await _openStockBox();
  // Group stock entries by productId
  final productQuantities = <String, double>{};
  for (var stock in stockBox.values.where((s) => s.userId == userId)) {
    if (stock.type == 'Sale') { 
      productQuantities[stock.productId] = (productQuantities[stock.productId] ?? 0) - stock.quantity;
    } else {
      productQuantities[stock.productId] = (productQuantities[stock.productId] ?? 0) + stock.quantity;
    }
  }
  // Get productIds with total quantity < 5
  final lowStockProductIds = productQuantities.entries
      .where((entry) => entry.value < 5)
      .map((entry) => entry.key)
      .toList();
  // Create a list of StockModel for low-stock products
  final lowStockList = stockBox.values
      .where((stock) => lowStockProductIds.contains(stock.productId) && stock.userId == userId)
      .toList();
  if (!listEquals(lowStockNotifier.value, lowStockList)) {
    lowStockNotifier.value = lowStockList;
    _log('Low stock notifier updated with ${lowStockProductIds.length} products');
  }
}

  static Future<Box<StockModel>> _openStockBox() async {
    if (_stockBox == null || !_stockBox!.isOpen) {
      _stockBox = await Hive.openBox<StockModel>(_stockBoxName);
    }
    return _stockBox!;
  }

  static Future<void> addStock(StockModel stock) async {
    if (stock.id.isEmpty) {
      throw Exception('Stock ID cannot be empty');
    }
    try {
      final stockBox = await _openStockBox();
      await stockBox.put(stock.id, stock);
      _updateLowStockNotifier();
      _log('Stock added: ID ${stock.id}'); 
    } catch (e) {
      _log('Error adding stock: $e');
      throw Exception('Failed to add stock: $e');
    }
  }

  static Future<bool> updateStock(String id, StockModel stock) async {
    if (id.isEmpty) {
      throw Exception('Stock ID cannot be empty');
    }
    try {
      final stockBox = await _openStockBox();
      final existingStock = stockBox.get(id);
      if (existingStock == null) {
        _log('Stock ID not found for update: $id');
        return false;
      }
      await stockBox.put(id, stock);
      _updateLowStockNotifier();
      _log('Stock updated: ID $id');
      return true;
    } catch (e) {
      _log('Error updating stock: $e');
      throw Exception('Failed to update stock: $e');
    }
  }

  static Future<List<StockModel>> getStocksByProduct(String productId) async {
    try {
      final stockBox = await _openStockBox();
      var stocks = stockBox.values.where((stock) => stock.productId == productId).toList();
      _log('Fetched ${stocks.length} stocks for product $productId');
      return stocks;
    } catch (e) {
      _log('Error fetching stocks by product: $e');
      throw Exception('Failed to fetch stocks for product $productId: $e');
    }
  }

  static Future<bool> deleteStock(String id) async {
    try {
      final stockBox = await _openStockBox();
      final stock = stockBox.get(id);
      if (stock == null) {
        _log('Stock ID not found: $id');
        return false;
      }
      await stockBox.delete(id);
      _updateLowStockNotifier();
      _log('Stock deleted: ID $id');
      return true;
    } catch (e) {
      _log('Error deleting stock: $e');
      throw Exception('Failed to delete stock: $e');
    }
  }

  static Future<void> clearAllStocks() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final stockBox = await _openStockBox();
      await stockBox.clear();
      _log('Cleared all stocks');
      stockListNotifier.value = stockBox.values.where((stock)=>stock.userId == userId).toList();
      _updateLowStockNotifier();
    } catch (e) {
      _log('Error clearing stocks: $e');
      throw Exception('Failed to clear stocks: $e');
    }
  }

  static Future<List<StockModel>> getLowStockAlert({
    double threshold = 5.0,
    String? sortBy, // 'quantity' or 'date'
    String? category, // Optional category filter
    int? limit, // Optional limit for results
  }) async {                
    final user = await  UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final stockBox = await _openStockBox();
      var lowStockList = stockBox.values.where((stock) => stock.quantity < threshold).toList();
      if (category != null && category.isNotEmpty) {
        final products = await ProductDB.getProducts();

        final productIdsInCategory = products
            .where((product) => product.category.id == category && product.userId == userId )
            .map((product) => product.id)
            .toSet();
        lowStockList = lowStockList
            .where((stock) => productIdsInCategory.contains(stock.productId))
            .toList();
      }
      if (sortBy != null) {
        if (sortBy == 'quantity') {
          lowStockList.sort((a, b) => a.quantity.compareTo(b.quantity));
        } else if (sortBy == 'date') {
          lowStockList.sort((a, b) => DateFormat('dd/MM/yyyy')
              .parse(a.date)
              .compareTo(DateFormat('dd/MM/yyyy').parse(b.date)));
        }
      }
      if (limit != null && limit > 0 && lowStockList.length > limit) {
        lowStockList = lowStockList.sublist(0, limit);
      }
      _log('Fetched ${lowStockList.length} low stock items (threshold: $threshold, sortBy: $sortBy, category: $category, limit: $limit)');
      return lowStockList;
    } catch (e) {
      _log('Error fetching low stock alert: $e');
      throw Exception('Failed to fetch low stock alert: $e');
    }
  }

  static Future<void> reduceStockForSale(String productId, int quantitySold, TransactionType transactionType) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty');
    }
    if (quantitySold <= 0 || !quantitySold.isFinite) {
      throw Exception('Quantity sold must be a positive, finite number');
    }
    try {
      final product = await ProductDB.getProduct(productId);
      if (product == null) {
        _log('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }
      final stockBox = await _openStockBox();
      var stocks = stockBox.values
          .where((stock) => stock.productId == productId && stock.type != 'Sale' && stock.type != 'SaleOrder')
          .toList();
      if (stocks.isEmpty) {
        _log('No modifiable stock entries for product: $productId');
        throw Exception('No modifiable stock available for product $productId');
      }
      stocks.sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(a.date)
          .compareTo(DateFormat('dd/MM/yyyy').parse(b.date)));
      double totalQuantity = stocks.fold(0.0, (sum, stock) => sum + stock.quantity);
      if (totalQuantity < quantitySold) {
        _log('Insufficient stock for product $productId: $totalQuantity available, $quantitySold requested');
        throw Exception('Insufficient stock for product $productId');
      }
      int remainingToReduce = quantitySold;
      for (var stock in stocks) {
        if (remainingToReduce <= 0) break;
        int quantityToReduce = remainingToReduce >= stock.quantity
            ? stock.quantity
            : remainingToReduce;
        final updatedStock = StockModel(
          id: stock.id,
          productId: stock.productId,
          type: stock.type,
          date: stock.date,
          quantity: stock.quantity - quantityToReduce,
          total: stock.total,
          userId: userId
        );
        await stockBox.put(stock.id, updatedStock);
        remainingToReduce -= quantityToReduce;
        _log('Reduced stock ID ${stock.id} by $quantityToReduce, new quantity: ${updatedStock.quantity}');
        if (updatedStock.quantity == 0) {   
          await stockBox.delete(stock.id);
          _log('Deleted stock ID ${stock.id} as quantity reached 0');
        }
      }
      final saleTransaction = StockModel(
        id: const Uuid().v4(),
        productId: productId,
        type: transactionType == TransactionType.sale ? 'Sale' : 'SaleOrder',
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        quantity: quantitySold,
        total: quantitySold * product.salePrice,
        userId: userId
      );
      await addStock(saleTransaction);
      _log('Created ${transactionType == TransactionType.sale ? 'sale' : 'sale order'} transaction for product $productId: Quantity $quantitySold');
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: (product.stock - quantitySold).toInt(),
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset, 
        creationDate: product.creationDate,
        userId: userId
      );
      await ProductDB.updateProduct(
        productId,
        updatedProduct,
        createStockTransaction: false,
      );
      _log('Updated product stock for ID $productId: New stock ${updatedProduct.stock}');
    } catch (e) {
      _log('Error reducing stock for ${transactionType == TransactionType.sale ? 'sale' : 'sale order'}: $e');
      throw Exception('Failed to reduce stock for product $productId: $e');
    }
  }

  static Future<void> restockProduct(String productId, int quantity) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    if (productId.isEmpty) {
      throw Exception('Product ID cannot be empty'); 
    }
    if (quantity <= 0 || !quantity.isFinite) {
      throw Exception('Restock quantity must be a positive, finite number');
    }
    try {
      final product = await ProductDB.getProduct(productId);
      if (product == null) {
        _log('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }
      final purchaseTransaction = StockModel(
        id: const Uuid().v4(),
        productId: productId,
        type: 'Restock',
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        quantity: quantity,
        total: quantity * product.purchasePrice,
        userId: userId
      );
      await addStock(purchaseTransaction);
      _log('Created purchase transaction for product $productId: Quantity $quantity');
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: (product.stock + quantity).toInt(),
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId
      );
      await ProductDB.updateProduct(
        productId,
        updatedProduct,
      ); 
      _log('Updated product stock for ID $productId: New stock ${updatedProduct.stock}');
    } catch (e) {
      _log('Error restocking product: $e');
      throw Exception('Failed to restock product $productId: $e');
    }
  }
     
  static Future<void> cancelSaleOrder(String saleStockId) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    if (saleStockId.isEmpty) {
      throw Exception('Sale stock ID cannot be empty');
    }
    try {
      final stockBox = await _openStockBox();
      final saleStock = stockBox.get(saleStockId);
      if (saleStock == null || saleStock.type != 'Sale') {
        _log('Sale stock ID not found or not a sale transaction: $saleStockId');
        throw Exception('Sale stock ID $saleStockId does not exist or is not a sale transaction');
      }
      final productId = saleStock.productId;
      final quantityToRestock = saleStock.quantity;
      final product = await ProductDB.getProduct(productId);
      if (product == null) {
        _log('Product not found for ID: $productId');
        throw Exception('Product ID $productId does not exist');
      }
      // Delete the sale transaction
      await stockBox.delete(saleStockId);
      _log('Deleted sale transaction ID: $saleStockId');
      // Create a new purchase transaction to restock
      final restockTransaction = StockModel(
        id: const Uuid().v4(),
        productId: productId,
        type: 'Cancelled',                    
        date: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        quantity: quantityToRestock,
        total: quantityToRestock * product.purchasePrice,
        userId: userId
      );
      await addStock(restockTransaction);
      _log('Created restock transaction for product $productId: Quantity $quantityToRestock');
      // Update product stock
      final updatedProduct = ProductModel(
        id: product.id,
        name: product.name,
        stock: (product.stock + quantityToRestock).toInt(),
        salePrice: product.salePrice,
        purchasePrice: product.purchasePrice,
        category: product.category,
        imagePath: product.imagePath,
        isAsset: product.isAsset,
        creationDate: product.creationDate,
        userId: userId
      );
      await ProductDB.updateProduct(
        productId,
        updatedProduct,
        createStockTransaction: false,
      );
      _log('Updated product stock for ID $productId: New stock ${updatedProduct.stock}');
      _updateLowStockNotifier();
    } catch (e) {
      _log('Error cancelling sale order: $e');
      throw Exception('Failed to cancel sale order for stock ID $saleStockId: $e');
    }
  }

  static void dispose() {
    _stockBox?.listenable().removeListener(_onBoxChange);
    _stockBox?.close();
    _stockBox = null;
    stockListNotifier.dispose();                    
    lowStockNotifier.dispose();
    _log('StockDB listener, box, and notifiers disposed');
  }
}
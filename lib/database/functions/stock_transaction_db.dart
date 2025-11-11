import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/stock_transaction_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';

class StockTransactionDB {
  static const String _boxName = 'stockTransactionBox';
  static Box<StockTransactionModel>? _box;
  
  static ValueNotifier<List<StockTransactionModel>> transactionNotifier = 
      ValueNotifier([]);

  // ============================================
  // INITIALIZATION  
  // ============================================

  static Future<void> initialize() async {
    try {
      await _openBox();
      _box?.listenable().addListener(_onBoxChange);
      
      debugPrint(
        'StockTransactionDB initialized with ${_box?.values.length} transactions',
      );
    } catch (e) {
      debugPrint('Error initializing StockTransactionDB: $e');
      throw Exception('Failed to initialize StockTransactionDB: $e');
    }
  }

  static Future<Box<StockTransactionModel>> _openBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<StockTransactionModel>(_boxName);
    }
    return _box!;
  }

  static void _onBoxChange() {
    refreshTransactions();
  }

  static Future<void> refreshTransactions() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    
    try {
      final box = await _openBox();
      var transactions = box.values
          .where((txn) => txn.userId == userId)
          .toList()
        ..sort((a, b) => DateFormat('dd/MM/yyyy')
            .parse(b.date)
            .compareTo(DateFormat('dd/MM/yyyy').parse(a.date)));
      
      transactionNotifier.value = transactions;
      debugPrint('Refreshed ${transactions.length} stock transactions');
    } catch (e) {
      debugPrint('Error refreshing stock transactions: $e');
      transactionNotifier.value = [];
    }
  }

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  static Future<void> addTransaction(StockTransactionModel transaction) async {
    try {
      final box = await _openBox();
      await box.put(transaction.id, transaction);
      
      debugPrint(
        'Stock transaction added: ${transaction.typeDisplayName} - '
        'Product: ${transaction.productName}, Qty: ${transaction.quantity}'
      );
      
      await refreshTransactions();
    } catch (e) {
      debugPrint('Error adding stock transaction: $e');
      throw Exception('Failed to add stock transaction: $e');
    }
  }

  static Future<void> deleteTransaction(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
      
      debugPrint('Stock transaction deleted: $id');
      await refreshTransactions();
    } catch (e) {
      debugPrint('Error deleting stock transaction: $e');
      throw Exception('Failed to delete stock transaction: $e');
    }
  }

  static Future<void> clearAllTransactions() async {
    try {
      final box = await _openBox();
      await box.clear();
      debugPrint('Cleared all stock transactions');
      await refreshTransactions();
    } catch (e) {
      debugPrint('Error clearing stock transactions: $e');
      throw Exception('Failed to clear stock transactions: $e');
    }
  }

  // ============================================
  // RETRIEVAL OPERATIONS
  // ============================================

  static Future<List<StockTransactionModel>> getTransactionsByProduct(
    String productId
  ) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    
    try {
      final box = await _openBox();
      var transactions = box.values
          .where((txn) => 
              txn.productId == productId && 
              txn.userId == userId
          )
          .toList()
        ..sort((a, b) => DateFormat('dd/MM/yyyy')
            .parse(b.date)
            .compareTo(DateFormat('dd/MM/yyyy').parse(a.date)));
      
      debugPrint(
        'Fetched ${transactions.length} transactions for product $productId'
      );
      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions by product: $e');
      return [];
    }
  }

  static Future<List<StockTransactionModel>> getTransactionsByType(
    StockTransactionType type
  ) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    
    try {
      final box = await _openBox();
      var transactions = box.values
          .where((txn) => 
              txn.type == type && 
              txn.userId == userId
          )
          .toList()
        ..sort((a, b) => DateFormat('dd/MM/yyyy')
            .parse(b.date)
            .compareTo(DateFormat('dd/MM/yyyy').parse(a.date)));
      
      debugPrint('Fetched ${transactions.length} transactions of type $type');
      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions by type: $e');
      return [];
    }
  }

  static Future<List<StockTransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
    {String? productId}
  ) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    
    try {
      final box = await _openBox();
      var transactions = box.values
          .where((txn) {
            if (txn.userId != userId) return false;
            if (productId != null && txn.productId != productId) return false;
            
            final txnDate = DateFormat('dd/MM/yyyy').parse(txn.date);
            return txnDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                   txnDate.isBefore(endDate.add(const Duration(days: 1)));
          })
          .toList()
        ..sort((a, b) => DateFormat('dd/MM/yyyy')
            .parse(b.date)
            .compareTo(DateFormat('dd/MM/yyyy').parse(a.date)));
      
      debugPrint(
        'Fetched ${transactions.length} transactions between '
        '${DateFormat('dd/MM/yyyy').format(startDate)} and '
        '${DateFormat('dd/MM/yyyy').format(endDate)}'
      );
      return transactions;
    } catch (e) {
      debugPrint('Error fetching transactions by date range: $e');
      return [];
    }
  }

  static Future<StockTransactionModel?> getTransaction(String id) async {
    try {
      final box = await _openBox();
      return box.get(id);
    } catch (e) {
      debugPrint('Error fetching transaction: $e');
      return null;
    }
  }

  // ============================================
  // ANALYTICS
  // ============================================

  static Future<Map<String, dynamic>> getProductStockSummary(
    String productId
  ) async {
    final transactions = await getTransactionsByProduct(productId);
    
    int totalIn = 0;
    int totalOut = 0;
    double totalValueIn = 0;
    double totalValueOut = 0;
    
    for (var txn in transactions) {
      if (txn.isStockIncrease) {
        totalIn += txn.quantity;
        totalValueIn += txn.totalValue;
      } else {
        totalOut += txn.quantity;
        totalValueOut += txn.totalValue;
      }
    }
    
    return {
      'totalIn': totalIn,
      'totalOut': totalOut,
      'totalValueIn': totalValueIn,
      'totalValueOut': totalValueOut,
      'netQuantity': totalIn - totalOut,
      'transactionCount': transactions.length,
    };
  }

  // ============================================
  // CLEANUP
  // ============================================

  static void dispose() {
    _box?.listenable().removeListener(_onBoxChange);
    _box?.close();
    _box = null;
    transactionNotifier.dispose();
    debugPrint('StockTransactionDB disposed');
  }
}
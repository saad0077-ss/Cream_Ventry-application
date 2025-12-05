import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SaleDB {
  static const String boxName = 'sales';
  static final ValueNotifier<List<SaleModel>> saleNotifier = ValueNotifier([]);

  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<SaleModel>(boxName);
      }
      debugPrint('Hive box "$boxName" initialized');
    } catch (e) {
      debugPrint('Error initializing SaleDB: $e');
      throw Exception('Failed to initialize SaleDB: $e');
    }
  }

  static Future<void> addSale(SaleModel sale) async {
    try {
      if (sale.id.isEmpty) {
        throw Exception('Sale ID cannot be empty');
      }
      if (sale.items.isEmpty) {
        throw Exception('Sale must contain at least one item');
      }
      
      final box = Hive.box<SaleModel>(boxName);
      
      // ONLY reduce stock for regular SALES or CLOSED sale orders
      // For OPEN sale orders, stock should NOT be reduced yet
      bool shouldReduceStock = sale.transactionType == TransactionType.sale || 
                               (sale.transactionType == TransactionType.saleOrder && 
                                sale.status == SaleStatus.closed);
      
      if (shouldReduceStock) {
        // Validate each item's productId and reduce stock
        for (var item in sale.items) {
          final product = await ProductDB.getProduct(item.id);
          if (product == null) {
            debugPrint('Product not found for SaleItem ID: ${item.id}');
            throw Exception('Product ID ${item.id} not found');
          }
          
          // Reduce stock with the appropriate transaction type
          await ProductDB.reduceStockForSale(
            item.id,
            item.quantity,
            sale.transactionType!,
          );
          
          debugPrint(
            'Reduced stock for Product ID: ${item.id}, Quantity: ${item.quantity}, TransactionType: ${sale.transactionType}',
          );
        }
      } else {
        debugPrint(
          'Skipped stock reduction for OPEN sale order ID: ${sale.id}',
        );
      }
      
      await box.put(sale.id, sale);
      _updateNotifier();
      
      // Update party balance if customerName is provided
      if (sale.customerName != null && sale.customerName!.isNotEmpty) {
        await PartyDb.updateBalanceAfterSale(sale);
      }
      
      debugPrint(
        'Sale added successfully with ID: ${sale.id}, TransactionType: ${sale.transactionType}, Status: ${sale.status}',
      );
    } catch (e) {
      debugPrint('Error adding sale ${sale.id}: $e');
      throw Exception('Failed to add sale ${sale.id}: $e');
    }
  }

  static Future<List<SaleModel>> getSales() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    await init();
    try {
      final box = Hive.box<SaleModel>(boxName);
      final sales = box.values.where((sale) => sale.userId == userId).toList();
      debugPrint('Fetched ${sales.length} sales for user Id: $userId');
      return sales;
    } catch (e) {
      debugPrint('Error fetching sales: $e');
      return [];
    }
  }

  static Future<SaleModel?> getSaleById(String id) async {
    try {
      final box = Hive.box<SaleModel>(boxName);
      final sale = box.get(id);
      if (sale == null) {
        debugPrint('Sale not found: $id');
        return null;
      }
      debugPrint('Retrieved sale: $id');
      return sale;
    } catch (e) {
      debugPrint('Error fetching sale with ID: $id, error: $e');
      return null;
    }
  }

  static void _updateNotifier() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = Hive.box<SaleModel>(boxName);
      final sales = box.values.where((sale) => sale.userId == userId).toList();
      saleNotifier.value = sales;
      debugPrint('Notifier updated with ${saleNotifier.value.length} sales');
    });
  }

  static ValueListenable<Box<SaleModel>> getListenable() {
    final box = Hive.box<SaleModel>(boxName);
    return box.listenable();
  }

  static Future<void> clearSales() async {
    try {
      final box = Hive.box<SaleModel>(boxName);
      await box.clear();
      debugPrint('Cleared all sales');
      _updateNotifier();
    } catch (e) {
      debugPrint('Error clearing sales: $e');
      throw Exception('Failed to clear sales: $e');
    }
  }

  static Future<int> getLatestInvoiceNumber() async {
    try {
      final sales = await getSales();
      if (sales.isEmpty) return 0;
      final invoiceNumbers = sales
          .map((sale) => int.tryParse(sale.invoiceNumber) ?? 0)
          .toList();
      return invoiceNumbers.reduce((a, b) => a > b ? a : b);
    } catch (e) {
      debugPrint('Error getting latest invoice number: $e');
      return 0;
    }
  }

  static Future<bool> updateSale(SaleModel sale) async {
    try {
      if (sale.id.isEmpty) throw Exception('Sale ID cannot be empty');
      if (sale.items.isEmpty) {
        throw Exception('Sale must contain at least one item');
      }

      final box = Hive.box<SaleModel>(boxName);
      final oldSale = box.get(sale.id);

      if (oldSale == null) {
        debugPrint('Sale with ID ${sale.id} not found');
        return false;
      }
 
      bool wasOpen = oldSale.status == SaleStatus.open;
      bool isNowClosed = sale.status == SaleStatus.closed;
      bool isNowCancelled = sale.status == SaleStatus.cancelled;
      bool isRegularSale = sale.transactionType == TransactionType.sale;

      // Stock adjustment logic:
      // 1. For regular SALES: always adjust stock on edit (if not cancelled)
      // 2. For SALE ORDERS: only adjust when closing (open → closed)
      // 3. When CANCELLING: NO stock adjustment (never restock on cancel)
      bool shouldAdjustStock = false;
      
      if (isNowCancelled) {
        // Cancelling: NEVER adjust stock (no restocking)
        shouldAdjustStock = false;
        debugPrint('Cancelling sale/order - NO stock changes');
      } else if (isRegularSale) {
        // Regular sales: adjust if items changed
        shouldAdjustStock = oldSale.items.length != sale.items.length || 
            !oldSale.items.every((oldItem) => 
                sale.items.any((newItem) => 
                    newItem.id == oldItem.id && 
                    newItem.quantity == oldItem.quantity));
      } else {
        // Sale orders: only adjust when closing (open → closed)
        shouldAdjustStock = isNowClosed && wasOpen;
      }

      if (shouldAdjustStock) {
        // Step 1: Restore old stock if it was already deducted
        if (!wasOpen || isRegularSale) {
          for (var oldItem in oldSale.items) {
            await ProductDB.restockProduct(oldItem.id, oldItem.quantity);
            debugPrint('Restored stock (edit): ${oldItem.id} x${oldItem.quantity}');
          }
        }

        // Step 2: Deduct stock for current items
        for (var item in sale.items) {
          final product = await ProductDB.getProduct(item.id);
          if (product == null) {
            throw Exception('Product ID ${item.id} not found');
          }

          await ProductDB.reduceStockForSale(
            item.id,  
            item.quantity,
            sale.transactionType!,
          );
          debugPrint('Deducted stock: ${item.id} x${item.quantity}');
        }
      } else {
        debugPrint('No stock adjustment needed - Status: ${sale.status}, Type: ${sale.transactionType}');
      }

      // Save the updated sale
      await box.put(sale.id, sale);
      _updateNotifier();

      // Update party balance
      if (sale.customerName != null && sale.customerName!.isNotEmpty) {
        await PartyDb.updateBalanceAfterSale(sale);
      }

      debugPrint('Updated sale with ID: ${sale.id}, Status: ${sale.status}');
      return true;
    } catch (e) {
      debugPrint('Error updating sale ${sale.id}: $e');
      rethrow;
    }
  }

  static Future<bool> isProductInSales(String productId) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await init();
      }
      final sales = saleNotifier.value.where((sale) => sale.userId == userId);
      for (var sale in sales) {
        for (var item in sale.items) {
          if (item.id == productId && item.userId == userId) {
            debugPrint('Product $productId found in sale ${sale.id}');
            return true;
          }
        }
      }
      debugPrint('Product $productId not found in any sales');
      return false;
    } catch (e) {
      debugPrint('Error checking product in sales: $e');
      throw Exception('Failed to check product in sales: $e');
    }
  }

  static Future<bool> deleteSale(String id) async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    try {
      final box = Hive.box<SaleModel>(boxName);
      final sale = box.get(id);
      if (sale == null) {
        debugPrint('Sale with ID $id not found');
        return false;
      }
      
      // Restore stock ONLY if:
      // 1. It's a regular SALE that was closed, OR
      // 2. It's a SALE ORDER that was closed
      // DO NOT restore for: open orders, cancelled orders/sales
      bool shouldRestock = sale.status == SaleStatus.closed;
      
      if (shouldRestock) {
        for (var item in sale.items) {
          await ProductDB.restockProduct(item.id, item.quantity);
          debugPrint('Restocked on delete: ${item.productName} x${item.quantity}');
        }
      } else {
        debugPrint('No restock on delete - sale status: ${sale.status} (${sale.status == SaleStatus.open ? "open" : sale.status == SaleStatus.cancelled ? "cancelled" : "unknown"})');
      }
      
      // Delete the sale
      await box.delete(id);
      
      // Delete any sale order that references the deleted sale
      final salesToDelete = box.values
          .where((s) => s.convertedToSaleId == id && s.userId == userId)
          .toList();
      for (var s in salesToDelete) {
        await box.delete(s.id);
        debugPrint('Deleted sale order with ID: ${s.id}');
      }
      
      _updateNotifier();
      
      // Update party balance if customerName is provided
      if (sale.customerName != null && sale.customerName!.isNotEmpty) {
        await PartyDb.updateBalanceAfterSale(sale);
      }
      
      debugPrint('Deleted sale with ID: $id');
      return true;
    } catch (e) {
      debugPrint('Error deleting sale $id: $e');
      throw Exception('Failed to delete sale $id: $e');
    }
  }

  static Future<void> refreshSales() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;

    try {
      final box = Hive.box<SaleModel>(boxName);
      final sales = box.values
          .where((sale) => sale.userId == userId)
          .toList();
      
      saleNotifier.value = sales;
      debugPrint('Refreshed ${sales.length} sales for user $userId');
    } catch (e) {
      debugPrint('Error reading sales: $e'); 
      saleNotifier.value = [];
    }
  }
}
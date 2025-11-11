import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/models/sale_item_model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SaleItemDB {
  static const String boxName = 'saleItems';
  static final ValueNotifier<List<SaleItemModel>> saleItemNotifier =
      ValueNotifier([]);

  // Initialize the Hive box
  static Future<void> init() async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<SaleItemModel>(boxName);
      }
      debugPrint(
        'Hive box "$boxName" initialized with ${Hive.box<SaleItemModel>(boxName).length} sale items',
      );
    } catch (e) {
      debugPrint('Error initializing SaleItemDB: $e');
      throw Exception('Failed to initialize SaleItemDB: $e');
    }
  }

  // Add a sale item
  static Future<void> addSaleItem(SaleItemModel item) async {
    try {
      final box = Hive.box<SaleItemModel>(boxName);
    
      // Validate product exists
      final product = await ProductDB.getProduct(item.id);
      if (product == null) {
        debugPrint('Product not found for SaleItem ID: ${item.id}');
        throw Exception('Product ID ${item.id} not found');
      }
      await box.put(item.id, item);
      _updateNotifier();
      debugPrint(
        'Added SaleItem: ID=${item.id}, ProductName=${item.productName}',
      );
    } catch (e) {
      debugPrint('Error adding sale item: $e');
      throw Exception('Failed to add sale item: $e');
    }
  }

  // Update an existing sale item
  static Future<bool> updateSaleItem(String id, SaleItemModel item) async {
    try {
      final box = Hive.box<SaleItemModel>(boxName);
      final existingItem = box.get(id);
      if (existingItem == null) {
        debugPrint('SaleItem not found: $id');
        return false;
      }
      // Validate product exists
      final product = await ProductDB.getProduct(item.id);
      if (product == null) {
        debugPrint('Product not found for SaleItem ID: ${item.id}');
        throw Exception('Product ID ${item.id} not found');
      }
      await box.put(id, item);
      debugPrint('Updated SaleItem: ID=$id, ProductName=${item.productName}');
      return true;
    } catch (e) {
      debugPrint('Error updating sale item $id: $e');
      throw Exception('Failed to update sale item $id: $e');
    }
  }
    
  // Get all sale items
  static Future<List<SaleItemModel>> getSaleItems({String? userId}) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<SaleItemModel>(boxName);
      }
      final box = Hive.box<SaleItemModel>(boxName);
      final items = box.values.toList();

      // Filter by userId if provided, otherwise fetch all items
      final filteredItems = userId != null
          ? items.where((item) => item.userId == userId).toList()
          : items;

      debugPrint(
        'Fetched ${filteredItems.length} sale items for userId: ${userId ?? "all"}',
      );
      return filteredItems;
    } catch (e) {
      debugPrint('Error fetching sale items: $e');
      throw Exception('Failed to fetch sale items: $e');
    }
  }

  // Update the notifier with the latest sale items
  static void _updateNotifier() async {
    final user = await UserDB.getCurrentUser();
    final userId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = Hive.box<SaleItemModel>(boxName);
      final items = box.values
          .where((saleItem) => saleItem.userId == userId)
          .toList();
      saleItemNotifier.value = items;
      debugPrint(
        'Notifier updated with ${saleItemNotifier.value.length} sale items',
      );
    });
  }

  // Clear all sale items
  static Future<void> clearSaleItems() async {
    try {
      final box = Hive.box<SaleItemModel>(boxName);
      await box.clear();
      debugPrint('Cleared all sale items');
      _updateNotifier();
    } catch (e) {
      debugPrint('Error clearing sale items: $e');
      throw Exception('Failed to clear sale items: $e');
    }
  }

  // Load items for editing
  static Future<void> loadItemsForEdit(List<SaleItemModel> items) async {
    try {
      // Validate all items
      for (var item in items) {
        final product = await ProductDB.getProduct(item.id);
        if (product == null) {
          throw Exception('Product ID ${item.id} not found');
        }
      }
      await clearSaleItems(); // Clear all items
      final box = Hive.box<SaleItemModel>(boxName);
      for (var item in items) {
        await box.put(item.id, item);
        debugPrint(
          'Loaded SaleItem: ID=${item.id}, ProductName=${item.productName}',
        );
      }
      _updateNotifier();
      debugPrint('Loaded ${items.length} sale items for editing');
    } catch (e) {
      debugPrint('Error loading sale items for edit: $e');
      throw Exception('Failed to load sale items for edit: $e');
    }
  }
}

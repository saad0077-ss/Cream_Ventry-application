import 'package:cream_ventory/core/notification/notification_setup.dart';
import 'package:cream_ventory/core/notification/app_notification_service.dart';
import 'package:cream_ventory/database/functions/category_db.dart';
import 'package:cream_ventory/database/functions/party_db.dart';
import 'package:cream_ventory/database/functions/payment_db.dart';
import 'package:cream_ventory/database/functions/product_db.dart';
import 'package:cream_ventory/database/functions/user_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_db.dart';
import 'package:cream_ventory/database/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/database/functions/stock_transaction_db.dart';
import 'package:cream_ventory/models/expence_model.dart';
import 'package:cream_ventory/models/expense_category_model.dart';
import 'package:cream_ventory/models/category_model.dart';
import 'package:cream_ventory/models/product_model.dart';
import 'package:cream_ventory/models/stock_transaction_model.dart';
import 'package:cream_ventory/models/party_model.dart';
import 'package:cream_ventory/models/payment_in_model.dart';
import 'package:cream_ventory/models/payment_out_model.dart';
import 'package:cream_ventory/models/sale_item_model.dart';
import 'package:cream_ventory/models/sale_model.dart';
import 'package:cream_ventory/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

class HiveInitialization {
  static DateTime? _lastCheckDate;
  static Timer? _midnightTimer;

  /// Initialize Hive, register adapters, open boxes, initialize databases, and set up notifications
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await _registerAdapters();
    await _openBoxes();
    await _initializeDatabases();
    
    // Initialize notifications (includes startup checks)
    await _initializeNotifications();
    
    // ✅ Set up midnight check for new day
    _setupMidnightCheck();
  }

  /// Register all Hive adapters
  static Future<void> _registerAdapters() async {
    if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(ProductModelAdapter().typeId)) {
      Hive.registerAdapter(ProductModelAdapter());
    }
    if (!Hive.isAdapterRegistered(PartyModelAdapter().typeId)) {
      Hive.registerAdapter(PartyModelAdapter());
    }
    if (!Hive.isAdapterRegistered(ExpenseModelAdapter().typeId)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(BilledItemAdapter().typeId)) {
      Hive.registerAdapter(BilledItemAdapter());
    }
    if (!Hive.isAdapterRegistered(ExpenseCategoryModelAdapter().typeId)) {
      Hive.registerAdapter(ExpenseCategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleItemModelAdapter().typeId)) {
      Hive.registerAdapter(SaleItemModelAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleModelAdapter().typeId)) {
      Hive.registerAdapter(SaleModelAdapter());
    }
    if (!Hive.isAdapterRegistered(PaymentInModelAdapter().typeId)) {
      Hive.registerAdapter(PaymentInModelAdapter());
    }
    if (!Hive.isAdapterRegistered(PaymentOutModelAdapter().typeId)) {
      Hive.registerAdapter(PaymentOutModelAdapter());
    }
    if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(SaleStatusAdapter().typeId)) {
      Hive.registerAdapter(SaleStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(StockTransactionModelAdapter().typeId)) {
      Hive.registerAdapter(StockTransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(StockTransactionTypeAdapter().typeId)) {
      Hive.registerAdapter(StockTransactionTypeAdapter());
    }
  }

  /// Open all Hive boxes
  static Future<void> _openBoxes() async {
    await Hive.openBox<UserModel>('userBox');
    await Hive.openBox<ProductModel>('productBox');
    await Hive.openBox<CategoryModel>('categoryBox');
    await Hive.openBox<PartyModel>('partyBox');
    await Hive.openBox<ExpenseModel>('expenseBox');
    await Hive.openBox<ExpenseCategoryModel>('expenseCategoryBox');
    await Hive.openBox<SaleItemModel>('saleItems');
    await Hive.openBox<SaleModel>('sales');
    await Hive.openBox<PaymentInModel>('payments');
    await Hive.openBox<PaymentOutModel>('paymentOutBox');
    await Hive.openBox<StockTransactionModel>('stockTransactionBox');
  }

  /// Initialize all database instances
  static Future<void> _initializeDatabases() async {
    CategoryDB.initAndLoad();
    ProductDB.initialize(); 
    PartyDb.init();
    UserDB.initializeHive();
    SaleItemDB.init();
    SaleDB.init();
    PaymentInDb.init();
    PaymentOutDb.init();
    StockTransactionDB.initialize();
  }

  /// Initialize notification services (includes startup checks)
  static Future<void> _initializeNotifications() async {
    try {
      // This function:
      // 1. Initializes notification service
      // 2. Checks low stock products
      // 3. Checks due dates
      // 4. Schedules daily notifications at 9 AM
      await NotificationSetup.initialize(); 
      
      // Store current date for midnight check
      _lastCheckDate = DateTime.now();
      
      debugPrint('✅ Notifications initialized with startup checks completed'); 
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// ✅ NEW: Set up midnight check to detect new day
  static void _setupMidnightCheck() {
    // Cancel existing timer if any
    _midnightTimer?.cancel();

    // Calculate time until next midnight
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    debugPrint('⏰ Next midnight check scheduled in ${durationUntilMidnight.inHours}h ${durationUntilMidnight.inMinutes % 60}m');

    // Schedule first check at midnight
    _midnightTimer = Timer(durationUntilMidnight, () {
      _onNewDay();
      
      // After first midnight, check every 1 minute to detect day change
      // (More reliable than calculating next midnight each time)
      _midnightTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
        _checkIfNewDay();
      });
    });

    debugPrint('✅ Midnight check system initialized');
  }

  /// ✅ Check if a new day has started
  static void _checkIfNewDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastCheckDate == null) {
      _lastCheckDate = today;
      return;
    }

    final lastCheck = DateTime(
      _lastCheckDate!.year,
      _lastCheckDate!.month,
      _lastCheckDate!.day,
    );

    // If date changed, trigger new day actions
    if (today.isAfter(lastCheck)) {
      debugPrint('📅 New day detected: $today (previous: $lastCheck)');
      _onNewDay();
      _lastCheckDate = today;
    }
  }

  /// ✅ Actions to perform when a new day starts
  static Future<void> _onNewDay() async {
    try {
      debugPrint('🌅 NEW DAY STARTED - Running checks...');
      
      // Reset notification tracking   
      InventoryNotificationService.resetNotifiedSales(); 
      InventoryNotificationService.resetNotifiedProducts();
      debugPrint('✅ Notification tracking reset');
      
      // Check due dates for new day
      final sales = await SaleDB.getSales();
      await InventoryNotificationService.checkAndNotifyDueSales(sales);
      debugPrint('✅ Due date check completed for new day');
      
      // Recheck low stock (in case stock was updated overnight)
      final lowStockProducts = ProductDB.lowStockNotifier.value;
      if (lowStockProducts.isNotEmpty) {
        await InventoryNotificationService.checkAndNotifyLowStock(
          lowStockProducts,
          lowStockThreshold: 5,
        );
        debugPrint('✅ Low stock check completed for new day');
      }
      
      debugPrint('🎉 NEW DAY CHECKS COMPLETED');
    } catch (e) {
      debugPrint('❌ Error in new day checks: $e');
    }
  }

  /// Cancel timers on app dispose
  static void dispose() {
    _midnightTimer?.cancel();
    debugPrint('🗑️ Midnight check timer cancelled');
  }
}
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
import 'package:hive_flutter/hive_flutter.dart';

class HiveInitialization {
  /// Initialize Hive, register adapters, open boxes, and initialize databases
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await _registerAdapters();
    await _openBoxes(); 
    _initializeDatabases();
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
  static void _initializeDatabases() {
    CategoryDB.initialize();
    ProductDB.initialize();
    PartyDb.init();
    UserDB.initializeHive();
    SaleItemDB.init();
    SaleDB.init();
    PaymentInDb.init();
    PaymentOutDb.init();
    StockTransactionDB.initialize();
  }
}
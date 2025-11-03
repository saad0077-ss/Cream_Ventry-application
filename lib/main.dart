import 'package:cream_ventory/db/functions/category_db.dart';
import 'package:cream_ventory/db/functions/party_db.dart';
import 'package:cream_ventory/db/functions/payment_db.dart';
import 'package:cream_ventory/db/functions/product_db.dart';
import 'package:cream_ventory/db/functions/user_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_db.dart';
import 'package:cream_ventory/db/functions/sale/sale_item_db.dart';
import 'package:cream_ventory/db/functions/stock_db.dart';
import 'package:cream_ventory/db/models/expence/expence_model.dart';
import 'package:cream_ventory/db/models/expence/expense_category_model.dart';
import 'package:cream_ventory/db/models/items/category/category_model.dart';
import 'package:cream_ventory/db/models/items/products/product_model.dart';
import 'package:cream_ventory/db/models/items/products/stock_model.dart';
import 'package:cream_ventory/db/models/parties/party_model.dart';
import 'package:cream_ventory/db/models/payment/payment_in_model.dart'; 
import 'package:cream_ventory/db/models/payment/payment_out_model.dart';
import 'package:cream_ventory/db/models/sale/sale_item_model.dart';
import 'package:cream_ventory/db/models/sale/sale_model.dart';
import 'package:cream_ventory/db/models/user/user_model.dart';
import 'package:cream_ventory/screen/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await registerHiveAdapters();
  await openHiveBoxes();
  initializeDatabases();
  runApp(const MyApp()); 
}

Future<void> registerHiveAdapters() async {
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
  if (!Hive.isAdapterRegistered(StockModelAdapter().typeId)) {
    Hive.registerAdapter(StockModelAdapter());
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
}

Future<void> openHiveBoxes() async {
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<ProductModel>('productBox');
  await Hive.openBox<CategoryModel>('categoryBox');                
  await Hive.openBox<PartyModel>('partyBox');    
  await Hive.openBox<ExpenseModel>('expenseBox');
  await Hive.openBox<ExpenseCategoryModel>('expenseCategoryBox');
  await Hive.openBox<StockModel>('stockBox');
  await Hive.openBox<SaleItemModel>('saleItems');
  await Hive.openBox<SaleModel>('sales'); 
  await Hive.openBox<PaymentInModel>('payments');
  await Hive.openBox<PaymentOutModel>('paymentOutBox');  
}  
 
void initializeDatabases() {          
  CategoryDB.initialize();    
  ProductDB.initialize();
  PartyDb.init(); 
  UserDB.initializeHive();
  StockDB.initialize();    
  SaleItemDB.init();
  SaleDB.init(); 
  PaymentInDb.init();
  PaymentOutDb.init();   
}    
  
class MyApp extends StatelessWidget {  
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),                                                                     
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        // showPerformanceOverlay: true, 
        debugShowCheckedModeBanner: false,     
         
        home: const ScreenSplash(),       
      ), 
    );
  }
}
   
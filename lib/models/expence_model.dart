import 'package:hive/hive.dart';

 part '../database/adapters/expence/expence_model.g.dart';

@HiveType(typeId: 3)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String invoiceNo;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  List<BilledItem> billedItems;

  @HiveField(5)
  String userId;


  ExpenseModel({
    required this.id,
    required this.invoiceNo,
    required this.category,
    required this.date,
    required this.billedItems,
    required this.userId,
  });
  factory ExpenseModel.create({
    required String invoiceNo,   
    required String category,
    required DateTime date,
    required List<BilledItem> billedItems,
    required String userId,
  }) {
    return ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      invoiceNo: invoiceNo,
      category: category,
      date: date,
      billedItems: billedItems,
      userId: userId,         
    );
  }

  double get totalAmount => billedItems.fold(
        0.0,
        (sum, item) => sum + item.amount,
      );

  @override
  String toString() {
    return 'ExpenseModel(id: $id, invoiceNo: $invoiceNo, category: $category, date: $date, totalAmount: $totalAmount , userId : $userId)';
  }
}

@HiveType(typeId: 4)
class BilledItem {
  @HiveField(0) 
  String name;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double rate;

  @HiveField(3)
  String userId;


  BilledItem({
    required this.name,
    required this.quantity,
    required this.rate,                
    required this.userId,
  });

  double get amount => quantity * rate;

  @override
  String toString() {
    return 'BilledItem(name: $name, quantity: $quantity, rate: $rate, amount: $amount userId: $userId)'; 
  }
} 
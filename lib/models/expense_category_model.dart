import 'package:hive/hive.dart';

part '../database/adapters/expence/expense_category_model.g.dart';

@HiveType(typeId: 7)
class ExpenseCategoryModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String userId; 


  ExpenseCategoryModel({
    required this.name,
    required this.userId,
  });
}
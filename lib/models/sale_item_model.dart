import 'package:hive/hive.dart';

part '../database/adapters/sale/sale_item_model.g.dart';

@HiveType(typeId: 11)
class SaleItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double rate;

  @HiveField(4)
  final double subtotal;

  @HiveField(5)
  final String categoryName;

  @HiveField(6)
  final int index;

  @HiveField(7)
  final String? imagePath;
  
  @HiveField(8)
  final String userId;

  SaleItemModel({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.rate,
    required this.subtotal,
    required this.categoryName,
    required this.index,
    this.imagePath,
    required this.userId
  });
}

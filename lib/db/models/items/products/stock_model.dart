import 'package:hive/hive.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 9)
class StockModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String date;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double total;

  @HiveField(6)
  final String userId;


  StockModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.date,
    required this.quantity,
    required this.total,
    required this.userId
  });
}
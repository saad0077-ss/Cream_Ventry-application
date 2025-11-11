import 'package:hive/hive.dart';
import 'package:cream_ventory/models/category_model.dart';

part '../database/adapters/items/products/product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int stock;

  @HiveField(2)
  final double salePrice;

  @HiveField(3)
  final double purchasePrice;

  @HiveField(4)
  final CategoryModel category;

  @HiveField(5)
  final String imagePath;

  @HiveField(6)
  final String id;

  @HiveField(7)
  final bool isAsset;

  @HiveField(8)
  final String creationDate;

  @HiveField(9)
  final String userId;


  ProductModel({
    required this.name,
    required this.stock,
    required this.salePrice,
    required this.purchasePrice,
    required this.category,
    required this.imagePath,
    required this.id,
    this.isAsset = false,
    required this.creationDate, 
    required this.userId
  });
}
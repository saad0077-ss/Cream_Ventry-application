import 'package:hive/hive.dart';

part '../database/adapters/items/category/category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String imagePath;

  @HiveField(3)
  bool isAsset;

  @HiveField(4)
  String discription;

  @HiveField(5)  
  String? userId;



  CategoryModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isAsset = false,
    required this.discription,
     this.userId,
  });

  @override 
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id ;
  @override
  int get hashCode => id.hashCode ;

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, imagePath: $imagePath, isAsset: $isAsset, discription: $discription, userId: $userId)';
}
// user_model.dart
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String username;

  @HiveField(3)
  final String password; 

  // Profile fields
  @HiveField(4)
  String? name;

  @HiveField(5)
  String? distributionName;

  @HiveField(6)
  String? phone;

  @HiveField(7)
  String? address;

  @HiveField(8)
  String? profileImagePath;

  UserModel({
    required this.id,
    required this.email,
    required this.password,
    required this.username,
    this.name,
    this.distributionName,
    this.phone,
    this.address,
    this.profileImagePath,
  });
}
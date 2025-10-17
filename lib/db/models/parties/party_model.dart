import 'package:hive/hive.dart';

part 'party_model.g.dart';

@HiveType(typeId: 5)
class PartyModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String contactNumber;

  @HiveField(3)
  double openingBalance;

  @HiveField(4)
  DateTime asOfDate;

  @HiveField(5)
  String billingAddress;

  @HiveField(6)
  String email;

  @HiveField(7)
  String paymentType;

  @HiveField(8)
  String imagePath;

  @HiveField(9)
  double partyBalance;

  @HiveField(10)
  String userId;


  PartyModel({
    required this.id,
    required this.name,
    required this.contactNumber,
    required this.openingBalance,
    required this.asOfDate,
    required this.billingAddress,
    required this.email,
    required this.paymentType,
    required this.imagePath,
    required this.partyBalance,
    required this.userId
  }); 


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyModel &&
          runtimeType == other.runtimeType &&
          id == other.id; // Compare by unique id

  @override
  int get hashCode => id.hashCode; // Use id for hashCode

}
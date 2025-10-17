import 'package:hive/hive.dart';

part 'payment_in_model.g.dart';

@HiveType(typeId: 12)
class PaymentInModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String receiptNo;

  @HiveField(2)
  String date;

  @HiveField(3)
  String? partyName;

  @HiveField(4)
  String? phoneNumber;

  @HiveField(5)
  double receivedAmount;

  @HiveField(6)
  String paymentType;

  @HiveField(7)
  String? note;

  @HiveField(8)
  String? imagePath;

  @HiveField(9)
  String userId;

  PaymentInModel({
    required this.id,
    required this.receiptNo,
    required this.date,
    this.partyName,  
    this.phoneNumber,
    required this.receivedAmount,
    required this.paymentType,
    this.note,
    this.imagePath,
    required this.userId
  });
}
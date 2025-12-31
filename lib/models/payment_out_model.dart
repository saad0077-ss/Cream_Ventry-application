import 'package:hive/hive.dart';

part '../database/adapters/payment/payment_out_model.g.dart';

@HiveType(typeId: 13)
class PaymentOutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String receiptNo;

  @HiveField(2)
  String date;

  @HiveField(3)
  String partyName;

  @HiveField(4)
  String phoneNumber;

  @HiveField(5)
  double paidAmount;
                   
  @HiveField(6)
  String paymentType;
   
  @HiveField(7)
  String? note;

  @HiveField(8) 
  String? imagePath; 

  @HiveField(9)
  String userId;

  @HiveField(10)  
  String? partyId; 

  PaymentOutModel({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.partyName,
    required this.phoneNumber,
    required this.paidAmount,
    required this.paymentType,
    this.note,
    this.imagePath,
    required this.userId,
    this.partyId,  
  });

  @override
  String toString() {
    return '====PaymentOutModel(id: $id, receiptNo: $receiptNo, date: $date, partyName: $partyName, partyId: $partyId, userId: $userId ====='
        'phoneNumber: $phoneNumber, paidAmount: $paidAmount, paymentType: $paymentType, '
        'note: $note, imagePath: $imagePath)';
  }
}
import 'package:hive/hive.dart';
import 'package:cream_ventory/models/sale_item_model.dart';

 part '../database/adapters/sale/sale_model.g.dart';

@HiveType(typeId: 15)
enum SaleStatus {
  @HiveField(0) 
  open,   

  @HiveField(1)
  closed,

  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 10)
class SaleModel {
  @HiveField(0)
  final String id; 

  @HiveField(1)
  final String invoiceNumber;

  @HiveField(2)
  final String date;

  @HiveField(3)
  final String? customerName;

  @HiveField(4)
  final List<SaleItemModel> items;

  @HiveField(5)
  final double total;

  @HiveField(6)
  final double receivedAmount;

  @HiveField(7)
  final double balanceDue;
   
  @HiveField(8)
  final String? dueDate;

  @HiveField(9)
  final TransactionType? transactionType;

  @HiveField(10)
  final SaleStatus status;

  @HiveField(11)
  final String? convertedToSaleId;

  @HiveField(12)
  final String userId;

  @HiveField(13) 
  final String? customerId;  



  SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customerName,
    required this.items,
    required this.total,
    required this.receivedAmount,
    required this.balanceDue,
    this.dueDate,
    this.transactionType,
    this.status = SaleStatus.open,
    this.convertedToSaleId,
    required this.userId,
    this.customerId
  });
}

@HiveType(typeId: 16)
enum TransactionType {
  @HiveField(0)
  sale,

  @HiveField(1)
  saleOrder,
}
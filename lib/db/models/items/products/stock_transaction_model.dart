import 'package:hive/hive.dart';

part 'stock_transaction_model.g.dart';

@HiveType(typeId: 18) // Use an appropriate typeId
class StockTransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final StockTransactionType type;

  @HiveField(4)
  final int quantity;

  @HiveField(5)          

  final double pricePerUnit;

  @HiveField(6)
  final double totalValue;

  @HiveField(7)
  final String date;

  @HiveField(8)
  final String userId;

  @HiveField(9)
  final String? referenceId; 

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final int stockAfterTransaction;

  StockTransactionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalValue,
    required this.date,
    required this.userId,
    this.referenceId,
    this.notes,
    required this.stockAfterTransaction,
  });

  // Helper method to get display name for transaction type
  String get typeDisplayName {
    switch (type) {
      case StockTransactionType.openingStock:
        return 'Opening Stock';
      case StockTransactionType.restock:
        return 'Restock';
      case StockTransactionType.sale:
        return 'Sale';
      case StockTransactionType.saleOrder:
        return 'Sale Order';
      case StockTransactionType.cancelled:
        return 'Sale Cancelled';
      case StockTransactionType.adjustment:
        return 'Stock Adjustment';
    }
  }

  // Helper to determine if transaction adds or removes stock
  bool get isStockIncrease {
    return type == StockTransactionType.openingStock ||
        type == StockTransactionType.restock ||
        type == StockTransactionType.cancelled;
  }
}

@HiveType(typeId: 17)
enum StockTransactionType {
  @HiveField(0)
  openingStock,
    
  @HiveField(1)
  restock,

  @HiveField(2)
  sale,

  @HiveField(3)
  saleOrder,

  @HiveField(4)
  cancelled,

  @HiveField(5)
  adjustment,
}
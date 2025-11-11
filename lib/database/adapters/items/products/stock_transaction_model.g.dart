// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../../models/stock_transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockTransactionModelAdapter extends TypeAdapter<StockTransactionModel> {
  @override
  final int typeId = 18;

  @override
  StockTransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockTransactionModel(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      type: fields[3] as StockTransactionType,
      quantity: fields[4] as int,
      pricePerUnit: fields[5] as double,
      totalValue: fields[6] as double,
      date: fields[7] as String,
      userId: fields[8] as String,
      referenceId: fields[9] as String?,
      notes: fields[10] as String?,
      stockAfterTransaction: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, StockTransactionModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.pricePerUnit)
      ..writeByte(6)
      ..write(obj.totalValue)
      ..writeByte(7)
      ..write(obj.date)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.referenceId)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.stockAfterTransaction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StockTransactionTypeAdapter extends TypeAdapter<StockTransactionType> {
  @override
  final int typeId = 17;

  @override
  StockTransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StockTransactionType.openingStock;
      case 1:
        return StockTransactionType.restock;
      case 2:
        return StockTransactionType.sale;
      case 3:
        return StockTransactionType.saleOrder;
      case 4:
        return StockTransactionType.cancelled;
      case 5:
        return StockTransactionType.adjustment;
      default:
        return StockTransactionType.openingStock;
    }
  }

  @override
  void write(BinaryWriter writer, StockTransactionType obj) {
    switch (obj) {
      case StockTransactionType.openingStock:
        writer.writeByte(0);
        break;
      case StockTransactionType.restock:
        writer.writeByte(1);
        break;
      case StockTransactionType.sale:
        writer.writeByte(2);
        break;
      case StockTransactionType.saleOrder:
        writer.writeByte(3);
        break;
      case StockTransactionType.cancelled:
        writer.writeByte(4);
        break;
      case StockTransactionType.adjustment:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

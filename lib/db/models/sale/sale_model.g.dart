// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleModelAdapter extends TypeAdapter<SaleModel> {
  @override
  final int typeId = 10;

  @override
  SaleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleModel(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      date: fields[2] as String,
      customerName: fields[3] as String?,
      items: (fields[4] as List).cast<SaleItemModel>(),
      total: fields[5] as double,
      receivedAmount: fields[6] as double,
      balanceDue: fields[7] as double,
      dueDate: fields[8] as String?,
      transactionType: fields[9] as TransactionType?,
      status: fields[10] as SaleStatus,
      convertedToSaleId: fields[11] as String?,
      userId: fields[12] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SaleModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.customerName)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.total)
      ..writeByte(6)
      ..write(obj.receivedAmount)
      ..writeByte(7)
      ..write(obj.balanceDue)
      ..writeByte(8)
      ..write(obj.dueDate)
      ..writeByte(9)
      ..write(obj.transactionType)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.convertedToSaleId)
      ..writeByte(12)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleStatusAdapter extends TypeAdapter<SaleStatus> {
  @override
  final int typeId = 15;

  @override
  SaleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SaleStatus.open;
      case 1:
        return SaleStatus.closed;
      case 2:
        return SaleStatus.cancelled;
      default:
        return SaleStatus.open;
    }
  }

  @override
  void write(BinaryWriter writer, SaleStatus obj) {
    switch (obj) {
      case SaleStatus.open:
        writer.writeByte(0);
        break;
      case SaleStatus.closed:
        writer.writeByte(1);
        break;
      case SaleStatus.cancelled:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 16;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.sale;
      case 1:
        return TransactionType.saleOrder;
      default:
        return TransactionType.sale;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.sale:
        writer.writeByte(0);
        break;
      case TransactionType.saleOrder:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

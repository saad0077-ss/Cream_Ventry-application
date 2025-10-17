// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_in_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentInModelAdapter extends TypeAdapter<PaymentInModel> {
  @override
  final int typeId = 12;

  @override
  PaymentInModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentInModel(
      id: fields[0] as String,
      receiptNo: fields[1] as String,
      date: fields[2] as String,
      partyName: fields[3] as String?,
      phoneNumber: fields[4] as String?,
      receivedAmount: fields[5] as double,
      paymentType: fields[6] as String,
      note: fields[7] as String?,
      imagePath: fields[8] as String?,
      userId: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentInModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.receiptNo)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.partyName)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.receivedAmount)
      ..writeByte(6)
      ..write(obj.paymentType)
      ..writeByte(7)
      ..write(obj.note)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentInModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

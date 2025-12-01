// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../../models/party_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartyModelAdapter extends TypeAdapter<PartyModel> {
  @override
  final int typeId = 5;

  @override
  PartyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartyModel(
      id: fields[0] as String,
      name: fields[1] as String,
      contactNumber: fields[2] as String,
      openingBalance: fields[3] as double,
      asOfDate: fields[4] as String,
      billingAddress: fields[5] as String,
      email: fields[6] as String,
      paymentType: fields[7] as String,
      imagePath: fields[8] as String,
      partyBalance: fields[9] as double,
      userId: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PartyModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.contactNumber)
      ..writeByte(3)
      ..write(obj.openingBalance)
      ..writeByte(4)
      ..write(obj.asOfDate)
      ..writeByte(5)
      ..write(obj.billingAddress)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.paymentType)
      ..writeByte(8)
      ..write(obj.imagePath)
      ..writeByte(9)
      ..write(obj.partyBalance)
      ..writeByte(10)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 1;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      amount: fields[2] as double,
      datetime: fields[3] as DateTime,
      description: fields[4] as String,
      type: fields[5] as String,
      note: fields[6] as String?,
      location: fields[7] as String?,
      tags: (fields[8] as List?)?.cast<String>(),
      isRecurring: fields[9] as bool,
      recurringType: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.datetime)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.tags)
      ..writeByte(9)
      ..write(obj.isRecurring)
      ..writeByte(10)
      ..write(obj.recurringType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

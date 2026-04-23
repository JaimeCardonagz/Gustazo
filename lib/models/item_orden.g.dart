// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_orden.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemOrdenAdapter extends TypeAdapter<ItemOrden> {
  @override
  final int typeId = 1;

  @override
  ItemOrden read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemOrden(
      productoId: fields[0] as String,
      nombreProducto: fields[1] as String,
      precioUnitario: fields[2] as double,
      gastoReposicionUnitario: fields[3] as double,
      cantidad: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ItemOrden obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productoId)
      ..writeByte(1)
      ..write(obj.nombreProducto)
      ..writeByte(2)
      ..write(obj.precioUnitario)
      ..writeByte(3)
      ..write(obj.gastoReposicionUnitario)
      ..writeByte(4)
      ..write(obj.cantidad);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemOrdenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

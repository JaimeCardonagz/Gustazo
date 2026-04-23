// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orden.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrdenAdapter extends TypeAdapter<Orden> {
  @override
  final int typeId = 2;

  @override
  Orden read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Orden(
      id: fields[0] as String,
      items: (fields[1] as List).cast<ItemOrden>(),
      metodoPago: fields[2] as MetodoPago,
      propina: fields[3] as double?,
      estado: fields[4] as EstadoOrden,
      fechaCreacion: fields[5] as DateTime?,
      fechaCompletado: fields[6] as DateTime?,
      empleadoId: fields[7] as String?,
      empleadoNombre: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Orden obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.metodoPago)
      ..writeByte(3)
      ..write(obj.propina)
      ..writeByte(4)
      ..write(obj.estado)
      ..writeByte(5)
      ..write(obj.fechaCreacion)
      ..writeByte(6)
      ..write(obj.fechaCompletado)
      ..writeByte(7)
      ..write(obj.empleadoId)
      ..writeByte(8)
      ..write(obj.empleadoNombre);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdenAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

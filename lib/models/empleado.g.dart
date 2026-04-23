// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empleado.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmpleadoAdapter extends TypeAdapter<Empleado> {
  @override
  final int typeId = 3;

  @override
  Empleado read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Empleado(
      id: fields[0] as String,
      nombre: fields[1] as String,
      cargo: fields[2] as String,
      salarioBase: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Empleado obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.cargo)
      ..writeByte(3)
      ..write(obj.salarioBase);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmpleadoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PagoEmpleadoAdapter extends TypeAdapter<PagoEmpleado> {
  @override
  final int typeId = 4;

  @override
  PagoEmpleado read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PagoEmpleado(
      id: fields[0] as String,
      empleadoId: fields[1] as String,
      empleadoNombre: fields[2] as String,
      monto: fields[3] as double,
      concepto: fields[4] as String,
      fecha: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PagoEmpleado obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.empleadoId)
      ..writeByte(2)
      ..write(obj.empleadoNombre)
      ..writeByte(3)
      ..write(obj.monto)
      ..writeByte(4)
      ..write(obj.concepto)
      ..writeByte(5)
      ..write(obj.fecha);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PagoEmpleadoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

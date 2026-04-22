import 'package:hive/hive.dart';

part 'empleado.g.dart';

@HiveType(typeId: 3)
class Empleado extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String cargo;

  @HiveField(3)
  double salarioBase;

  Empleado({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.salarioBase,
  });
}

@HiveType(typeId: 4)
class PagoEmpleado extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String empleadoId;

  @HiveField(2)
  String empleadoNombre;

  @HiveField(3)
  double monto;

  @HiveField(4)
  String concepto;

  @HiveField(5) // CAMPO AGREGADO: Fecha del pago
  DateTime fecha;

  PagoEmpleado({
    required this.id,
    required this.empleadoId,
    required this.empleadoNombre,
    required this.monto,
    required this.concepto,
    required this.fecha,
  });
}

/// Modelo de datos para Empleados y Pagos en la app "EL GUSTAZO"
/// Mejora 1: Integrado con Hive para persistencia local

import 'package:hive/hive.dart';

part 'empleado.g.dart';

@HiveType(typeId: 3)
class Empleado extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String cargo;

  @HiveField(3)
  double salarioBase;

  @HiveField(4)
  final bool activo;

  @HiveField(5)
  final DateTime fechaContratacion;

  @HiveField(6)
  String? telefono;

  @HiveField(7)
  String? email;

  Empleado({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.salarioBase,
    this.activo = true,
    DateTime? fechaContratacion,
    this.telefono,
    this.email,
  }) : fechaContratacion = fechaContratacion ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cargo': cargo,
      'salarioBase': salarioBase,
      'activo': activo,
      'fechaContratacion': fechaContratacion.toIso8601String(),
      'telefono': telefono,
      'email': email,
    };
  }

  factory Empleado.fromMap(Map<String, dynamic> map) {
    return Empleado(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: map['nombre'] as String? ?? '',
      cargo: map['cargo'] as String? ?? 'General',
      salarioBase: (map['salarioBase'] as num?)?.toDouble() ?? 0.0,
      activo: map['activo'] as bool? ?? true,
      fechaContratacion: map['fechaContratacion'] != null
          ? DateTime.parse(map['fechaContratacion'] as String)
          : null,
      telefono: map['telefono'] as String?,
      email: map['email'] as String?,
    );
  }

  Empleado copyWith({
    String? id,
    String? nombre,
    String? cargo,
    double? salarioBase,
    bool? activo,
    DateTime? fechaContratacion,
    String? telefono,
    String? email,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cargo: cargo ?? this.cargo,
      salarioBase: salarioBase ?? this.salarioBase,
      activo: activo ?? this.activo,
      fechaContratacion: fechaContratacion ?? this.fechaContratacion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }

  @override
  String toString() => 'Empleado($nombre - $cargo)';
}

@HiveType(typeId: 4)
class PagoEmpleado extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String empleadoId;

  @HiveField(2)
  final String empleadoNombre;

  @HiveField(3)
  final double monto;

  @HiveField(4)
  final String concepto; // Salario, Bono, Extra, etc.

  @HiveField(5)
  final DateTime fechaPago;

  @HiveField(6)
  String? notas;

  @HiveField(7)
  final bool esDeduccion; // Si es true, resta de ganancias

  PagoEmpleado({
    required this.id,
    required this.empleadoId,
    required this.empleadoNombre,
    required this.monto,
    required this.concepto,
    DateTime? fechaPago,
    this.notas,
    this.esDeduccion = true, // Por defecto los pagos restan
  }) : fechaPago = fechaPago ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empleadoId': empleadoId,
      'empleadoNombre': empleadoNombre,
      'monto': monto,
      'concepto': concepto,
      'fechaPago': fechaPago.toIso8601String(),
      'notas': notas,
      'esDeduccion': esDeduccion,
    };
  }

  factory PagoEmpleado.fromMap(Map<String, dynamic> map) {
    return PagoEmpleado(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      empleadoId: map['empleadoId'] as String? ?? '',
      empleadoNombre: map['empleadoNombre'] as String? ?? '',
      monto: (map['monto'] as num?)?.toDouble() ?? 0.0,
      concepto: map['concepto'] as String? ?? 'Pago',
      fechaPago: map['fechaPago'] != null
          ? DateTime.parse(map['fechaPago'] as String)
          : null,
      notas: map['notas'] as String?,
      esDeduccion: map['esDeduccion'] as bool? ?? true,
    );
  }

  bool esDelDia(DateTime dia) {
    return fechaPago.year == dia.year &&
        fechaPago.month == dia.month &&
        fechaPago.day == dia.day;
  }

  bool estaEnRango(DateTime inicio, DateTime fin) {
    return fechaPago.isAfter(inicio) && fechaPago.isBefore(fin);
  }

  PagoEmpleado copyWith({
    String? id,
    String? empleadoId,
    String? empleadoNombre,
    double? monto,
    String? concepto,
    DateTime? fechaPago,
    String? notas,
    bool? esDeduccion,
  }) {
    return PagoEmpleado(
      id: id ?? this.id,
      empleadoId: empleadoId ?? this.empleadoId,
      empleadoNombre: empleadoNombre ?? this.empleadoNombre,
      monto: monto ?? this.monto,
      concepto: concepto ?? this.concepto,
      fechaPago: fechaPago ?? this.fechaPago,
      notas: notas ?? this.notas,
      esDeduccion: esDeduccion ?? this.esDeduccion,
    );
  }

  @override
  String toString() => 'PagoEmpleado($empleadoNombre: \$${monto.toStringAsFixed(2)} - $concepto)';
}

/// Modelo de datos para Órdenes en la app "EL GUSTAZO"
/// Mejora 1: Integrado con Hive para persistencia local

import 'package:hive/hive.dart';
import 'item_orden.dart';
import '../utils/enums.dart';

part 'orden.g.dart';

@HiveType(typeId: 2)
class Orden extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<ItemOrden> items;

  @HiveField(2)
  MetodoPago metodoPago;

  @HiveField(3)
  double? propina;

  @HiveField(4)
  EstadoOrden estado;

  @HiveField(5)
  final DateTime fechaCreacion;

  @HiveField(6)
  DateTime? fechaCompletado;

  @HiveField(7)
  String? empleadoId;

  @HiveField(8)
  String? empleadoNombre;

  Orden({
    required this.id,
    required this.items,
    required this.metodoPago,
    this.propina,
    this.estado = EstadoOrden.pendiente,
    DateTime? fechaCreacion,
    this.fechaCompletado,
    this.empleadoId,
    this.empleadoNombre,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  /// Total de la venta (sin propina)
  double get totalVenta {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Total del gasto de reposición
  double get totalGastoReposicion {
    return items.fold(0.0, (sum, item) => sum + item.gastoReposicionTotal);
  }

  /// Ganancia bruta: (Ventas - Gasto de Reposición)
  double get gananciaBruta => totalVenta - totalGastoReposicion;

  /// Total con propina (lo que paga el cliente)
  double get totalConPropina => totalVenta + (propina ?? 0.0);

  /// Cantidad total de items
  int get cantidadTotalItems {
    return items.fold(0, (sum, item) => sum + item.cantidad);
  }

  void agregarItem(ItemOrden item) {
    items.add(item);
  }

  void completar({double? propina, String? empleadoId, String? empleadoNombre}) {
    this.propina = propina;
    this.empleadoId = empleadoId;
    this.empleadoNombre = empleadoNombre;
    estado = EstadoOrden.completada;
    fechaCompletado = DateTime.now();
    save();
  }

  void cancelar() {
    estado = EstadoOrden.cancelada;
    save();
  }

  bool esDelDia(DateTime dia) {
    return fechaCreacion.year == dia.year &&
        fechaCreacion.month == dia.month &&
        fechaCreacion.day == dia.day;
  }

  bool estaEnRango(DateTime inicio, DateTime fin) {
    return fechaCreacion.isAfter(inicio) && fechaCreacion.isBefore(fin);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((i) => i.toMap()).toList(),
      'metodoPago': metodoPago.index,
      'propina': propina,
      'estado': estado.index,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaCompletado': fechaCompletado?.toIso8601String(),
      'empleadoId': empleadoId,
      'empleadoNombre': empleadoNombre,
    };
  }

  factory Orden.fromMap(Map<String, dynamic> map) {
    return Orden(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      items: (map['items'] as List?)
              ?.map((i) => ItemOrden.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      metodoPago: MetodoPago.values[map['metodoPago'] as int? ?? 0],
      propina: (map['propina'] as num?)?.toDouble(),
      estado: EstadoOrden.values[map['estado'] as int? ?? 0],
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'] as String)
          : null,
      fechaCompletado: map['fechaCompletado'] != null
          ? DateTime.parse(map['fechaCompletado'] as String)
          : null,
      empleadoId: map['empleadoId'] as String?,
      empleadoNombre: map['empleadoNombre'] as String?,
    );
  }

  Orden copyWith({
    String? id,
    List<ItemOrden>? items,
    MetodoPago? metodoPago,
    double? propina,
    EstadoOrden? estado,
    DateTime? fechaCreacion,
    DateTime? fechaCompletado,
    String? empleadoId,
    String? empleadoNombre,
  }) {
    return Orden(
      id: id ?? this.id,
      items: items ?? this.items,
      metodoPago: metodoPago ?? this.metodoPago,
      propina: propina ?? this.propina,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaCompletado: fechaCompletado ?? this.fechaCompletado,
      empleadoId: empleadoId ?? this.empleadoId,
      empleadoNombre: empleadoNombre ?? this.empleadoNombre,
    );
  }

  @override
  String toString() {
    return 'Orden(id: $id, total: \$${totalVenta.toStringAsFixed(2)}, estado: $estado)';
  }
}

/// Modelo de datos para Items de Orden en la app "EL GUSTAZO"
/// Mejora 1: Integrado con Hive para persistencia local

import 'package:hive/hive.dart';

part 'item_orden.g.dart';

@HiveType(typeId: 1)
class ItemOrden extends HiveObject {
  @HiveField(0)
  final String productoId;

  @HiveField(1)
  final String nombreProducto;

  @HiveField(2)
  final double precioUnitario;

  @HiveField(3)
  final double gastoReposicionUnitario;

  @HiveField(4)
  int cantidad;

  ItemOrden({
    required this.productoId,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.gastoReposicionUnitario,
    required this.cantidad,
  });

  /// Subtotal del item (precio * cantidad)
  double get subtotal => precioUnitario * cantidad;

  /// Ganancia bruta del item (sin propina)
  double get ganancia => (precioUnitario - gastoReposicionUnitario) * cantidad;

  /// Gasto total de reposición para este item
  double get gastoReposicionTotal => gastoReposicionUnitario * cantidad;

  void incrementar() {
    cantidad++;
  }

  void decrementar() {
    if (cantidad > 1) {
      cantidad--;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombreProducto': nombreProducto,
      'precioUnitario': precioUnitario,
      'gastoReposicionUnitario': gastoReposicionUnitario,
      'cantidad': cantidad,
    };
  }

  factory ItemOrden.fromMap(Map<String, dynamic> map) {
    return ItemOrden(
      productoId: map['productoId'] as String? ?? '',
      nombreProducto: map['nombreProducto'] as String? ?? '',
      precioUnitario: (map['precioUnitario'] as num?)?.toDouble() ?? 0.0,
      gastoReposicionUnitario: (map['gastoReposicionUnitario'] as num?)?.toDouble() ?? 0.0,
      cantidad: map['cantidad'] as int? ?? 1,
    );
  }

  ItemOrden copyWith({
    String? productoId,
    String? nombreProducto,
    double? precioUnitario,
    double? gastoReposicionUnitario,
    int? cantidad,
  }) {
    return ItemOrden(
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      gastoReposicionUnitario: gastoReposicionUnitario ?? this.gastoReposicionUnitario,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  @override
  String toString() {
    return 'ItemOrden($nombreProducto x$cantidad - \$${subtotal.toStringAsFixed(2)})';
  }
}

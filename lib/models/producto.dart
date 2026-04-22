/// Modelo de datos para Productos en la app "EL GUSTAZO"
/// Este modelo gestiona el inventario, precios y costos de reposición
/// Mejora 1: Integrado con Hive para persistencia local

import 'package:hive/hive.dart';

part 'producto.g.dart';

@HiveType(typeId: 0)
class Producto extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String nombre;
  
  @HiveField(2)
  final String categoria;
  
  @HiveField(3)
  double stock;
  
  @HiveField(4)
  double precioVenta;
  
  @HiveField(5)
  double gastoReposicion; // Costo de reponer una unidad
  
  @HiveField(6)
  final bool disponible;
  
  @HiveField(7)
  final DateTime fechaCreacion;

  Producto({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.stock,
    required this.precioVenta,
    required this.gastoReposicion,
    this.disponible = true,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  /// Calcula la ganancia por unidad vendida
  double get gananciaUnitaria => precioVenta - gastoReposicion;

  /// Verifica si hay suficiente stock para una cantidad dada
  bool tieneStock(int cantidad) => stock >= cantidad && disponible;

  /// Reduce el stock (llamado al vender) - Auto-guardado con Hive
  void reducirStock(int cantidad) {
    if (tieneStock(cantidad)) {
      stock -= cantidad;
      save(); // Auto-guardado gracias a Hive
    } else {
      throw Exception('Stock insuficiente para $nombre');
    }
  }

  /// Aumenta el stock (para reposición) - Auto-guardado con Hive
  void aumentarStock(int cantidad) {
    if (cantidad < 0) {
      throw Exception('La cantidad debe ser positiva');
    }
    stock += cantidad;
    save();
  }

  /// Actualiza el stock (para reposición manual)
  void actualizarStock(double nuevaCantidad) {
    if (nuevaCantidad < 0) {
      throw Exception('El stock no puede ser negativo');
    }
    stock = nuevaCantidad;
    save();
  }

  /// Crea una copia del producto con campos modificables actualizados
  Producto copyWith({
    String? id,
    String? nombre,
    String? categoria,
    double? stock,
    double? precioVenta,
    double? gastoReposicion,
    bool? disponible,
    DateTime? fechaCreacion,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      stock: stock ?? this.stock,
      precioVenta: precioVenta ?? this.precioVenta,
      gastoReposicion: gastoReposicion ?? this.gastoReposicion,
      disponible: disponible ?? this.disponible,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  /// Convierte el producto a Map para serialización
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'categoria': categoria,
      'stock': stock,
      'precioVenta': precioVenta,
      'gastoReposicion': gastoReposicion,
      'disponible': disponible,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  /// Crea un producto desde un Map
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: map['nombre'] as String? ?? '',
      categoria: map['categoria'] as String? ?? 'General',
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (map['precioVenta'] as num?)?.toDouble() ?? 0.0,
      gastoReposicion: (map['gastoReposicion'] as num?)?.toDouble() ?? 0.0,
      disponible: map['disponible'] as bool? ?? true,
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.parse(map['fechaCreacion'] as String) 
          : null,
    );
  }

  @override
  String toString() {
    return 'Producto(id: $id, nombre: $nombre, stock: $stock, precio: \$${precioVenta.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Producto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

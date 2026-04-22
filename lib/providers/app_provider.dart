import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'dart:async';

class AppProvider with ChangeNotifier {
  // Cajas de Hive
  Box<Producto> get productosBox => Hive.box<Producto>('productos');
  Box<Orden> get ordenesBox => Hive.box<Orden>('ordenes');
  Box<Empleado> get empleadosBox => Hive.box<Empleado>('empleados');
  Box<PagoEmpleado> get pagosBox => Hive.box<PagoEmpleado>('pagos_empleados');
  Box get configBox => Hive.box('configuracion');

  bool _diaIniciado = false;
  DateTime? _fechaInicioDia;

  bool get diaIniciado => _diaIniciado;
  DateTime? get fechaInicioDia => _fechaInicioDia;

  List<Producto> get productos => productosBox.values.toList();
  List<Orden> get ordenes => ordenesBox.values.toList();
  List<Empleado> get empleados => empleadosBox.values.toList();
  List<PagoEmpleado> get pagosEmpleados => pagosBox.values.toList();

  Future<void> init() async {
    await _cargarEstadoDia();
    notifyListeners();
  }

  Future<void> _cargarEstadoDia() async {
    _diaIniciado = configBox.get('diaIniciado', defaultValue: false);
    final fechaString = configBox.get('fechaInicioDia');
    _fechaInicioDia = fechaString != null ? DateTime.parse(fechaString) : null;
  }

  Future<void> iniciarDia() async {
    _diaIniciado = true;
    _fechaInicioDia = DateTime.now();
    await configBox.put('diaIniciado', true);
    await configBox.put('fechaInicioDia', _fechaInicioDia!.toIso8601String());
    notifyListeners();
  }

  Future<void> cerrarDia() async {
    _diaIniciado = false;
    _fechaInicioDia = null;
    await configBox.put('diaIniciado', false);
    await configBox.delete('fechaInicioDia');
    notifyListeners();
  }

  Future<void> agregarProducto(Producto producto) async {
    await productosBox.put(producto.id, producto);
    notifyListeners();
  }

  Future<void> actualizarProducto(Producto producto) async {
    await productosBox.put(producto.id, producto);
    notifyListeners();
  }

  Future<void> eliminarProducto(String id) async {
    await productosBox.delete(id);
    notifyListeners();
  }

  // CORRECCIÓN: Ahora requiere el argumento 'limite'
  List<Producto> getProductosConStockBajo(int limite) {
    return productos.where((p) => p.stock < limite).toList();
  }

  Future<void> guardarOrden(Orden orden) async {
    await ordenesBox.put(orden.id, orden);
    for (var item in orden.items) {
      final producto = productosBox.get(item.productoId);
      if (producto != null) {
        producto.reducirStock(item.cantidad);
        await productosBox.put(producto.id, producto);
      }
    }
    notifyListeners();
  }

  Future<void> agregarEmpleado(Empleado empleado) async {
    await empleadosBox.put(empleado.id, empleado);
    notifyListeners();
  }

  Future<void> actualizarEmpleado(Empleado empleado) async {
    await empleadosBox.put(empleado.id, empleado);
    notifyListeners();
  }

  Future<void> eliminarEmpleado(String id) async {
    await empleadosBox.delete(id);
    notifyListeners();
  }

  Future<void> registrarPago(PagoEmpleado pago) async {
    await pagosBox.add(pago);
    notifyListeners();
  }

  double _calcularVentasNetasRango(DateTime inicio, DateTime fin) {
    double total = 0.0;
    for (var orden in ordenes) {
      if (orden.estado == EstadoOrden.completada &&
          orden.fechaCreacion.isAfter(inicio) &&
          orden.fechaCreacion.isBefore(fin)) {
        total += orden.gananciaBruta;
      }
    }
    return total;
  }

  double _calcularPagosRango(DateTime inicio, DateTime fin) {
    double total = 0.0;
    for (var pago in pagosEmpleados) {
      if (pago.fecha.isAfter(inicio) && pago.fecha.isBefore(fin)) {
        total += pago.monto;
      }
    }
    return total;
  }

  double get gananciaBrutaHoy {
    if (!_diaIniciado || _fechaInicioDia == null) return 0.0;
    return _calcularVentasNetasRango(_fechaInicioDia!, DateTime.now());
  }

  double get totalPagosHoy {
    if (!_diaIniciado || _fechaInicioDia == null) return 0.0;
    return _calcularPagosRango(_fechaInicioDia!, DateTime.now());
  }

  double get gananciaNetaHoy => gananciaBrutaHoy - totalPagosHoy;

  double get gananciaBrutaQuincenal {
    final fin = DateTime.now();
    final inicio = fin.subtract(const Duration(days: 15));
    return _calcularVentasNetasRango(inicio, fin);
  }

  double get totalPagosQuincenal {
    final fin = DateTime.now();
    final inicio = fin.subtract(const Duration(days: 15));
    return _calcularPagosRango(inicio, fin);
  }

  double get gananciaNetaQuincenal =>
      gananciaBrutaQuincenal - totalPagosQuincenal;

  double get gananciaBrutaMensual {
    final fin = DateTime.now();
    final inicio = fin.subtract(const Duration(days: 30));
    return _calcularVentasNetasRango(inicio, fin);
  }

  double get totalPagosMensual {
    final fin = DateTime.now();
    final inicio = fin.subtract(const Duration(days: 30));
    return _calcularPagosRango(inicio, fin);
  }

  double get gananciaNetaMensual => gananciaBrutaMensual - totalPagosMensual;
}

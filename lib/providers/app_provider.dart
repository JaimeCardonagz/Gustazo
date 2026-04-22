import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'dart:async';

class AppProvider with ChangeNotifier {
  // Cajas de Hive (Ya abiertas en main.dart)
  Box<Producto> get productosBox => Hive.box<Producto>('productos');
  Box<Orden> get ordenesBox => Hive.box<Orden>('ordenes');
  Box<Empleado> get empleadosBox => Hive.box<Empleado>('empleados');
  Box<PagoEmpleado> get pagosBox => Hive.box<PagoEmpleado>('pagos_empleados');
  Box get configBox => Hive.box('configuracion');

  // Estado del día
  bool _diaIniciado = false;
  DateTime? _fechaInicioDia;

  bool get diaIniciado => _diaIniciado;
  DateTime? get fechaInicioDia => _fechaInicioDia;

  // Getters de listas
  List<Producto> get productos => productosBox.values.toList();
  List<Orden> get ordenes => ordenesBox.values.toList();
  List<Empleado> get empleados => empleadosBox.values.toList();
  List<PagoEmpleado> get pagosEmpleados => pagosBox.values.toList();

  // Inicialización (Solo carga estado, NO registra adaptadores)
  Future<void> init() async {
    await _cargarEstadoDia();
    notifyListeners();
  }

  Future<void> _cargarEstadoDia() async {
    _diaIniciado = configBox.get('diaIniciado', defaultValue: false);
    final fechaString = configBox.get('fechaInicioDia');
    _fechaInicioDia = fechaString != null ? DateTime.parse(fechaString) : null;
  }

  // --- Lógica del Día ---

  Future<void> iniciarDia() async {
    _diaIniciado = true;
    _fechaInicioDia = DateTime.now();
    await configBox.put('diaIniciado', true);
    await configBox.put('fechaInicioDia', _fechaInicioDia!.toIso8601String());

    // Opcional: Aquí podrías archivar las órdenes de ayer si quisieras
    notifyListeners();
  }

  Future<void> cerrarDia() async {
    _diaIniciado = false;
    _fechaInicioDia = null;
    await configBox.put('diaIniciado', false);
    await configBox.remove('fechaInicioDia');
    notifyListeners();
  }

  // --- Productos (Inventario) ---

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

  // --- Órdenes ---

  Future<void> guardarOrden(Orden orden) async {
    await ordenesBox.put(orden.id, orden);

    // Actualizar stock automáticamente
    for (var item in orden.items) {
      final producto = productosBox.get(item.productoId);
      if (producto != null) {
        producto.reducirStock(item.cantidad);
        await productosBox.put(producto.id, producto);
      }
    }

    notifyListeners();
  }

  // --- Empleados y Pagos ---

  Future<void> agregarEmpleado(Empleado empleado) async {
    await empleadosBox.put(empleado.id, empleado);
    notifyListeners();
  }

  Future<void> registrarPago(PagoEmpleado pago) async {
    await pagosBox.add(pago);
    notifyListeners();
  }

  // --- Cálculos de Ganancias ---

  double calcularGananciaRango(DateTime inicio, DateTime fin) {
    // 1. Ventas Netas (Ventas - Gasto Reposición) de órdenes completadas
    double gananciaBruta = 0.0;
    for (var orden in ordenes) {
      if (orden.estado == EstadoOrden.completada &&
          orden.fechaCreacion.isAfter(inicio) &&
          orden.fechaCreacion.isBefore(fin)) {
        gananciaBruta += orden.gananciaBruta;
      }
    }

    // 2. Restar Pagos a Empleados en ese rango
    double totalPagos = 0.0;
    for (var pago in pagosEmpleados) {
      if (pago.fecha.isAfter(inicio) && pago.fecha.isBefore(fin)) {
        totalPagos += pago.monto;
      }
    }

    return gananciaBruta - totalPagos;
  }

  // Métricas para el Dashboard HOY
  Map<String, dynamic> obtenerMetricasHoy() {
    if (!_diaIniciado || _fechaInicioDia == null) {
      return {'ganancia': 0.0, 'ventas': 0.0, 'ordenes': 0, 'items': 0};
    }

    final now = DateTime.now();
    double ventasTotales = 0.0;
    double gastosTotales = 0.0;
    int countOrdenes = 0;
    int countItems = 0;

    for (var orden in ordenes) {
      if (orden.estado == EstadoOrden.completada &&
          orden.fechaCreacion.isAfter(_fechaInicioDia!) &&
          orden.fechaCreacion.isBefore(now)) {
        ventasTotales += orden.totalVenta;
        gastosTotales += orden.totalGastoReposicion;
        countOrdenes++;
        countItems += orden.items.fold(0, (sum, item) => sum + item.cantidad);
      }
    }

    // Restar pagos hoy
    double pagosHoy = 0.0;
    for (var pago in pagosEmpleados) {
      if (pago.fecha.isAfter(_fechaInicioDia!) && pago.fecha.isBefore(now)) {
        pagosHoy += pago.monto;
      }
    }

    return {
      'ganancia': (ventasTotales - gastosTotales) - pagosHoy,
      'ventas': ventasTotales,
      'gastos': gastosTotales + pagosHoy,
      'ordenes': countOrdenes,
      'items': countItems,
    };
  }
}

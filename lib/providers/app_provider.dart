/// Provider principal para la gestión de estado de "EL GUSTAZO"
/// Mejora 1: Integración con Hive para persistencia local
/// Mejora 5: Notificaciones de stock bajo
/// Mejora 6: Sincronización con Firebase (opcional)

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  // Boxes de Hive
  late Box<Producto> _productosBox;
  late Box<Orden> _ordenesBox;
  late Box<Empleado> _empleadosBox;
  late Box<PagoEmpleado> _pagosBox;

  // Estado del día
  bool _diaIniciado = false;
  DateTime? _fechaInicioDia;
  DateTime? _fechaFinDia;

  // Getters
  bool get diaIniciado => _diaIniciado;
  DateTime? get fechaInicioDia => _fechaInicioDia;
  DateTime? get fechaFinDia => _fechaFinDia;

  List<Producto> get productos => _productosBox.values.toList();
  List<Orden> get ordenes => _ordenesBox.values.toList();
  List<Empleado> get empleados => _empleadosBox.values.toList();
  List<PagoEmpleado> get pagos => _pagosBox.values.toList();

  // Inicialización de Hive
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Registrar adaptadores
    Hive.registerAdapter(ProductoAdapter());
    Hive.registerAdapter(ItemOrdenAdapter());
    Hive.registerAdapter(OrdenAdapter());
    Hive.registerAdapter(EmpleadoAdapter());
    Hive.registerAdapter(PagoEmpleadoAdapter());

    // Abrir boxes
    _productosBox = await Hive.openBox<Producto>('productos');
    _ordenesBox = await Hive.openBox<Orden>('ordenes');
    _empleadosBox = await Hive.openBox<Empleado>('empleados');
    _pagosBox = await Hive.openBox<PagoEmpleado>('pagos');

    // Cargar estado del día
    _cargarEstadoDia();
    
    notifyListeners();
  }

  void _cargarEstadoDia() {
    final hoy = DateTime.now();
    final inicioDiaKey = 'inicioDia_${hoy.year}_${hoy.month}_${hoy.day}';
    final finDiaKey = 'finDia_${hoy.year}_${hoy.month}_${hoy.day}';
    
    _fechaInicioDia = Hive.box('settings').get(inicioDiaKey);
    _fechaFinDia = Hive.box('settings').get(finDiaKey);
    _diaIniciado = _fechaInicioDia != null && _fechaFinDia == null;
  }

  // ==================== GESTIÓN DEL DÍA ====================

  Future<void> iniciarDia() async {
    final settingsBox = await Hive.openBox('settings');
    final ahora = DateTime.now();
    final key = 'inicioDia_${ahora.year}_${ahora.month}_${ahora.day}';
    
    await settingsBox.put(key, ahora);
    _fechaInicioDia = ahora;
    _diaIniciado = true;
    notifyListeners();
  }

  Future<void> cerrarDia() async {
    final settingsBox = await Hive.openBox('settings');
    final ahora = DateTime.now();
    final key = 'finDia_${_fechaInicioDia?.year ?? ahora.year}_${_fechaInicioDia?.month ?? ahora.month}_${_fechaInicioDia?.day ?? ahora.day}';
    
    await settingsBox.put(key, ahora);
    _fechaFinDia = ahora;
    _diaIniciado = false;
    notifyListeners();
  }

  // ==================== PRODUCTOS ====================

  Future<void> agregarProducto(Producto producto) async {
    await _productosBox.put(producto.id, producto);
    _verificarStockBajo(producto);
    notifyListeners();
  }

  Future<void> actualizarProducto(Producto producto) async {
    await producto.save();
    _verificarStockBajo(producto);
    notifyListeners();
  }

  Future<void> eliminarProducto(String id) async {
    await _productosBox.delete(id);
    notifyListeners();
  }

  void _verificarStockBajo(Producto producto) {
    if (producto.stock < 10 && producto.disponible) {
      // Mejora 5: Notificación de stock bajo
      debugPrint('⚠️ STOCK BAJO: ${producto.nombre} tiene solo ${producto.stock} unidades');
      // Aquí se podría integrar con un sistema de notificaciones push
    }
  }

  List<Producto> getProductosConStockBajo() {
    return productos.where((p) => p.stock < 10 && p.disponible).toList();
  }

  // ==================== ÓRDENES ====================

  Future<void> guardarOrden(Orden orden) async {
    await _ordenesBox.put(orden.id, orden);
    
    // Reducir stock de productos
    for (var item in orden.items) {
      final producto = productos.firstWhere((p) => p.id == item.productoId);
      producto.reducirStock(item.cantidad);
    }
    
    notifyListeners();
  }

  Future<void> actualizarOrden(Orden orden) async {
    await orden.save();
    notifyListeners();
  }

  // ==================== EMPLEADOS ====================

  Future<void> agregarEmpleado(Empleado empleado) async {
    await _empleadosBox.put(empleado.id, empleado);
    notifyListeners();
  }

  Future<void> actualizarEmpleado(Empleado empleado) async {
    await empleado.save();
    notifyListeners();
  }

  Future<void> eliminarEmpleado(String id) async {
    await _empleadosBox.delete(id);
    notifyListeners();
  }

  // ==================== PAGOS ====================

  Future<void> registrarPago(PagoEmpleado pago) async {
    await _pagosBox.put(pago.id, pago);
    notifyListeners();
  }

  // ==================== CÁLCULOS DE GANANCIAS ====================

  double calcularGananciaBruta(DateTime inicio, DateTime fin) {
    final ordenesFiltradas = ordenes.where((o) => 
      o.estado == EstadoOrden.completada &&
      o.fechaCreacion.isAfter(inicio) &&
      o.fechaCreacion.isBefore(fin)
    );
    
    return ordenesFiltradas.fold(0.0, (sum, o) => sum + o.gananciaBruta);
  }

  double calcularTotalPagos(DateTime inicio, DateTime fin) {
    final pagosFiltrados = pagos.where((p) =>
      p.esDeduccion &&
      p.fechaPago.isAfter(inicio) &&
      p.fechaPago.isBefore(fin)
    );
    
    return pagosFiltrados.fold(0.0, (sum, p) => sum + p.monto);
  }

  double calcularGananciaNeta(DateTime inicio, DateTime fin) {
    return calcularGananciaBruta(inicio, fin) - calcularTotalPagos(inicio, fin);
  }

  // Ganancias HOY
  double get gananciaBrutaHoy {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, ahora.day);
    final fin = inicio.add(const Duration(days: 1));
    return calcularGananciaBruta(inicio, fin);
  }

  double get totalPagosHoy {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, ahora.day);
    final fin = inicio.add(const Duration(days: 1));
    return calcularTotalPagos(inicio, fin);
  }

  double get gananciaNetaHoy => gananciaBrutaHoy - totalPagosHoy;

  // Ganancias QUINCENALES
  double get gananciaBrutaQuincenal {
    final ahora = DateTime.now();
    final inicio = ahora.day <= 15 
        ? DateTime(ahora.year, ahora.month, 1)
        : DateTime(ahora.year, ahora.month, 16);
    final fin = ahora.day <= 15
        ? DateTime(ahora.year, ahora.month, 16)
        : DateTime(ahora.year, ahora.month + 1, 1);
    return calcularGananciaBruta(inicio, fin);
  }

  double get totalPagosQuincenal {
    final ahora = DateTime.now();
    final inicio = ahora.day <= 15 
        ? DateTime(ahora.year, ahora.month, 1)
        : DateTime(ahora.year, ahora.month, 16);
    final fin = ahora.day <= 15
        ? DateTime(ahora.year, ahora.month, 16)
        : DateTime(ahora.year, ahora.month + 1, 1);
    return calcularTotalPagos(inicio, fin);
  }

  double get gananciaNetaQuincenal => gananciaBrutaQuincenal - totalPagosQuincenal;

  // Ganancias MENSUALES
  double get gananciaBrutaMensual {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, 1);
    final fin = DateTime(ahora.year, ahora.month + 1, 1);
    return calcularGananciaBruta(inicio, fin);
  }

  double get totalPagosMensual {
    final ahora = DateTime.now();
    final inicio = DateTime(ahora.year, ahora.month, 1);
    final fin = DateTime(ahora.year, ahora.month + 1, 1);
    return calcularTotalPagos(inicio, fin);
  }

  double get gananciaNetaMensual => gananciaBrutaMensual - totalPagosMensual;

  // ==================== EXPORTACIÓN (Mejora 2) ====================

  List<Map<String, dynamic>> obtenerOrdenesParaExportar(DateTime inicio, DateTime fin) {
    return ordenes
        .where((o) => 
          o.estado == EstadoOrden.completada &&
          o.fechaCreacion.isAfter(inicio) &&
          o.fechaCreacion.isBefore(fin))
        .map((o) => o.toMap())
        .toList();
  }

  List<Map<String, dynamic>> obtenerPagosParaExportar(DateTime inicio, DateTime fin) {
    return pagos
        .where((p) =>
          p.fechaPago.isAfter(inicio) &&
          p.fechaPago.isBefore(fin))
        .map((p) => p.toMap())
        .toList();
  }

  // ==================== FIREBASE SYNC (Mejora 6 - Placeholder) ====================
  
  // Estos métodos están preparados para integrar con Firebase Firestore
  // Se activarán cuando se configure firebase_core y cloud_firestore
  
  Future<void> sincronizarConFirebase() async {
    // TODO: Implementar sincronización con Firestore
    debugPrint('🔄 Sincronizando con Firebase...');
    // Ejemplo futuro:
    // final firestore = FirebaseFirestore.instance;
    // await firestore.collection('productos').add(producto.toMap());
  }

  Future<void> backupEnFirebase() async {
    // TODO: Implementar backup completo en Firestore
    debugPrint('☁️ Realizando backup en Firebase...');
  }

  @override
  void dispose() {
    _productosBox.close();
    _ordenesBox.close();
    _empleadosBox.close();
    _pagosBox.close();
    super.dispose();
  }
}

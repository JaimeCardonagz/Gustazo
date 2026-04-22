import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'models/models.dart';
import 'screens/pantalla_ordenes.dart';
import 'screens/pantalla_inventario.dart';
import 'screens/pantalla_cobros.dart';
import 'screens/pantalla_ganancias.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Hive
  await Hive.initFlutter();

  // 2. Registrar Adaptadores (SOLO AQUÍ, no en el Provider)
  // Los IDs deben ser únicos por tipo
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProductoAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ItemOrdenAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(OrdenAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(EmpleadoAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(PagoEmpleadoAdapter());

  // 3. Abrir Cajas
  await Hive.openBox<Producto>('productos');
  await Hive.openBox<Orden>('ordenes');
  await Hive.openBox<Empleado>('empleados');
  await Hive.openBox<PagoEmpleado>('pagos_empleados');
  await Hive.openBox('configuracion'); // Para estado del día, propinas, etc.

  // Datos iniciales de prueba si está vacío (Opcional)
  if (Hive.box<Producto>('productos').isEmpty) {
    final box = Hive.box<Producto>('productos');
    box.add(Producto(
        id: '1',
        nombre: 'Hamburguesa Clásica',
        categoria: 'Comida',
        stock: 50,
        precioVenta: 85.0,
        gastoReposicion: 45.0));
    box.add(Producto(
        id: '2',
        nombre: 'Papas Fritas',
        categoria: 'Comida',
        stock: 100,
        precioVenta: 35.0,
        gastoReposicion: 15.0));
    box.add(Producto(
        id: '3',
        nombre: 'Refresco Grande',
        categoria: 'Bebida',
        stock: 80,
        precioVenta: 25.0,
        gastoReposicion: 12.0));
    box.add(Producto(
        id: '4',
        nombre: 'Hot Dog Especial',
        categoria: 'Comida',
        stock: 40,
        precioVenta: 55.0,
        gastoReposicion: 25.0));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'EL GUSTAZO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6F00), // Naranja Gustazo
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          // CORRECCIÓN: Usar CardThemeData en lugar de CardTheme
          cardTheme: CardThemeData(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // Botones grandes
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: const PantallaPrincipal(),
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 0;

  final List<Widget> _pantallas = [
    const PantallaOrdenes(),
    const PantallaInventario(),
    const PantallaCobros(),
    const PantallaGanancias(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceActual],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (index) => setState(() => _indiceActual = index),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu), label: 'Órdenes'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined), label: 'Inventario'),
          NavigationDestination(
              icon: Icon(Icons.people_outline), label: 'Cobros'),
          NavigationDestination(
              icon: Icon(Icons.analytics_outlined), label: 'Ganancias'),
        ],
      ),
    );
  }
}

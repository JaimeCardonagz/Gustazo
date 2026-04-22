import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/pantalla_ordenes.dart';
import 'screens/pantalla_inventario.dart';
import 'screens/pantalla_cobros.dart';
import 'screens/pantalla_ganancias.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appProvider = AppProvider();
  await appProvider.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appProvider,
      child: const ElGustazoApp(),
    ),
  );
}

class ElGustazoApp extends StatelessWidget {
  const ElGustazoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EL GUSTAZO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PantallaPrincipal(),
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

  final List<Widget> _pantallas = const [
    PantallaOrdenes(),
    PantallaInventario(),
    PantallaCobros(),
    PantallaGanancias(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceActual,
        children: _pantallas,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceActual,
        onDestinationSelected: (index) => setState(() => _indiceActual = index),
        backgroundColor: Colors.white,
        indicatorColor: Colors.orange.shade100,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Órdenes'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Inventario'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Empleados'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Ganancias'),
        ],
      ),
    );
  }
}

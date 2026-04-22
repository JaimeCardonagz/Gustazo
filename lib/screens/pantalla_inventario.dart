import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class PantallaInventario extends StatefulWidget {
  const PantallaInventario({super.key});

  @override
  State<PantallaInventario> createState() => _PantallaInventarioState();
}

class _PantallaInventarioState extends State<PantallaInventario> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _categoriaController;
  late TextEditingController _stockController;
  late TextEditingController _precioController;
  late TextEditingController _gastoController;
  
  Producto? _productoEditando;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nombreController = TextEditingController();
    _categoriaController = TextEditingController(text: 'General');
    _stockController = TextEditingController();
    _precioController = TextEditingController();
    _gastoController = TextEditingController();
  }

  void _limpiarFormulario() {
    _nombreController.clear();
    _categoriaController.text = 'General';
    _stockController.clear();
    _precioController.clear();
    _gastoController.clear();
    _productoEditando = null;
  }

  void _mostrarDialogoProducto([Producto? producto]) {
    if (producto != null) {
      _productoEditando = producto;
      _nombreController.text = producto.nombre;
      _categoriaController.text = producto.categoria;
      _stockController.text = producto.stock.toInt().toString();
      _precioController.text = producto.precioVenta.toStringAsFixed(2);
      _gastoController.text = producto.gastoReposicion.toStringAsFixed(2);
    } else {
      _limpiarFormulario();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(producto == null ? '➕ Nuevo Producto' : '✏️ Editar Producto'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoriaController,
                  decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock inicial', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(labelText: 'Precio Venta (\$)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _gastoController,
                  decoration: const InputDecoration(labelText: 'Gasto Reposición (\$)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: _guardarProducto,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _guardarProducto() {
    if (_formKey.currentState!.validate()) {
      final producto = Producto(
        id: _productoEditando?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        nombre: _nombreController.text,
        categoria: _categoriaController.text,
        stock: double.tryParse(_stockController.text) ?? 0,
        precioVenta: double.tryParse(_precioController.text) ?? 0,
        gastoReposicion: double.tryParse(_gastoController.text) ?? 0,
      );

      final provider = context.read<AppProvider>();
      if (_productoEditando == null) {
        provider.agregarProducto(producto);
      } else {
        provider.actualizarProducto(producto);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_productoEditando == null ? 'Producto agregado' : 'Producto actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final productos = provider.productos;
        final stockBajo = provider.getProductosConStockBajo();

        return Scaffold(
          appBar: AppBar(
            title: const Text('📦 Inventario', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            actions: [
              if (stockBajo.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Chip(
                      label: Text('⚠️ ${stockBajo.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];
              final esStockBajo = p.stock < 10;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                color: esStockBajo ? Colors.red.shade50 : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(p.nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categoría: ${p.categoria}'),
                      Text(
                        'Stock: ${p.stock.toInt()} ${esStockBajo ? '⚠️ BAJO' : ''}',
                        style: TextStyle(color: esStockBajo ? Colors.red : null, fontWeight: FontWeight.bold),
                      ),
                      Text('Precio: \$${p.precioVenta.toStringAsFixed(2)} | Gasto: \$${p.gastoReposicion.toStringAsFixed(2)}'),
                      Text('Ganancia/unit: \$${p.gananciaUnitaria.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoProducto(p)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmarEliminar(p)),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _mostrarDialogoProducto(),
            backgroundColor: Colors.blue,
            icon: const Icon(Icons.add),
            label: const Text('PRODUCTO'),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(Producto producto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text('¿Estás seguro de eliminar "${producto.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().eliminarProducto(producto.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _stockController.dispose();
    _precioController.dispose();
    _gastoController.dispose();
    super.dispose();
  }
}

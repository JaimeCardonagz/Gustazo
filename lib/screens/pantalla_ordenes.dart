import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class PantallaOrdenes extends StatefulWidget {
  const PantallaOrdenes({super.key});

  @override
  State<PantallaOrdenes> createState() => _PantallaOrdenesState();
}

class _PantallaOrdenesState extends State<PantallaOrdenes> {
  final Map<String, int> _cantidades = {};
  MetodoPago _metodoPago = MetodoPago.efectivo;
  String? _empleadoSeleccionadoId;
  String? _empleadoSeleccionadoNombre;

  double get _totalVenta {
    double total = 0;
    _cantidades.forEach((productoId, cantidad) {
      final producto = context.read<AppProvider>().productos.firstWhere(
        (p) => p.id == productoId,
        orElse: () => Producto(
          id: '',
          nombre: '',
          categoria: '',
          stock: 0,
          precioVenta: 0,
          gastoReposicion: 0,
        ),
      );
      total += producto.precioVenta * cantidad;
    });
    return total;
  }

  void _agregarAlCarrito(String productoId) {
    setState(() {
      _cantidades[productoId] = (_cantidades[productoId] ?? 0) + 1;
    });
  }

  void _removerDelCarrito(String productoId) {
    setState(() {
      if (_cantidades.containsKey(productoId)) {
        _cantidades[productoId] = _cantidades[productoId]! - 1;
        if (_cantidades[productoId]! <= 0) {
          _cantidades.remove(productoId);
        }
      }
    });
  }

  void _mostrarDialogoPropina() async {
    double? propinaSeleccionada = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Hubo propina?', style: TextStyle(fontSize: 20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Seleccione el monto de propina:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _botonPropinaSimple(0, 'Sin propina'),
                _botonPropinaSimple(5, '\$5'),
                _botonPropinaSimple(10, '\$10'),
                _botonPropinaSimple(20, '\$20'),
                _botonPropinaSimple(50, '\$50'),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Otro monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // El usuario puede escribir un monto personalizado
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0.0),
            child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, 0.0);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirmar', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );

    if (propinaSeleccionada != null) {
      _finalizarOrden(propinaSeleccionada);
    }
  }

  Widget _botonPropinaSimple(double monto, String label) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context, monto),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        minimumSize: const Size(80, 60),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Future<void> _finalizarOrden(double propina) async {
    if (_cantidades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega productos a la orden')),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    final items = <ItemOrden>[];

    for (var entry in _cantidades.entries) {
      final producto = provider.productos.firstWhere((p) => p.id == entry.key);
      items.add(ItemOrden(
        productoId: producto.id,
        nombreProducto: producto.nombre,
        precioUnitario: producto.precioVenta,
        gastoReposicionUnitario: producto.gastoReposicion,
        cantidad: entry.value,
      ));
    }

    final orden = Orden(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      metodoPago: _metodoPago,
      empleadoId: _empleadoSeleccionadoId,
      empleadoNombre: _empleadoSeleccionadoNombre,
    );

    orden.completar(propina: propina);
    await provider.guardarOrden(orden);

    setState(() {
      _cantidades.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orden completada. Total: \$${(orden.totalVenta + propina).toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final productos = provider.productos;

        return Scaffold(
          appBar: AppBar(
            title: const Text('📝 Nueva Orden', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            elevation: 2,
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          body: Column(
            children: [
              // Selector de método de pago
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade50,
                child: Row(
                  children: [
                    const Text('Método de pago:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ToggleButtons(
                        isSelected: [_metodoPago == MetodoPago.efectivo, _metodoPago == MetodoPago.tarjeta],
                        onPressed: (index) {
                          setState(() {
                            _metodoPago = index == 0 ? MetodoPago.efectivo : MetodoPago.tarjeta;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        selectedColor: Colors.white,
                        fillColor: Colors.orange,
                        color: Colors.black87,
                        constraints: const BoxConstraints(minWidth: 100, minHeight: 50),
                        children: const [
                          Text('💵 Efectivo', style: TextStyle(fontSize: 16)),
                          Text('💳 Tarjeta', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de productos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    final cantidad = _cantidades[producto.id] ?? 0;
                    final tieneStock = producto.tieneStock(1);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.nombre,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${producto.precioVenta.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 16, color: Colors.orange.shade700, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    producto.tieneStock(10) 
                                        ? 'Stock: ${producto.stock.toInt()}' 
                                        : '⚠️ Stock bajo: ${producto.stock.toInt()}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: producto.tieneStock(10) ? Colors.grey : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Contador +/-
                            Row(
                              children: [
                                _botonContador(
                                  icon: Icons.remove,
                                  color: Colors.red,
                                  enabled: cantidad > 0,
                                  onPressed: () => _removerDelCarrito(producto.id),
                                ),
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$cantidad',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _botonContador(
                                  icon: Icons.add,
                                  color: Colors.green,
                                  enabled: tieneStock,
                                  onPressed: tieneStock ? () => _agregarAlCarrito(producto.id) : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Barra inferior con total y botón de pagar
              if (_cantidades.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 10)], // Evita withOpacity deprecated
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total:', style: TextStyle(fontSize: 16)),
                              Text(
                                '\$${_totalVenta.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _mostrarDialogoPropina,
                          icon: const Icon(Icons.payment, size: 28),
                          label: const Text('COBRAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            minimumSize: const Size(150, 60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _botonContador({
    required IconData icon,
    required Color color,
    required bool enabled,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: enabled ? color : Colors.grey,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

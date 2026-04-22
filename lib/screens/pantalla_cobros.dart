import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class PantallaCobros extends StatefulWidget {
  const PantallaCobros({super.key});

  @override
  State<PantallaCobros> createState() => _PantallaCobrosState();
}

class _PantallaCobrosState extends State<PantallaCobros> {
  final _formEmpleadoKey = GlobalKey<FormState>();
  final _formPagoKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreEmpleadoController;
  late TextEditingController _cargoController;
  late TextEditingController _salarioController;
  late TextEditingController _montoPagoController;
  late TextEditingController _conceptoController;
  late TextEditingController _notasController;
  
  Empleado? _empleadoSeleccionado;

  @override
  void initState() {
    super.initState();
    _nombreEmpleadoController = TextEditingController();
    _cargoController = TextEditingController(text: 'General');
    _salarioController = TextEditingController();
    _montoPagoController = TextEditingController();
    _conceptoController = TextEditingController(text: 'Salario');
    _notasController = TextEditingController();
  }

  void _mostrarDialogoEmpleado([Empleado? empleado]) {
    if (empleado != null) {
      _nombreEmpleadoController.text = empleado.nombre;
      _cargoController.text = empleado.cargo;
      _salarioController.text = empleado.salarioBase.toStringAsFixed(2);
    } else {
      _nombreEmpleadoController.clear();
      _cargoController.text = 'General';
      _salarioController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(empleado == null ? '➕ Nuevo Empleado' : '✏️ Editar Empleado'),
        content: Form(
          key: _formEmpleadoKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreEmpleadoController,
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cargoController,
                decoration: const InputDecoration(labelText: 'Cargo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salarioController,
                decoration: const InputDecoration(labelText: 'Salario Base (\$)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (_formEmpleadoKey.currentState!.validate()) {
                final empleadoObj = Empleado(
                  id: empleado?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  nombre: _nombreEmpleadoController.text,
                  cargo: _cargoController.text,
                  salarioBase: double.tryParse(_salarioController.text) ?? 0,
                );
                
                if (empleado == null) {
                  context.read<AppProvider>().agregarEmpleado(empleadoObj);
                } else {
                  context.read<AppProvider>().actualizarEmpleado(empleadoObj);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoPago() {
    if (_empleadoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un empleado primero')),
      );
      return;
    }

    _montoPagoController.clear();
    _conceptoController.text = 'Salario';
    _notasController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💰 Registrar Pago'),
        content: Form(
          key: _formPagoKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Empleado: ${_empleadoSeleccionado!.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoPagoController,
                decoration: const InputDecoration(labelText: 'Monto (\$)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _conceptoController.text,
                decoration: const InputDecoration(labelText: 'Concepto', border: OutlineInputBorder()),
                items: ['Salario', 'Bono', 'Extra', 'Comisión', 'Otro'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => _conceptoController.text = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(labelText: 'Notas (opcional)', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (_formPagoKey.currentState!.validate()) {
                final pago = PagoEmpleado(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  empleadoId: _empleadoSeleccionado!.id,
                  empleadoNombre: _empleadoSeleccionado!.nombre,
                  monto: double.tryParse(_montoPagoController.text) ?? 0,
                  concepto: _conceptoController.text,
                  notas: _notasController.text.isEmpty ? null : _notasController.text,
                );
                context.read<AppProvider>().registrarPago(pago);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pago registrado')));
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final empleados = provider.empleados;
        final pagos = provider.pagos;

        return Scaffold(
          appBar: AppBar(
            title: const Text('👥 Cobros a Empleados', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          body: Row(
            children: [
              // Lista de empleados
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.purple.shade50,
                      child: Row(
                        children: [
                          const Text('Empleados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.purple),
                            onPressed: () => _mostrarDialogoEmpleado(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: empleados.length,
                        itemBuilder: (context, index) {
                          final e = empleados[index];
                          final seleccionado = _empleadoSeleccionado?.id == e.id;
                          
                          return ListTile(
                            selected: seleccionado,
                            selectedTileColor: Colors.purple.shade100,
                            title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${e.cargo} - \$${e.salarioBase.toStringAsFixed(2)}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _mostrarDialogoEmpleado(e)),
                                IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () {
                                  provider.eliminarEmpleado(e.id);
                                  if (_empleadoSeleccionado?.id == e.id) setState(() => _empleadoSeleccionado = null);
                                }),
                              ],
                            ),
                            onTap: () => setState(() => _empleadoSeleccionado = e),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const VerticalDivider(width: 1),
              
              // Detalles y pagos
              Expanded(
                flex: 1,
                child: _empleadoSeleccionado == null
                    ? const Center(child: Text('Selecciona un empleado', style: TextStyle(fontSize: 16)))
                    : Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.purple.shade50,
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_empleadoSeleccionado!.nombre, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Text('Cargo: ${_empleadoSeleccionado!.cargo}'),
                                Text('Salario base: \$${_empleadoSeleccionado!.salarioBase.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _mostrarDialogoPago,
                                  icon: const Icon(Icons.payment),
                                  label: const Text('REGISTRAR PAGO'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Historial de Pagos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: pagos.where((p) => p.empleadoId == _empleadoSeleccionado!.id).length,
                              itemBuilder: (context, index) {
                                final pago = pagos.where((p) => p.empleadoId == _empleadoSeleccionado!.id).toList()[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.attach_money, color: Colors.white)),
                                    title: Text('\$${pago.monto.toStringAsFixed(2)}'),
                                    subtitle: Text('${pago.concepto} - ${pago.fechaPago.day}/${pago.fechaPago.month}/${pago.fechaPago.year}'),
                                    trailing: pago.notas != null ? const Icon(Icons.note, color: Colors.grey) : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nombreEmpleadoController.dispose();
    _cargoController.dispose();
    _salarioController.dispose();
    _montoPagoController.dispose();
    _conceptoController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}

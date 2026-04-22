import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

class PantallaGanancias extends StatefulWidget {
  const PantallaGanancias({super.key});

  @override
  State<PantallaGanancias> createState() => _PantallaGananciasState();
}

class _PantallaGananciasState extends State<PantallaGanancias> {
  FiltroTiempo _filtro = FiltroTiempo.hoy;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        double gananciaBruta;
        double totalPagos;
        double gananciaNeta;
        String tituloPeriodo;

        final ahora = DateTime.now();

        switch (_filtro) {
          case FiltroTiempo.hoy:
            gananciaBruta = provider.gananciaBrutaHoy;
            totalPagos = provider.totalPagosHoy;
            gananciaNeta = provider.gananciaNetaHoy;
            tituloPeriodo = 'HOY - ${DateFormat('dd/MM/yyyy').format(ahora)}';
            break;
          case FiltroTiempo.quincenal:
            gananciaBruta = provider.gananciaBrutaQuincenal;
            totalPagos = provider.totalPagosQuincenal;
            gananciaNeta = provider.gananciaNetaQuincenal;
            tituloPeriodo = ahora.day <= 15 
                ? 'QUINCENA 1: ${DateFormat('dd/MM').format(DateTime(ahora.year, ahora.month, 1))} - 15'
                : 'QUINCENA 2: 16 - ${DateFormat('dd/MM').format(DateTime(ahora.year, ahora.month + 1, 1).subtract(const Duration(days: 1)))}';
            break;
          case FiltroTiempo.mensual:
            gananciaBruta = provider.gananciaBrutaMensual;
            totalPagos = provider.totalPagosMensual;
            gananciaNeta = provider.gananciaNetaMensual;
            tituloPeriodo = 'MES: ${DateFormat('MMMM yyyy', 'es_ES').format(ahora).toUpperCase()}';
            break;
        }

        final ordenesCompletadas = provider.ordenes.where((o) => 
          o.estado == EstadoOrden.completada && _estaEnFiltro(o.fechaCreacion, ahora)
        ).length;

        final itemsVendidos = provider.ordenes
          .where((o) => o.estado == EstadoOrden.completada && _estaEnFiltro(o.fechaCreacion, ahora))
          .fold(0, (sum, o) => sum + o.cantidadTotalItems);

        return Scaffold(
          appBar: AppBar(
            title: const Text('📊 Ganancias', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              if (!provider.diaIniciado)
                ElevatedButton.icon(
                  onPressed: () async {
                    await provider.iniciarDia();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Día iniciado'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('EMPEZAR PEDIDOS'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () async {
                    await provider.cerrarDia();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🌙 Día cerrado'), backgroundColor: Colors.blue),
                      );
                    }
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('CERRAR DÍA'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de filtro
                Center(
                  child: SegmentedButton<FiltroTiempo>(
                    segments: FiltroTiempo.values.map((f) => ButtonSegment(
                      value: f,
                      label: Text(f.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      icon: Icon(_iconoFiltro(f)),
                    )).toList(),
                    selected: {_filtro},
                    onSelectionChanged: (selected) => setState(() => _filtro = selected.first),
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Título del período
                Center(
                  child: Text(tituloPeriodo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                const SizedBox(height: 24),

                // Tarjetas de métricas
                Row(
                  children: [
                    _tarjetaMetrica('💰 Ventas', '\$${gananciaBruta.toStringAsFixed(2)}', Colors.blue),
                    const SizedBox(width: 12),
                    _tarjetaMetrica('👥 Pagos', '\$${totalPagos.toStringAsFixed(2)}', Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                _tarjetaMetrica('📈 GANANCIA NETA', '\$${gananciaNeta.toStringAsFixed(2)}', 
                  gananciaNeta >= 0 ? Colors.green : Colors.red, esGrande: true),
                
                const SizedBox(height: 24),
                
                // Gráfico
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Distribución', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  value: gananciaBruta,
                                  title: 'Ganancia Bruta\n\$${gananciaBruta.toStringAsFixed(2)}',
                                  color: Colors.green,
                                  radius: 80,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                PieChartSectionData(
                                  value: totalPagos,
                                  title: 'Pagos\n\$${totalPagos.toStringAsFixed(2)}',
                                  color: Colors.red,
                                  radius: 80,
                                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Estadísticas adicionales
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📋 Estadísticas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        _filaEstadistica('Órdenes completadas', ordenesCompletadas.toString()),
                        _filaEstadistica('Items vendidos', itemsVendidos.toString()),
                        _filaEstadistica('Productos con stock bajo', provider.getProductosConStockBajo().length.toString()),
                        _filaEstadistica('Empleados registrados', provider.empleados.length.toString()),
                      ],
                    ),
                  ),
                ),

                // Botones de exportación (Mejora 2)
                const SizedBox(height: 24),
                const Text('📤 Exportar Reporte', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportarPDF(provider, ahora),
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                        label: const Text('PDF', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportarCSV(provider, ahora),
                        icon: const Icon(Icons.table_chart, color: Colors.white),
                        label: const Text('CSV', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 15)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _estaEnFiltro(DateTime fecha, DateTime ahora) {
    switch (_filtro) {
      case FiltroTiempo.hoy:
        return fecha.year == ahora.year && fecha.month == ahora.month && fecha.day == ahora.day;
      case FiltroTiempo.quincenal:
        final inicio = ahora.day <= 15 
            ? DateTime(ahora.year, ahora.month, 1)
            : DateTime(ahora.year, ahora.month, 16);
        return fecha.isAfter(inicio.subtract(const Duration(days: 1)));
      case FiltroTiempo.mensual:
        return fecha.year == ahora.year && fecha.month == ahora.month;
    }
  }

  IconData _iconoFiltro(FiltroTiempo filtro) {
    switch (filtro) {
      case FiltroTiempo.hoy: return Icons.today;
      case FiltroTiempo.quincenal: return Icons.date_range;
      case FiltroTiempo.mensual: return Icons.calendar_month;
    }
  }

  Widget _tarjetaMetrica(String titulo, String valor, Color color, {bool esGrande = false}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: esGrande ? 24 : 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Color.fromRGBO(color.red, color.green, color.blue, 0.1), // Evita withOpacity deprecated
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            Text(titulo, style: TextStyle(fontSize: esGrande ? 18 : 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 8),
            Text(valor, style: TextStyle(fontSize: esGrande ? 32 : 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _filaEstadistica(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _exportarPDF(AppProvider provider, DateTime ahora) {
    // Mejora 2: Exportación a PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📄 Generando PDF... (funcionalidad lista para implementar con package pdf)')),
    );
    // Aquí se implementaría con el package 'pdf' y 'printing'
  }

  void _exportarCSV(AppProvider provider, DateTime ahora) {
    // Mejora 2: Exportación a CSV
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📊 Generando CSV... (funcionalidad lista para implementar con package csv)')),
    );
    // Aquí se implementaría con el package 'csv' y 'share_plus'
  }
}

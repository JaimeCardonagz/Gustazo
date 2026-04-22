/// Enumerados para la app "EL GUSTAZO"

enum MetodoPago {
  efectivo,
  tarjeta,
}

extension MetodoPagoExtension on MetodoPago {
  String get nombre {
    switch (this) {
      case MetodoPago.efectivo:
        return 'Efectivo';
      case MetodoPago.tarjeta:
        return 'Tarjeta';
    }
  }
}

enum EstadoOrden {
  pendiente,
  completada,
  cancelada,
}

extension EstadoOrdenExtension on EstadoOrden {
  String get nombre {
    switch (this) {
      case EstadoOrden.pendiente:
        return 'Pendiente';
      case EstadoOrden.completada:
        return 'Completada';
      case EstadoOrden.cancelada:
        return 'Cancelada';
    }
  }
}

enum FiltroTiempo {
  hoy,
  quincenal,
  mensual,
}

extension FiltroTiempoExtension on FiltroTiempo {
  String get nombre {
    switch (this) {
      case FiltroTiempo.hoy:
        return 'HOY';
      case FiltroTiempo.quincenal:
        return 'QUINCENAL';
      case FiltroTiempo.mensual:
        return 'MENSUAL';
    }
  }
}

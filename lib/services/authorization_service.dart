import '../models/activos/autorizacion_activo_model.dart';

class ResultadoAutorizacion {
  final bool permitido;
  final String motivo;
  final AutorizacionActivo? autorizacionAplicada;

  const ResultadoAutorizacion({
    required this.permitido,
    required this.motivo,
    this.autorizacionAplicada,
  });

  static ResultadoAutorizacion permitir(
    AutorizacionActivo autorizacion,
  ) {
    return ResultadoAutorizacion(
      permitido: true,
      motivo: 'Autorización activa y compatible con la acción solicitada.',
      autorizacionAplicada: autorizacion,
    );
  }

  static ResultadoAutorizacion denegar(String motivo) {
    return ResultadoAutorizacion(
      permitido: false,
      motivo: motivo,
    );
  }
}

class AuthorizationService {
  const AuthorizationService();

  ResultadoAutorizacion evaluar({
    required String usuarioId,
    required String activoId,
    required PermisoAutorizacion permiso,
    required AmbitoAutorizacion ambito,
    required DateTime fechaHora,
    required List<AutorizacionActivo> autorizaciones,
  }) {
    if (usuarioId.trim().isEmpty) {
      return ResultadoAutorizacion.denegar(
        'Usuario no identificado.',
      );
    }

    if (activoId.trim().isEmpty) {
      return ResultadoAutorizacion.denegar(
        'Activo Agro no identificado.',
      );
    }

    final candidatas = autorizaciones.where((autorizacion) {
      return autorizacion.activoId == activoId &&
          autorizacion.usuarioAutorizado == usuarioId &&
          autorizacion.permiso == permiso;
    }).toList();

    if (candidatas.isEmpty) {
      return ResultadoAutorizacion.denegar(
        'No existe una autorización para el usuario, Activo Agro y permiso solicitados.',
      );
    }

    for (final autorizacion in candidatas) {
      if (autorizacion.estado != EstadoAutorizacion.activa) {
        continue;
      }

      if (fechaHora.isBefore(autorizacion.fechaInicio)) {
        continue;
      }

      if (autorizacion.fechaFin != null &&
          fechaHora.isAfter(autorizacion.fechaFin!)) {
        continue;
      }

      if (!_ambitoCompatible(
        autorizacion.ambito,
        ambito,
      )) {
        continue;
      }

      return ResultadoAutorizacion.permitir(autorizacion);
    }

    return ResultadoAutorizacion.denegar(
      'Existe una autorización, pero ninguna está activa, vigente y compatible con el ámbito solicitado.',
    );
  }

  bool _ambitoCompatible(
    AmbitoAutorizacion autorizado,
    AmbitoAutorizacion solicitado,
  ) {
    if (autorizado.tipo != solicitado.tipo) {
      return false;
    }

    if (autorizado.referenciaId == null ||
        autorizado.referenciaId!.trim().isEmpty) {
      return true;
    }

    return autorizado.referenciaId == solicitado.referenciaId;
  }
}

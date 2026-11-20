import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../produccion/produccion_estilo.dart';

/// QA Grupo B (18/11/2026): "Primeros pasos" en la ficha del campo.
///
/// En el QA se vio que sin ayuda cuesta saber por dónde empezar. Esta
/// tarjeta muestra 5 pasos que se tildan solos con datos que ya existen,
/// y cada renglón lleva directo a su pantalla. Desaparece cuando están
/// los 5. No guarda nada nuevo.
enum PasoInicial { mapa, documento, suelo, lugares, animalesOCultivos }

class EstadoPrimerosPasos {
  final Set<PasoInicial> hechos;

  const EstadoPrimerosPasos(this.hechos);

  /// Calcula qué pasos están hechos. No usa Firebase: recibe los datos.
  factory EstadoPrimerosPasos.calcular({
    required bool tieneMapa,
    required int documentos,
    required String estadoSuelo,
    required int lugares,
    required int animalesOCultivos,
  }) {
    return EstadoPrimerosPasos({
      if (tieneMapa) PasoInicial.mapa,
      if (documentos > 0) PasoInicial.documento,
      if (estadoSuelo.isNotEmpty && estadoSuelo != 'sin_evaluar')
        PasoInicial.suelo,
      if (lugares > 0) PasoInicial.lugares,
      if (animalesOCultivos > 0) PasoInicial.animalesOCultivos,
    });
  }

  factory EstadoPrimerosPasos.desdeActivo(
    ActivoAgroV2 activo, {
    required int lugares,
    required int animalesOCultivos,
  }) {
    return EstadoPrimerosPasos.calcular(
      tieneMapa: activo.ubicacion.tieneCoordenadas,
      documentos: activo.documentacion.documentosEstructurados.length,
      estadoSuelo: activo.suelo.estado,
      lugares: lugares,
      animalesOCultivos: animalesOCultivos,
    );
  }

  bool hecho(PasoInicial paso) => hechos.contains(paso);

  int get cantidadHechos => hechos.length;

  bool get completos => hechos.length == PasoInicial.values.length;
}

String textoPaso(PasoInicial paso) {
  switch (paso) {
    case PasoInicial.mapa:
      return 'Marcá el campo en el mapa';
    case PasoInicial.documento:
      return 'Cargá un documento';
    case PasoInicial.suelo:
      return 'Cargá el suelo';
    case PasoInicial.lugares:
      return 'Cargá tus potreros, lotes o galpones';
    case PasoInicial.animalesOCultivos:
      return 'Cargá tus animales o cultivos';
  }
}

String ayudaPaso(PasoInicial paso) {
  switch (paso) {
    case PasoInicial.mapa:
      return 'Buscá el pueblo o pegá las coordenadas';
    case PasoInicial.documento:
      return 'Escritura, permiso, certificación...';
    case PasoInicial.suelo:
      return 'Textura, pH, materia orgánica';
    case PasoInicial.lugares:
      return 'En Producción → "+ Lote o potrero"';
    case PasoInicial.animalesOCultivos:
      return 'En Producción → "+ Cargar"';
  }
}

/// La tarjeta: título con el avance y un renglón por paso.
class TarjetaPrimerosPasos extends StatelessWidget {
  final EstadoPrimerosPasos estado;
  final void Function(PasoInicial paso) alTocar;

  const TarjetaPrimerosPasos({
    super.key,
    required this.estado,
    required this.alTocar,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaBlanca(
      colorBorde: AgroTema.terracota,
      colorFondo: AgroTema.terracotaClaro,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconoCirculo(Icons.flag,
                    color: AgroTema.terracota, tamano: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Primeros pasos · ${estado.cantidadHechos} de '
                    '${PasoInicial.values.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.pizarra,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final paso in PasoInicial.values) _renglon(paso),
          ],
        ),
      ),
    );
  }

  Widget _renglon(PasoInicial paso) {
    final hecho = estado.hecho(paso);
    return InkWell(
      onTap: () => alTocar(paso),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              hecho ? Icons.check_circle : Icons.radio_button_unchecked,
              color: hecho ? AgroTema.verde : AgroTema.pizarraSuave,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    textoPaso(paso),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: hecho ? FontWeight.w400 : FontWeight.w600,
                      color: hecho ? AgroTema.pizarraSuave : AgroTema.pizarra,
                      decoration: hecho ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (!hecho)
                    Text(
                      ayudaPaso(paso),
                      style: const TextStyle(
                          fontSize: 12, color: AgroTema.pizarraSuave),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AgroTema.pizarraSuave),
          ],
        ),
      ),
    );
  }
}

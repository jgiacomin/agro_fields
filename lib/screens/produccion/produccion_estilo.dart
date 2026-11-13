import 'package:flutter/material.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_existencias.dart';

/// Colores, piezas y textos compartidos por las pantallas de produccion
/// (paso 6a, GAP-PROD-01). Botones grandes para usar con el dedo en el
/// campo; se elige tocando en lugar de escribir.
///
/// Los colores salen de AgroTema (lib/core/theme/agro_tema.dart), para que
/// toda la app use la misma paleta (referencia visual del 10/11/2026).
class EstiloProduccion {
  static const Color fondo = AgroTema.crema;
  static const Color terracota = AgroTema.terracota;
  static const Color verde = AgroTema.verde;
  static const Color verdeClaro = AgroTema.verdeClaro;
  static const Color texto = AgroTema.pizarra;
  static const Color textoSuave = AgroTema.pizarraSuave;
  static const Color borde = AgroTema.borde;
  static const Color rojo = AgroTema.rojo;
  static const Color rojoFondo = AgroTema.rojoFondo;
  static const Color rojoBorde = AgroTema.rojoBorde;
  static const Color dorado = AgroTema.dorado;
  static const Color terracotaClaro = AgroTema.terracotaClaro;
}

/// Diseño V8 campo (13/11/2026): el botón lleno va con un degradé
/// naranja suave; el de contorno, blanco con borde naranja. Ícono opcional.
class BotonGrande extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool ocupado;
  final bool contorno;
  final IconData? icono;

  /// Flecha a la derecha (como en la demo), para botones que abren otra
  /// pantalla.
  final bool flecha;

  const BotonGrande({
    super.key,
    required this.texto,
    required this.onPressed,
    this.ocupado = false,
    this.contorno = false,
    this.icono,
    this.flecha = false,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = ocupado
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 22),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  texto,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
    final conFlecha = flecha && !ocupado
        ? Row(
            children: [
              const SizedBox(width: 24),
              Expanded(child: Center(child: contenido)),
              const Icon(Icons.chevron_right, size: 26),
            ],
          )
        : contenido;
    final activo = onPressed != null && !ocupado;

    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: contorno
          ? OutlinedButton(
              onPressed: ocupado ? null : onPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: EstiloProduccion.terracota,
                side: const BorderSide(
                  color: EstiloProduccion.terracota,
                  width: 1.5,
                ),
                shape: forma,
              ),
              child: conFlecha,
            )
          : DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: activo
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AgroTema.terracotaVivo,
                          AgroTema.terracotaOscuro,
                        ],
                      )
                    : null,
                color: activo ? null : const Color(0xFFE7DED2),
              ),
              child: ElevatedButton(
                onPressed: ocupado ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: forma,
                ),
                child: conFlecha,
              ),
            ),
    );
  }
}

/// Diseño V8 campo (13/11/2026): título de sección como banda oscura con
/// ícono dorado y una línea dorada abajo.
class TituloSeccion extends StatelessWidget {
  final String texto;
  final IconData? icono;

  const TituloSeccion(this.texto, {super.key, this.icono});

  @override
  Widget build(BuildContext context) {
    // Como en la demo: la banda oscura sigue hacia la derecha con un
    // pedazo del paisaje que se funde con el fondo.
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 44,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [Color(0x00000000), Color(0xCC000000)],
                    stops: [0.25, 1.0],
                  ).createShader(r),
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/encabezado_campo.jpg',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0.4, 0.9),
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _bandaTitulo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandaTitulo() {
    return Container(
          height: 44,
          padding: const EdgeInsets.fromLTRB(16, 9, 26, 9),
          decoration: const BoxDecoration(
            color: EstiloProduccion.texto,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(28),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
            border: Border(
              bottom: BorderSide(color: EstiloProduccion.dorado, width: 3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icono != null) ...[
                Icon(icono, size: 22, color: EstiloProduccion.dorado),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

/// Diseño V8 campo (13/11/2026): ícono dentro de un círculo de color suave.
class IconoCirculo extends StatelessWidget {
  final IconData icono;
  final Color color;
  final double tamano;

  const IconoCirculo(this.icono,
      {super.key, required this.color, this.tamano = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: color.withAlpha(48),
        shape: BoxShape.circle,
      ),
      child: Icon(icono, color: color, size: tamano * 0.55),
    );
  }
}

/// Diseño V8 campo: pone un ícono en círculo a la izquierda del contenido
/// de una tarjeta.
class FilaConIcono extends StatelessWidget {
  final IconData icono;
  final Color color;
  final Widget child;

  const FilaConIcono(
      {super.key,
      required this.icono,
      required this.color,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconoCirculo(icono, color: color, tamano: 48),
        ),
        Expanded(child: child),
      ],
    );
  }
}

/// Diseño V8 campo: fila de números grandes de colores (resumen arriba).
class ResumenNumeros extends StatelessWidget {
  /// (número, texto, ícono, color)
  final List<(String, String, IconData, Color)> datos;

  const ResumenNumeros(this.datos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < datos.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: datos[i].$4.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: datos[i].$4.withAlpha(90)),
              ),
              child: Row(
                children: [
                  Icon(datos[i].$3, color: datos[i].$4, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          datos[i].$1,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: datos[i].$4,
                          ),
                        ),
                        Text(
                          datos[i].$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: EstiloProduccion.textoSuave),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Diseño V8 campo: pantalla o sección vacía, con un ícono grande y el
/// texto que invita a empezar (en vez de un texto suelto).
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String texto;

  const EstadoVacio({super.key, required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6D6BC)),
      ),
      child: Row(
        children: [
          IconoCirculo(icono, color: EstiloProduccion.terracota, tamano: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: EstiloProduccion.textoSuave),
            ),
          ),
        ],
      ),
    );
  }
}

class TarjetaBlanca extends StatelessWidget {
  final Widget child;
  final Color colorBorde;
  final Color colorFondo;
  final VoidCallback? onTap;

  const TarjetaBlanca({
    super.key,
    required this.child,
    this.colorBorde = const Color(0xFFE6D6BC),
    this.colorFondo = const Color(0xFFFFFAF2),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorFondo,
      // Diseño V8 campo: sombra suave para que la tarjeta se despegue.
      elevation: 1.5,
      shadowColor: const Color(0x22000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorBorde),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: child),
    );
  }
}

/// Fila de opciones para elegir tocando (una sola a la vez).
class OpcionesTocar<T> extends StatelessWidget {
  final List<T> opciones;
  final T? elegida;
  final String Function(T) etiqueta;
  final ValueChanged<T> alElegir;

  const OpcionesTocar({
    super.key,
    required this.opciones,
    required this.elegida,
    required this.etiqueta,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: opciones.map((opcion) {
        final activa = opcion == elegida;
        return ChoiceChip(
          label: Text(etiqueta(opcion)),
          selected: activa,
          onSelected: (_) => alElegir(opcion),
          showCheckmark: false,
          labelStyle: TextStyle(
            fontSize: 15,
            fontWeight: activa ? FontWeight.w600 : FontWeight.w400,
            color: activa ? const Color(0xFF1F4A27) : EstiloProduccion.texto,
          ),
          selectedColor: EstiloProduccion.verdeClaro,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: activa ? EstiloProduccion.verde : const Color(0xFFC9CFC2),
            width: activa ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        );
      }).toList(),
    );
  }
}

/// Etiqueta de un campo de formulario.
class EtiquetaCampo extends StatelessWidget {
  final String texto;

  const EtiquetaCampo(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 18),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}

InputDecoration decoracionCampo({String? ayuda}) {
  return InputDecoration(
    hintText: ayuda,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  );
}

// -------------------------------------------------------------------
// Textos en castellano
// -------------------------------------------------------------------

String nombreCategoria(String clave, {int cantidad = 2}) {
  const plurales = {
    'vaca': 'Vacas',
    'vaquillona': 'Vaquillonas',
    'toro': 'Toros',
    'ternero': 'Terneros',
    'ternera': 'Terneras',
    'novillito': 'Novillitos',
    'novillo': 'Novillos',
  };
  const singulares = {
    'vaca': 'Vaca',
    'vaquillona': 'Vaquillona',
    'toro': 'Toro',
    'ternero': 'Ternero',
    'ternera': 'Ternera',
    'novillito': 'Novillito',
    'novillo': 'Novillo',
  };
  final tabla = cantidad == 1 ? singulares : plurales;
  if (tabla.containsKey(clave)) return tabla[clave]!;
  if (clave.isEmpty) return clave;
  return clave[0].toUpperCase() + clave.substring(1);
}

String nombreEtapa(EtapaGanadera etapa) {
  switch (etapa) {
    case EtapaGanadera.cria:
      return 'Cría';
    case EtapaGanadera.recriaPastoril:
      return 'Recría pastoril';
    case EtapaGanadera.recriaCorral:
      return 'Recría a corral';
    case EtapaGanadera.recriaMixta:
      return 'Recría mixta';
    case EtapaGanadera.terminacion:
      return 'Terminación';
    case EtapaGanadera.feedlot:
      return 'Feedlot';
    case EtapaGanadera.otra:
      return 'Otra';
  }
}

String nombreTenencia(TenenciaAnimales tenencia) {
  switch (tenencia) {
    case TenenciaAnimales.propios:
      return 'Propios';
    case TenenciaAnimales.capitalizacion:
      return 'Capitalización';
    case TenenciaAnimales.hoteleria:
      return 'Hotelería';
    case TenenciaAnimales.desconocida:
      return 'No sé';
  }
}

String nombreTipoUnidad(TipoUnidadProductiva tipo) {
  switch (tipo) {
    case TipoUnidadProductiva.potrero:
      return 'Potrero';
    case TipoUnidadProductiva.corral:
      return 'Corral';
    case TipoUnidadProductiva.lote:
      return 'Lote';
    case TipoUnidadProductiva.galpon:
      return 'Galpón';
    case TipoUnidadProductiva.tambo:
      return 'Tambo';
    case TipoUnidadProductiva.invernadero:
      return 'Invernadero';
    case TipoUnidadProductiva.estanque:
      return 'Estanque';
    case TipoUnidadProductiva.apiario:
      return 'Apiario';
    case TipoUnidadProductiva.otro:
      return 'Otro';
  }
}

String nombreOrigen(OrigenAlta origen) {
  switch (origen) {
    case OrigenAlta.nacimiento:
      return 'Nacimiento';
    case OrigenAlta.compra:
      return 'Compra';
    case OrigenAlta.capitalizacion:
      return 'Capitalización';
    case OrigenAlta.hoteleria:
      return 'Hotelería';
    case OrigenAlta.otro:
      return 'Otro';
  }
}

String nombreMotivo(MotivoBaja motivo) {
  switch (motivo) {
    case MotivoBaja.venta:
      return 'Venta';
    case MotivoBaja.muerte:
      return 'Muerte';
    case MotivoBaja.consumo:
      return 'Consumo';
    case MotivoBaja.traslado:
      return 'Traslado';
    case MotivoBaja.otro:
      return 'Otro';
  }
}

String nombreTipoEvento(TipoEventoProductivo tipo) {
  switch (tipo) {
    case TipoEventoProductivo.alta:
      return 'Entrada';
    case TipoEventoProductivo.baja:
      return 'Salida';
    case TipoEventoProductivo.movimiento:
      return 'Cambio de potrero';
    case TipoEventoProductivo.cambioCategoria:
      return 'Cambio de categoría';
    case TipoEventoProductivo.sanidad:
      return 'Vacuna o tratamiento';
    case TipoEventoProductivo.reproduccion:
      return 'Reproducción';
    case TipoEventoProductivo.pesaje:
      return 'Pesaje';
    case TipoEventoProductivo.alimentacion:
      return 'Alimentación';
    case TipoEventoProductivo.siembra:
      return 'Siembra';
    case TipoEventoProductivo.cosecha:
      return 'Cosecha';
    case TipoEventoProductivo.monitoreo:
      return 'Monitoreo';
    case TipoEventoProductivo.aplicacion:
      return 'Aplicación';
  }
}

String nombreEstadoDato(EstadoDatoEvento estado) {
  switch (estado) {
    case EstadoDatoEvento.declarado:
      return 'Declarado';
    case EstadoDatoEvento.conEvidencia:
      return 'Con evidencia';
    case EstadoDatoEvento.verificado:
      return 'Verificado';
  }
}

String fechaCorta(DateTime fecha) {
  final d = fecha.day.toString().padLeft(2, '0');
  final m = fecha.month.toString().padLeft(2, '0');
  return '$d/$m/${fecha.year}';
}

/// Nombre de una unidad a partir de su ID; si no se encuentra, lo dice.
String nombreUnidad(String unidadId, Map<String, UnidadProductiva> unidades) {
  if (unidadId == sinUbicacion) return 'Sin ubicación';
  return unidades[unidadId]?.nombre ?? 'Unidad desconocida';
}

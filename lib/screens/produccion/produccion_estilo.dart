import 'package:flutter/material.dart';

import '../../models/activos/evento_productivo_model.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../models/activos/unidad_productiva_model.dart';
import '../../services/calculo_existencias.dart';

/// Colores, piezas y textos compartidos por las pantallas de produccion
/// (paso 6a, GAP-PROD-01). Botones grandes para usar con el dedo en el
/// campo; se elige tocando en lugar de escribir.
class EstiloProduccion {
  static const Color fondo = Color(0xFFF6F7F3);
  static const Color verde = Color(0xFF2F6B3A);
  static const Color verdeClaro = Color(0xFFE7F0E5);
  static const Color texto = Color(0xFF1C2419);
  static const Color textoSuave = Color(0xFF4A5547);
  static const Color borde = Color(0xFFE3E6DE);
  static const Color rojo = Color(0xFF912018);
  static const Color rojoFondo = Color(0xFFFEF3F2);
  static const Color rojoBorde = Color(0xFFF4C7C2);
}

class BotonGrande extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool ocupado;
  final bool contorno;

  const BotonGrande({
    super.key,
    required this.texto,
    required this.onPressed,
    this.ocupado = false,
    this.contorno = false,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = ocupado
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(
            texto,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          );

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
                foregroundColor: EstiloProduccion.verde,
                side: const BorderSide(
                  color: EstiloProduccion.verde,
                  width: 1.5,
                ),
                shape: forma,
              ),
              child: contenido,
            )
          : ElevatedButton(
              onPressed: ocupado ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: EstiloProduccion.verde,
                foregroundColor: Colors.white,
                shape: forma,
              ),
              child: contenido,
            ),
    );
  }
}

class TituloSeccion extends StatelessWidget {
  final String texto;

  const TituloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: EstiloProduccion.textoSuave,
        ),
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
    this.colorBorde = EstiloProduccion.borde,
    this.colorFondo = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorFondo,
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

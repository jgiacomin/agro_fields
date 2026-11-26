import 'package:flutter/material.dart';

import '../core/theme/agro_tema.dart';
import '../models/activos/activo_agro_model_v2.dart';
import '../screens/campos/detalle_activo_agro_screen.dart'
    show actividadesDeclaradas;
import '../screens/produccion/produccion_activo_screen.dart'
    show nombreActividad;
import '../screens/produccion/produccion_estilo.dart';

/// GAP-EDITAR-01 (26/11/2026): la tarjeta completa de un campo (la que
/// estaba en "Mis campos"), para el Inicio. Tocarla abre la ficha; el
/// botón ✏️ "Editar" abre "Editar campo" (solo si [alEditar] no es null:
/// dueño o broker del campo).
class TarjetaCampo extends StatelessWidget {
  final ActivoAgroV2 activo;

  /// Actividades cargadas en Producción (null = no se pudieron leer).
  final List<String>? actividadesCargadas;
  final VoidCallback alAbrir;
  final VoidCallback? alEditar;

  const TarjetaCampo({
    super.key,
    required this.activo,
    required this.alAbrir,
    this.alEditar,
    this.actividadesCargadas,
  });

  static String _estadoTexto(String estado) {
    switch (estado) {
      case 'publicado':
        return 'Publicado';
      case 'borrador':
        return 'Borrador';
      case 'verificado':
        return 'Verificado';
      case 'pendienteRevision':
        return 'En revisión';
      case 'pausado':
        return 'Pausado';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = activo.ubicacion;
    final lugar = [u.localidad, u.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    // AF-135: lo declarado al crear el campo + lo cargado en Producción.
    final cargadas = actividadesCargadas;
    final declaradas = actividadesDeclaradas(activo);
    final actividades = cargadas == null && declaradas.isEmpty
        ? null
        : [
            ...declaradas,
            ...?cargadas?.where((a) => !declaradas.contains(a)),
          ];
    // QA 26/11/2026: el estado de la publicación (el que cambia el admin).
    final estado = activo.estadoPublicacion;
    final avance = activo.madurez.porcentaje.clamp(0, 100).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TarjetaBlanca(
        // Se toca la tarjeta entera para entrar a la ficha.
        onTap: alAbrir,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const IconoCirculo(Icons.grass,
                      color: AgroTema.verde, tamano: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activo.nombre,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AgroTema.pizarra,
                          ),
                        ),
                        // GAP-BROKER-01: campo cargado para un cliente.
                        if (activo.sinDueno)
                          Text(
                            activo.duenoDeclarado == null
                                ? 'Campo de un cliente'
                                : 'Cliente: ${activo.duenoDeclarado}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AgroTema.azul,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.place,
                                size: 16, color: AgroTema.terracota),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lugar.isEmpty
                                    ? "Ubicación sin información"
                                    : lugar,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AgroTema.pizarraSuave),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AgroTema.pizarraSuave),
                ],
              ),
              if (activo.descripcion.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  activo.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, color: AgroTema.pizarra),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (actividades != null)
                    _chip(
                      Icons.agriculture,
                      actividades.isEmpty
                          ? "Sin actividades cargadas"
                          : actividades.map(nombreActividad).join(" · "),
                      actividades.isEmpty
                          ? AgroTema.pizarraSuave
                          : AgroTema.verde,
                    ),
                  // GAP-MERC-01: lo que se ofrece en el Mercado.
                  for (final o in activo.economia.ofertas)
                    _chip(Icons.sell_outlined, o.texto, AgroTema.azul),
                  _chip(
                    estado == "publicado"
                        ? Icons.storefront
                        : estado == "pendienteRevision"
                            ? Icons.hourglass_top
                            : Icons.edit_note,
                    _estadoTexto(estado),
                    estado == "publicado"
                        ? AgroTema.azul
                        : estado == "pendienteRevision"
                            ? AgroTema.dorado
                            : AgroTema.terracota,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    "Expediente",
                    style: TextStyle(
                        fontSize: 13, color: AgroTema.pizarraSuave),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: avance / 100,
                        minHeight: 8,
                        backgroundColor: AgroTema.borde,
                        color: AgroTema.verde,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${avance.round()}%",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AgroTema.pizarra,
                    ),
                  ),
                ],
              ),
              // GAP-EDITAR-01: el mismo ✏️ en todos lados (dueño o broker).
              if (alEditar != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: alEditar,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AgroTema.terracota,
                      side: const BorderSide(color: AgroTema.terracota),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Widget _chip(IconData icono, String texto, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              texto,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/agro_tema.dart';
import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/activos/grupo_productivo_model.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/produccion_service.dart';
import '../produccion/produccion_activo_screen.dart'
    show actividadDeGrupo, nombreActividad;
import '../produccion/produccion_estilo.dart';

import 'detalle_activo_agro_screen.dart';
import 'publicar_campo_screen.dart';
import '../../widgets/barra_campo.dart';

class MisActivosScreen extends StatefulWidget {
  const MisActivosScreen({super.key});

  @override
  State<MisActivosScreen> createState() => _MisActivosScreenState();
}

class _MisActivosScreenState extends State<MisActivosScreen> {
  final ActivoAgroServiceV2 servicio = ActivoAgroServiceV2();

  List<ActivoAgroV2> activos = [];

  /// Diseño "Mis campos" (24/11/2026): actividades reales de cada campo,
  /// sacadas de lo cargado en Producción (no del "tipo", que siempre
  /// quedaba "agrícola"). Si no se pueden leer, no se muestran.
  Map<String, List<String>> actividadesPorCampo = {};

  bool cargando = true;

  @override
  void initState() {
    super.initState();

    cargarActivos();
  }

  Future<void> cargarActivos() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }

      return;
    }

    try {
      final resultado = await servicio.buscarPorPropietario(usuario.uid);
      final resultadoActualizado = <ActivoAgroV2>[];

      for (final activo in resultado) {
        final actualizado = await servicio.obtenerActivoPorId(activo.activoId);

        resultadoActualizado.add(actualizado ?? activo);
      }

      for (final activo in resultado) {
        debugPrint(
          '🔎 ACTIVO ${activo.nombre} | '
          'confianza=${activo.confianza.nivelGeneral} | '
          'madurez=${activo.madurez.porcentaje} | '
          'estado=${activo.estado.name} | '
          'publicacion=${activo.estadoPublicacion} | '
          'visible=${activo.visible}',
        );
      }

      if (!mounted) {
        return;
      }

      // QA T1-02 (18/11/2026): el más nuevo primero.
      resultadoActualizado
          .sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      final actividades = await _leerActividades(resultadoActualizado);

      if (!mounted) {
        return;
      }

      setState(() {
        activos = resultadoActualizado;
        actividadesPorCampo = actividades;

        cargando = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        cargando = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error cargando activos: $e")));
    }
  }

  /// Diseño "Mis campos": actividades de cada campo (en paralelo).
  Future<Map<String, List<String>>> _leerActividades(
      List<ActivoAgroV2> campos) async {
    final produccion = ProduccionService();
    const orden = ['ganaderia', 'agricultura', 'avicultura', 'piscicultura'];
    final resultado = <String, List<String>>{};
    await Future.wait(campos.map((c) async {
      try {
        final grupos = await produccion.gruposDeActivo(c.activoId);
        final presentes = grupos
            .where((g) => g.estado == EstadoGrupoProductivo.activo)
            .map(actividadDeGrupo)
            .toSet();
        resultado[c.activoId] = [
          ...orden.where(presentes.contains),
          ...presentes.where((a) => !orden.contains(a)),
        ];
      } catch (_) {
        // Sin señal o sin permiso: ese campo queda sin chips de actividad.
      }
    }));
    return resultado;
  }

  String estadoTexto(String estado) {
    switch (estado) {
      case "publicado":
        return "Publicado";

      case "borrador":
        return "Borrador";

      case "verificado":
        return "Verificado";

      case "pendienteRevision":
        return "En revisión";

      default:
        return estado;
    }
  }

  /// GAP-MERC-01 Parte A: publicar abre "Publicar en el Mercado"
  /// (operación y precio). Si se envió, se recarga la lista.
  Future<void> abrirPublicar(ActivoAgroV2 activo) async {
    final envio = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PublicarCampoScreen(activo: activo),
      ),
    );
    if (envio == true) await cargarActivos();
  }

  Future<void> publicar(String id) async {
    try {
      await servicio.publicarActivo(id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Enviado a revisión: se verá en el marketplace cuando se apruebe 🚜",
          ),
        ),
      );

      await cargarActivos();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _abrirFicha(ActivoAgroV2 activo) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleActivoAgroScreen(activo: activo),
      ),
    );

    await cargarActivos();
  }

  @override
  Widget build(BuildContext context) {
    // Diseño "Mis campos" (24/11/2026): mismo estilo que la ficha.
    return Scaffold(
      appBar: BarraCampo(title: const Text("Mis campos")),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : activos.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: EstadoVacio(
                icono: Icons.agriculture,
                texto: "Todavía no tenés campos cargados.",
              ),
            )
          : RefreshIndicator(
              onRefresh: cargarActivos,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: activos.length,
                itemBuilder: (context, index) =>
                    _tarjetaCampo(activos[index]),
              ),
            ),
    );
  }

  Widget _tarjetaCampo(ActivoAgroV2 activo) {
    final u = activo.ubicacion;
    final lugar = [u.localidad, u.provincia]
        .where((x) => x.trim().isNotEmpty)
        .join(', ');
    // AF-135: lo declarado al crear el campo + lo cargado en Producción.
    final cargadas = actividadesPorCampo[activo.activoId];
    final declaradas = actividadesDeclaradas(activo);
    final actividades = cargadas == null && declaradas.isEmpty
        ? null
        : [
            ...declaradas,
            ...?cargadas?.where((a) => !declaradas.contains(a)),
          ];
    final estado = activo.estado.name;
    final yaEnviado = estado == "publicado" || estado == "pendienteRevision";
    final avance = activo.madurez.porcentaje.clamp(0, 100).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TarjetaBlanca(
        // Se toca la tarjeta entera para entrar a la ficha.
        onTap: () => _abrirFicha(activo),
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
                    estadoTexto(estado),
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
              if (!yaEnviado) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => abrirPublicar(activo),
                    icon: const Icon(Icons.publish, size: 18),
                    label: const Text("Publicar en el Mercado"),
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

  Widget _chip(IconData icono, String texto, Color color) {
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
  }
}

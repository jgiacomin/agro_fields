import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';
import '../operaciones/operaciones_activo_screen.dart';
import '../produccion/produccion_activo_screen.dart';

class DetalleActivoAgroScreen extends StatefulWidget {
  final ActivoAgroV2 activo;

  const DetalleActivoAgroScreen({super.key, required this.activo});

  @override
  State<DetalleActivoAgroScreen> createState() =>
      _DetalleActivoAgroScreenState();
}

class _DetalleActivoAgroScreenState extends State<DetalleActivoAgroScreen> {
  final ActivoAgroServiceV2 _activoService = ActivoAgroServiceV2();

  late ActivoAgroV2 activo;

  bool evaluando = false;
  Future<void> evaluarActivo() async {
    if (evaluando) {
      return;
    }

    setState(() {
      evaluando = true;
    });

    try {
      await _activoService.evaluarActivo(activo.activoId);

      final actualizado = await _activoService.obtenerActivoPorId(
        activo.activoId,
      );

      if (actualizado == null) {
        throw Exception('No se pudo recuperar el activo actualizado');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        activo = actualizado;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluación de confianza realizada correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error evaluando activo: $e')));
    } finally {
      if (mounted) {
        setState(() {
          evaluando = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    activo = widget.activo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(activo.nombre)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              activo.nombre,

              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(activo.descripcion, style: const TextStyle(fontSize: 16)),

            const Divider(height: 30),

            _titulo("Ubicación"),

            Text("País: ${activo.ubicacion.pais}"),

            Text("Provincia: ${activo.ubicacion.provincia}"),

            Text("Localidad: ${activo.ubicacion.localidad}"),

            Text("Superficie: ${activo.ubicacion.superficie} ha"),

            const Divider(height: 30),

            _titulo("Clasificación"),

            _titulo("Suelo"),

            Text("Estado: ${activo.suelo.estado}"),

            Text("Textura: ${activo.suelo.textura ?? 'Sin registrar'}"),

            Text("Drenaje: ${activo.suelo.drenaje ?? 'Sin registrar'}"),

            Text("pH: ${activo.suelo.ph?.toString() ?? 'Sin registrar'}"),

            Text(
              "Materia orgánica: ${activo.suelo.materiaOrganica?.toString() ?? 'Sin registrar'}",
            ),

            Text("Evidencias: ${activo.suelo.evidencias.length}"),

            if (activo.suelo.observaciones != null &&
                activo.suelo.observaciones!.isNotEmpty)
              Text("Observaciones: ${activo.suelo.observaciones}"),

            if (activo.suelo.fechaEvaluacion != null)
              Text("Fecha de evaluación: ${activo.suelo.fechaEvaluacion}"),

            const Divider(height: 30),

            Text("Tipo: ${activo.tipoActivo.name}"),

            Text(
              "Categorías: "
              "${activo.categorias.join(', ')}",
            ),
            const Divider(height: 30),

            _titulo("Producción"),
            if (activo.produccionPrincipal != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Actividad: "
                    "${activo.produccionPrincipal!.actividad}",
                  ),
                  Text(activo.produccionPrincipal!.descripcion),
                ],
              )
            else
              const Text("Sin producción registrada"),

            // Paso 6a (GAP-PROD-01): rodeos, potreros y eventos.
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProduccionActivoScreen(
                      activoAgroId: activo.activoId,
                      nombreActivo: activo.nombre,
                    ),
                  ),
                ),
                icon: const Icon(Icons.pets),
                label: const Text('Producción'),
              ),
            ),
            // Paso 7a (GAP-OPER-01): ventas protegidas antes de entregar.
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OperacionesActivoScreen(
                      activoAgroId: activo.activoId,
                      nombreActivo: activo.nombre,
                    ),
                  ),
                ),
                icon: const Icon(Icons.verified_user),
                label: const Text('Operaciones protegidas'),
              ),
            ),

                        const Divider(height: 30),

            _titulo("Economía"),

            Text(
              "Valor solicitado: "
              "${activo.economia.valorSolicitado} "
              "${activo.economia.moneda}",
            ),

            Text(
              "Tipo de operación: "
              "${activo.economia.tipoOperacion.isEmpty ? 'Sin registrar' : activo.economia.tipoOperacion}",
            ),

            Text(
              "Capital requerido: "
              "${activo.economia.capitalRequerido} "
              "${activo.economia.moneda}",
            ),

            Text(
              "Inversión esperada: "
              "${activo.economia.inversionEsperada} "
              "${activo.economia.moneda}",
            ),

            Text(
              "Período de evaluación: "
              "${activo.economia.periodoEvaluacion.isEmpty ? 'Sin registrar' : activo.economia.periodoEvaluacion}",
            ),

            if (activo.economia.objetivoProyecto.isNotEmpty)
              Text(
                "Objetivo: ${activo.economia.objetivoProyecto}",
              ),

            if (activo.economia.etapaProyecto.isNotEmpty)
              Text(
                "Etapa: ${activo.economia.etapaProyecto}",
              ),

            if (activo.economia.capacidadActual.isNotEmpty)
              Text(
                "Capacidad actual: ${activo.economia.capacidadActual}",
              ),

            if (activo.economia.capacidadProyectada.isNotEmpty)
              Text(
                "Capacidad proyectada: ${activo.economia.capacidadProyectada}",
              ),

            if (activo.economia.ingresosEstimados.isNotEmpty)
              Text(
                "Ingresos estimados: ${activo.economia.ingresosEstimados}",
              ),

            if (activo.economia.costosEstimados.isNotEmpty)
              Text(
                "Costos estimados: ${activo.economia.costosEstimados}",
              ),

            if (activo.economia.rentabilidadDeclarada.isNotEmpty)
              Text(
                "Rentabilidad declarada: ${activo.economia.rentabilidadDeclarada}",
              ),

            if (activo.economia.riesgosIdentificados.isNotEmpty)
              Text(
                "Riesgos identificados: ${activo.economia.riesgosIdentificados}",
              ),

            if (activo.economia.datosEconomicos.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Text(
                "Datos económicos trazables",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...activo.economia.datosEconomicos.map(
                (dato) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dato.nombreDato,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Valor: ${dato.valor}",
                      ),
                      Text(
                        "Tipo: ${dato.tipoTemporal.name}",
                      ),
                      Text(
                        "Período: ${dato.periodo}",
                      ),
                      if (dato.escenarioId != null &&
                          dato.escenarioId!.isNotEmpty)
                        Text(
                          "Escenario: ${dato.escenarioId}",
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const Divider(height: 30),

            _titulo("Estado del activo"),
            Text(
              "Estado interno: "
              "${activo.estado.name}",
            ),
            _titulo("Infraestructura"),

if (activo.infraestructura.isEmpty)
  const Text("Sin infraestructura registrada")
else
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: activo.infraestructura.map((infraestructura) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tipo: ${infraestructura.tipo}"),
            Text("Nombre: ${infraestructura.nombre}"),
            Text("Descripción: ${infraestructura.descripcion}"),
            Text("Cantidad: ${infraestructura.cantidad}"),
            Text("Estado: ${infraestructura.estado}"),
            if (infraestructura.moduloProduccionId != null &&
                infraestructura.moduloProduccionId!.isNotEmpty)
              Text(
                "Producción relacionada: "
                "${infraestructura.moduloProduccionId}",
              ),
          ],
        ),
      );
    }).toList(),
  ),

const Divider(height: 30),
            Text(
              "Publicación: "
              "${activo.estadoPublicacion}",
            ),
            Text(
              activo.visible
                  ? "Visible públicamente"
                  : "No visible públicamente",
            ),
            const Divider(height: 30),
            _titulo("Confianza"),

            Text(
              "Nivel general: "
              "${activo.confianza.nivelGeneral}%",
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            Text("Evaluación: ${activo.evaluacion.nivelGeneral}%"),

            const SizedBox(height: 8),
            Text(
              "Documental: ${activo.evaluacion.documental.estado} "
              "(${activo.evaluacion.documental.nivel}%)",
            ),
            Text(
              "Productivo: ${activo.evaluacion.productivo.estado} "
              "(${activo.evaluacion.productivo.nivel}%)",
            ),

            Text(
              "Económico: ${activo.evaluacion.economico.estado} "
              "(${activo.evaluacion.economico.nivel}%)",
            ),

            Text(
              "Legal: ${activo.evaluacion.legal.estado} "
              "(${activo.evaluacion.legal.nivel}%)",
            ),

            Text(
              "Profesional: ${activo.evaluacion.profesional.estado} "
              "(${activo.evaluacion.profesional.nivel}%)",
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: evaluando ? null : evaluarActivo,
                icon: evaluando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.analytics),
                label: Text(evaluando ? 'Evaluando...' : 'Evaluar confianza'),
              ),
            ),

            const Divider(height: 30),

            _titulo("Participantes"),

            if (activo.participantes.isEmpty)
              const Text("Sin participantes registrados")
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: activo.participantes.map((participante) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),

                    child: Text(
                      "• Usuario: ${participante.usuarioId} "
                      "(${participante.rol})",
                    ),
                  );
                }).toList(),
              ),
            Text(
              "Evidencias: "
              "${activo.confianza.cantidadEvidencias}",
            ),
            const Divider(height: 30),

            _titulo("Madurez"),

            Text(
              "Porcentaje: "
              "${activo.madurez.porcentaje}%",
            ),

            if (activo.madurez.faltantes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const SizedBox(height: 8),

                  const Text(
                    "Pendientes:",

                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  ...activo.madurez.faltantes.map((e) => Text("• $e")),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

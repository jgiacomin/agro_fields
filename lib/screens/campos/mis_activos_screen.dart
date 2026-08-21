import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';

import 'detalle_activo_agro_screen.dart';

class MisActivosScreen extends StatefulWidget {
  const MisActivosScreen({super.key});

  @override
  State<MisActivosScreen> createState() => _MisActivosScreenState();
}

class _MisActivosScreenState extends State<MisActivosScreen> {
  final ActivoAgroServiceV2 servicio = ActivoAgroServiceV2();

  List<ActivoAgroV2> activos = [];

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

      setState(() {
        activos = resultadoActualizado;

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

  String estadoTexto(String estado) {
    switch (estado) {
      case "publicado":
        return "Publicado";

      case "borrador":
        return "Borrador";

      case "verificado":
        return "Verificado";

      default:
        return estado;
    }
  }

  Future<void> publicar(String id) async {
    try {
      await servicio.publicarActivo(id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Activo publicado correctamente 🚜")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Activos")),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : activos.isEmpty
          ? const Center(child: Text("No tienes activos registrados"))
          : ListView.builder(
              itemCount: activos.length,

              itemBuilder: (context, index) {
                final activo = activos[index];

                return Card(
                  margin: const EdgeInsets.all(12),

                  elevation: 3,

                  child: Padding(
                    padding: const EdgeInsets.all(15),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          activo.nombre,

                          style: const TextStyle(
                            fontSize: 22,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(activo.descripcion),

                        const SizedBox(height: 10),

                        Text(
                          "Estado: "
                          "${estadoTexto(activo.estado.name)}",
                        ),

                        Text(
                          "Tipo: "
                          "${activo.tipoActivo.name}",
                        ),

                        Text(
                          "Ubicación: "
                          "${activo.ubicacion.localidad}, "
                          "${activo.ubicacion.provincia}",
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Text(
                              "Confianza: "
                              "${activo.confianza.nivelGeneral}%",
                            ),

                            const SizedBox(width: 20),

                            Text(
                              "Madurez: "
                              "${activo.madurez.porcentaje}%",
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.visibility),

                                label: const Text("Ver"),

                                onPressed: () async {
                                  await Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetalleActivoAgroScreen(
                                            activo: activo,
                                          ),
                                    ),
                                  );

                                  await cargarActivos();
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.publish),

                                label: Text(
                                  activo.estado.name == "publicado"
                                      ? "Publicado"
                                      : "Publicar",
                                ),

                                onPressed: activo.estado.name == "publicado"
                                    ? null
                                    : () {
                                        publicar(activo.activoId);
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

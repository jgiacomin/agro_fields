import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';



class DetalleActivoAgroScreen extends StatefulWidget {


  final ActivoAgroV2 activo;



  const DetalleActivoAgroScreen({

    super.key,

    required this.activo,

  });

@override
State<DetalleActivoAgroScreen> createState() =>
    _DetalleActivoAgroScreenState();
}

class _DetalleActivoAgroScreenState
    extends State<DetalleActivoAgroScreen> {

  final ActivoAgroServiceV2 _activoService =
      ActivoAgroServiceV2();

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
    await _activoService.evaluarActivo(
      activo.activoId,
    );

    final actualizado =
        await _activoService.obtenerActivoPorId(
      activo.activoId,
    );

    if (actualizado == null) {
      throw Exception(
        'No se pudo recuperar el activo actualizado',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      activo = actualizado;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Evaluación de confianza realizada correctamente',
        ),
      ),
    );
  } catch (e) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error evaluando activo: $e',
        ),
      ),
    );
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


      appBar:

      AppBar(

        title:

        Text(
          activo.nombre,
        ),

      ),





      body:

      SingleChildScrollView(


        padding:

        const EdgeInsets.all(16),




        child:

        Column(


          crossAxisAlignment:

          CrossAxisAlignment.start,



          children:[





            Text(

              activo.nombre,

              style:

              const TextStyle(

                fontSize:26,

                fontWeight:
                FontWeight.bold,

              ),

            ),





            const SizedBox(
              height:10,
            ),






            Text(

              activo.descripcion,

              style:

              const TextStyle(

                fontSize:16,

              ),

            ),






            const Divider(
              height:30,
            ),





            _titulo(
              "Ubicación",
            ),





            Text(

              "País: ${activo.ubicacion.pais}",

            ),



            Text(

              "Provincia: ${activo.ubicacion.provincia}",

            ),



            Text(

              "Localidad: ${activo.ubicacion.localidad}",

            ),



            Text(

              "Superficie: ${activo.ubicacion.superficie} ha",

            ),







            const Divider(
              height:30,
            ),






            _titulo(
              "Clasificación",
            ),

            _titulo(
              "Suelo",
            ),

            Text(
              "Estado: ${activo.suelo.estado}",
            ),

            Text(
              "Textura: ${activo.suelo.textura ?? 'Sin registrar'}",
            ),

            Text(
              "Drenaje: ${activo.suelo.drenaje ?? 'Sin registrar'}",
            ),

            Text(
              "pH: ${activo.suelo.ph?.toString() ?? 'Sin registrar'}",
            ),

            Text(
              "Materia orgánica: ${activo.suelo.materiaOrganica?.toString() ?? 'Sin registrar'}",
            ),

            Text(
              "Evidencias: ${activo.suelo.evidencias.length}",
            ),

            if (activo.suelo.observaciones != null &&
                activo.suelo.observaciones!.isNotEmpty)
              Text(
                "Observaciones: ${activo.suelo.observaciones}",
              ),

            if (activo.suelo.fechaEvaluacion != null)
              Text(
                "Fecha de evaluación: ${activo.suelo.fechaEvaluacion}",
              ),

            const Divider(
              height:30,
            ),






            Text(

              "Tipo: ${activo.tipoActivo.name}",

            ),



            Text(

              "Categorías: "
                  "${activo.categorias.join(', ')}",

            ),






            const Divider(
              height:30,
            ),






            _titulo(
              "Producción",
            ),





            if(activo.produccionPrincipal != null)


              Column(

                crossAxisAlignment:

                CrossAxisAlignment.start,


                children:[



                  Text(

                    "Actividad: "
                        "${activo.produccionPrincipal!.actividad}",

                  ),



                  Text(

                    activo.produccionPrincipal!.descripcion,

                  ),


                ],

              )



            else


              const Text(

                "Sin producción registrada",

              ),







            const Divider(
              height:30,
            ),






            _titulo(
              "Estado del activo",
            ),





            Text(

              "Estado interno: "
                  "${activo.estado.name}",

            ),



            Text(

              "Publicación: "
                  "${activo.estadoPublicacion}",

            ),



            Text(

              activo.visible

                  ?

              "Visible públicamente"

                  :

              "No visible públicamente",

            ),







            const Divider(
              height:30,
            ),






            _titulo(
              "Confianza",
            ),





            Text(

  "Nivel general: "
      "${activo.confianza.nivelGeneral}%",

),

const SizedBox(
  height:10,
),

Text(
  "Evaluación: ${activo.evaluacion.nivelGeneral}%",
),

const SizedBox(
  height: 8,
),
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
        const SizedBox(
  height: 16,
),

SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: evaluando
        ? null
        : evaluarActivo,
    icon: evaluando
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : const Icon(Icons.analytics),
    label: Text(
      evaluando
          ? 'Evaluando...'
          : 'Evaluar confianza',
    ),
  ),
),

            const Divider(
              height:30,
            ),





            _titulo(
              "Participantes",
            ),




            if(activo.participantes.isEmpty)


              const Text(
                "Sin participantes registrados",
              )



            else


              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:


                activo.participantes.map(

                      (participante){


                    return Padding(

                      padding:
                      const EdgeInsets.only(
                        top:8,
                      ),


                    child:

                    Text(

                     "• Usuario: ${participante.usuarioId} "
                  "(${participante.rol})",

                  ),


                    );


                  },

                ).toList(),


              ),


            Text(

              "Evidencias: "
                  "${activo.confianza.cantidadEvidencias}",

            ),






            const Divider(
              height:30,
            ),






            _titulo(
              "Madurez",
            ),





            Text(

              "Porcentaje: "
                  "${activo.madurez.porcentaje}%",

            ),






            if(activo.madurez.faltantes.isNotEmpty)


              Column(

                crossAxisAlignment:

                CrossAxisAlignment.start,


                children:[



                  const SizedBox(
                    height:8,
                  ),



                  const Text(

                    "Pendientes:",

                    style:

                    TextStyle(

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),





                  ...activo.madurez.faltantes.map(

                        (e)=>

                        Text(
                          "• $e",
                        ),

                  ),


                ],

              ),





          ],


        ),


      ),


    );


  }



  Widget _titulo(String texto){


    return Text(

      texto,

      style:

      const TextStyle(

        fontSize:20,

        fontWeight:
        FontWeight.bold,

      ),

    );


  }


}

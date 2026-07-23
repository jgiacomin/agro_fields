import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';



class DetalleActivoAgroScreen extends StatelessWidget {


  final ActivoAgroV2 activo;



  const DetalleActivoAgroScreen({

    super.key,

    required this.activo,

  });






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

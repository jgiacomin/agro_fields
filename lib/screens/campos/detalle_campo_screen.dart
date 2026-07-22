import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../models/solicitud_contacto_model.dart';
import '../../services/solicitud_contacto_service.dart';
import '../../enums/solicitud_estado.dart';



class DetalleCampoScreen extends StatefulWidget {


  final ActivoAgroV2 activo;


  const DetalleCampoScreen({
    super.key,
    required this.activo,
  });



  @override
  State<DetalleCampoScreen> createState() =>
      _DetalleCampoScreenState();

}





class _DetalleCampoScreenState
    extends State<DetalleCampoScreen> {


  final SolicitudContactoService solicitudService =
      SolicitudContactoService();





  String estadoTexto(){


    switch(widget.activo.estado.name){


      case 'publicado':
        return 'Publicado';


      case 'borrador':
        return 'Borrador';


      case 'verificado':
        return 'Verificado';


      default:
        return widget.activo.estado.name;


    }

  }







  Future<void> enviarSolicitud() async {


    final user =
        FirebaseAuth.instance.currentUser;



    if(user == null){

      return;

    }




    if(user.uid ==
        widget.activo.propietarioId){


      if(!mounted){
        return;
      }


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:

          Text(
            "No puedes solicitar tu propio activo",
          ),

        ),

      );


      return;

    }







    final solicitud = SolicitudContacto(


      solicitudId:'',


      campoId:
      widget.activo.activoId,


      interesadoId:
      user.uid,


      propietarioId:
      widget.activo.propietarioId,


      tipoInteres:
      'inversion',


      estado:
      SolicitudEstado.pendiente,


      fechaCreacion:
      DateTime.now(),


    );





    try{


      await solicitudService.crearSolicitud(
        solicitud,
      );




      if(!mounted){

        return;

      }




      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(

          content:

          Text(
            "Solicitud enviada correctamente 🚜",
          ),

        ),


      );



    }

    catch(e){



      if(!mounted){

        return;

      }




      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          content:

          Text(
            "Error: $e",
          ),

        ),


      );


    }


  }










  @override
  Widget build(BuildContext context) {


    final activo = widget.activo;



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

                fontSize:28,

                fontWeight:
                FontWeight.bold,

              ),

            ),





            const SizedBox(height:15),






            Card(

              child:

              Padding(

                padding:
                const EdgeInsets.all(15),


                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[



                    const Text(

                      "📍 Ubicación",

                      style:
                      TextStyle(

                        fontWeight:
                        FontWeight.bold,

                        fontSize:18,

                      ),

                    ),




                    const SizedBox(height:8),





                    Text(

                      "${activo.ubicacion.localidad}, "
                      "${activo.ubicacion.provincia}, "
                      "${activo.ubicacion.pais}",

                    ),





                    const SizedBox(height:8),





                    Text(

                      "🌱 Superficie: "
                      "${activo.ubicacion.superficie} ha",

                    ),



                  ],

                ),

              ),

            ),








            const SizedBox(height:15),






            Card(


              color:

              Colors.green.shade50,



              child:

              Padding(

                padding:
                const EdgeInsets.all(15),



                child:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,



                  children:[



                    const Text(

                      "🔐 Información Agro Fields",

                      style:
                      TextStyle(

                        fontSize:18,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),





                    const SizedBox(height:10),





                    Text(
                      "Estado: ${estadoTexto()}",
                    ),





                    Text(

                      "Confianza: "
                      "${activo.confianza.nivelGeneral}%",

                    ),





                    Text(

                      "Madurez: "
                      "${activo.madurez.porcentaje}%",

                    ),



                  ],


                ),


              ),


            ),








            const SizedBox(height:20),






            const Text(

              "Descripción",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),






            const SizedBox(height:8),






            Text(

              activo.descripcion,

            ),








            const SizedBox(height:20),






            const Text(

              "Producción",

              style:
              TextStyle(

                fontSize:20,

                fontWeight:
                FontWeight.bold,

              ),

            ),






            const SizedBox(height:10),






            ...activo.producciones.map(


              (p)=>Card(

                child:

                ListTile(


                  leading:

                  const Icon(

                    Icons.agriculture,

                    color:
                    Colors.green,

                  ),



                  title:

                  Text(
                    p.actividad,
                  ),



                  subtitle:

                  Text(
                    p.descripcion,
                  ),



                ),

              ),


            ),







            const SizedBox(height:30),







            SizedBox(


              width:
              double.infinity,



              child:

              ElevatedButton.icon(



                icon:

                const Icon(
                  Icons.handshake,
                ),




                label:

                const Text(
                  "Estoy interesado",
                ),






                onPressed:


                activo.estado.name != 'publicado'


                    ?

                    (){


                  ScaffoldMessenger.of(context)
                      .showSnackBar(


                    const SnackBar(

                      content:

                      Text(
                        "Este activo todavía no está publicado",
                      ),

                    ),


                  );


                }




                    :

                    enviarSolicitud,



              ),


            ),




          ],


        ),


      ),


    );


  }



}
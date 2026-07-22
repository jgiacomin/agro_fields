import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/solicitud_contacto_model.dart';
import '../../models/activos/activo_agro_model_v2.dart';

import '../../services/solicitud_contacto_service.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/chat_service.dart';
import '../../enums/solicitud_estado.dart';



class SolicitudesRecibidasScreen extends StatelessWidget {


  SolicitudesRecibidasScreen({super.key});



  final SolicitudContactoService solicitudService =
      SolicitudContactoService();



  final UserService userService =
      UserService();



  final ActivoAgroServiceV2 activoService =
      ActivoAgroServiceV2();



  final ChatService chatService =
      ChatService();





  @override
  Widget build(BuildContext context) {


    final usuario =
        FirebaseAuth.instance.currentUser;



    if (usuario == null) {


      return const Scaffold(

        body: Center(

          child: Text(
            'Usuario no encontrado',
          ),

        ),

      );

    }





    return Scaffold(


      appBar: AppBar(

        title: const Text(
          'Solicitudes recibidas',
        ),

      ),





      body: StreamBuilder<List<SolicitudContacto>>(


        stream:

          solicitudService.obtenerSolicitudesPropietario(
            usuario.uid,
          ),



        builder: (context, snapshot) {



          if (snapshot.connectionState ==
              ConnectionState.waiting) {


            return const Center(

              child:
                CircularProgressIndicator(),

            );


          }





          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {



            return const Center(

              child:
                Text(
                  'Todavía no hay interesados',
                ),

            );


          }





          final solicitudes =
              snapshot.data!;





          return ListView.builder(



            itemCount:
              solicitudes.length,



            itemBuilder:
              (context,index) {



              final solicitud =
                  solicitudes[index];





              return Card(



                margin:
                  const EdgeInsets.all(12),





                child: Padding(



                  padding:
                    const EdgeInsets.all(16),





                  child: Column(



                    crossAxisAlignment:
                      CrossAxisAlignment.start,



                    children: [





                      FutureBuilder<ActivoAgroV2?>(



                       future:
                      activoService.obtenerActivoPorId(
                        solicitud.campoId,
                          ),





                        builder:
                          (context,campoSnap) {



                         if (campoSnap.connectionState == ConnectionState.waiting) {

                         return const Text(
                         'Cargando campo...',
                          );

                         }


                       if (campoSnap.hasError) {

                       return Text(
                           'Error cargando campo: ${campoSnap.error}',
                         );

                           }




                          final campo = campoSnap.data;





                          if (campo == null) {



                            return const Text(
                              'Campo no encontrado',
                            );


                          }





                          return Column(



                            crossAxisAlignment:
                              CrossAxisAlignment.start,



                            children: [



                              Text(

                                '🌱 ${campo.nombre}',

                                style:
                                  const TextStyle(

                                    fontWeight:
                                      FontWeight.bold,

                                    fontSize:
                                      18,

                                  ),

                              ),




                              Text(
                               '📍 ${campo.ubicacion.localidad}, '
                                '${campo.ubicacion.provincia}, '
                                '${campo.ubicacion.pais}',
                                   ),




                              Text(
                             '📐 ${campo.ubicacion.superficie} hectáreas',
                                 ),




                              Text(

                                '🌾 ${campo.descripcion}',

                              ),




                              const SizedBox(
                                height: 12,
                              ),



                            ],


                          );


                        },


                      ),






                      FutureBuilder(



                        future:

                          userService.getUsuario(
                            solicitud.interesadoId,
                          ),





                        builder:
                          (context,usuarioSnap) {



                          if (!usuarioSnap.hasData) {



                            return const CircularProgressIndicator();


                          }





                          final interesado =
                              usuarioSnap.data;





                          if(interesado == null){



                            return const Text(
                              'Usuario no encontrado',
                            );


                          }





                          return Column(



                            crossAxisAlignment:
                              CrossAxisAlignment.start,



                            children: [



                              Text(

                                '👤 ${interesado.nombre}',

                              ),




                              Text(

                                interesado.email,

                              ),



                            ],


                          );


                        },


                      ),





                      const SizedBox(
                        height: 12,
                      ),





                      Text(

                        'Interés: ${solicitud.tipoInteres}',

                      ),





                      Text(

                        'Estado: ${solicitud.estado.name}',

                      ),





                      const SizedBox(
                        height: 15,
                      ),





                      Row(



                        children: [





                          ElevatedButton(



                            onPressed:

                            solicitud.estado == SolicitudEstado.pendiente

                              ? () async {



                                  final chatId =

                                      await chatService.crearChat(


                                        campoId:
                                          solicitud.campoId,


                                        propietarioId:
                                          solicitud.propietarioId,


                                        interesadoId:
                                          solicitud.interesadoId,


                                      );





                   await solicitudService.actualizarEstadoSolicitud(
                      solicitud.solicitudId,
                             SolicitudEstado.aceptada,
                      chatId: chatId,
                                      );
                                }


                              : null,



                            child:
                              const Text(
                                'Aceptar contacto',
                              ),



                          ),





                          const SizedBox(
                            width: 10,
                          ),





                          ElevatedButton(



                            style: ElevatedButton.styleFrom(

                         backgroundColor: Colors.red,

                        disabledBackgroundColor: Colors.red.shade200,

                           ),




                            onPressed:

                              solicitud.estado == SolicitudEstado.pendiente

                              ? () async {



                    await solicitudService.actualizarEstadoSolicitud(
                   solicitud.solicitudId,
               SolicitudEstado.rechazada,
                 );


                                }


                              : null,



                            child:

                              const Text(
                                'Rechazar',
                              ),



                          ),



                        ],


                      ),





                    ],


                  ),


                ),


              );



            },


          );



        },


      ),


    );


  }
 }




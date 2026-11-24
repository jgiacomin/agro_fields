import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/solicitud_contacto_model.dart';
import '../../models/activos/activo_agro_model_v2.dart';

import '../../services/solicitud_contacto_service.dart';
import '../../services/user_service.dart';
import '../../services/activo_agro_service_v2.dart';
import '../../services/chat_service.dart';
import '../../enums/solicitud_estado.dart';
import '../../widgets/barra_campo.dart';
import '../chat/chat_screen.dart';



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


      appBar: BarraCampo(

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






                      // GAP-MERC-01 Parte C: los datos que dejó el
                      // interesado (si es una solicitud vieja, como antes).
                      if (solicitud.interesadoNombre.isNotEmpty)
                        _datosInteresado(solicitud)
                      else
                      FutureBuilder(



                        future:

                          userService.getUsuario(
                            solicitud.interesadoId,
                          ),





                        builder:
                          (context,usuarioSnap) {



                          // QA 20/11/2026: los datos del interesado no se pueden leer
                          // (privacidad); antes quedaba cargando para siempre.
                          if (usuarioSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          if (usuarioSnap.hasError || usuarioSnap.data == null) {
                            return const Text(
                              '👤 Un usuario de Agro Fields está interesado. '
                              'Sus datos de contacto se comparten cuando aceptás.',
                            );
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

                        'Le interesa: ${_textoInteres(solicitud.tipoInteres)}',

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

                                        // GAP-MERC-01 Parte C: nombres
                                        // para el chat.
                                        interesadoNombre:
                                          solicitud.interesadoNombre,
                                        propietarioNombre: FirebaseAuth
                                            .instance.currentUser?.displayName,



                                      );





                   await solicitudService.actualizarEstadoSolicitud(
                      solicitud.solicitudId,
                             SolicitudEstado.aceptada,
                      chatId: chatId,
                                      );
                                  // QA 20/11/2026: al aceptar se abre el chat.
                                  if (!context.mounted) return;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatScreen(
                                        chatId: chatId,
                                        otroUsuarioId: solicitud.interesadoId,
                                        nombreOtro: solicitud.interesadoNombre,
                                      ),
                                    ),
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

  /// GAP-MERC-01 Parte C: "venta" -> "Comprar", etc.
  static String _textoInteres(String tipo) => switch (tipo) {
        'venta' => 'Comprar',
        'alquiler' => 'Alquilar',
        'arrendamiento' => 'Arrendar',
        'compra' => 'Comprar',
        _ => 'Saber más del campo',
      };

  /// GAP-MERC-01 Parte C: nombre, teléfono y mensaje del interesado.
  Widget _datosInteresado(SolicitudContacto s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👤 ${s.interesadoNombre}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        if (s.interesadoTelefono != null &&
            s.interesadoTelefono!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SelectableText('📞 ${s.interesadoTelefono}'),
          ),
        if (s.mensaje != null && s.mensaje!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('💬 "${s.mensaje}"',
                style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}

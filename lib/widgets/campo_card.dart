import 'package:flutter/material.dart';

import '../models/activos/activo_publico_model.dart';
import '../screens/campos/detalle_campo_screen.dart';


class CampoCard extends StatelessWidget {


  final ActivoPublico activo;


  const CampoCard({

    super.key,

    required this.activo,

  });



  @override
  Widget build(BuildContext context) {


    return Card(

      margin: const EdgeInsets.all(12),

      elevation: 3,


      child: InkWell(


        borderRadius:
        BorderRadius.circular(12),


        onTap: (){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (context)=>

              DetalleCampoScreen(

                activo: activo,

              ),

            ),

          );


        },



        child: Padding(


          padding:
          const EdgeInsets.all(16),



          child: Column(


            crossAxisAlignment:
            CrossAxisAlignment.start,



            children:[



              Text(

                activo.nombre,

                style:
                const TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),




              const SizedBox(height:8),




              Text(

                '📍 ${activo.provincia} - '
                '${activo.localidad}',

                style:
                TextStyle(

                  color:
                  Colors.grey[700],

                ),

              ),




              const SizedBox(height:8),




              Text(

                '🌱 ${activo.superficie} hectáreas',

              ),




              const SizedBox(height:12),




              Row(


                children:[


                  Icon(

                    activo.estadoPublicacion == 'publicado'

                    ? Icons.verified

                    : Icons.pending,

                    color:

                    activo.estadoPublicacion == 'publicado'

                    ? Colors.green

                    : Colors.orange,

                  ),



                  const SizedBox(width:6),



                  Text(

                    activo.estadoPublicacion == 'publicado'

                    ? 'Publicado'

                    : 'Pendiente de verificación',


                    style:

                    TextStyle(

                      color:

                      activo.estadoPublicacion == 'publicado'

                      ? Colors.green[700]

                      : Colors.orange[700],


                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),


                ],


              ),





              const SizedBox(height:10),




              Text(

                '🌾 Tipo: ${activo.tipoActivo}',

              ),





              const SizedBox(height:10),




              Container(


                padding:
                const EdgeInsets.symmetric(

                  horizontal:10,

                  vertical:5,

                ),



                decoration:
                BoxDecoration(

                  color:
                  Colors.green[100],

                  borderRadius:
                  BorderRadius.circular(8),

                ),



                child: Text(

                  activo.estadoPublicacion.toUpperCase(),


                  style:
                  TextStyle(

                    color:
                    Colors.green[800],

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),





              const SizedBox(height:12),




              const Align(


                alignment:
                Alignment.centerRight,



                child:
                Text(

                  'Ver oportunidad →',


                  style:
                  TextStyle(

                    color:
                    Colors.blue,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),

              ),



            ],


          ),


        ),


      ),


    );


  }


}
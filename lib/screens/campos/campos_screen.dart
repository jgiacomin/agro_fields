import 'package:flutter/material.dart';

import '../../models/activos/activo_agro_model_v2.dart';
import '../../services/activo_agro_service_v2.dart';

import 'detalle_campo_screen.dart';



class CamposScreen extends StatelessWidget {


  CamposScreen({
    super.key,
  });



  final ActivoAgroServiceV2 _service =
      ActivoAgroServiceV2();





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
        const Text(
          "Campos disponibles",
        ),

        centerTitle:true,

      ),





      body:

      FutureBuilder<List<ActivoAgroV2>>(


        future:
        _service.obtenerActivosPublicados(),



        builder:(context,snapshot){



          if(snapshot.connectionState ==
              ConnectionState.waiting){


            return const Center(

              child:
              CircularProgressIndicator(),

            );


          }





          if(snapshot.hasError){


            return Center(

              child:
              Text(
                "Error: ${snapshot.error}",
              ),

            );


          }






          if(!snapshot.hasData ||
              snapshot.data!.isEmpty){


            return const Center(

              child:
              Text(
                "No hay campos disponibles",
              ),

            );


          }






          final activos =
              snapshot.data!;






          return ListView.builder(


            padding:
            const EdgeInsets.all(10),



            itemCount:
            activos.length,



            itemBuilder:(context,index){


              final activo =
                  activos[index];



              return _ActivoCard(

                activo:
                activo,

              );


            },



          );



        },


      ),


    );


  }


}







class _ActivoCard extends StatelessWidget {


  final ActivoAgroV2 activo;



  const _ActivoCard({

    required this.activo,

  });






  @override
  Widget build(BuildContext context) {


    return Card(


      elevation:4,


      margin:
      const EdgeInsets.only(

        bottom:12,

      ),



      shape:
      RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(12),

      ),




      child:

      InkWell(


        borderRadius:
        BorderRadius.circular(12),



        onTap:(){



          Navigator.push(


            context,


            MaterialPageRoute(


              builder:(context)=>


              DetalleCampoScreen(

                activo:
                activo,

              ),


            ),


          );



        },





        child:

        Padding(


          padding:
          const EdgeInsets.all(15),




          child:

          Column(



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





              const SizedBox(
                height:8,
              ),





              Text(

                activo.descripcion,


                maxLines:4,


                overflow:
                TextOverflow.ellipsis,


              ),





              const SizedBox(
                height:10,
              ),





              Row(

                children:[


                  const Icon(

                    Icons.location_on,

                    size:18,

                    color:
                    Colors.green,

                  ),




                  const SizedBox(
                    width:5,
                  ),




                  Text(

                    "${activo.ubicacion.localidad}, "
                    "${activo.ubicacion.provincia}",

                  ),


                ],

              ),





              const SizedBox(
                height:8,
              ),





              Text(

                "Tipo: ${activo.tipoActivo.name}",

              ),





              Text(

                "Superficie: ${activo.ubicacion.superficie} ha",

              ),





              const SizedBox(
                height:10,
              ),





              Container(


                padding:
                const EdgeInsets.symmetric(

                  horizontal:10,

                  vertical:6,

                ),



                decoration:
                BoxDecoration(

                  color:
                  Colors.green.shade100,


                  borderRadius:
                  BorderRadius.circular(8),

                ),



                child:

                const Text(

                  "PUBLICADO",

                  style:
                  TextStyle(

                    color:
                    Colors.green,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),





              const SizedBox(
                height:12,
              ),





              Align(


                alignment:
                Alignment.centerRight,



                child:

                Text(

                  "Ver detalle →",


                  style:
                  TextStyle(

                    color:
                    Colors.blue.shade700,

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
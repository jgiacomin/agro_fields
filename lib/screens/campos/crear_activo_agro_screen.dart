import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/activos/tipo_activo.dart';
import '../../models/activos/ubicacion_activo_model.dart';
import '../../models/activos/modulo_produccion_model.dart';
import '../../models/activos/madurez_activo_model.dart';
import '../../models/activos/estado_activo.dart';
import '../../models/activos/activo_agro_model_v2.dart';

import '../../models/activos/confianza_activo_model.dart';
import '../../models/activos/economia_activo_model.dart';
import '../../models/activos/documentacion_activo_model.dart';
import '../../models/activos/evaluacion_confianza_model.dart';

import '../../services/activo_agro_service_v2.dart';






class CrearActivoAgroScreen extends StatefulWidget {

  const CrearActivoAgroScreen({
    super.key,
  });


  @override
  State<CrearActivoAgroScreen> createState() =>
      _CrearActivoAgroScreenState();

}






class _CrearActivoAgroScreenState
    extends State<CrearActivoAgroScreen> {


  final _formKey =
      GlobalKey<FormState>();


  final ActivoAgroServiceV2 _activoService =
      ActivoAgroServiceV2();




  final nombreController =
      TextEditingController();


  final provinciaController =
      TextEditingController();


  final localidadController =
      TextEditingController();


  final superficieController =
      TextEditingController();


  final descripcionController =
      TextEditingController();



  bool loading = false;







  @override
  void dispose(){

    nombreController.dispose();

    provinciaController.dispose();

    localidadController.dispose();

    superficieController.dispose();

    descripcionController.dispose();

    super.dispose();

  }








  Future<void> guardarActivo() async {


    if(!_formKey.currentState!.validate()){

      return;

    }



    setState(() {

      loading = true;

    });






    try {


      final user =
          FirebaseAuth.instance.currentUser;



      if(user == null){

        throw Exception(
          'Usuario no autenticado',
        );

      }





      final nombre =
          nombreController.text.trim();



      final provincia =
          provinciaController.text.trim();



      final localidad =
          localidadController.text.trim();




      var superficieTexto =
    superficieController.text
        .toLowerCase()
        .trim();


superficieTexto = superficieTexto
    .replaceAll("hectáreas", "")
    .replaceAll("hectareas", "")
    .replaceAll("hectárea", "")
    .replaceAll("hectarea", "")
    .replaceAll("has", "")
    .replaceAll("ha", "")
    .trim();


superficieTexto = superficieTexto
    .replaceAll(".", "")
    .replaceAll(",", ".");


final superficie =
    double.tryParse(superficieTexto) ?? 0;




      final descripcion =
          descripcionController.text.trim();







      final ahora =
          DateTime.now();






      final hashActivo =

          'AGRO_V2|'
          '${nombre.toLowerCase()}|'
          '${provincia.toLowerCase()}|'
          '${localidad.toLowerCase()}|'
          '$superficie';








      final activo = ActivoAgroV2(



        activoId:

        ahora
            .millisecondsSinceEpoch
            .toString(),






        nombre:

        nombre,






        descripcion:

        descripcion,






        tipoActivo:

        TipoActivo.agricola,






        categorias:[

          'produccion',
          'agro',

        ],







        ubicacion:

        UbicacionActivo(


          pais:

          'Argentina',



          provincia:

          provincia,



          localidad:

          localidad,



          latitud:

          0,



          longitud:

          0,



          superficie:

          superficie,

        ),







        producciones:[


          ModuloProduccion(

            actividad:

            'agricultura',


            dominio:

            'agropecuario',


            descripcion:

            'Producción inicial',


            datos:{},


          ),


        ],







        economia:

        EconomiaActivo.inicial(),







        documentacion:

        DocumentacionActivo.inicial(),







        confianza:

        ConfianzaActivo(


          nivelGeneral:

          0,



          identidadVerificada:

          false,



          documentacionCompleta:

          false,



          cantidadEvidencias:

          0,



          informacionProductivaCompleta:

          false,



          participantesVerificados:

          false,



          ultimaVerificacion:

          ahora,



          observaciones:

          'Activo creado pendiente de validación',


        ),







        evaluacion:

        EvaluacionConfianza.inicial(),







        madurez:

        MadurezActivo(


          porcentaje:

          0,



          faltantes:[


            'Documentación',


            'Producción',


            'Evidencias',


          ],


        ),







        participantes:[],








        propietarioId:

        user.uid,



        creadorId:

        user.uid,



        publicadorId:

        user.uid,



        tipoRelacionPropietario:

        'propietario',







        estado:

        EstadoActivo.borrador,



        estadoPublicacion:

        'borrador',



        visible:

        false,



        versionDatos:

        1,







        historial:[],







        hashActivo:

        hashActivo,







        fechaCreacion:

        ahora,







        ultimaActualizacion:

        ahora,



      );








    

       debugPrint('ANTES DE GUARDAR ACTIVO');
debugPrint(activo.toString());

final mapa = activo.toMap();

debugPrint('MAPA GENERADO CORRECTAMENTE');
debugPrint(mapa.toString());

await _activoService.crearActivo(
  activo,
);

debugPrint('ACTIVO GUARDADO CORRECTAMENTE');






      if(!mounted){

        return;

      }







      ScaffoldMessenger.of(context)
          .showSnackBar(


        const SnackBar(

          content:

          Text(

            'Activo Agro creado correctamente',

          ),

        ),

      );







      Navigator.pop(context);





    }


    catch(e, stack){


  debugPrint(
    '==============================',
  );

  debugPrint(
    'ERROR CREANDO ACTIVO:',
  );

  debugPrint(
    e.toString(),
  );


  debugPrint(
    'STACK:',
  );

  debugPrint(
    stack.toString(),
  );


  debugPrint(
    '==============================',
  );




  if(!mounted){

    return;

  }





  ScaffoldMessenger.of(context)
      .showSnackBar(


    SnackBar(

      content:

      Text(

        'Error creando activo: $e',

      ),

    ),

  );



}



    finally{



      if(mounted){

        setState(() {

          loading = false;

        });

      }


    }



  }









  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar:

      AppBar(

        title:

        const Text(

          'Crear Activo Agro',

        ),

      ),





      body:

      Padding(

        padding:

        const EdgeInsets.all(16),





        child:

        Form(

          key:

          _formKey,





          child:

          ListView(

            children:[





              TextFormField(

                controller:

                nombreController,



                decoration:

                const InputDecoration(

                  labelText:

                  'Nombre del activo',

                ),




                validator:(value){


                  if(value == null ||
                      value.trim().isEmpty){

                    return 'Ingrese nombre';

                  }


                  return null;

                },

              ),






              TextFormField(

                controller:

                provinciaController,



                decoration:

                const InputDecoration(

                  labelText:

                  'Provincia',

                ),


                validator:(value){

                  if(value == null ||
                      value.trim().isEmpty){

                    return 'Ingrese provincia';

                  }

                  return null;

                },

              ),






              TextFormField(

                controller:

                localidadController,



                decoration:

                const InputDecoration(

                  labelText:

                  'Localidad',

                ),


                validator:(value){

                  if(value == null ||
                      value.trim().isEmpty){

                    return 'Ingrese localidad';

                  }

                  return null;

                },

              ),






              TextFormField(

                controller:

                superficieController,



                keyboardType:

                TextInputType.number,



                decoration:

                const InputDecoration(

                  labelText:

                  'Superficie (hectáreas)',

                ),


               validator: (value) {

  debugPrint("========== SUPERFICIE ==========");
  debugPrint("Valor recibido: '$value'");


  var texto = (value ?? "")
      .toLowerCase()
      .trim();


  texto = texto
      .replaceAll("hectáreas", "")
      .replaceAll("hectareas", "")
      .replaceAll("hectárea", "")
      .replaceAll("hectarea", "")
      .replaceAll("has", "")
      .replaceAll("ha", "")
      .trim();


  texto = texto
      .replaceAll(".", "")
      .replaceAll(",", ".");


  debugPrint("Texto preparado:");
  debugPrint(texto);


  final superficie =
      double.tryParse(texto);


  debugPrint("Resultado parse:");
  debugPrint(superficie.toString());

  debugPrint("===============================");



  if(superficie == null || superficie <= 0){

    return 'Ingrese una superficie válida';

  }


  return null;

},

),








              TextFormField(

                controller:

                descripcionController,



                maxLines:

                3,



                decoration:

                const InputDecoration(

                  labelText:

                  'Descripción',

                ),

              ),






              const SizedBox(

                height:

                24,

              ),






              ElevatedButton(


                onPressed:

                loading

                    ? null

                    : guardarActivo,




                child:

                loading

                    ?

                const SizedBox(

                  height:

                  20,


                  width:

                  20,


                  child:

                  CircularProgressIndicator(

                    strokeWidth:

                    2,

                  ),

                )


                    :

                const Text(

                  'Crear Activo Agro',

                ),



              ),




            ],

          ),

        ),

      ),


    );


  }



}

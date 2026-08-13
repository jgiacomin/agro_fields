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
import '../../models/activos/historial_activo_model.dart';


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


  final paisController =
      TextEditingController();


  final provinciaController =
      TextEditingController();


  final departamentoController =
      TextEditingController();


  final localidadController =
      TextEditingController();


  final codigoPostalController =
      TextEditingController();


  final superficieController =
      TextEditingController();


  final descripcionController =
      TextEditingController();



  bool loading = false;




  @override
  void dispose() {

    nombreController.dispose();

    paisController.dispose();

    provinciaController.dispose();

    departamentoController.dispose();

    localidadController.dispose();

    codigoPostalController.dispose();

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






      final ahora =
          DateTime.now();





      final nombre =
          nombreController.text.trim();



      final pais =
          paisController.text.trim();



      final provincia =
          provinciaController.text.trim();



      final departamento =
          departamentoController.text.trim();



      final localidad =
          localidadController.text.trim();



      final codigoPostal =
          codigoPostalController.text.trim();






      var superficieTexto =
          superficieController.text
              .toLowerCase()
              .trim();



      superficieTexto =
          superficieTexto
              .replaceAll("hectáreas", "")
              .replaceAll("hectareas", "")
              .replaceAll("hectárea", "")
              .replaceAll("hectarea", "")
              .replaceAll("has", "")
              .replaceAll("ha", "")
              .trim();



      superficieTexto =
          superficieTexto
              .replaceAll(".", "")
              .replaceAll(",", ".");



      final superficie =
          double.tryParse(superficieTexto) ?? 0;






      final descripcion =
          descripcionController.text.trim();







      final hashActivo =

          'AGRO_V2|'
          '${nombre.toLowerCase()}|'
          '${provincia.toLowerCase()}|'
          '${localidad.toLowerCase()}|'
          '$superficie';







      final activo = ActivoAgroV2(

        activoId:
            ahora.millisecondsSinceEpoch.toString(),



        nombre:
            nombre,



        descripcion:
            descripcion,



        tipoActivo:
            TipoActivo.agricola,



        categorias:
        [
          'produccion',
          'agro',
        ],




        ubicacion:

        UbicacionActivo(

          pais:
              pais,


          provincia:
              provincia,


          departamento:
              departamento,


          localidad:
              localidad,


          codigoPostal:
              codigoPostal,


          latitud:
              0,


          longitud:
              0,


          superficie:
              superficie,


          tipoZona:
              'rural',


          zonaHoraria:
              'America/Argentina/Buenos_Aires',


          accesoCaminos:
              '',


          descripcionEntorno:
              '',


          disponibilidadServicios:
              '',


          jurisdiccionLegal:
              '',


          regionProductiva:
              provincia,


          monedaLocal:
              'ARS',

        ),



          producciones:
          [

            ModuloProduccion(

              actividad:
                  'agricultura',

              dominio:
                  'agropecuario',

              descripcion:
                  'Producción inicial',

              datos:
              {},

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

  faltantes:
  [
    'Documentación',
    'Producción',
    'Evidencias',
  ],

  etapa:
      'inicial',

  nivelTecnologico:
      'bajo',

  preparacionInversion:
      'inicial',

),




          participantes:
              [],





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
              ActivoAgroV2.modeloVersion,




          historial:

        [

  HistorialActivo(

    eventoId:
        ahora.millisecondsSinceEpoch.toString(),

    tipoEvento:
        'creacion',

    descripcion:
        'Activo Agro creado pendiente de validación',

    usuarioId:
        user.uid,

        moduloOrigen:
     'activo',

    fecha:
        ahora,

  ),
],





          hashActivo:
              hashActivo,




          fechaCreacion:
              ahora,




          ultimaActualizacion:
              ahora,


      );






      debugPrint('ANTES DE GUARDAR ACTIVO');

      debugPrint(activo.toString());



      final mapa =
          activo.toMap();



      debugPrint(
          'MAPA GENERADO CORRECTAMENTE'
      );


      debugPrint(
          mapa.toString()
      );




      await _activoService.crearActivo(
        activo,
      );




      debugPrint(
          'ACTIVO GUARDADO CORRECTAMENTE'
      );






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
        'ERROR CREANDO ACTIVO:',
      );


      debugPrint(
        e.toString(),
      );


      debugPrint(
        stack.toString(),
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

            children:
            [





              TextFormField(

                controller:
                    nombreController,


                decoration:
                const InputDecoration(

                  labelText:
                      'Nombre del activo',

                ),



                validator:(v){

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese nombre';

                  }


                  return null;

                },

              ),





              TextFormField(

                controller:
                    paisController,


                decoration:
                const InputDecoration(

                  labelText:
                      'País',

                ),

              ),





              TextFormField(

                controller:
                    provinciaController,


                decoration:
                const InputDecoration(

                  labelText:
                      'Provincia',

                ),



                validator:(v){

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese provincia';

                  }


                  return null;

                },

              ),





              TextFormField(

                controller:
                    departamentoController,


                decoration:
                const InputDecoration(

                  labelText:
                      'Departamento / Estado',

                ),

              ),





              TextFormField(

                controller:
                    localidadController,


                decoration:
                const InputDecoration(

                  labelText:
                      'Localidad',

                ),

              ),





              TextFormField(

                controller:
                    codigoPostalController,


                decoration:
                const InputDecoration(

                  labelText:
                      'Código postal',

                ),

              ),





              TextFormField(

                controller:
                    superficieController,


                keyboardType:
                    TextInputType.number,


                decoration:
                const InputDecoration(

                  labelText:
                      'Superficie hectáreas',

                ),



                validator:(v){

                  final valor =
                  double.tryParse(
                    (v ?? '')
                        .replaceAll(',', '.'),
                  );


                  if(valor == null ||
                      valor <= 0){

                    return 'Ingrese superficie válida';

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
                height: 24,
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

                  height:20,

                  width:20,

                  child:
                  CircularProgressIndicator(),

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

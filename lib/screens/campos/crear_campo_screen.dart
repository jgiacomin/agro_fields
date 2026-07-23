import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/campo_model.dart';
import '../../services/campo_service.dart';


class CrearCampoScreen extends StatefulWidget {

  const CrearCampoScreen({
    super.key,
  });


  @override
  State<CrearCampoScreen> createState() =>
      _CrearCampoScreenState();

}



class _CrearCampoScreenState
    extends State<CrearCampoScreen> {


  final _formKey =
      GlobalKey<FormState>();


  final CampoService _campoService =
      CampoService();



  final nombreController =
      TextEditingController();

  final paisController =
    TextEditingController();

  final provinciaController =
      TextEditingController();


  final localidadController =
      TextEditingController();

  
  final departamentoController =
    TextEditingController();


  final codigoPostalController =
    TextEditingController();


  final hectareasController =
      TextEditingController();


  final descripcionController =
      TextEditingController();



  bool loading = false;



  @override
  void dispose() {

    nombreController.dispose();

    paisController.dispose();

     provinciaController.dispose();

    localidadController.dispose();

    departamentoController.dispose();

    codigoPostalController.dispose();

    hectareasController.dispose();

    descripcionController.dispose();

    super.dispose();

  }






  Future<void> guardarCampo() async {


    if (!_formKey.currentState!.validate()) {
      return;
    }



    setState(() {
      loading = true;
    });




    try {


      final user =
          FirebaseAuth.instance.currentUser;



      if (user == null) {

        throw Exception(
          'Usuario no autenticado',
        );

      }





      final nombre =
          nombreController.text.trim();

      final pais =
           paisController.text.trim();

      final provincia =
          provinciaController.text.trim();



      final localidad =
          localidadController.text.trim();




      final departamento =
           departamentoController.text.trim();


      final codigoPostal =
          codigoPostalController.text.trim();


    

      final hectareas =
          double.tryParse(
            hectareasController.text.trim(),
          ) ?? 0;




      final descripcion =
          descripcionController.text.trim();





      final hash =
    Campo.generateHash(

      nombre: nombre,

      pais: pais,

      provincia: provincia,

      departamento: departamento,

      localidad: localidad,

      hectareas: hectareas,

    );








      final campo = Campo(


        campoId: '',


        propietarioId:
            user.uid,


        publicadorId:
            user.uid,


        tipoRelacion:
            'propietario',


        nombre:
    nombre,


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


         hectareas:
          hectareas,




        descripcion:
            descripcion,


        estadoPublicacion:
            'disponible',


        verificado:
            false,


        hashCampo:
            hash,


        fechaCreacion:
            DateTime.now(),


      );






      await _campoService.crearCampo(
        campo,
      );





      if (!mounted) {
        return;
      }




      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:

          Text(
            'Campo publicado correctamente',
          ),

        ),

      );




      Navigator.pop(context);





    } catch (e) {



      if (!mounted) {
        return;
      }




      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:

          Text(
            'Error creando campo: $e',
          ),

        ),

      );



    } finally {



      if (mounted) {

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
          'Crear Campo',
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

            children: [





              TextFormField(

                controller:
                nombreController,


                decoration:

                const InputDecoration(

                  labelText:
                  'Nombre del campo',

                ),




                validator: (v) {

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese un nombre';

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

  validator: (v) {

    if(v == null ||
       v.trim().isEmpty){

      return 'Ingrese país';

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



                validator: (v) {

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese provincia';

                  }


                  return null;

                },


              ),




           TextFormField(
  controller: departamentoController,

  decoration: const InputDecoration(
    labelText: 'Departamento / Estado',
  ),

  validator: (v) {
    if (v == null || v.trim().isEmpty) {
      return 'Ingrese departamento o estado';
    }

    return null;
  },

),



             TextFormField(
  controller: codigoPostalController,

  decoration: const InputDecoration(
    labelText: 'Código postal',
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



                validator: (v) {

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese localidad';

                  }


                  return null;

                },


              ),






              TextFormField(

                controller:
                hectareasController,


                keyboardType:
                TextInputType.number,


                decoration:

                const InputDecoration(

                  labelText:
                  'Hectáreas',

                ),



                validator: (v) {

                  if(v == null ||
                      v.trim().isEmpty){

                    return 'Ingrese hectáreas';

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
                height: 20,
              ),






              ElevatedButton(


                onPressed:

                loading
                    ? null
                    : guardarCampo,




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

                    color:
                    Colors.white,

                  ),

                )


                    :

                const Text(
                  'Guardar Campo',
                ),



              ),





            ],

          ),


        ),


      ),


    );


  }


}
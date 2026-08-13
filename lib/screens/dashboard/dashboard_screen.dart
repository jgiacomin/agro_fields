import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_model.dart';
import '../../services/user_service.dart';

import '../campos/crear_activo_agro_screen.dart';
import '../campos/mis_activos_screen.dart';
import '../campos/campos_screen.dart';

import '../solicitudes/solicitudes_recibidas_screen.dart';
import '../chat/chat_page.dart';



class DashboardScreen extends StatefulWidget {

  const DashboardScreen({
    super.key,
  });


  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();

}



class _DashboardScreenState
    extends State<DashboardScreen> {


  UserModel? usuario;


  bool loading = true;



  final UserService _userService =
      UserService();



  @override
  void initState() {

    super.initState();

    cargarUsuario();

  }




  Future<void> cargarUsuario() async {


    try {


      final user =
          FirebaseAuth.instance.currentUser;


// USER AUTH: ${user?.uid}
     //  print(
      //   "USER AUTH: ${user?.uid}",
    //   );



      if(user == null){

        setState(() {
          loading = false;
        });

        return;

      }



      final data =
          await _userService.getUsuario(
            user.uid,
          );

// DATA: ${data?.nombre}

// ROL: ${data?.rol}

     // print(
     //   "DATA: ${data?.nombre}",
     // );


     // print(
        //"ROL: ${data?.rol}",
    // );



      setState(() {

        usuario = data;

        loading = false;

      });



    }
    catch(e){


  // ERROR cargando usuario: $e


  setState(() {

    loading = false;

       });


    }


  }

Future<void> cerrarSesion() async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text(
          '¿Querés cerrar la sesión actual?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      );
    },
  );

  if (confirmar != true) {
    return;
  }

  await FirebaseAuth.instance.signOut();

  final usuario = FirebaseAuth.instance.currentUser;

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        usuario == null
            ? 'SESIÓN CERRADA'
            : 'SIGUE LOGUEADO: ${usuario.email}',
      ),
    ),
  );
}



  @override
  Widget build(BuildContext context) {


    return Scaffold(


     appBar: AppBar(
  title: const Text(
    "Agro Fields",
  ),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Cerrar sesión',
      onPressed: cerrarSesion,
    ),
  ],
),



      body:

      Center(

        child:

        loading

            ?

        const CircularProgressIndicator()



            :

        usuario == null

            ?

        const Text(
          "No se pudo cargar el usuario",
        )



            :

        Padding(

          padding:
          const EdgeInsets.all(20),


          child:

          Column(

            mainAxisAlignment:
            MainAxisAlignment.center,


            children:[



              const Icon(

                Icons.agriculture,

                size:80,

                color:Colors.green,

              ),



              const SizedBox(
                height:20,
              ),



              Text(

                usuario!.nombre,

                style:
                const TextStyle(

                  fontSize:24,

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              const SizedBox(
                height:10,
              ),



              Text(

                "Rol: ${usuario!.rol}",

                style:
                const TextStyle(

                  fontSize:18,

                ),

              ),



              const SizedBox(
                height:30,
              ),



              _buildContenidoPorRol(),


            ],


          ),


        ),


      ),


    );


  }






  Widget _buildContenidoPorRol(){



    switch(usuario!.rol){



      case "Comprador":


        return Column(

          children:[



            ElevatedButton(

              onPressed:(){

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(context)=>

                    CamposScreen(),

                  ),

                );

              },


              child:
              const Text(
                "Ver campos disponibles",
              ),

            ),




            const SizedBox(
              height:15,
            ),




            ElevatedButton(

              onPressed:(){

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(context)=>

                    ChatPage(),

                  ),

                );

              },


              child:
              const Text(
                "Mis conversaciones",
              ),

            ),


          ],

        );






      case "Dueño":

  return Column(

    children:[


      ElevatedButton(

        onPressed:(){

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

              const CrearActivoAgroScreen(),

            ),

          );

        },


        child:
        const Text(
          "Crear Activo Agro",
        ),


      ),




      const SizedBox(
        height:15,
      ),




      ElevatedButton(

        onPressed:(){

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

              const MisActivosScreen(),

            ),

          );

        },


        child:
        const Text(
          "Mis Activos / Publicar campo",
        ),


      ),




      const SizedBox(
        height:15,
      ),




      ElevatedButton(

        onPressed:(){

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

              SolicitudesRecibidasScreen(),

            ),

          );

        },


        child:
        const Text(
          "Solicitudes recibidas",
        ),


      ),




      const SizedBox(
        height:15,
      ),




      ElevatedButton(

        onPressed:(){

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(context)=>

              ChatPage(),

            ),

          );

        },


        child:
        const Text(
          "Mis conversaciones",
        ),


      ),


    ],

  );




      case "Inversor":


        return Column(

          children:[



            ElevatedButton(

              onPressed:(){},


              child:
              const Text(
                "Ir a Invertir",
              ),

            ),




            const SizedBox(
              height:15,
            ),



            ElevatedButton(

              onPressed:(){

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(context)=>

                    ChatPage(),

                  ),

                );

              },


              child:
              const Text(
                "Mis conversaciones",
              ),

            ),


          ],

        );






      case "Broker":


        return ElevatedButton(

          onPressed:(){},


          child:
          const Text(
            "Gestionar contactos",
          ),

        );






      default:


        return const Text(

          "Bienvenido a Agro Fields",

        );


    }


  }


}
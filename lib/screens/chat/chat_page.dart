import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/chat_service.dart';
import 'chat_screen.dart';



class ChatPage extends StatelessWidget {


  ChatPage({super.key});


  final ChatService chatService =
      ChatService();





  @override
  Widget build(BuildContext context) {


    final user =
        FirebaseAuth.instance.currentUser;



    if (user == null) {


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

        title:

          const Text(

            'Mis conversaciones',

          ),

      ),






      body:

      StreamBuilder(


        stream:

          chatService.obtenerChatsPreviewUsuario(

            user.uid,

          ),




        builder:

        (context, snapshot) {



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

                  'Todavía no tenés conversaciones',

                ),

            );


          }





          final chats =

              snapshot.data!;






          return ListView.builder(


            itemCount:

              chats.length,



            itemBuilder:

            (context,index) {



              final chat =

                  chats[index];





              return Card(


                margin:

                  const EdgeInsets.all(12),




                child: ListTile(





                  leading:

                    CircleAvatar(


                      backgroundColor:

                        Colors.green,


                      child:

                        const Icon(

                          Icons.agriculture,

                          color:

                            Colors.white,

                        ),


                    ),





                  title:

                    Text(


                      '🌱 ${chat.nombreActivo}',



                      style:

                        const TextStyle(


                          fontWeight:

                            FontWeight.bold,


                        ),


                    ),






                  subtitle:

                    Column(


                      crossAxisAlignment:

                        CrossAxisAlignment.start,



                      children: [



                        Text(

                          '📍 ${chat.provincia}',

                        ),



                        Text(

                          '📐 ${chat.hectareas} hectáreas',

                        ),




                        Text(

                          '👤 ${chat.contacto.nombre}',

                        ),




                        Text(

                          'Estado: ${chat.estado}',

                        ),



                      ],


                    ),






                  trailing:

                    const Icon(

                      Icons.arrow_forward_ios,

                    ),






                  onTap: () {



                    Navigator.push(


                      context,


                      MaterialPageRoute(



                        builder: (context) =>


                          ChatScreen(



                            chatId:

                              chat.chatId,



                            otroUsuarioId:

                              chat.contacto.uid,


                          ),


                      ),


                    );


                  },



                ),


              );



            },


          );



        },


      ),


    );


  }


}
import 'package:cloud_firestore/cloud_firestore.dart';


class ParticipanteActivo {


  final String usuarioId;

  final String rol;

  final String estado;

  final DateTime fechaIngreso;



  ParticipanteActivo({

    required this.usuarioId,

    required this.rol,

    required this.estado,

    required this.fechaIngreso,

  });



  factory ParticipanteActivo.fromMap(
      Map<String,dynamic> map
      ){

    return ParticipanteActivo(

      usuarioId:
      map['usuarioId'] ?? '',


      rol:
      map['rol'] ?? 'interesado',


      estado:
      map['estado'] ?? 'activo',


      fechaIngreso:
      _leerFecha(
        map['fechaIngreso'],
      ),

    );

  }




  static DateTime _leerFecha(dynamic valor){

    if(valor is Timestamp){

      return valor.toDate();

    }


    if(valor is DateTime){

      return valor;

    }


    if(valor is String){

      return DateTime.tryParse(valor)
          ?? DateTime.now();

    }


    return DateTime.now();

  }




  Map<String,dynamic> toMap(){

    return {

      'usuarioId':
      usuarioId,


      'rol':
      rol,


      'estado':
      estado,


      'fechaIngreso':
      Timestamp.fromDate(
        fechaIngreso,
      ),

    };

  }


}

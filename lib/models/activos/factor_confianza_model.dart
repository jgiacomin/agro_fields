import 'package:cloud_firestore/cloud_firestore.dart';


class FactorConfianza {

  final int nivel;

  final String descripcion;

  final List<String> evidencias;

  final DateTime fechaActualizacion;


  FactorConfianza({

    required this.nivel,

    required this.descripcion,

    required this.evidencias,

    required this.fechaActualizacion,

  });


  factory FactorConfianza.fromMap(
      Map<String, dynamic> map) {

    return FactorConfianza(

      nivel: map['nivel'] ?? 0,

      descripcion: map['descripcion'] ?? '',

      evidencias:
          List<String>.from(
            map['evidencias'] ?? [],
          ),

      fechaActualizacion:

          map['fechaActualizacion'] is Timestamp

              ? (map['fechaActualizacion'] as Timestamp)
                  .toDate()

              : map['fechaActualizacion'] is DateTime

                  ? map['fechaActualizacion']

                  : DateTime.now(),

    );

  }


  Map<String, dynamic> toMap() {

    return {

      'nivel': nivel,

      'descripcion': descripcion,

      'evidencias': evidencias,

      'fechaActualizacion': fechaActualizacion,

    };

  }


  factory FactorConfianza.inicial() {

    return FactorConfianza(

      nivel: 0,

      descripcion: '',

      evidencias: [],

      fechaActualizacion: DateTime.now(),

    );

  }


  FactorConfianza copyWith({

    int? nivel,

    String? descripcion,

    List<String>? evidencias,

    DateTime? fechaActualizacion,

  }) {

    return FactorConfianza(

      nivel: nivel ?? this.nivel,

      descripcion: descripcion ?? this.descripcion,

      evidencias: evidencias ?? this.evidencias,

      fechaActualizacion:
          fechaActualizacion ?? this.fechaActualizacion,

    );

  }


  bool get aprobado {

    return nivel >= 70;

  }


  String get estado {

    if (nivel >= 90) {

      return 'Excelente';

    }


    if (nivel >= 70) {

      return 'Bueno';

    }


    if (nivel >= 40) {

      return 'Regular';

    }


    return 'Bajo';

  }

}


import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activos/activo_agro_model_v2.dart';
import '../models/activos/confianza_activo_model.dart';



class ActivoAgroServiceV2 {


  final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  final String coleccion =
      'activos_agro';





  // =====================================================
  // CREAR ACTIVO
  // =====================================================

  Future<String> crearActivo(
      ActivoAgroV2 activo,
      ) async {


    final existente = await _db
        .collection(coleccion)
        .where(
          'hashActivo',
          isEqualTo: activo.hashActivo,
        )
        .limit(1)
        .get();



    if(existente.docs.isNotEmpty){

      throw Exception(
        'Ya existe un activo similar registrado',
      );

    }



    final doc = _db
        .collection(coleccion)
        .doc(activo.activoId);



    await doc.set(
      activo.toMap(),
    );



    return doc.id;

  }





  // =====================================================
  // OBTENER ACTIVO POR ID
  // =====================================================

  Future<ActivoAgroV2?> obtenerActivoPorId(
      String id,
      ) async {


    final snapshot =
        await _db
            .collection(coleccion)
            .doc(id)
            .get();



    if(!snapshot.exists){

      return null;

    }



    return ActivoAgroV2.fromMap(
      snapshot.data()!,
      snapshot.id,
    );


  }





  // =====================================================
  // OBTENER TODOS LOS ACTIVOS
  // =====================================================

  Future<List<ActivoAgroV2>> obtenerActivos() async {


    final snapshot =
        await _db
            .collection(coleccion)
            .get();



    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();


  }





  // =====================================================
  // ACTIVOS PUBLICADOS PARA INVERSORES
  // =====================================================

  Future<List<ActivoAgroV2>> obtenerActivosPublicados() async {


    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'estadoPublicacion',
              isEqualTo: 'publicado',
            )
            .where(
              'visible',
              isEqualTo: true,
            )
            .get();



    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();


  }





  // =====================================================
  // ACTIVOS DEL PROPIETARIO
  // =====================================================

  Future<List<ActivoAgroV2>> buscarPorPropietario(
      String propietarioId,
      ) async {


    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'propietarioId',
              isEqualTo: propietarioId,
            )
            .get();



    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();


  }





  // =====================================================
  // ACTIVOS PUBLICADOS POR INTERMEDIARIO
  // =====================================================

  Future<List<ActivoAgroV2>> buscarPorPublicador(
      String publicadorId,
      ) async {


    final snapshot =
        await _db
            .collection(coleccion)
            .where(
              'publicadorId',
              isEqualTo: publicadorId,
            )
            .get();



    return snapshot.docs
        .map(

          (doc)=>

          ActivoAgroV2.fromMap(
            doc.data(),
            doc.id,
          ),

    )
        .toList();


  }





  // =====================================================
  // PUBLICAR ACTIVO
  // =====================================================

  Future<void> publicarActivo(
      String activoId,
      ) async {


    await _db
        .collection(coleccion)
        .doc(activoId)
        .update({

      'estadoPublicacion':
      'publicado',


      'visible':
      true,


      'ultimaActualizacion':
      Timestamp.now(),

    });


  }





  // =====================================================
  // PAUSAR ACTIVO
  // =====================================================

  Future<void> pausarActivo(
      String activoId,
      ) async {


    await _db
        .collection(coleccion)
        .doc(activoId)
        .update({

      'estadoPublicacion':
      'pausado',


      'visible':
      false,


      'ultimaActualizacion':
      Timestamp.now(),

    });


  }





  // =====================================================
  // ACTUALIZAR ACTIVO COMPLETO
  // =====================================================

  Future<void> actualizarActivo(
      ActivoAgroV2 activo,
      ) async {


    await _db
        .collection(coleccion)
        .doc(activo.activoId)
        .update(

      activo.toMap(),

    );


  }





  // =====================================================
  // ACTUALIZAR SISTEMA DE CONFIANZA
  // =====================================================

  Future<void> actualizarConfianza(
      String activoId,
      ConfianzaActivo confianza,
      ) async {


    await _db
        .collection(coleccion)
        .doc(activoId)
        .update({

      'confianza':
      confianza.toMap(),


      'ultimaActualizacion':
      Timestamp.now(),

    });


  }


}

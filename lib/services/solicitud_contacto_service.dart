import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/solicitud_contacto_model.dart';
import '../enums/solicitud_estado.dart';


class SolicitudContactoService {


  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  final String collection =
      'solicitudes_contacto';



/// 🤝 Crear solicitud de contacto
Future<void> crearSolicitud(
  SolicitudContacto solicitud,
) async {

  // Verificar si ya existe una solicitud
  // para este campo + interesado.
  final existente = await _firestore
      .collection(collection)
      .where(
        'campoId',
        isEqualTo: solicitud.campoId,
      )
      .where(
        'interesadoId',
        isEqualTo: solicitud.interesadoId,
      )
      .where(
        'propietarioId',
        isEqualTo: solicitud.propietarioId,
      )
      .limit(1)
      .get();

  if (existente.docs.isNotEmpty) {
    throw Exception(
      'Ya existe una solicitud para este activo',
    );
  }

  final doc = _firestore
      .collection(collection)
      .doc();

  final solicitudConId = SolicitudContacto(
    solicitudId: doc.id,
    campoId: solicitud.campoId,
    interesadoId: solicitud.interesadoId,
    propietarioId: solicitud.propietarioId,
    tipoInteres: solicitud.tipoInteres,
    estado: solicitud.estado,
    chatId: solicitud.chatId,
    fechaCreacion: solicitud.fechaCreacion,
  );

  


    await doc.set(
    solicitudConId.toMap(),
  );
}







  /// 📩 Solicitudes recibidas por propietario
  Stream<List<SolicitudContacto>>
      obtenerSolicitudesPropietario(
        String propietarioId,
      ) {


    return _firestore
    .collection(collection)
    .where(
  'propietarioId',
  isEqualTo: propietarioId,
)
.where(
  'estado',
  isEqualTo: 'pendiente',
)
    .snapshots()

        .map(

          (snapshot) =>

              snapshot.docs
                  .map(

                    (doc) =>

                        SolicitudContacto.fromMap(
                          doc.data(),
                          doc.id,
                        ),

                  )
                  .toList(),

        );


  }







  /// 👤 Solicitudes realizadas por interesado
  Stream<List<SolicitudContacto>>
      obtenerSolicitudesInteresado(
        String interesadoId,
      ) {


    return _firestore
        .collection(collection)

        .where(
          'interesadoId',
          isEqualTo: interesadoId,
        )

        .orderBy(
          'fechaCreacion',
          descending: true,
        )

        .snapshots()

        .map(

          (snapshot) =>

              snapshot.docs
                  .map(

                    (doc) =>

                        SolicitudContacto.fromMap(
                          doc.data(),
                          doc.id,
                        ),

                  )
                  .toList(),

        );


  }







  /// 🔄 Actualizar estado de solicitud
  Future<void> actualizarEstadoSolicitud(

      String solicitudId,

      SolicitudEstado nuevoEstado, {

      String? chatId,

  }) async {



    final Map<String,dynamic> datos = {


      'estado':
          nuevoEstado.name,


    };





    if(chatId != null){

      datos['chatId'] =
          chatId;

    }






    await _firestore

        .collection(collection)

        .doc(solicitudId)

        .update(datos);



  }




}